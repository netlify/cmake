include(FindPackageHandleStandardArgs)
include(FeatureSummary)
include(FindVersion)

find_program(SCCache_EXECUTABLE NAMES sccache)
find_version(SCCache_VERSION COMMAND "${SCCache_EXECUTABLE}" DOC "SCCache Version")

find_package_handle_standard_args(SCCache
  REQUIRED_VARS SCCache_EXECUTABLE
  VERSION_VAR SCCache_VERSION)

set_package_properties(SCCache
  PROPERTIES
    DESCRIPTION "Shared Compilation Cache"
    URL "https://github.com/mozilla/sccache")

if (SCCache_FOUND AND NOT TARGET SCCache::SCCache)
  add_executable(SCCache::SCCache IMPORTED)
  set_property(TARGET SCCache::SCCache PROPERTY IMPORTED_LOCATION ${SCCache_EXECUTABLE})
  set_property(TARGET SCCache::SCCache PROPERTY VERSION ${SCCache_VERSION})
  mark_as_advanced(SCCache_VERSION SCCache_EXECUTABLE)
endif()
