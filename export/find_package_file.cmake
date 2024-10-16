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

#[=======================================================================[.rst:
rapids_export_cpm
-----------------

Record a given <PackageName> found by `CPMFindPackage` is required for a
given export set

.. versionadded:: 0.20

.. command:: rapids_export_find_package_file

  .. code-block:: cmake

    rapids_export_find_package_file( (build|install)
                                     <file_path>
                                     <ExportSet>
                                    )

#]=======================================================================]
function(rapids_export_find_package_file type file_path export_set)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.export.find_package_file")

  string(TOLOWER ${type} type)

  if(NOT TARGET rapids_export_${type}_${export_set} )
    add_library(rapids_export_${type}_${export_set} INTERFACE)
  endif()

  # Don't remove duplicates here as that cost should only be paid
  # Once per export set. So that should occur in `write_dependencies`

  set_property(TARGET rapids_export_${type}_${export_set}
               APPEND
               PROPERTY "FIND_PACKAGES_TO_INSTALL" "${file_path}")

endfunction()
