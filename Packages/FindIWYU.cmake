include(FindPackageHandleStandardArgs)
include(FeatureSummary)

find_program(IWYU_EXECUTABLE NAMES include-what-you-use)
find_version(IWYU_VERSION COMMAND "${IWYU_EXECUTABLE}")

find_package_handle_standard_args(IWYU
  REQUIRED_VARS IWYU_EXECUTABLE
  VERSION_VAR IWYU_VERSION)

set_package_properties(IWYU
  PROPERTIES
    DESCRIPTION "A tool to analyze #includes in C and C++ source files"
    URL "https://include-what-you-use.org")

if (IWYU_FOUND AND NOT TARGET IWYU::IWYU)
  add_executable(IWYU::IWYU IMPORTED)
  set_property(TARGET IWYU::IWYU PROPERTY IMPORTED_LOCATION ${IWYU_EXECUTABLE})
  set_property(TARGET IWYU::IWYU PROPERTY VERSION ${IWYU_VERSION})
endif()
