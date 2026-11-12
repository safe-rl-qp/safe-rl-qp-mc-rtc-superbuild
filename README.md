# safe-rl-qp-mc-rtc-superbuild

Acc-CBF-QP was introduced in:

> **Safe Execution of RL Policies via Acceleration-based CBF-QP Constraint Enforcement for Real-World Robotic Deployments**
> Bastien Muraccioli, Alice Cariou, Pierre-Alexandre Leziart, Mathieu Celerier, Arnaud Demont, Gentiane Venture, Mehdi Benallegue
> IROS 2026 — [Paper](https://hal.science/hal-05362571) · [Project page](https://safe-rl-qp.github.io/)

Part of the Acc-CBF-QP ecosystem: [paper implementation](https://github.com/safe-rl-qp/mc-safe-rl-qp) · superbuild (this repo) · [controller template](https://github.com/bastien-muraccioli/new-rl-qp-controller) · [community controllers](https://github.com/safe-rl-qp/awesome-safe-rl-qp)

[![CI](https://github.com/safe-rl-qp/safe-rl-qp-mc-rtc-superbuild/actions/workflows/install-test.yml/badge.svg)](https://github.com/safe-rl-qp/safe-rl-qp-mc-rtc-superbuild/actions/workflows/install-test.yml)
[![Ubuntu 24.04](https://img.shields.io/badge/Ubuntu-24.04-E95420)](https://github.com/safe-rl-qp/safe-rl-qp-mc-rtc-superbuild#installation)
[![Project Page](https://img.shields.io/badge/Project_Page-Visit-blue.svg)](https://safe-rl-qp.github.io/)
[![PDF](https://img.shields.io/badge/PDF-arXiv-b31b1b.svg)](https://arxiv.org/abs/2607.14488)
[![Award](https://img.shields.io/badge/IEEE%20IES-SYPA%20Award-gold)](https://2026.ieee-iros.org/attend/ies-sypa/)
[![Watch the video](https://img.shields.io/badge/YouTube-IROS%202026%20Introduction-red?logo=youtube&logoColor=white)](https://www.youtube.com/watch?v=MPlcEFUSASg)

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
- [Useful superbuild targets](#useful-superbuild-targets)
- [Using a devcontainer instead](#using-a-devcontainer-instead)
- [Contributing and issues](#contributing-and-issues)

## Overview

This project is based on [mc-rtc-superbuild](https://github.com/mc-rtc/mc-rtc-superbuild): it will clone, update, build, and install all of the dependencies needed to run Acc-CBF-QP.

On top of upstream, this fork adds the following extensions (in [extensions/](extensions/)), which are built by default:
- [mc_mujoco](https://github.com/bastien-muraccioli/mc_mujoco), together with a MuJoCo binary download
- [rl_controller](https://github.com/bastien-muraccioli/rl_controller), the example RL-QP controller
- [mc_joystick_plugin](https://github.com/bastien-muraccioli/mc_joystick_plugin)
- [mc_external_forces_observer](https://github.com/isri-aist/mc_external_forces_observer)

It also builds `mc_rtc`, `state-observation` and `mc_state_observation` from forks that carry changes needed by Acc-CBF-QP (see [mc_rtc.cmake](mc_rtc.cmake)), and extends the `WITH_H1` robot option (**ON by default** in this fork) with everything needed for the example.

At the end of the installation you'll be able to run an example controller for the Unitree H1 with a walking policy in Mujoco. We also give the details needed to create your own controller for your own robot and policy.

You can check the [mc-rtc-superbuild README](https://github.com/mc-rtc/mc-rtc-superbuild) for additional background (all the `AddProject`/`AptInstall`/... functions, the full option list, etc.), but you don't need to read it to run the controller example.

This project was tested on Ubuntu 24.04. We do not officially support other operating systems at the moment.

## Installation

### Fork the superbuild

We recommend having your own superbuild by forking this one — as you add your own controllers and extensions, it's much easier to manage with your own fork rather than working directly off of ours.

Clone your fork into your home directory:

```bash
cd ~
git clone git@github.com:{GIT_USERNAME}/safe-rl-qp-mc-rtc-superbuild.git
```

The build presets place everything else next to it, in `~/workspace` (see [Build](#build)).

### Installing the requirements (bootstrapping)

You can install the requirements by running our bootstrap script:

```bash
~/safe-rl-qp-mc-rtc-superbuild/utils/bootstrap-linux.sh
```

A note on Python virtual environments: make sure no venv is active when running the bootstrap script. It will then create one in `~/.mc-rtc-venv` (with `--system-site-packages`, which ROS needs), and that venv must be active whenever you use the superbuild.

### Git setup

Make sure you've configured `git` first:

```sh
git config --global user.name "Full Name"
git config --global user.email "your.email@provider.com"
```

### Build

Run the superbuild from the terminal, or use VS Code's "CMake Tools" extension to select your desired build preset.

By default, the presets will:
- clone all projects into `~/workspace/devel`
- build all projects into `~/workspace/build/projects`
- use `~/workspace/build/superbuild` as the superbuild's own build folder
- install all projects into `~/workspace/install`

The `WITH_H1` option is **ON by default**, so this single build already includes everything needed for the H1 example (robot module, URDF, MuJoCo description, and driver).

```bash
# Source the mc_rtc venv created by the bootstrap script
source ~/.mc-rtc-venv/bin/activate
cd ~/safe-rl-qp-mc-rtc-superbuild
# Build all projects
cmake --preset relwithdebinfo
cmake --build --preset relwithdebinfo
```

The following presets are available (use the same name for `--preset` and `--build --preset`):

| Preset | Description |
| :--- | :--- |
| `relwithdebinfo` | RelWithDebInfo, with ROS, Python bindings and tests (default) |
| `relwithdebinfo-noros` | RelWithDebInfo without ROS |
| `relwithdebinfo-nopython` | RelWithDebInfo without Python bindings |
| `relwithdebinfo-noros-nopython` | RelWithDebInfo without ROS nor Python bindings |
| `relwithdebinfo-notests` | RelWithDebInfo without tests |
| `release` | Release, with ROS, Python bindings and tests |
| `release-notests` | Release without tests (this is what our CI uses) |

If these defaults do not suit you (e.g. you want other folders), you can define your own presets inheriting from these in a `CMakeUserPresets.json` file, see the [mc-rtc-superbuild README](https://github.com/mc-rtc/mc-rtc-superbuild#build-with-cmake-presets-recommended).

### Config superbuild (adding robots and options)

To add robots or modify the superbuild options, after your first build you can run:

```bash
cd ~/workspace/build/superbuild
# Configure the superbuild
ccmake .
```

Inside the menu, use your keyboard's arrow keys to navigate and Enter to edit an entry (e.g. set `WITH_<robot>` to `ON` to add a robot). `WITH_H1` is already `ON` by default; keep it that way to run the controller example.

Once done, press `[c]` to Configure, and once configuration is finished, press `[g]` to Generate and update the superbuild. When that's done, press `[q]` to quit.

You can now rebuild the superbuild to install the newly enabled projects:

```bash
cd ~/safe-rl-qp-mc-rtc-superbuild
# Build all projects
cmake --build --preset relwithdebinfo
```

Alternatively, you can pass options directly on the command line, e.g. to add the G1 or to drop the H1 if you don't need it:

```bash
cd ~/safe-rl-qp-mc-rtc-superbuild
cmake --preset relwithdebinfo -DWITH_G1=ON -DWITH_H1=OFF
cmake --build --preset relwithdebinfo
```

### Bashrc

At the end of the build, the superbuild will ask you to add the following line to your `.bashrc`:

```bash
source ~/workspace/install/setup_mc_rtc.sh
```

This file is generated after the first configuration of the superbuild (the step above).

You can also add the following aliases to your `.bashrc` to simplify using the framework:

```bash
# Run the superbuild
alias mc_build='source ~/.mc-rtc-venv/bin/activate; cd ~/safe-rl-qp-mc-rtc-superbuild; cmake --build --preset relwithdebinfo'

# Config the superbuild
alias mc_superbuild_config="cd ~/workspace/build/superbuild; ccmake ."

# Automatically update the superbuild and all associated projects via git pull
alias mc_update='
modified_repos=""
for dir in ~/workspace/devel/*/; do
    if [ -d "$dir/.git" ] && ! git -C "$dir" diff HEAD --quiet; then
        modified_repos="$modified_repos$(basename "$dir")\n"
    fi
done

if [ -n "$modified_repos" ]; then
    echo "⚠️  The following repositories have local modifications and will be skipped by the update:"
    printf "$modified_repos"
    echo
fi

cd ~/workspace/build/superbuild &&
cmake --build . --config RelWithDebInfo --target update
'

# Open the mc_rtc rviz interface
alias mc_rviz="ros2 launch mc_rtc_ticker display.launch"

# Configure mc_rtc: robot and controller selection (replace gnome-text-editor with your preferred text editor)
alias mc_config="mkdir -p ~/.config/mc_rtc && gnome-text-editor ~/.config/mc_rtc/mc_rtc.yaml &"
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
cd ~/workspace/devel/rl_controller/policy/
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
cd ~/safe-rl-qp-mc-rtc-superbuild/extensions
gnome-text-editor {controller name}.cmake
```

```cmake
AddProject({controller name}
  GITHUB {github username}/{controller name}
  GIT_TAG origin/{branch name}
  DEPENDS mc_rtc
)
```

The `GITHUB` command clones the repo over HTTPS; use `GITHUB_PRIVATE` instead if you want to clone over SSH. `GIT_TAG` values starting with `origin/` are treated as branches, anything else as a tag. Check the [mc-rtc-superbuild README](https://github.com/mc-rtc/mc-rtc-superbuild#addproject) for more details.

Then rebuild the superbuild:

```bash
mc_build
```

And update your mc_rtc config file with your new controller:

```bash
mc_config
```

## mc_rtc robots

By default, mc_rtc is compatible with many robots, as you can see when configuring the superbuild via `mc_superbuild_config` (every `WITH_<robot>` option, defined in [robots/](robots/)). Some robots also have options for their control interface/driver, e.g. `WITH_MC_RTDE`/`WITH_RTDE_DRIVER` (Universal Robots), `WITH_KORTEX_DRIVER` (Kinova), `WITH_XARM_DRIVER` (xArm), `WITH_MC_FRANKA` (Panda), or `WITH_ROS2_CONTROL_DRIVER` (generic ros2_control). If you want to add a custom robot that isn't already in the list, follow this [tutorial](https://jrl.cnrs.fr/mc_rtc/tutorials/advanced/new-robot.html).

In short, each robot in mc_rtc has four modules:

- **Robot module** `mc_{robot name}` — e.g. [mc_h1](https://github.com/isri-aist/mc_h1). Contains the constraint definitions (joint limits, self-collision), joint order, and sensor declarations.
- **Robot URDF** `{robot name}_description` — e.g. [h1_description](https://github.com/isri-aist/h1_description). Installed in `~/workspace/devel/catkin_data_ws`; contains the full robot description in the format used by ROS. This is what mc_rtc uses for QP constraints and the dynamic model, and what mc_rviz uses for display.
- **Robot Mujoco description** `{robot name}_mj_description` — e.g. [h1_mj_description](https://github.com/isri-aist/h1_mj_description). Used by Mujoco to display and simulate the robot's physics. Unless intentional, it's important to keep the same robot model in the URDF and the Mujoco XML description.
- **Robot driver interface** `mc_{robot driver name}` — e.g. [mc_unitree2](https://github.com/isri-aist/mc_unitree2). Installs the driver needed to run your mc_rtc controller on the real robot. The exact command differs per robot driver — for H1, running your controller on the real robot requires `MCControlUnitree`. Always check the README of the relevant driver repo, since most require additional information in your mc_rtc config file (`mc_config`), such as the robot's IP address.

The `WITH_H1` option (ON by default) adds all four modules at once — this isn't true for every robot. At minimum you'll need the robot module and the URDF; if the Mujoco description or robot driver are missing, check the [isri-aist](https://github.com/isri-aist) GitHub account and add the missing modules manually in the superbuild's extension folder.

## Useful superbuild targets

Run these from `~/workspace/build/superbuild`:

```bash
# Clone everything without building
cmake --build . --config RelWithDebInfo --target clone
# Pull all projects (or a single one with update-<project>, e.g. update-mc_rtc)
cmake --build . --config RelWithDebInfo --target update
# Update the superbuild itself and the cloned extensions
cmake --build . --config RelWithDebInfo --target self-update
# Uninstall all projects (or a single one with uninstall-<project>)
cmake --build . --target uninstall
```

Avoid running `make -jN` in the superbuild folder: each project already builds in parallel, so building several projects at once is likely too much for your machine's RAM. Use the `BUILD_PARALLEL_JOBS` option instead if needed.

## Using a devcontainer instead

Instead of installing everything on your host, you can build the superbuild inside one of the provided devcontainers (Ubuntu jammy, noble, or resolute, in [.devcontainer/](.devcontainer/)). See [doc/devcontainer.md](doc/devcontainer.md). Note that these devcontainers use the upstream mc-rtc-superbuild images, so you still need to build this superbuild inside the container (see [Build](#build)), and that we only test the native Ubuntu 24.04 install described above.

## Contributing and issues

Since this repository is a fork of [mc-rtc-superbuild](https://github.com/mc-rtc/mc-rtc-superbuild), if you run into installation issues we recommend addressing them directly on the original repo. Likewise, since the superbuild is just a collection of CMake files, issues with a specific project are best reported directly on that project's repo.

The main useful way to contribute to this repo specifically is by improving this installation guide (this README) if you spot any issues.
