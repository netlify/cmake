include(FindPackageHandleStandardArgs)
include(CheckCXXCompilerFlag)
include(CMakePushCheckState)
include(FeatureSummary)

cmake_push_check_state(RESET)
set(CMAKE_REQUIRED_LINK_OPTIONS -fsanitize=address)
set(CMAKE_REQUIRED_QUIET YES)
check_cxx_compiler_flag(-fsanitize=address AddressSanitizer_SUPPORTED)
cmake_pop_check_state()

if (AddressSanitizer_SUPPORTED)
  set(AddressSanitizer_FLAG -fsanitize=address CACHE STRING "AddressSanitizer Compiler Flag")
endif()

find_package_handle_standard_args(AddressSanitizer
  REQUIRED_VARS AddressSanitizer_FLAG)

set_package_properties(AddressSanitizer
  PROPERTIES
    DESCRIPTION "Fast memory error detector"
    URL "https://clang.llvm.org/docs/AddressSanitizer.html")

if (AddressSanitizer_FOUND)
  mark_as_advanced(AddressSanitizer_FLAG)
endif()

if (AddressSanitizer_FOUND AND NOT TARGET Sanitizer::Address)
  add_library(Sanitizer::Address INTERFACE IMPORTED GLOBAL)
  target_compile_options(Sanitizer::Address
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:${AddressSanitizer_FLAG}>)
  target_link_options(Sanitizer::Address
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:${AddressSanitizer_FLAG}>)
endif()

