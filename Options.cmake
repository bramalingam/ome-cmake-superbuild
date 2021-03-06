## #%L
# OME C++ libraries (cmake super-build infrastructure)
# %%
# Copyright © 2006 - 2014 Open Microscopy Environment:
#   - Massachusetts Institute of Technology
#   - National Institutes of Health
#   - University of Dundee
#   - Board of Regents of the University of Wisconsin-Madison
#   - Glencoe Software, Inc.
# %%
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are
# those of the authors and should not be interpreted as representing official
# policies, either expressed or implied, of any organization.
# #L%

# These are annoyingly verbose, produce false positives or don't work
# nicely with all supported compiler versions, so are disabled unless
# explicitly enabled.
option(extra-warnings "Enable extra compiler warnings" OFF)

# This will cause the compiler to fail when an error occurs.
option(fatal-warnings "Compiler warnings are errors" OFF)

# Unit tests.
option(test "Enable unit tests (requires gtest)" ON)
option(extended-tests "Enable extended tests (more comprehensive, longer run time)" OFF)

# Note that unlike in individual components, the default here is ON
# since we require it to be relocatable to move it out of the
# superbuild-install directory in the build tree.
option(relocatable-install "Install tree will be relocatable" ON)

option(head "Force building from current git develop branch (all OME components)" OFF)

# List of packages to build
set(build-packages "ome-files" CACHE STRING "Packages to build")

option(build-prerequisites "Build third-party prerequisites" ON)

# Doxygen documentation
find_package(Doxygen)
set(DOXYGEN_DEFAULT OFF)
if (DOXYGEN_FOUND AND DOXYGEN_DOT_FOUND)
  set (DOXYGEN_DEFAULT ON)
endif (DOXYGEN_FOUND AND DOXYGEN_DOT_FOUND)
option(doxygen "Enable doxygen documentation" ${DOXYGEN_DEFAULT})
set(BUILD_DOXYGEN ${doxygen})

# Qt GUI
find_package(Qt5 5.2.0 COMPONENTS Core Gui Widgets Svg)
find_package(OpenGL)
set(OME_QTOPENGL_DEFAULT OFF)
if (Qt5Core_FOUND AND Qt5Gui_FOUND AND Qt5Widgets_FOUND AND Qt5Svg_FOUND AND OPENGL_FOUND)
  set(OME_QTOPENGL_DEFAULT ON)
endif()
option(qtgui "Build Qt GUI widgets and image viewer" ${OME_QTOPENGL_DEFAULT})

# Sphinx documentation generator
find_program(SPHINX_BUILD sphinx-build)
if (SPHINX_BUILD)
  message(STATUS "Looking for sphinx-build - ${SPHINX_BUILD}")
else()
  message(STATUS "Looking for sphinx-build - not found")
endif()
find_program(XELATEX xelatex)
if (XELATEX)
  message(STATUS "Looking for xelatex - ${XELATEX}")
else()
  message(STATUS "Looking for xelatex - not found")
endif()
find_program(MAKEINDEX makeindex)
if (MAKEINDEX)
  message(STATUS "Looking for makeindex - ${MAKEINDEX}")
else()
  message(STATUS "Looking for makeindex - not found")
endif()

set(SPHINX_DEFAULT OFF)
if(SPHINX_BUILD)
  set(SPHINX_DEFAULT ON)
endif()
option(sphinx "Enable sphinx manual page and HTML documentation" ${SPHINX_DEFAULT})
set(SPHINX_PDF_DEFAULT OFF)
if(SPHINX_DEFAULT AND XELATEX AND MAKEINDEX)
  set(SPHINX_PDF_DEFAULT ON)
endif()
option(sphinx-pdf "Enable sphinx PDF documentation" ${SPHINX_PDF_DEFAULT})

set(SUPERBUILD_OPTIONS
    "-Dextra-warnings:BOOL=${extra-warnings}"
    "-Dfatal-warnings:BOOL=${fatal-warnings}"
    "-Drelocatable-install:BOOL=${relocatable-install}"
    "-Dtest:BOOL=${test}"
    "-Dextended-tests:BOOL=${extended-tests}"
    "-Dqtgui:BOOL=${qtgui}"
    "-Ddoxygen:BOOL=${doxygen}"
    "-Dsphinx:BOOL=${sphinx}"
    "-Dsphinx-pdf:BOOL=${sphinx-pdf}")
