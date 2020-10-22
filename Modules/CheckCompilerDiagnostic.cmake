include_guard(GLOBAL)

include(CheckCXXCompilerFlag)
include(CheckCCompilerFlag)

#[[
Given a diagnostic like strict-aliasing, we check if the given flag works for a
C++ compiler.  If it does, we then generate a --warn, --allow, --deny, and
--forbid prefixed set of variables. Users are then free to simply apply them to
targets at will.
]]
function (check_compiler_diagnostic diagnostic)
  string(MAKE_C_IDENTIFIER "${diagnostic}" suffix)
  string(TOUPPER "${suffix}" suffix)
  check_cxx_compiler_flag(-W${diagnostic} CXX_DIAGNOSTIC_${suffix})
  set(when $<AND:$<COMPILE_LANGUAGE:CXX>,$<BOOL:${CXX_DIAGNOSTIC_${suffix}}>>)
  set(--forbid-${diagnostic} $<${when}:-Werror=${diagnostic}> PARENT_SCOPE)
  set(--allow-${diagnostic} $<${when}:-Wno-${diagnostic}> PARENT_SCOPE)
  set(--warn-${diagnostic} $<${when}:-W${diagnostic}> PARENT_SCOPE)

  set(--deny-${diagnostic} ${--forbid-${diagnostic}} PARENT_SCOPE)
endfunction()
