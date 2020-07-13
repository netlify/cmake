include(FindPackageHandleStandardArgs)

find_program(ClangFormat_Git_EXECUTABLE NAMES git-clang-format)
find_program(ClangFormat_EXECUTABLE NAMES clang-format)
find_version(ClangFormat_VERSION COMMAND "${ClangFormat_EXECUTABLE}")

if (ClangFormat_Git_EXECUTABLE)
  set(ClangFormat_Git_FOUND YES)
endif()

find_package_handle_standard_args(ClangFormat
  REQUIRED_VARS ClangFormat_EXECUTABLE
  VERSION_VAR ClangFormat_VERSION
  HANDLE_COMPONENTS)

if (ClangFormat_Git_FOUND AND NOT TARGET Clang::Format::Git)
  add_executable(Clang::Format::Git IMPORTED)
  set_property(TARGET Clang::Format::Git PROPERTY IMPORTED_LOCATION ${ClangFormat_Git_EXECUTABLE})
  set_property(TARGET Clang::Format::Git
    PROPERTY GIT_EMPTY_TREE_HASH "4b825dc642cb6eb9a060e54bf8d69288fbee4904")
endif()

if (ClangFormat_FOUND AND NOT TARGET Clang::Format)
  add_executable(Clang::Format IMPORTED)
  set_property(TARGET Clang::Format PROPERTY IMPORTED_LOCATION ${ClangFormat_EXECUTABLE})
  set_property(TARGET Clang::Format PROPERTY VERSION "${ClangFormat_VERSION}")
endif()
