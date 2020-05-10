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
#ifndef GAZEBO_PLUGINS_LIFTDRAGPLUGIN_HH_
#define GAZEBO_PLUGINS_LIFTDRAGPLUGIN_HH_

#include <string>
#include <vector>

#include <ignition/math/Vector3.hh>

#include "gazebo/common/Plugin.hh"
#include "gazebo/physics/physics.hh"
#include "gazebo/transport/TransportTypes.hh"

namespace gazebo
{
  /// \brief A plugin that simulates lift and drag.
  class GZ_PLUGIN_VISIBLE LiftDragPlugin2 : public ModelPlugin
  {
    /// \brief Constructor.
    public: LiftDragPlugin2();

    /// \brief Destructor.
    public: ~LiftDragPlugin2();

    // Documentation Inherited.
    public: virtual void Load(physics::ModelPtr _model, sdf::ElementPtr _sdf);

    /// \brief Callback for World Update events.
    protected: virtual void OnUpdate();

    /// \brief Connection to World Update events.
    protected: event::ConnectionPtr updateConnection;

    /// \brief Pointer to world.
    protected: physics::WorldPtr world{};

    /// \brief Pointer to physics engine.
    protected: physics::PhysicsEnginePtr physics{};

    /// \brief Pointer to model containing plugin.
    protected: physics::ModelPtr model{};

    /// \brief Coefficient of Lift / alpha slope.
    protected: double cLa{0};

    /// \brief Cd0 for drag polar
    protected: double cD0{0};

    /// \brief Coefficient of Moment / alpha slope.
    protected: double cma{0};

    /// \brief angle of attach when airfoil stalls
    protected: double alphaStall{0};

    /// \brief CL-alpha rate after stall
    protected: double cLaStall{0};

    /// \brief CD-alpha rate after stall
    /// \brief CD = CD0 + kcDcL*(cL - cL0)
    protected: double kcDcL{0};

    /// \brief Cm-alpha rate after stall
    protected: double cmaStall{0};

    /// \brief air density
    /// at 25 deg C it's about 1.1839 kg/m^3
    /// At 20 °C and 101.325 kPa, dry air has a density of 1.2041 kg/m3.
    protected: double rho{1.225};

    /// \brief effective planform surface area
    protected: double area{0};

    /// \brief lift coefficient at zero angle of attack
    protected: double cL0{0};

    /// \brief moment coefficient at zero angle of attack
    protected: double cm0{0};

    /// \brief Pose of airfoil, x along chord line, z perp to chord line in upward direction for airfoil
    public: ignition::math::Pose3d pose;

    /// \brief Pointer to link currently targeted by mud joint.
    protected: physics::LinkPtr link{};

    /// \brief Pointer to a joint that actuates a control surface for
    /// this lifting body
    protected: physics::JointPtr controlJoint{};

    /// \brief how much to change CL per radian of control surface joint
    /// value.
    protected: double controlJointRadToCL{0};

    /// \brief how much to change Cm per radian of control surface joint
    /// value.
    protected: double controlJointRadToCm{0};

    /// \brief SDF for this plugin;
    protected: sdf::ElementPtr sdf{};

    /// \brief verbose
    protected: bool verbose{false};
  };
}
#endif
