# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/json/parse.cmake)

# Verify the variable `name` is defined, and that its value is `expected`
function(check_equal name expected)
  if(NOT DEFINED ${name})
    message(FATAL_ERROR "${name}: expected [${expected}] but the variable is not defined")
  endif()
  if(NOT "${${name}}" STREQUAL "${expected}")
    message(FATAL_ERROR "${name}: expected [${expected}] but found [${${name}}]")
  endif()
endfunction()

set(ns "my::ns")
set(dir "/expanded/dir")
set(json
    [=[
{
  "value" : "${ns}::tag<@x@, ${ns}>",
  "list" : [ "${ns}", "<plain.hpp>", "x${ns}y" ],
  "path" : "${dir}/a.cpp",
  "relative" : "b.cpp",
  "paths" : [ "${dir}/c.cpp", "d.cpp" ],
  "undefined" : "a${this_is_not_defined}b",
  "other_forms" : "$ENV{HOME} $<TARGET_FILE:x> $ plain",
  "quotes" : "a \"b\" c \\ d",
  "obj" : { "inner" : "${ns}" }
}
]=])

# Validate nothing is expanded by default
rapids_json_parse(p STRING "${json}" VALUES value LISTS list PATHS path)
check_equal(p_value "\${ns}::tag<@x@, \${ns}>")
check_equal(p_list "\${ns};<plain.hpp>;x\${ns}y")
check_equal(p_path "${CMAKE_CURRENT_LIST_DIR}/\${dir}/a.cpp")

# Validate EXPAND_VARIABLES expands values, lists, and paths
rapids_json_parse(p STRING "${json}" BASE_DIR /base VALUES value undefined other_forms quotes LISTS
                  list PATHS path relative paths OBJECTS obj EXPAND_VARIABLES)
check_equal(p_value "my::ns::tag<@x@, my::ns>")
check_equal(p_list "my::ns;<plain.hpp>;xmy::nsy")

# Expansion happens before relative paths are evaluated
check_equal(p_path "/expanded/dir/a.cpp")
check_equal(p_relative "/base/b.cpp")
check_equal(p_paths "/expanded/dir/c.cpp;/base/d.cpp")

# Variables that are not defined are empty
check_equal(p_undefined "ab")

# Other uses of `$`, and special characters are kept
check_equal(p_other_forms [=[$ENV{HOME} $<TARGET_FILE:x> $ plain]=])
check_equal(p_quotes [=[a "b" c \ d]=])

# Objects are not expanded
string(JSON inner GET "${p_obj}" inner)
check_equal(inner "\${ns}")

# Validate values can't run code
rapids_json_parse(p STRING [=[{ "v" : "\") message(FATAL_ERROR \"injected\") set(x \"" }]=] VALUES
                  v EXPAND_VARIABLES)
check_equal(p_v "\") message(FATAL_ERROR \"injected\") set(x \"")
