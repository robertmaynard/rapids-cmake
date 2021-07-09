#=============================================================================
# Copyright (c) 2018-2021, NVIDIA CORPORATION.
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
rapids_cmake_write_version_file
-------------------------------

.. versionadded:: v21.08.00

Generate a C++ header file that hold the version (`X.Y.Z`) information of the calling project.

.. code-block:: cmake

  rapids_cmake_write_version_file(file_path)

The file generated by :cmake:command:`rapids_cmake_write_version_file` will hold the following
components of a `X.Y.Z` version string as C++ defines, extracted from the
CMake :cmake:command:`project` call.

- PROJECT_VERSION_MAJOR (X)
- PROJECT_VERSION_MINOR (Y)
- PROJECT_VERSION_PATCH (Z)

Each of the components will have all leading zeroes removed as we presume
all components of the version can be represented as decimal values.

 .. note::
    If a component doesn't exist, zero will be used as a placeholder value.
    For example version 2.4 the PATCH value will become 0.

``file_path``
    Either an absolute or relative path.
    When a relative path, the absolute location will be computed from
    cmake:variable:`CMAKE_CURRENT_BINARY_DIR`

#]=======================================================================]
function(rapids_cmake_write_version_file file_path)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cmake.write_version_file")

  cmake_path(IS_RELATIVE file_path is_relative)
  if(is_relative)
    cmake_path(APPEND CMAKE_CURRENT_BINARY_DIR ${file_path} OUTPUT_VARIABLE output_path)
  else()
    set(output_path "${file_path}")
  endif()

  if(PROJECT_VERSION_MAJOR)
    math(EXPR RAPIDS_WRITE_MAJOR "${PROJECT_VERSION_MAJOR} + 0" OUTPUT_FORMAT DECIMAL)
  else()
    set(RAPIDS_WRITE_MAJOR 0)
  endif()

  if(PROJECT_VERSION_MINOR)
    math(EXPR RAPIDS_WRITE_MINOR "${PROJECT_VERSION_MINOR} + 0" OUTPUT_FORMAT DECIMAL)
  else()
    set(RAPIDS_WRITE_MINOR 0)
  endif()

  if(PROJECT_VERSION_PATCH)
    math(EXPR RAPIDS_WRITE_PATCH "${PROJECT_VERSION_PATCH} + 0" OUTPUT_FORMAT DECIMAL)
  else()
    set(RAPIDS_WRITE_PATCH 0)
  endif()

  configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/template/version.hpp.in" "${output_path}"
                 @ONLY)
endfunction()
