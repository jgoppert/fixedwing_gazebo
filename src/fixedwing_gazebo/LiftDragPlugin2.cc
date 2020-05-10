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

  GZ_ASSERT(_sdf->HasElement("cL0"), "LiftDragPlugin2 must set cL0");
  this->cL0 = _sdf->Get<double>("cL0");

  GZ_ASSERT(_sdf->HasElement("cm0"), "LiftDragPlugin2 must set cm0");
  this->cm0 = _sdf->Get<double>("cm0");

  GZ_ASSERT(_sdf->HasElement("cLa"), "LiftDragPlugin2 must set cLa");
  this->cLa = _sdf->Get<double>("cLa");

  GZ_ASSERT(_sdf->HasElement("cD0"), "LiftDragPlugin2 must set cD0");
  this->cD0 = _sdf->Get<double>("cD0");

  GZ_ASSERT(_sdf->HasElement("cma"), "LiftDragPlugin2 must set cma");
  this->cma = _sdf->Get<double>("cma");

  GZ_ASSERT(_sdf->HasElement("alpha_stall"), "LiftDragPlugin2 must set alpha_stall");
  this->alphaStall = _sdf->Get<double>("alpha_stall");

  GZ_ASSERT(_sdf->HasElement("cLa_stall"), "LiftDragPlugin2 must set cLa_stall");
  this->cLaStall = _sdf->Get<double>("cLa_stall");

  GZ_ASSERT(_sdf->HasElement("kcDcL"), "LiftDragPlugin2 must set kcDcL");
  this->kcDcL = _sdf->Get<double>("kcDcL");

  GZ_ASSERT(_sdf->HasElement("cma_stall"), "LiftDragPlugin2 must set cma_stall");
  this->cmaStall = _sdf->Get<double>("cma_stall");

  GZ_ASSERT(_sdf->HasElement("pose"), "LiftDragPlugin2 must set pose");
  this->pose = _sdf->Get<ignition::math::Pose3d>("pose");

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
  using ignition::math::Vector3d;
  using ignition::math::Pose3d;

  GZ_ASSERT(this->link, "Link was NULL");
  // get linear velocity at cp in inertial frame
  Vector3d vel = this->link->WorldLinearVel(this->pose.Pos());

  if (vel.Length() <= 0.01)
    return;

  Vector3d velI = vel;
  velI.Normalize();

  //Pose3d world_from_airfoil = this->pose + this->link->WorldPose();
  Pose3d world_from_airfoil = this->pose*this->link->WorldPose();
  Pose3d airfoil_from_world = world_from_airfoil.Inverse();

  double v = vel.Length();
  double q = 0.5 * this->rho * v * v;
  // velocity in airfoil frame
  Vector3d velA = airfoil_from_world.Rot().RotateVector(vel);
  double alpha = atan(-velA.Z()/velA.X());
  double beta = asin(velA.Y()/v);

  // get control surface deflection
  double controlAngle = 0;
  if (this->controlJoint)
  {
    controlAngle = this->controlJoint->Position(0);
  }

  // compute coefficients
  double cL = this->cL0 + this->controlJointRadToCL*controlAngle;
  double cm = this->cm0 + this->controlJointRadToCm*controlAngle;
  bool stall = false;
  if (fabs(alpha) < this->alphaStall) {
    cL += this->cLa*alpha;
    cm += this->cma*alpha;
  } else if (alpha < -this->alphaStall) {
    stall = true;
    cL += -this->cLa*this->alphaStall + this->cLaStall*(alpha + this->alphaStall);
    cm += -this->cma*this->alphaStall + this->cmaStall*(alpha + this->alphaStall);
    if (this->verbose) {
      gzdbg << "\nnegative stall" << std::setprecision(3) << std::fixed
         << "\tstart cL: " << this->cLa*this->alphaStall
         << "\tdelta cL: " << this->cLaStall*(alpha + this->alphaStall) << "\n";
    }
  } else if (alpha >= this->alphaStall) {
    stall = true;
    cL += this->cLa*this->alphaStall + this->cLaStall*(alpha - this->alphaStall);
    cm += this->cma*this->alphaStall + this->cmaStall*(alpha - this->alphaStall);
    if (this->verbose) {
      gzdbg << "\npositive stall" << std::setprecision(3) << std::fixed
         << "\tstart cL: " << this->cLa*this->alphaStall
         << "\tdelta cL: " << this->cLaStall*(alpha - this->alphaStall) << "\n";
    }
  }
  cL = clamp(cL, -2.0, 2.0);
  cm = clamp(cm, -1.0, 1.0);

  // compute cd
  double delta_cL = cL - cL0;
  double cD = this->cD0 + this->kcDcL*delta_cL*delta_cL;

  // forces and moments at cp
  Vector3d spanI = world_from_airfoil.Rot().RotateVector(Vector3d(0, 1, 0));
  Vector3d liftI = velI.Cross(spanI).Normalize();
  Vector3d momentI = velI.Cross(liftI).Normalize();
  double drag = cD * q * this->area;
  double lift = cL * q * this->area;
  double moment = cm * q * this->area;

  Vector3d force = -drag * velI  + lift * liftI;
  Vector3d torque = moment * momentI;

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
    gzdbg << "forwardI: " << world_from_airfoil.Rot().RotateVector(Vector3d(1, 0, 0)) << "\n";
    gzdbg << "spanI: " << world_from_airfoil.Rot().RotateVector(Vector3d(0, 1, 0)) << "\n";
    gzdbg << "upwardI: " << world_from_airfoil.Rot().RotateVector(Vector3d(0, 0, 1)) << "\n";
    gzdbg << "control: " << controlAngle << "\n";
    gzdbg << "control->CL: " << this->controlJointRadToCL << "\n";
    gzdbg << "control->Cm: " << this->controlJointRadToCm << "\n";
    gzdbg << "velocity in airfoil frame (U, -V, -W): " << velA << "\n";
    gzdbg << "stall: " << stall << ", alpha: " << alpha << ", beta: " << beta << "\n";
    gzdbg << "lift: " << lift << ", drag: " << drag << "\n";
    gzdbg << "moment: " << moment << "\n";
    gzdbg << "q: " << q << ", area: " << area << "\n";
    gzdbg << "cL0: " << cL0 << ", cL: " << cL << ", cD: " << cD << "\n";
    gzdbg << "cm0: " << cm0 << ", cm: " << cm << "\n";
  }

  // Correct for nan or inf
  this->pose.Correct();
  force.Correct();
  torque.Correct();

  //gapply forces at cg (with torques for position shift)
  this->link->AddForceAtRelativePosition(force, this->pose.Pos());
  this->link->AddTorque(torque);
}

/* vim: set et fenc=utf-8 ff=unix sts=0 sw=2 ts=2 : */
