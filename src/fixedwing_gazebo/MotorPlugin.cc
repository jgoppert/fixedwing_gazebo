/*
 * Copyright (C) 2016 Open Source Robotics Foundation
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

#include <chrono>
#include <functional>
#include <thread>
#include <ignition/math/Vector3.hh>
#include <ignition/math/Pose3.hh>

#include "gazebo/common/Assert.hh"
#include "gazebo/common/PID.hh"
#include "gazebo/transport/transport.hh"
#include "fixedwing_gazebo/MotorPlugin.hh"

using namespace gazebo;

GZ_REGISTER_MODEL_PLUGIN(MotorPlugin)


  /// \brief Private data class
class gazebo::MotorPluginPrivate
{
  /// \brief Callback when a throttle message is received.
  /// \param[in] _msg Message containing the key press value.
  public: void OnThrottle(ConstAnyPtr &_msg);

  /// \brief Connection to World Update events.
  public: event::ConnectionPtr updateConnection;

  /// \brief Pointer to world.
  public: physics::WorldPtr world;

  /// \brief Pointer to physics engine.
  public: physics::PhysicsEnginePtr physics;

  /// \brief Pointer to model containing plugin.
  public: physics::ModelPtr model;

  /// \brief SDF for this plugin;
  public: sdf::ElementPtr sdf;

  /// \brief Pointer to the joint controlled
  public: physics::JointPtr joint;

  /// \brief Pointer to the propeller link
  public: physics::LinkPtr propeller;

  /// \brief Propeller diameter
  public: double diameter;

  /// \brief CT coefficients
  public: double ct_coeff[5];

  /// \brief CP coefficients
  public: double cp_coeff[5];

  /// \brief kV of motor
  public: double kV;

  /// \brief battery voltage (max voltage)
  public: double battV;

  /// \brief battery capacity (battery capacity mAh)
  public: double capacity;

  /// \brief max current
  public: double iMax;

  /// \brief zero torque current
  public: double i0;

  /// \brief motor resistance
  public: double r0;

  /// \brief motor efficiency
  public: double motor_eff;

  /// \brief motor angular vel [rad/sec]
  public: double omega{0};

  /// \brief axis of rotation, 0-x, 1-y, 2-z
  public: int axis_num;

  /// \brief throttle (0-1)
  public: double throttle{0};

  /// \brief Mutex to protect updates
  public: std::mutex mutex;

  /// \brief Pointer to a node for communication.
  public: transport::NodePtr gzNode;

  /// \brief State subscriber.
  public: transport::SubscriberPtr throttleSub;

  /// \brief last update time
  public: common::Time last_time;

  /// \brief verbose output
  public: bool verbose{false};

  /// \brief verbose output
  public: bool reverse{false};
};

/////////////////////////////////////////////////
MotorPlugin::MotorPlugin()
  : dataPtr(new MotorPluginPrivate)
{
}

/////////////////////////////////////////////////
MotorPlugin::~MotorPlugin()
{
}

/////////////////////////////////////////////////
void MotorPlugin::Load(physics::ModelPtr _model,
                     sdf::ElementPtr _sdf)
{
  GZ_ASSERT(_model, "MotorPlugin _model pointer is NULL");
  auto & data = this->dataPtr;
  data->model = _model;
  data->sdf = _sdf;

  data->world = data->model->GetWorld();
  GZ_ASSERT(data->world, "MotorPlugin world pointer is NULL");

  data->physics = data->world->Physics();
  GZ_ASSERT(data->physics, "MotorPlugin physics pointer is NULL");

  GZ_ASSERT(_sdf, "MotorPlugin _sdf pointer is NULL");

  //gzdbg << "Motor Plugin loading, model: " << data->model->GetName() << "\n";

  GZ_ASSERT(_sdf->HasElement("capacity"), "MotorPlugin must set capacity");
  GZ_ASSERT(_sdf->HasElement("kV"), "MotorPlugin must set kV");
  GZ_ASSERT(_sdf->HasElement("i0"), "MotorPlugin must set i0");
  GZ_ASSERT(_sdf->HasElement("r0"), "MotorPlugin must set r0");
  GZ_ASSERT(_sdf->HasElement("motor_eff"), "MotorPlugin must set motor_eff");
  GZ_ASSERT(_sdf->HasElement("battV"), "MotorPlugin must set battV");
  GZ_ASSERT(_sdf->HasElement("iMax"), "MotorPlugin must set iMax");
  GZ_ASSERT(_sdf->HasElement("axis_num"), "MotorPlugin must set axis_num");
  GZ_ASSERT(_sdf->HasElement("diameter"), "MotorPlugin must set diameter");
  GZ_ASSERT(_sdf->HasElement("gztopic"), "MotorPlugin must set gztopic");

  data->capacity = _sdf->Get<double>("capacity");
  data->kV = _sdf->Get<double>("kV");
  data->i0 = _sdf->Get<double>("i0");
  data->r0 = _sdf->Get<double>("r0");
  data->motor_eff = _sdf->Get<double>("motor_eff");
  data->battV = _sdf->Get<double>("battV");
  data->iMax = _sdf->Get<double>("iMax");
  data->axis_num = _sdf->Get<int>("axis_num");
  data->diameter = _sdf->Get<double>("diameter");
  std::string gztopic = _sdf->Get<std::string>("gztopic");
  if (_sdf->HasElement("verbose")) {
    data->verbose = _sdf->Get<bool>("verbose");
  }

  if (_sdf->HasElement("reverse")) {
    data->reverse = _sdf->Get<bool>("reverse");
  }

  std::string ct = _sdf->Get<std::string>("ct");
  {
    std::istringstream ss(ct);
    for (int i = 0; i < 5; i++) {
      double cti;
      ss >> cti;
      //gzdbg << cti << std::endl;
      data->ct_coeff[i] = cti;
    }
  }
  std::string cp = _sdf->Get<std::string>("cp");
  {
    std::istringstream ss(cp);
    for (int i = 0; i < 5; i++) {
      double cpi;
      ss >> cpi;
      //gzdbg << cpi << std::endl;
      data->cp_coeff[i] = cpi;
    }
  }

  //gzdbg << "loading joint" << std::endl;
  std::string jointName = _sdf->Get<std::string>("joint_name");
  physics::JointPtr joint = data->model->GetJoint(jointName);
  data->joint = joint;

  //gzdbg << "loading prop" << std::endl;
  std::string propName = _sdf->Get<std::string>("prop_name");
  data->propeller = data->model->GetLink(propName);

  //gzdbg << "initializing transport" << std::endl;
  data->gzNode = transport::NodePtr(new transport::Node());
  data->gzNode->Init();

  //gzdbg << "creating throttle sub" << std::endl;
  data->throttleSub = data->gzNode->Subscribe<msgs::Any>(
    "~/" + data->model->GetName() +
    gztopic, &MotorPluginPrivate::OnThrottle,
    data.get());

  #if GAZEBO_MAJOR_VERSION >= 9
  data->last_time = data->world->SimTime();
  #else
  data->last_time = data->world->GetSimTime();
  #endif

  //gzdbg << "Load done.\n";
}

/////////////////////////////////////////////////
void MotorPlugin::Init()
{
  auto & data = this->dataPtr;
  data->updateConnection = event::Events::ConnectWorldUpdateBegin(
          std::bind(&MotorPlugin::OnUpdate, this));
  //gzdbg << "Init done.\n";
}

/////////////////////////////////////////////////
void MotorPlugin::OnUpdate()
{
  auto & data = this->dataPtr;;
  std::lock_guard<std::mutex> lock(data->mutex);

#if GAZEBO_MAJOR_VERSION >= 9
  common::Time current_time  = data->world->SimTime();
#else
  common::Time current_time  = data->world->GetSimTime();
#endif
  double dt = (current_time - data->last_time).Double();
  data->last_time = current_time;
  double t = current_time.Double();

  using ignition::math::clamp;

  // if using approx method
  //double omega = data->omega;
  double dir = 1;
  if (data->reverse) {
    dir = -1;
  }
  //gzdbg << "reverse: " << data->reverse << std::endl;
  double omega = dir*data->joint->GetVelocity(0);
  omega = clamp(omega, 0.0, 10000.0);
  //gzdbg << "omega: " << omega << std::endl;

  const double rho = 1.225;
  auto vel_vect = data->propeller->RelativeLinearVel();
  double vel = vel_vect[data->axis_num];
  double n = omega/(2*M_PI);
  double kV = data->kV*(M_PI/30); // kV in SI units of (rad/sec)/V
  double J = 0;
  double aero_torque = 0;
  double power = 0;
  double thrust = 0;
  double CT = 0;
  double CP = 0;
  double eta = 0;
  const double in2m = 0.0254;
  double V = clamp(data->throttle, 0.0, 1.0) * data->battV;

  if (n > 0.1) {
    // see https://m-selig.ae.illinois.edu/props/propDB.html
    double D = data->diameter*in2m;
    J = clamp(vel/(n*D), 0.0, 1.0);
    CT = clamp(data->ct_coeff[0] + data->ct_coeff[1]*J + data->ct_coeff[2]*pow(J, 2)
      + data->ct_coeff[3]*pow(J, 3) + data->ct_coeff[4]*pow(J, 4), 0.0, 1.0);
    thrust = CT*rho*pow(n, 2)*pow(D, 4); // Newton
    CP = clamp(data->cp_coeff[0] + data->cp_coeff[1]*J + data->cp_coeff[2]*pow(J, 2)
      + data->cp_coeff[3]*pow(J, 3) + data->cp_coeff[4]*pow(J, 4), 0.0, 1.0);
    if (CP > 0) {
      eta = CT*J/CP;
    } else {
      eta = 1;
    }
    aero_torque = clamp((CP/(2*M_PI))*rho*pow(n, 2)*pow(D, 5), -100.0, 100.0);
    thrust = clamp(thrust, 0.0, 100.0);
  }

  // see http://web.mit.edu/drela/Public/web/qprop/motor1_theory.pdf
  double i = clamp((V - omega/kV)/data->r0 + data->i0, 0.0, data->iMax);
  double torque = data->motor_eff*(i - data->i0)/kV;
  double rate = i*1.0e3/3600; // mAh/sec
  data->capacity -= rate*dt;
  double endurance_min = 0;
  if (data->capacity > 0) {
    endurance_min = data->capacity/rate/60.0;
  } else {
    data->capacity = 0;
    thrust = 0;
    torque = 0;
  }

  if (data->verbose) {
    gzdbg << std::fixed << std::setprecision(3)
     << "J:" <<  std::setw(5) << J
     << " eff.:" << std::setw(5) << eta*data->motor_eff
     << " CP:" << std::setw(5) << CP
     << " CT:" << std::setw(5) << CT
     << " Thrust:" << std::setw(5) << thrust
     //<< " Q Mtr:" << std::setw(5) << torque
     //<< " Q Aero:" << std::setw(5) << aero_torque
     << " Volts:" << std::setw(5) << V
     << " cap (mAh):" << std::setw(5) << data->capacity
     << " end (min):" << std::setw(5) << endurance_min
     << " Amps:" << std::setw(5) << i
     << " RPM:" << std::setw(5) << std::setprecision(0) << n*60
     << std::endl;
  }
  GZ_ASSERT(isfinite(thrust), "non finite force");
  GZ_ASSERT(isfinite(torque), "non finite torque");
  GZ_ASSERT(isfinite(aero_torque), "non finite aero torque");
  if (data->axis_num==0) {
    data->propeller->AddRelativeForce(ignition::math::Vector3d(thrust, 0, 0));
    data->propeller->AddRelativeTorque(ignition::math::Vector3d(-dir*aero_torque, 0, 0));
  } else if (data->axis_num==1) {
    data->propeller->AddRelativeForce(ignition::math::Vector3d(0, thrust, 0));
    data->propeller->AddRelativeTorque(ignition::math::Vector3d(0, -dir*aero_torque, 0));
  } else if (data->axis_num==2) {
    data->propeller->AddRelativeForce(ignition::math::Vector3d(0, 0, thrust));
    data->propeller->AddRelativeTorque(ignition::math::Vector3d(0, 0, -dir*aero_torque));
  }

  // approximate approach
  //double tau = 0.1;
  //double alpha = exp(dt*(-1/tau));
  //data->omega = alpha*data->omega + (1 - alpha)*(0.8*kV*V);
  //data->joint->SetVelocity(0, data->omega*0.01);
  
  data->joint->SetForce(0, dir*torque);
}

/////////////////////////////////////////////////
void MotorPluginPrivate::OnThrottle(ConstAnyPtr &_msg)
{
  std::lock_guard<std::mutex> lock(this->mutex);
  double throttle =_msg->double_value();
  //gzdbg << "throttle: " << std::setprecision(5) << throttle << std::endl;
  this->throttle = throttle;
}

/* vim: set et fenc=utf-8 ff=unix sts=0 sw=2 ts=2 : */
