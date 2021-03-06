# ome-common superbuild

# Options to build from git (defaults to source zip if unset)
set(ome-common-head ${head} CACHE BOOL "Force building from current git develop branch")
set(ome-common-dir "" CACHE PATH "Local directory containing the OME Common C++ source code")
set(ome-common-git-url "" CACHE STRING "URL of OME Common C++ git repository")
set(ome-common-git-branch "" CACHE STRING "URL of OME Common C++ git repository")

# Current stable release.
set(RELEASE_URL "https://downloads.openmicroscopy.org/ome-common-cpp/5.2.0-m2/source/ome-common-cpp-5.2.0-m2.tar.xz")
set(RELEASE_HASH "SHA512=e3ca0f27e91a2fa301a453f256086d18f5979389acb165cf518abafad5eaa5562fada9da1e516426ac071461809ceca1f521e45390d3cbe94ab44c73c7e7ddc6")

# Current development branch (defaults for ome-common-head option).
set(GIT_URL "https://github.com/ome/ome-common-cpp.git")
set(GIT_BRANCH "develop")

if(NOT ome-common-head)
  if(ome-common-git-url)
    set(GIT_URL ${ome-common-git-url})
  endif()
  if(ome-common-git-branch)
    set(GIT_BRANCH ${ome-common-git-branch})
  endif()
endif()

if(ome-common-dir)
  set(EP_SOURCE_DOWNLOAD
    DOWNLOAD_COMMAND "")
  set(EP_SOURCE_DIR "${ome-common-dir}")
  set(BOOST_VERSION 1.60)
  message(STATUS "Building OME Common C++ from local directory (${ome-common-dir})")
elseif(ome-common-head OR ome-common-git-url OR ome-common-git-branch)
  set(EP_SOURCE_DOWNLOAD
    GIT_REPOSITORY "${GIT_URL}"
    GIT_TAG "${GIT_BRANCH}"
    UPDATE_DISCONNECTED 1)
  set(BOOST_VERSION 1.60)
  message(STATUS "Building OME Common C++ from git (URL ${GIT_URL}, branch/tag ${GIT_BRANCH})")
else()
  set(EP_SOURCE_DOWNLOAD
    URL "${RELEASE_URL}"
    URL_HASH "${RELEASE_HASH}")
  set(BOOST_VERSION 1.60)
  message(STATUS "Building OME Common C++ from source release (${RELEASE_URL})")
endif()

# Set dependency list
ome_add_dependencies(ome-common THIRD_PARTY_DEPENDENCIES boost-${BOOST_VERSION} gtest xerces xalan)

unset(CONFIGURE_OPTIONS)
list(APPEND CONFIGURE_OPTIONS
     "-DBOOST_ROOT=${OME_EP_INSTALL_DIR}"
     -DBoost_NO_BOOST_CMAKE:BOOL=true
     "-DBoost_ADDITIONAL_VERSIONS=${BOOST_VERSION}"
     ${SUPERBUILD_OPTIONS})
if(TARGET gtest)
  list(APPEND CONFIGURE_OPTIONS "-DGTEST_SOURCE=${CMAKE_BINARY_DIR}/gtest-source")
endif()
if(SOURCE_ARCHIVE_DIR)
  list(APPEND CONFIGURE_OPTIONS "-DSOURCE_ARCHIVE_DIR=${SOURCE_ARCHIVE_DIR}")
endif()
string(REPLACE ";" "^^" CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS}")

ExternalProject_Add(${EP_PROJECT}
  ${OME_EP_COMMON_ARGS}
  ${EP_SOURCE_DOWNLOAD}
  SOURCE_DIR ${EP_SOURCE_DIR}
  BINARY_DIR ${EP_BINARY_DIR}
  INSTALL_DIR ""
  CONFIGURE_COMMAND ${CMAKE_COMMAND}
    "-DSOURCE_DIR:PATH=${EP_SOURCE_DIR}"
    "-DBUILD_DIR:PATH=${EP_BINARY_DIR}"
    "-DCONFIGURE_OPTIONS=${CONFIGURE_OPTIONS}"
    "-DCONFIG:INTERNAL=$<CONFIG>"
    "-DEP_SCRIPT_CONFIG:FILEPATH=${EP_SCRIPT_CONFIG}"
    -P "${GENERIC_CMAKE_CONFIGURE}"
  BUILD_COMMAND ${CMAKE_COMMAND}
    "-DSOURCE_DIR:PATH=${EP_SOURCE_DIR}"
    "-DBUILD_DIR:PATH=${EP_BINARY_DIR}"
    "-DCONFIG:INTERNAL=$<CONFIG>"
    "-DEP_SCRIPT_CONFIG:FILEPATH=${EP_SCRIPT_CONFIG}"
    -P "${GENERIC_CMAKE_BUILD}"
  INSTALL_COMMAND ${CMAKE_COMMAND}
    "-DSOURCE_DIR:PATH=${EP_SOURCE_DIR}"
    "-DBUILD_DIR:PATH=${EP_BINARY_DIR}"
    "-DCONFIG:INTERNAL=$<CONFIG>"
    "-DEP_SCRIPT_CONFIG:FILEPATH=${EP_SCRIPT_CONFIG}"
    -P "${GENERIC_CMAKE_INSTALL}"
  TEST_COMMAND ${CMAKE_COMMAND}
    "-DSOURCE_DIR:PATH=${EP_SOURCE_DIR}"
    "-DBUILD_DIR:PATH=${EP_BINARY_DIR}"
    "-DCONFIG:INTERNAL=$<CONFIG>"
    "-DEP_SCRIPT_CONFIG:FILEPATH=${EP_SCRIPT_CONFIG}"
    -P "${GENERIC_CMAKE_TEST}"
  DEPENDS
    ${EP_PROJECT}-prerequisites
)
