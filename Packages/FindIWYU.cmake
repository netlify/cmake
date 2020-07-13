include(FindPackageHandleStandardArgs)

find_program(IWYU_EXECUTABLE NAMES include-what-you-use)
find_version(IWYU_VERSION COMMAND "${IWYU_EXECUTABLE}")

find_package_handle_standard_args(IWYU
  REQUIRED_VARS IWYU_EXECUTABLE
  VERSION_VAR IWYU_VERSION)

if (IWYU_FOUND AND NOT TARGET IWYU::IWYU)
  add_executable(IWYU::IWYU IMPORTED)
  set_property(TARGET IWYU::IWYU PROPERTY IMPORTED_LOCATION ${IWYU_EXECUTABLE})
  set_property(TARGET IWYU::IWYU PROPERTY VERSION ${IWYU_VERSION})
endif()
