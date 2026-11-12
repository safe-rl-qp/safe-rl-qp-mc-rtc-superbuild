set(MUJOCO_VERSION 3.5.0)

if(UNIX AND NOT APPLE AND NOT EMSCRIPTEN)
  set(MUJOCO_URL "https://github.com/deepmind/mujoco/releases/download/${MUJOCO_VERSION}/mujoco-${MUJOCO_VERSION}-linux")
  if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm")
    set(MUJOCO_URL "${MUJOCO_URL}-aarch64.tar.gz")
  else()
    set(MUJOCO_URL "${MUJOCO_URL}-x86_64.tar.gz")
  endif()
  DownloadFile("${MUJOCO_URL}" "${CMAKE_CURRENT_BINARY_DIR}/mujoco/mujoco.tar.gz" "")
  file(ARCHIVE_EXTRACT
        INPUT "${CMAKE_CURRENT_BINARY_DIR}/mujoco/mujoco.tar.gz"
        DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/mujoco"
  )
  set(MUJOCO_ROOT_DIR "${CMAKE_CURRENT_BINARY_DIR}/mujoco/mujoco-${MUJOCO_VERSION}")
else()
  if(NOT DEFINED MUJOCO_ROOT_DIR)
    message(FATAL_ERROR "MuJoCo must be installed manually on your platform, you must then defined MUJOCO_ROOT_DIR")
  endif()
endif()

AptInstall(libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev libglew-dev)

AddProject(mc_mujoco
  GITHUB bastien-muraccioli/mc_mujoco
  GIT_TAG origin/main
  CMAKE_ARGS -DMUJOCO_ROOT_DIR=${MUJOCO_ROOT_DIR}
  DEPENDS mc_rtc
)

if(WITH_H1)
  AddProject(
    h1_mj_description
    GITHUB bastien-muraccioli/h1_mj_description
    GIT_TAG origin/master
    DEPENDS mc_rtc mc_mujoco
  )
endif()
