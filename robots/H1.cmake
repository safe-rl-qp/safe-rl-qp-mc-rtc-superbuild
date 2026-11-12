option(WITH_H1 "Build with Unitree's H1 robot support" ON)

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

# h1_mj_description is declared in extensions/mc_mujoco.cmake, after mc_mujoco

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
