#=============================================================================
# Copyright (c) 2026, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#=============================================================================
include_guard(GLOBAL)

#[=======================================================================[.rst:
rapids_cmake_enable_features
----------------------------

.. versionadded:: v26.06.00

Extends the :cmake:command:`project() <cmake:command:project>` to enable modern CMake
features that establish best practices for RAPIDS projects.

  .. code-block:: cmake

    rapids_cmake_enable_features( [EPOCH]

                                )


``EPOCH <N>``
    Extract the first component (`X`) from `version` and place it in the variable
    named in `out_variable_name`

``CUDA_INIT``
  Hook to rapids-cmake cuda_init ( RAPIDS || NATIVE )

``CMAKE_COLOR_DIAGNOSTICS``

``CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION``

``CMAKE_EXPORT_COMPILE_COMMANDS``

``CMAKE_FIND_PACKAGE_TARGETS_GLOBAL``

``CMAKE_FIND_USE_INSTALL_PREFIX```

``CMAKE_LINK_LIBRARIES_ONLY_TARGETS``

``CMAKE_SKIP_INSTALL_ALL_DEPENDENCY``

``CMAKE_SKIP_TEST_ALL_DEPENDENCY``

``DEFAULT_BUILD_TYPE_IS_RELEASE``

``PROJECT_NAME_AS_INSTALL_COMPONENT``


Example on how to properly use :cmake:command:`rapids_cmake_enable_features`:

.. code-block:: cmake

  cmake_minimum_required(...)

  if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/EXAMPLE_RAPIDS.cmake)
    file(DOWNLOAD https://raw.githubusercontent.com/rapidsai/rapids-cmake/branch-<VERSION_MAJOR>.<VERSION_MINOR>/RAPIDS.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/EXAMPLE_RAPIDS.cmake)
  endif()
  include(${CMAKE_CURRENT_BINARY_DIR}/EXAMPLE_RAPIDS.cmake)
  include(rapids-cuda)

  rapids_cmake_enable_features(ALL)
  project(ExampleProject ...)



If the generator is `Ninja` or `Makefile` the :cmake:variable:`CMAKE_BUILD_TYPE <cmake:variable:CMAKE_BUILD_TYPE>`
variable will be established if not explicitly set by the user either by
the env variable `CMAKE_BUILD_TYPE` or by passing `-DCMAKE_BUILD_TYPE=`. This removes
situations where the `No-Config` / `Empty` build type is used.

``default_type``
  The default build type to use if one doesn't already exist

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`CMAKE_BUILD_TYPE <cmake:variable:CMAKE_BUILD_TYPE>` will be set to ``default_type`` if not already set

#]=======================================================================]
function(rapids_cmake_enable_features )
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cmake.build_type")

  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(VERBOSE "Setting build type to '${default_type}' since none specified.")
    set(CMAKE_BUILD_TYPE "${default_type}" CACHE STRING "Choose the type of build." FORCE)
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel"
                                                 "RelWithDebInfo")
  endif()
endfunction()
