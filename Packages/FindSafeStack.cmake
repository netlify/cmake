include(FindPackageHandleStandardArgs)
include(CheckCXXCompilerFlag)
include(CMakePushCheckState)

cmake_push_check_state(RESET)
set(CMAKE_REQUIRED_LINK_OPTIONS -fsanitize=address)
set(CMAKE_REQUIRED_QUIET YES)
check_cxx_compiler_flag(-fsanitize=address SafeStack_SUPPORTED)
cmake_pop_check_state()

if (SafeStack_SUPPORTED)
  set(SafeStack_FLAG -fsanitize=address CACHE STRING "SafeStack Compiler Flag")
endif()

find_package_handle_standard_args(SafeStack
  REQUIRED_VARS SafeStack_FLAG)

if (SafeStack_FOUND)
  mark_as_advanced(SafeStack_FLAG)
endif()

if (SafeStack_FOUND AND NOT TARGET Sanitizer::SafeStack)
  add_library(Sanitizer::SafeStack INTERFACE IMPORTED GLOBAL)
  target_compile_options(Sanitizer::SafeStack
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:${SafeStack_FLAG}>)
  target_link_options(Sanitizer::SafeStack
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:${SafeStack_FLAG}>)
endif()

