include(FindPackageHandleStandardArgs)
include(FeatureSummary)
include(FindVersion)

find_program(ClangCheck_EXECUTABLE NAMES clang-check)
find_version(ClangCheck_VERSION COMMAND "${ClangCheck_EXECUTABLE}")

find_package_handle_standard_args(ClangCheck
  REQUIRED_VARS ClangCheck_EXECUTABLE
  VERSION_VAR ClangCheck_VERSION)

set_package_properties(ClangCheck
  PROPERTIES
  DESCRIPTION "LibTooling wrapper for basic error checking and AST dumping"
    URL "https://clang.llvm.org/docs/ClangCheck.html")

if (ClangCheck_FOUND AND NOT TARGET Clang::Check)
  add_executable(Clang::Check IMPORTED)
  set_property(TARGET Clang::Check PROPERTY IMPORTED_LOCATION ${ClangCheck_EXECUTABLE})
  set_property(TARGET Clang::Check PROPERTY VERSION "${ClangCheck_VERSION}")
endif()
