/*
 * Copyright (C) 2014 Open Source Robotics Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
*/

#include <algorithm>
#include <functional>
#include <string>

#include <ignition/math/Pose3.hh>

#include "gazebo/common/Assert.hh"
#include "gazebo/physics/physics.hh"
#include "gazebo/sensors/SensorManager.hh"
#include "gazebo/transport/transport.hh"
#include "LiftDragPlugin2.hh"

using namespace gazebo;

GZ_REGISTER_MODEL_PLUGIN(LiftDragPlugin2)

/////////////////////////////////////////////////
LiftDragPlugin2::LiftDragPlugin2()
{
}

/////////////////////////////////////////////////
LiftDragPlugin2::~LiftDragPlugin2()
{
}

/////////////////////////////////////////////////
void LiftDragPlugin2::Load(physics::ModelPtr _model,
                     sdf::ElementPtr _sdf)
{
  GZ_ASSERT(_model, "LiftDragPlugin2 _model pointer is NULL");
  GZ_ASSERT(_sdf, "LiftDragPlugin2 _sdf pointer is NULL");
  this->model = _model;
  this->sdf = _sdf;

  this->world = this->model->GetWorld();
  GZ_ASSERT(this->world, "LiftDragPlugin2 world pointer is NULL");

  this->physics = this->world->Physics();
  GZ_ASSERT(this->physics, "LiftDragPlugin2 physics pointer is NULL");

  GZ_ASSERT(_sdf, "LiftDragPlugin2 _sdf pointer is NULL");

  if (_sdf->HasElement("radial_symmetry"))
    this->radialSymmetry = _sdf->Get<bool>("radial_symmetry");

  GZ_ASSERT(_sdf->HasElement("cL_a0"), "LiftDragPlugin2 must set cL_a0");
  this->cL_alpha0 = _sdf->Get<double>("cL_a0");

  GZ_ASSERT(_sdf->HasElement("cm_a0"), "LiftDragPlugin2 must set cm_a0");
  this->cL_alpha0 = _sdf->Get<double>("cm_a0");

  GZ_ASSERT(_sdf->HasElement("cLa"), "LiftDragPlugin2 must set cLa");
  this->cLa = _sdf->Get<double>("cLa");

  GZ_ASSERT(_sdf->HasElement("cD0"), "LiftDragPlugin2 must set cD0");
  this->cD0 = _sdf->Get<double>("cD0");

  GZ_ASSERT(_sdf->HasElement("cma"), "LiftDragPlugin2 must set cma");
  this->cma = _sdf->Get<double>("cma");

  GZ_ASSERT(_sdf->HasElement("alpha_stall"), "LiftDragPlugin2 must set alpha_stall");
  this->alphaStall = _sdf->Get<double>("alpha_stall");

  GZ_ASSERT(_sdf->HasElement("cLa_stall"), "LiftDragPlugin2 must set cLa_stall");
  this->cLaStall = _sdf->Get<double>("cla_stall");

  GZ_ASSERT(_sdf->HasElement("kcDcL"), "LiftDragPlugin2 must set kcDcL");
  this->kcDcL = _sdf->Get<double>("kcDcL");

  GZ_ASSERT(_sdf->HasElement("cma_stall"), "LiftDragPlugin2 must set cma_stall");
  this->cmaStall = _sdf->Get<double>("cma_stall");

  GZ_ASSERT(_sdf->HasElement("cp"), "LiftDragPlugin2 must set cp");
  this->cp = _sdf->Get<ignition::math::Vector3d>("cp");

  // blade forward (-drag) direction in link frame
  GZ_ASSERT(_sdf->HasElement("forward"), "LiftDragPlugin2 must set forward");
  this->forward = _sdf->Get<ignition::math::Vector3d>("forward");
  this->forward.Normalize();

  // blade upward (+lift) direction in link frame
  GZ_ASSERT(_sdf->HasElement("upward"), "LiftDragPlugin2 must set upward");
  this->upward = _sdf->Get<ignition::math::Vector3d>("upward");
  this->upward.Normalize();

  GZ_ASSERT(_sdf->HasElement("area"), "LiftDragPlugin2 must set area");
  this->area = _sdf->Get<double>("area");

  GZ_ASSERT(_sdf->HasElement("air_density"), "LiftDragPlugin2 must set air_density");
  this->rho = _sdf->Get<double>("air_density");

  GZ_ASSERT(_sdf->HasElement("link_name"), "LiftDragPlugin2 must set link_name");
  {
    sdf::ElementPtr elem = _sdf->GetElement("link_name");
    GZ_ASSERT(elem, "Element link_name doesn't exist!");
    std::string linkName = elem->Get<std::string>();
    this->link = this->model->GetLink(linkName);
    GZ_ASSERT(this->link, "Link was NULL");

    if (!this->link)
    {
      gzerr << "Link with name[" << linkName << "] not found. "
        << "The LiftDragPlugin2 will not generate forces\n";
    }
    else
    {
      this->updateConnection = event::Events::ConnectWorldUpdateBegin(
          std::bind(&LiftDragPlugin2::OnUpdate, this));
    }
  }

  if (_sdf->HasElement("control_joint_name"))
  {
    std::string controlJointName = _sdf->Get<std::string>("control_joint_name");
    this->controlJoint = this->model->GetJoint(controlJointName);
    if (!this->controlJoint)
    {
      gzerr << "Joint with name[" << controlJointName << "] does not exist.\n";
    }

    GZ_ASSERT(_sdf->HasElement("control_joint_rad_to_cL"),
        "LiftDragPlugin2 must set control_joint_rad_to_cL");
    this->controlJointRadToCL = _sdf->Get<double>("control_joint_rad_to_cL");

    GZ_ASSERT(_sdf->HasElement("control_joint_rad_to_cD"),
        "LiftDragPlugin2 must set control_joint_rad_to_cD");
    this->controlJointRadToCD = _sdf->Get<double>("control_joint_rad_to_cD");

    GZ_ASSERT(_sdf->HasElement("control_joint_rad_to_cm"),
        "LiftDragPlugin2 must set control_joint_rad_to_cm");
    this->controlJointRadToCm = _sdf->Get<double>("control_joint_rad_to_cm");
  }

  if (_sdf->HasElement("verbose"))
    this->verbose = _sdf->Get<bool>("verbose");
}

