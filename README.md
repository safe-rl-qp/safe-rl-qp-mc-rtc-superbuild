# safe-rl-qp-mc-rtc-superbuild

Acc-CBF-QP was introduced in:

> **Safe Execution of RL Policies via Acceleration-based CBF-QP Constraint Enforcement for Real-World Robotic Deployments**
> Bastien Muraccioli, Alice Cariou, Pierre-Alexandre Leziart, Mathieu Celerier, Arnaud Demont, Gentiane Venture, Mehdi Benallegue
> IROS 2026 — [Paper](https://hal.science/hal-05362571) · [Project page](https://safe-rl-qp.github.io/)

Part of the Acc-CBF-QP ecosystem: [paper implementation](https://github.com/safe-rl-qp/mc-safe-rl-qp) · superbuild (this repo) · [controller template](https://github.com/bastien-muraccioli/new-rl-qp-controller) · [community controllers](https://github.com/safe-rl-qp/awesome-safe-rl-qp)

## Contents

- [Overview](#overview)
- [Installation](#installation)
  - [Fork the superbuild](#fork-the-superbuild)
  - [Installing the requirements (bootstrapping)](#installing-the-requirements-bootstrapping)
  - [Git setup](#git-setup)
  - [Build](#build)
  - [Config superbuild (adding robots and options)](#config-superbuild-adding-robots-and-options)
  - [Bashrc](#bashrc)
- [Running a controller](#running-a-controller)
- [Adding your own RL-QP controller](#adding-your-own-rl-qp-controller)
  - [Fork the template](#fork-the-template)
  - [Add your controller to the superbuild](#add-your-controller-to-the-superbuild)
- [mc_rtc robots](#mc_rtc-robots)
- [Contributing and issues](#contributing-and-issues)

## Overview

This project is based on [mc-rtc-superbuild](https://github.com/mc-rtc/mc-rtc-superbuild): it will clone, update, build, and install all of the dependencies needed to run Acc-CBF-QP.

At the end of the installation you'll be able to run an example controller for the Unitree H1 with a walking policy in Mujoco. We also give the details needed to create your own controller for your own robot and policy.

You can check the [mc-rtc-superbuild README](https://github.com/mc-rtc/mc-rtc-superbuild) for additional background, but you don't need to read it to run the controller example.

This project was tested on Ubuntu 24.04. We do not officially support other operating systems at the moment.

## Installation

### Fork the superbuild

We recommend having your own superbuild by forking this one — as you add your own controllers and extensions, it's much easier to manage with your own fork rather than working directly off of ours.

Create a workspace folder in your home directory and clone your fork into it:

```bash
mkdir ~/workspace
cd ~/workspace
git clone git@github.com:{GIT_USERNAME}/safe-rl-qp-mc-rtc-superbuild.git
```

### Installing the requirements (bootstrapping)

You can install the requirements by running our bootstrap script:

```bash
cd ~/workspace/
./safe-rl-qp-mc-rtc-superbuild/utils/bootstrap-linux.sh
```

### Git setup

Make sure you've configured `git` first:

```sh
git config --global user.name "Full Name"
git config --global user.email "your.email@provider.com"
```

### Build

Run the superbuild from the terminal, or use VS Code's "CMake Tools" extension to select your desired build preset.

By default, the presets will:
- clone all projects into `~/workspace/src`
- build all projects into `~/workspace/build/`
- install all projects into `~/workspace/install`

```bash
cd ~/workspace/safe-rl-qp-mc-rtc-superbuild
# Build all projects
cmake --preset relwithdebinfo
cmake --build --preset relwithdebinfo
```

### Config superbuild (adding robots and options)

To add robots or modify the superbuild options, after your first build you can run:

```bash
cd ~/workspace/build/superbuild
# Configure the superbuild
ccmake .
```

Inside the menu, use your keyboard's arrow keys to navigate and Enter to edit an entry. To run the controller example, you'll need to set the `WITH_H1` option to `ON`.

Once done, press `[c]` to Configure, and once configuration is finished, press `[g]` to Generate and update the superbuild. When that's done, press `[q]` to quit.

You can now rebuild the superbuild to install the H1 robot module:

```bash
cd ~/workspace/safe-rl-qp-mc-rtc-superbuild
# Build all projects
cmake --build --preset relwithdebinfo
```

### Bashrc

At the end of the build, the superbuild will ask you to add the following line to your `.bashrc`:

```bash
source /home/$USERNAME/workspace/install/setup_mc_rtc.sh
```

This file is generated after the first configuration of the superbuild (the step above).

You can also add the following aliases to your `.bashrc` to simplify using the framework:

```bash
# Run the superbuild
alias mc_build='cd ~/workspace/safe-rl-qp-mc-rtc-superbuild; cmake --build --preset relwithdebinfo'

# Config the superbuild
alias mc_superbuild_config="cd ~/workspace/build/superbuild; ccmake ."

# Automatically update the superbuild and all associated projects via git pull
alias mc_update='cd ~/workspace/build/superbuild; cmake --build . --config RelWithDebInfo --target update'

# Open the mc_rtc rviz interface
alias mc_rviz="ros2 launch mc_rtc_ticker display.launch"

# Configure mc_rtc: robot and controller selection (replace gnome-text-editor with your preferred text editor)
alias mc_config="gnome-text-editor ~/.config/mc_rtc/mc_rtc.yaml &"
```

When you're done editing your `.bashrc`, don't forget to source it or open a fresh terminal.

## Running a controller

Use your new `mc_config` alias to create the `mc_rtc.yaml` config file, which tells mc_rtc which controller to run with which robot:

```bash
mc_config
```

Then add the following:

```yaml
MainRobot: H1               # Robot Name
Enabled: RLController        # Controller Name
Timestep: 0.0025             # Controller timestep
LogPolicy: threaded
```

Save the file, then `cd` into the folder containing the policy to run — `mc_mujoco` needs to be run from there, not from an arbitrary directory — and start the controller in Mujoco:

```bash
cd ~/workspace/src/rl_controller/policy/
mc_mujoco --sync
```

In another terminal, you can run this to access the RViz interface (optional with Mujoco):

```bash
mc_rviz
```

Congrats — you should now see H1 walking! If you have a gamepad plugged into your PC (such as a DS4 controller), you can control the robot with the joystick.

## Adding your own RL-QP controller

### Fork the template

Fork [new-rl-qp-controller](https://github.com/bastien-muraccioli/new-rl-qp-controller) and follow its README. You can also check [awesome-safe-rl-qp](https://github.com/safe-rl-qp/awesome-safe-rl-qp) to see other controllers based on the template for more examples.

### Add your controller to the superbuild

In the superbuild's extension folder, add a CMake file to register your controller (the same approach works for adding mc_rtc plugins, interfaces, or any other mc_rtc project):

```bash
cd ~/workspace/safe-rl-qp-mc-rtc-superbuild/extensions
gnome-text-editor {controller name}.cmake
```

```cmake
AddProject({controller name}
  GITHUB {github username}/{controller name}
  GIT_TAG origin/{branch name}
  DEPENDS mc_rtc
)
```

The `GITHUB` command clones the repo over HTTPS; use `GITHUB_PRIVATE` instead if you want to clone over SSH. Check the [mc-rtc-superbuild README](https://github.com/mc-rtc/mc-rtc-superbuild) for more details.

Then rebuild the superbuild:

```bash
mc_build
```

And update your mc_rtc config file with your new controller:

```bash
mc_config
```

## mc_rtc robots

By default, mc_rtc is compatible with many robots, as you can see when configuring the superbuild via `mc_superbuild_config`. If you want to add a custom robot that isn't already in the list, follow this [tutorial](https://jrl.cnrs.fr/mc_rtc/tutorials/advanced/new-robot.html).

In short, each robot in mc_rtc has four modules:

- **Robot module** `mc_{robot name}` — e.g. [mc_h1](https://github.com/isri-aist/mc_h1). Contains the constraint definitions (joint limits, self-collision), joint order, and sensor declarations.
- **Robot URDF** `{robot name}_description` — e.g. [h1_description](https://github.com/isri-aist/h1_description). Installed in `src/catkin_data_ws`; contains the full robot description in the format used by ROS. This is what mc_rtc uses for QP constraints and the dynamic model, and what mc_rviz uses for display.
- **Robot Mujoco description** `{robot name}_mj_description` — e.g. [h1_mj_description](https://github.com/isri-aist/h1_mj_description). Used by Mujoco to display and simulate the robot's physics. Unless intentional, it's important to keep the same robot model in the URDF and the Mujoco XML description.
- **Robot driver interface** `mc_{robot driver name}` — e.g. [mc_unitree2](https://github.com/isri-aist/mc_unitree2). Installs the driver needed to run your mc_rtc controller on the real robot. The exact command differs per robot driver — for H1, running your controller on the real robot requires `MCControlUnitree`. Always check the README of the relevant driver repo, since most require additional information in your mc_rtc config file (`mc_config`), such as the robot's IP address.

The `WITH_H1` option in `mc_superbuild_config` adds all four modules at once — this isn't true for every robot. At minimum you'll need the robot module and the URDF; if the Mujoco description or robot driver are missing, check the [isri-aist](https://github.com/isri-aist) GitHub account and add the missing modules manually in the superbuild's extension folder.

## Contributing and issues

Since this repository is a fork of [mc-rtc-superbuild](https://github.com/mc-rtc/mc-rtc-superbuild), if you run into installation issues we recommend addressing them directly on the original repo. Likewise, since the superbuild is just a collection of CMake files, issues with a specific project are best reported directly on that project's repo.

The main useful way to contribute to this repo specifically is by improving this installation guide (this README) if you spot any issues.