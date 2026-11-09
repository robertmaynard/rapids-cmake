# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

# Expand `${name}` references in `value` using the variables visible to the caller.
#
# Only the simple `${name}` form is expanded, where name is made of `[A-Za-z0-9_.+-]`. Every other
# `$` is kept literally, and the value can't terminate the evaluated code. Undefined variables
# expand to an empty string, as they do for `cpm/versions.json`.
function(rapids_json_expand_variables out_var value)
  # Escape everything so the value is inert when evaluated
  string(REPLACE "\\" "\\\\" _rapids_value "${value}")
  string(REPLACE "\"" "\\\"" _rapids_value "${_rapids_value}")
  string(REPLACE "$" "\\$" _rapids_value "${_rapids_value}")
  # Re-enable the simple `${name}` form
  string(REGEX REPLACE "\\\\\\$\\{([A-Za-z0-9_.+-]+)\\}" "\${\\1}" _rapids_value "${_rapids_value}")
  cmake_language(EVAL CODE "set(_rapids_value \"${_rapids_value}\")")
  set(${out_var} "${_rapids_value}" PARENT_SCOPE)
endfunction()