/////////////////////////////////////////////////
void LiftDragPlugin2::OnUpdate()
{
  using ignition::math::clamp;

  GZ_ASSERT(this->link, "Link was NULL");
  // get linear velocity at cp in inertial frame
  ignition::math::Vector3d vel = this->link->WorldLinearVel(this->cp);
  ignition::math::Vector3d velI = vel;
  velI.Normalize();

  if (vel.Length() <= 0.01)
    return;

  // pose of body
  ignition::math::Pose3d pose = this->link->WorldPose();

  // rotate forward and upward vectors into inertial frame
  ignition::math::Vector3d forwardI = pose.Rot().RotateVector(this->forward);

  ignition::math::Vector3d upwardI;
  if (this->radialSymmetry)
  {
    // use inflow velocity to determine upward direction
    // which is the component of inflow perpendicular to forward direction.
    ignition::math::Vector3d tmp = forwardI.Cross(velI);
    upwardI = forwardI.Cross(tmp).Normalize();
  }
  else
  {
    upwardI = pose.Rot().RotateVector(this->upward);
  }

  // spanI, along the span of the wing
  ignition::math::Vector3d spanI = forwardI.Cross(upwardI).Normalize();

  double v = vel.Length();
  double q = 0.5 * this->rho * v * v;

  // wing (body) frame velocities
  double U = velI.Dot(forwardI);
  double V = velI.Dot(spanI);
  double W = -velI.Dot(upwardI);

  double alpha = atan(W/U);
  double beta = asin(V/v);

  // get direction of lift
  ignition::math::Vector3d dragI = -velI.Normalize();
  ignition::math::Vector3d liftI = dragI.Cross(spanI).Normalize();

  // compute coefficients
  double cL0 = -this->cL_alpha0*this->cLa;
  double cm0 = -this->cm_alpha0*this->cma;
  double cL = cL0;
  double cm = cm0;
  if (fabs(alpha) < this->alphaStall) {
    cL += this->cLa*alpha;
    cm += this->cma*alpha;
  } else if (alpha < -this->alphaStall) {
    cL += -this->cLa*this->alphaStall + this->cLaStall*(alpha - this->alphaStall);
    cm += -this->cma*this->alphaStall + this->cmaStall*(alpha - this->alphaStall);
  } else if (alpha > this->alphaStall) {
    cL += this->cLa*this->alphaStall + this->cLaStall*(alpha - this->alphaStall);
    cm += this->cma*this->alphaStall + this->cmaStall*(alpha - this->alphaStall);
  }

  // compute cd
  double delta_cL = cL - cL0;
  double cD = this->cD0 + this->kcDcL*delta_cL*delta_cL;

  // modify cl per control joint value
  if (this->controlJoint)
  {
    double controlAngle = this->controlJoint->Position(0);
    cL += this->controlJointRadToCL * controlAngle;
    cD += this->controlJointRadToCD * controlAngle;
    cm += this->controlJointRadToCm * controlAngle;
  }

  // limit
  //cL = clamp(cL, 0.0, 2.0);
  //cD = clamp(cD, 0.0, 0.2);
  //cm = clamp(cm, 0.0, 0.0);

  // forces and moments at cp
  ignition::math::Vector3d drag = cD * q * this->area * dragI;
  ignition::math::Vector3d lift = cL * q * this->area * liftI;
  ignition::math::Vector3d moment = cm * q * this->area * spanI;
  ignition::math::Vector3d force = lift + drag;
  ignition::math::Vector3d torque = moment;

  if (this->verbose)
  {
    gzdbg << std::fixed << std::setprecision(3);
    gzdbg << "=============================\n";
    gzdbg << "sensor: [" << this->GetHandle() << "]\n";
    gzdbg << "Link: [" << this->link->GetName()
          << "] pose: [" << pose
          << "] dynamic pressure: [" << q << "]\n";
    gzdbg << "spd: [" << vel.Length()
          << "] vel: [" << vel << "]\n";
    gzdbg << "forward (inertial): " << forwardI << "\n";
    gzdbg << "upward (inertial): " << upwardI << "\n";
    gzdbg << "lift dir (inertial): " << liftI << "\n";
    gzdbg << "drag dir (inertial): " << dragI << "\n";
    gzdbg << "Span direction (normal to LD plane): " << spanI << "\n";
    gzdbg << "alpha: " << alpha << "\n";
    gzdbg << "beta: " << beta << "\n";
    gzdbg << "lift: " << lift << "\n";
    gzdbg << "drag: " << drag << "\n";
    gzdbg << "moment: " << moment << "\n";
    gzdbg << "q: " << q << "\n";
    gzdbg << "area: " << area << "\n";
    gzdbg << "cL: " << cL << "\n";
    gzdbg << "cD: " << cD << "\n";
    gzdbg << "cm: " << cm << "\n";
    gzdbg << "force: " << force << "\n";
    gzdbg << "torque: " << torque << "\n";
  }

  // Correct for nan or inf
  force.Correct();
  this->cp.Correct();
  torque.Correct();

  //gapply forces at cg (with torques for position shift)
  this->link->AddForceAtRelativePosition(force, this->cp);
  this->link->AddTorque(torque);
}

/* vim: set et fenc=utf-8 ff=unix sts=0 sw=2 ts=2 : */
