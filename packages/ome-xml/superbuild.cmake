# ome-xml superbuild

# Options to build from git (defaults to source zip if unset)
set(ome-xml-head ${head} CACHE BOOL "Force building from current git develop branch")
set(ome-xml-dir "" CACHE PATH "Local directory containing the OME-XML [Bio-Formats] source code")
set(ome-xml-git-url "" CACHE STRING "URL of OME-XML [Bio-Formats] git repository")
set(ome-xml-git-branch "" CACHE STRING "URL of OME-XML [Bio-Formats] git repository")

# Current stable release.
set(RELEASE_URL "https://downloads.openmicroscopy.org/bio-formats/5.2.0-m2.5/artifacts/bioformats-dfsg-5.2.0-m2.5.tar.xz")
set(RELEASE_HASH "SHA512=a9e6c21c37a9d141a94b5da64305e08c5da9b563d82f2efbdfd40a1bd68fa86c0aeaf6a74a28d04b1826c65c351f0a83bc780ebe26c11acc47f889a6e14c9023")

# Current development branch (defaults for ome-xml-head option).
set(GIT_URL "https://github.com/openmicroscopy/bioformats.git")
set(GIT_BRANCH "develop")

if(NOT ome-xml-head)
  if(ome-xml-git-url)
    set(GIT_URL ${ome-xml-git-url})
  endif()
  if(ome-xml-git-branch)
    set(GIT_BRANCH ${ome-xml-git-branch})
  endif()
endif()

if(ome-xml-dir)
  set(EP_SOURCE_DOWNLOAD
    DOWNLOAD_COMMAND "")
  set(EP_SOURCE_DIR "${ome-xml-dir}")
  set(BOOST_VERSION 1.60)
  message(STATUS "Building OME XML C++ from local directory (${ome-xml-dir})")
elseif(ome-xml-head OR ome-xml-git-url OR ome-xml-git-branch)
  set(EP_SOURCE_DOWNLOAD
    GIT_REPOSITORY "${GIT_URL}"
    GIT_TAG "${GIT_BRANCH}"
    UPDATE_DISCONNECTED 1)
  set(BOOST_VERSION 1.60)
  message(STATUS "Building OME XML C++ from git (URL ${GIT_URL}, branch/tag ${GIT_BRANCH})")
else()
  set(EP_SOURCE_DOWNLOAD
    URL "${RELEASE_URL}"
    URL_HASH "${RELEASE_HASH}")
  set(BOOST_VERSION 1.60)
  message(STATUS "Building OME XML C++ from source release (${RELEASE_URL})")
endif()

# Set dependency list
ome_add_dependencies(ome-xml
                     DEPENDENCIES ome-common
                     THIRD_PARTY_DEPENDENCIES boost-${BOOST_VERSION} png tiff xerces
                                              xalan py-genshi py-sphinx gtest)

unset(CONFIGURE_OPTIONS)
list(APPEND CONFIGURE_OPTIONS
     "-DBOOST_ROOT=${OME_EP_INSTALL_DIR}"
     -DBoost_NO_BOOST_CMAKE:BOOL=true
     "-DBoost_ADDITIONAL_VERSIONS=${BOOST_VERSION}"
     ${SUPERBUILD_OPTIONS})
if(TARGET gtest)
  list(APPEND CONFIGURE_OPTIONS "-DGTEST_SOURCE=${CMAKE_BINARY_DIR}/gtest-source")
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
