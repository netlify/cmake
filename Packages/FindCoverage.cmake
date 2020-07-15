include(FindPackageHandleStandardArgs)

include(CMakePushCheckState)
include(CheckCXXCompilerFlag)

# TODO: Redesign this file to be specifically written to help support
# llvm-cov, as it does a better job than gcov or gcovr, etc.

cmake_push_check_state(RESET)
set(CMAKE_REQUIRED_LINK_OPTIONS --coverage)
set(CMAKE_REQUIRED_QUIET YES)
check_cxx_compiler_flag(--coverage Coverage_SUPPORTED)
cmake_pop_check_state()

# This is for the LLVM Component
cmake_push_check_state(RESET)
set(CMAKE_REQUIRED_QUIET YES)
check_cxx_compiler_flag(-fprofile-instr-generate Coverage_LLVM_PROFILE_SUPPORTED)
cmake_pop_check_state()

cmake_push_check_state(RESET)
set(CMAKE_REQUIRED_QUIET YES)
set(CMAKE_REQUIRED_FLAGS -fprofile-instr-generate)
check_cxx_compiler_flag(-fcoverage-mapping Coverage_LLVM_MAPPING_SUPPORTED)
cmake_pop_check_state()

if (Coverage_SUPPORTED)
  set(Coverage_FLAG --coverage CACHE STRING "Coverage compiler flag")
endif()

if (Coverage_LLVM_PROFILE_SUPPORTED AND Coverage_LLVM_MAPPING_SUPPORTED)
  set(Coverage_LLVM_FLAGS -fprofile-instr-generate -fcoverage-mapping
    CACHE STRING "LLVM Source Based Code Coverage compiler flags")
  set(Coverage_LLVM_FOUND YES)
endif()

find_package_handle_standard_args(Coverage
  REQUIRED_VARS Coverage_FLAG
  HANDLE_COMPONENTS)

if (Coverage_FOUND AND NOT TARGET Coverage::Coverage)
  add_library(Coverage::Coverage IMPORTED INTERFACE)
  target_compile_options(Coverage::Coverage
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:${Coverage_FLAG}>)
  target_link_options(Coverage::Coverage
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:${Coverage_FLAG}>)
endif()

if (Coverage_LLVM_FOUND AND NOT TARGET Coverage::LLVM)
  add_library(Coverage::LLVM IMPORTED INTERFACE)
  target_compile_options(Coverage::LLVM
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:${Coverage_LLVM_FLAGS}>)
  target_link_options(Coverage::LLVM
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:${Coverage_LLVM_FLAGS}>)
endif()
