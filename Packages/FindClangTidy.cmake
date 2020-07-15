include(FindPackageHandleStandardArgs)
include(FeatureSummary)

find_program(ClangTidy_EXECUTABLE NAMES clang-tidy)
find_version(ClangTidy_VERSION COMMAND "${ClangTidy_EXECUTABLE}")

find_package_handle_standard_args(ClangTidy
  REQUIRED_VARS ClangTidy_EXECUTABLE
  VERSION_VAR ClangTidy_VERSION)

set_package_properties(ClangTidy
  PROPERTIES
    DESCRIPTION "Clang based C++ 'linter' tool"
    URL "https://clang.llvm.org/extra/clang-tidy")

if (ClangTidy_FOUND AND NOT TARGET Clang::Tidy)
  add_executable(Clang::Tidy IMPORTED)
  set_property(TARGET Clang::Tidy PROPERTY IMPORTED_LOCATION ${ClangTidy_EXECUTABLE})
  set_property(TARGET Clang::Tidy PROPERTY VERSION "${ClangTidy_VERSION}")
endif()
