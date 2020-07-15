include(FindPackageHandleStandardArgs)
include(CheckCXXCompilerFlag)
include(CMakePushCheckState)
include(FeatureSummary)

set_package_properties(MemorySanitizer
  PROPERTIES
    DESCRIPTION "Detector of uninitalized reads"
    URL "https://clang.llvm.org/docs/MemorySanitizer.html")

set(MemorySanitizer_LINKER_FLAG -fsanitize=memory)

cmake_push_check_state(RESET)
set(CMAKE_REQUIRED_LINK_OPTIONS -fsanitize=memory)
set(CMAKE_REQUIRED_QUIET YES)
check_cxx_compiler_flag(-fsanitize=memory MemorySanitizer_CXX_SUPPORTED)
cmake_pop_check_state()

if (MemorySanitizer_CXX_SUPPORTED)
  set(MemorySanitizer_CXX_FLAG -fsanitize=memory CACHE STRING "MemorySanitizer C++ Compiler Flag")
endif()

find_package_handle_standard_args(MemorySanitizer
  REQUIRED_VARS MemorySanitizer_CXX_FLAG MemorySanitizer_LINKER_FLAG)

if (MemorySanitizer_FOUND)
  mark_as_advanced(MemorySanitizer_CXX_FLAG)
endif()

if (MemorySanitizer_FOUND AND NOT TARGET Sanitizer::Memory)
  add_library(Sanitizer::Memory INTERFACE IMPORTED GLOBAL)
  target_compile_options(Sanitizer::Memory
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:${MemorySanitizer_CXX_FLAG}>
      $<$<COMPILE_LANGUAGE:CXX>:-fno-omit-frame-pointer>)
  target_link_options(Sanitizer::Memory
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:${MemorySanitizer_CXX_FLAG}>)
endif()
