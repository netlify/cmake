include(FindPackageHandleStandardArgs)
include(CheckCXXCompilerFlag)
include(CMakePushCheckState)

cmake_push_check_state(RESET)
set(CMAKE_REQUIRED_LINK_OPTIONS -fsanitize=undefined)
set(CMAKE_REQUIRED_QUIET YES)
check_cxx_compiler_flag(-fsanitize=undefined UndefinedBehaviorSanitizer_SUPPORTED)
cmake_pop_check_state()

if (UndefinedBehaviorSanitizer_SUPPORTED)
  set(UndefinedBehaviorSanitizer_FLAG -fsanitize=undefined
    CACHE STRING "UndefinedBehaviorSanitizer Compiler Flag")
endif()

find_package_handle_standard_args(UndefinedBehaviorSanitizer
  REQUIRED_VARS UndefinedBehaviorSanitizer_FLAG)

if (UndefinedBehaviorSanitizer_FOUND)
  mark_as_advanced(UndefinedBehaviorSanitizer_FLAG)
endif()

if (UndefinedBehaviorSanitizer_FOUND AND NOT TARGET Sanitizer::UndefinedBehavior)
  add_library(Sanitizer::UndefinedBehavior INTERFACE IMPORTED GLOBAL)
  target_compile_options(Sanitizer::UndefinedBehavior
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:${UndefinedBehaviorSanitizer_FLAG}>
      $<$<COMPILE_LANGUAGE:CXX>:-fno-omit-frame-pointer>)
  target_link_options(Sanitizer::UndefinedBehavior
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:${UndefinedBehaviorSanitizer_FLAG}>)
endif()
