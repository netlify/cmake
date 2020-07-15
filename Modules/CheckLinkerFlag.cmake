if (CMAKE_VERSION VERSION_GREATER_EQUAL 3.18)
  return()
endif()
include_guard(GLOBAL)

include(CMakeCheckCompilerFlagCommonPatterns)
include(CheckCXXSourceCompiles)
include(CheckCSourceCompiles)

# TODO: Finish backporting
function (check_linker_flag language flag var)
  get_property(supported-languages GLOBAL PROPERTY ENABLED_LANGUAGES)
  if (NOT language IN_LIST supported-languages)
    message(SEND_ERROR "check_linker_flag: ${language}: unknown language")
  endif()
  set(CMAKE_REQUIRED_LINK_OPTIONS "${flag}")

  foreach (var IN LISTS locales)
  endforeach()

  # Normalize
endfunction ()
