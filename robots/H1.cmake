option(WITH_H1 "Build with Unitree's H1 robot support" OFF)

if(NOT WITH_H1)
  return()
endif()

AptInstall(libfmt-dev)

AddCatkinProject(
  h1_description
  GITHUB bastien-muraccioli/h1_description
  GIT_TAG origin/main
  WORKSPACE data_ws
)

find_package(mc_mujoco QUIET)

if(mc_mujoco_FOUND)
  AddProject(
    h1_mj_description
    GITHUB bastien-muraccioli/h1_mj_description
    GIT_TAG origin/master
    DEPENDS mc_rtc
  )
endif()

AddProject(
  mc_h1
  GITHUB bastien-muraccioli/mc_h1
  GIT_TAG origin/main
  DEPENDS mc_rtc
)

AddProject(
  unitree_sdk2
  GITHUB bastien-muraccioli/unitree_sdk2
  GIT_TAG origin/main
)

ExternalProject_Get_Property(unitree_sdk2 SOURCE_DIR)

AddProject(
  mc_unitree2
  GITHUB bastien-muraccioli/mc_unitree2
  GIT_TAG origin/master
  CMAKE_ARGS -DGENERATE_H1_CONTROLLER=ON -DUNITREE_SDK2_SRC_DIR=${SOURCE_DIR}
                                         -DCMAKE_POLICY_VERSION_MINIMUM=3.5
  DEPENDS mc_rtc unitree_sdk2
)
