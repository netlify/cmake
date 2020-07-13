include(FindPackageHandleStandardArgs)

include(CMakePushCheckState)
include(CheckCXXCompilerFlag)

cmake_push_check_state(RESET)
set(CMAKE_REQUIRED_LINK_OPTIONS --coverage)
set(CMAKE_REQUIRED_QUIET YES)
check_cxx_compiler_flag(--coverage Coverage_SUPPORTED)
cmake_pop_check_state()

if (Coverage_SUPPORTED)
  set(Coverage_FLAG --coverage CACHE STRING "Coverage compiler flag")
endif()

find_package_handle_standard_args(Coverage REQUIRED_VARS Coverage_FLAG)

if (Coverage_FOUND AND NOT TARGET Coverage::Coverage)
  add_library(Coverage::Coverage IMPORTED INTERFACE)
  target_compile_options(Coverage::Coverage
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:--coverage>)
  target_link_options(Coverage::Coverage
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:--coverage>)
endif()
