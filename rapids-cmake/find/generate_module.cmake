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

cmake_policy(PUSH)
cmake_policy(VERSION 3.20)

#[=======================================================================[.rst:
rapids_find_generate_module
--------------

Generate a Find*.cmake module for the requested package

.. versionadded:: 0.20

.. command:: rapids_find_generate_module

  .. code-block:: cmake

    rapids_find_generate_module( <PackageName>
                    HEADER_NAMES <paths...>
                    [LIBRARY_NAMES <names...>]
                    [INCLUDE_SUFFIXES <suffixes...>]
                    [VERSION <version>]
                    [NO_CONFIG]
                    [BUILD_EXPORT_SET <name>]
                    [INSTALL_EXPORT_SET <name>]
                    )

  Generates a custom Find module for the requested package. Makes
  it easier for projects to look for packages that don't have
  an exisiting FindModule or don't provide a CONFIG module
  when installed.

  Note:
    If you are using this for a module that is part of
    your BUILD or INSTALL export set, it is highly likely
    that this needs to be part of the same export sets.



  ``HEADER_NAMES``
    Header names that should be provided to `find_path` to
    determine the include directory of the package. If provided
    a list of names only one needs to be found for a directory
    to be considered a match

  ``LIBRARY_NAMES``
    library names that should be provided to `find_library` to
    determine the include directory of the package. If provided
    a list of names only one needs to be found for a directory
    to be considered a match

    Note:
      Every entry that doesn't start with `lib` will also be
      searched for as `lib<name>`

  ``INCLUDE_SUFFIXES``
    Extra relative sub-directories to use while searching for `HEADER_NAMES`.

  ``VERSION``
    Will append extra entries of the library to search for based on the
    content of `LIBRARY_NAMES`:
      - <name><version>
      - <name>.<version>
      - lib<name><version>
      - lib<name>.<version>

    :Note
      This ordering is done explicitly to follow CMake recommendations
      for searching for versioned libraries:

      "We recommend specifying the unversioned name first so that locally-built packages
      can be found before those provided by distributions."

  ``NO_CONFIG``
    When provied will stop the generated Find Module from
    first searching for the projects shipped Find Config.

  ``BUILD_EXPORT_SET``
    Record that this custom FindPackage module needs to be part
    of our build directory export set. This means that it will be
    usable by the calling package if it needs to search for
    <PackageName> again.

  ``INSTALL_EXPORT_SET``
    Record that this custom FindPackage module needs to be part
    of our install export set. This means that it will be installed as
    part of our packages CMake infrastructure

Result Variables
^^^^^^^^^^^^^^^^
  CMAKE_BUILD_TYPE will be set to ``default_type`` if not already set

#]=======================================================================]
function(rapids_find_generate_module name)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.find.generate_module")

  set(options NO_CONFIG)
  set(one_value VERSION BUILD_EXPORT_SET INSTALL_EXPORT_SET)
  set(multi_value HEADER_NAMES LIBRARY_NAMES INCLUDE_SUFFIXES)
  cmake_parse_arguments(RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(NOT DEFINED RAPIDS_HEADER_NAMES)
    message(FATAL_ERROR "rapids_find_generate_module requires HEADER_NAMES to be provided")
  endif()

  set(RAPIDS_PKG_NAME ${name})

  # Construct any extra suffix search paths
  set(RAPIDS_PATH_SEARCH_ARGS )
  if(RAPIDS_INCLUDE_SUFFIXES)
    string(APPEND RAPIDS_PATH_SEARCH_ARGS "PATH_SUFFIXES ${RAPIDS_INCLUDE_SUFFIXES}")
  endif()

  set(RAPIDS_HEADER_ONLY TRUE)
  if(DEFINED RAPIDS_LIBRARY_NAMES)
    set(RAPIDS_HEADER_ONLY FALSE)

    # Construct the release and debug library names
    # handling version number suffixes
    set(RAPIDS_PKG_LIB_NAMES ${RAPIDS_LIBRARY_NAMES})
    set(RAPIDS_PKG_LIB_DEBUG_NAMES ${RAPIDS_LIBRARY_NAMES})
    list(TRANSFORM RAPIDS_PKG_LIB_DEBUG_NAMES APPEND "d")

    if(DEFINED RAPIDS_VERSION)
      list(TRANSFORM RAPIDS_PKG_LIB_NAMES APPEND "${RAPIDS_VERSION}" OUTPUT_VARIABLE lib_version1)
      list(TRANSFORM RAPIDS_PKG_LIB_NAMES APPEND ".${RAPIDS_VERSION}" OUTPUT_VARIABLE lib_version2)
      list(PREPEND RAPIDS_PKG_LIB_NAMES ${lib_version1} ${lib_version2})

      list(TRANSFORM RAPIDS_PKG_LIB_DEBUG_NAMES APPEND "${RAPIDS_VERSION}" OUTPUT_VARIABLE lib_version1)
      list(TRANSFORM RAPIDS_PKG_LIB_DEBUG_NAMES APPEND ".${RAPIDS_VERSION}" OUTPUT_VARIABLE lib_version2)
      list(PREPEND RAPIDS_PKG_LIB_DEBUG_NAMES ${lib_version1} ${lib_version2})
    endif()
  endif()

  # Need to generate the module
  configure_file(
    "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/template/find_module.cmake.in"
    "${CMAKE_BINARY_DIR}/cmake/find_modules/Find${name}.cmake"
    @ONLY)

  # Need to add our generated modules to CMAKE_MODULE_PATH!
  if(NOT "${CMAKE_BINARY_DIR}/rapids-cmake/find_modules/" IN_LIST CMAKE_MODULE_PATH)
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_BINARY_DIR}/cmake/find_modules/")
    set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)
  endif()

  # Record what export sets this module is part of
  if(RAPIDS_BUILD_EXPORT_SET)
    include("${rapids-cmake-dir}/export/find_package_file.cmake")
    rapids_export_find_package_file(BUILD  "${CMAKE_BINARY_DIR}/cmake/find_modules/Find${name}.cmake"
                                    ${RAPIDS_BUILD_EXPORT_SET}
                                    )
  endif()

  if(RAPIDS_INSTALL_EXPORT_SET)
    include("${rapids-cmake-dir}/export/find_package_file.cmake")
    rapids_export_find_package_file(INSTALL "${CMAKE_BINARY_DIR}/cmake/find_modules/Find${name}.cmake"
                                    ${RAPIDS_INSTALL_EXPORT_SET}
                                    )
  endif()
endfunction()

cmake_policy(POP)