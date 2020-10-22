include(FindPackageHandleStandardArgs)
include(FeatureSummary)
include(FindVersion)

find_program(Sphinx_Build_EXECUTABLE NAMES sphinx-build)
find_version(Sphinx_Build_VERSION COMMAND "${Sphinx_Build_EXECUTABLE}")

if (Sphinx_Build_EXECUTABLE)
  set(Sphinx_Build_FOUND YES)
endif()

find_package_handle_standard_args(Sphinx
  REQUIRED_VARS Sphinx_Build_EXECUTABLE
  VERSION_VAR Sphinx_Build_VERSION
  HANDLE_COMPONENTS)

set_package_properties(Sphinx
  PROPERTIES
    DESCRIPTION "Sphinx Documentation Generator"
    URL "https://sphinx-doc.org")

if (Sphinx_Build_FOUND AND NOT TARGET Sphinx::Build)
  add_executable(Sphinx::Build IMPORTED)
  set_property(TARGET Sphinx::Build PROPERTY IMPORTED_LOCATION ${Sphinx_Build_EXECUTABLE})
  set_property(TARGET Sphinx::Build PROPERTY VERSION ${Sphinx_Build_VERSION})
  mark_as_advanced(Sphinx_Build_EXECUTABLE Sphinx_Build_VERSION)
endif()
