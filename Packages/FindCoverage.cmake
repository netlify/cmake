include(FindPackageHandleStandardArgs)

include(CMakePushCheckState)
include(CheckCXXCompilerFlag)

find_program(Coverage_EXECUTABLE NAMES llvm-cov)
find_version(Coverage_VERSION COMMAND "${Coverage_EXECUTABLE}")

cmake_push_check_state(RESET)
set(CMAKE_REQUIRED_LINK_OPTIONS --coverage)
set(CMAKE_REQUIRED_QUIET YES)
check_cxx_compiler_flag(--coverage Coverage_COMPILER_FLAG)
cmake_pop_check_state()

find_package_handle_standard_args(Coverage
  REQUIRED_VARS Coverage_EXECUTABLE Coverage_COMPILER_FLAG
  VERSION_VAR Coverage_VERSION)

if (Coverage_FOUND AND NOT TARGET Coverage::Coverage)
  add_library(Coverage::Coverage IMPORTED INTERFACE)
  target_compile_options(Coverage::Coverage INTERFACE --coverage)
  target_link_options(Coverage::Coverage INTERFACE --coverage)
endif()
