# The Builtin CMake Doxygen module does not suit our needs
include(FindPackageHandleStandardArgs)
include(FeatureSummary)

find_program(Doxygen_EXECUTABLE NAMES doxygen)
find_version(Doxygen_VERSION COMMAND "${Doxygen_EXECUTABLE}" DOC "Doxygen Version")

find_package_handle_standard_args(Doxygen
  REQUIRED_VARS Doxygen_EXECUTABLE
  VERSION_VAR Doxygen_VERSION)

set_package_properties(Doxygen
  PROPERTIES
    DESCRIPTION "Documentation Generator"
    URL "https://www.doxygen.nl/")

if (Doxygen_FOUND AND NOT TARGET Doxygen::Doxygen)
  add_executable(Doxygen::Doxygen IMPORTED)
  set_property(TARGET Doxygen::Doxygen PROPERTY IMPORTED_LOCATION ${Doxygen_EXECUTABLE})
  set_property(TARGET Doxygen::Doxygen PROPERTY VERSION ${Doxygen_VERSION})
  mark_as_advanced(Doxygen_VERSION Doxygen_EXECUTABLE)
endif()
