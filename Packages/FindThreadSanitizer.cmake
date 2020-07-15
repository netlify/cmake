include(FindPackageHandleStandardArgs)
include(CheckCXXCompilerFlag)
include(CMakePushCheckState)
include(FeatureSummary)

set_package_properties(ThreadSanitizer
  PROPERTIES
    DESCRIPTION "Data race detector"
    URL "https://clang.llvm.org/docs/ThreadSanitizer.html")

cmake_push_check_state(RESET)
set(CMAKE_REQUIRED_LINK_OPTIONS -fsanitize=thread)
set(CMAKE_REQUIRED_QUIET YES)
check_cxx_compiler_flag(-fsanitize=thread ThreadSanitizer_CXX_SUPPORTED)
cmake_pop_check_state()

if (ThreadSanitizer_CXX_SUPPORTED)
  set(ThreadSanitizer_CXX_FLAG -fsanitize=thread
    CACHE STRING "ThreadSanitizer C++ Compiler Flag")
endif()

find_package_handle_standard_args(ThreadSanitizer
  REQUIRED_VARS ThreadSanitizer_CXX_FLAG)

if (ThreadSanitizer_FOUND)
  mark_as_advanced(ThreadSanitizer_CXX_FLAG)
endif()

if (ThreadSanitizer_FOUND AND NOT TARGET Sanitizer::Thread)
  add_library(Sanitizer::Thread INTERFACE IMPORTED GLOBAL)
  target_compile_options(Sanitizer::Thread
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:${ThreadSanitizer_CXX_FLAG}>)
  target_link_options(Sanitizer::Thread
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:${ThreadSanitizer_CXX_FLAG}>)
endif()
