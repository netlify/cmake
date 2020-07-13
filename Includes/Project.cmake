include_guard(DIRECTORY)

list(PREPEND CMAKE_MODULE_PATH "${NETLIFY_CMAKE_PACKAGES}")
list(PREPEND CMAKE_MODULE_PATH "${NETLIFY_CMAKE_MODULES}")
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

set(CMAKE_EXPORT_COMPILE_COMMANDS YES)
set(THREADS_PREFER_PTHREAD_FLAG YES)

include(CheckCXXCompilerFlag)
include(CheckCCompilerFlag)
include(CheckIPOSupported)

include(CMakeDependentOption)
include(CMakePrintHelpers)
include(GNUInstallDirs)
include(FeatureSummary)
include(FetchContent)
include(CTest)

include(CheckCompilerDiagnostic)
include(FindVersion)

# Build Dependencies
find_package(UndefinedBehaviorSanitizer)
find_package(AddressSanitizer)
find_package(Coverage REQUIRED)
find_package(Threads REQUIRED)

# Build Tooling Dependencies
find_package(ClangFormat COMPONENTS Git)
find_package(ClangTidy)
find_package(SCCache)
find_package(Sphinx COMPONENTS Build)
find_package(IWYU)

FetchContent_Declare(catch
  GIT_REPOSITORY https://github.com/catchorg/Catch2.git
  GIT_SHALLOW ON
  GIT_TAG v2.12.1)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_C_STANDARD 11)

check_ipo_supported(RESULT NETLIFY_IPO_SUPPORTED)

if (TARGET SCCache::SCCache AND NOT CMAKE_CXX_COMPILER_LAUNCHER)
  get_property(CMAKE_CXX_COMPILER_LAUNCHER TARGET SCCache::SCCache PROPERTY IMPORTED_LOCATION)
endif()

if (TARGET SCCache::SCCache AND NOT CMAKE_C_COMPILER_LAUNCHER)
  get_property(CMAKE_C_COMPILER_LAUNCHER TARGET SCCache::SCCache PROPERTY IMPORTED_LOCATION)
endif()

# IWYU is very... odd, and honestly barely works with our codebase.
# it doesn't seem to understand half of what our code does, and incorrectly labels
# headers to include
#if (TARGET IWYU::IWYU AND NOT CMAKE_CXX_INCLUDE_WHAT_YOU_USE)
#  get_property(CMAKE_CXX_INCLUDE_WHAT_YOU_USE TARGET IWYU::IWYU PROPERTY IMPORTED_LOCATION)
#  list(APPEND CMAKE_CXX_INCLUDE_WHAT_YOU_USE -Xiwyu --no_default_mappings)
#  list(APPEND CMAKE_CXX_INCLUDE_WHAT_YOU_USE -Xiwyu --prefix_header_includes=keep)
#  list(APPEND CMAKE_CXX_INCLUDE_WHAT_YOU_USE -Xiwyu --transitive_includes_only)
#endif()

if (TARGET Clang::Tidy AND NOT CMAKE_CXX_CLANG_TIDY)
  get_property(CMAKE_CXX_CLANG_TIDY TARGET Clang::Tidy PROPERTY IMPORTED_LOCATION)
endif()

# Setup Feature Summary Descriptions Here

string(MAKE_C_IDENTIFIER "${PROJECT_NAME}" project-name)
string(TOUPPER "${project-name}" project-name)

cmake_dependent_option(${project-name}_BUILD_TESTS
  "Build ${PROJECT_NAME} Unit Tests" ON
  "CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME;BUILD_TESTING" OFF)
cmake_dependent_option(${project-name}_BUILD_DOCS
  "Build ${PROJECT_NAME} Documentation" ON
  "CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME;TARGET Sphinx::Build" OFF)
cmake_dependent_option(${project-name}_WITH_LTO
  "Build ${PROJECT_NAME} with Link Time Optimization" ON
  "CMAKE_BUILD_TYPE STREQUAL \"Release\";NETLIFY_IPO_SUPPORTED" OFF)
cmake_dependent_option(${project-name}_WITH_COVERAGE
  "Build ${PROJECT_NAME} with Code Coverage" ON
  "CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME;TARGET Coverage::Coverage" OFF)

cmake_dependent_option(${project-name}_ENABLE_UNDEFINED_BEHAVIOR_SANITIZER
  "Build ${PROJECT_NAME} with Undefined Behavior Sanitizer" OFF
  "CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME;TARGET Sanitizer::UndefinedBehavior" OFF)
cmake_dependent_option(${project-name}_ENABLE_ADDRESS_SANITIZER
  "Build ${PROJECT_NAME} with Address Sanitizer" OFF
  "CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME;TARGET Sanitizer::Address" OFF)
cmake_dependent_option(${project-name}_ENABLE_SAFE_STACK
  "Build ${PROJECT_NAME} with Safe Stack instrumentation pass" OFF
  "CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME;TARGET Sanitizer::SafeStack" OFF)

check_compiler_diagnostic(strict-aliasing)
check_compiler_diagnostic(uninitialized)
check_compiler_diagnostic(useless-cast)
check_compiler_diagnostic(cast-align)
check_compiler_diagnostic(pedantic)
check_compiler_diagnostic(extra)

add_compile_options($<$<AND:$<COMPILE_LANG_AND_ID:CXX,Clang>,$<CONFIG:Debug>>:-ggdb3>)
add_compile_options($<$<AND:$<COMPILE_LANG_AND_ID:CXX,Clang>,$<CONFIG:Debug>>:-Og>)
add_compile_options($<$<COMPILE_LANG_AND_ID:CXX,Clang>:-fcolor-diagnostics>)
add_compile_options($<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wall>)

set_property(DIRECTORY APPEND PROPERTY LINK_LIBRARIES
  $<$<BOOL:${${project-name}_ENABLE_UNDEFINED_BEHAVIOR_SANITIZER}>:Sanitizer::UndefinedBehavior>
  $<$<BOOL:${${project-name}_ENABLE_ADDRESS_SANITIZER}>:Sanitizer::Address>
  $<$<BOOL:${${project-name}_ENABLE_SAFE_STACK}>:Sanitizer::SafeStack>)

add_feature_info("Link Time Optimization" ${project-name}_WITH_LTO
  "Better optimizations at the expense of longer link times")
add_feature_info("Code Profiling" ${project-name}_WITH_PROFILING "Generate profiling data")
add_feature_info("Code Coverage" ${project-name}_WITH_COVERAGE "Generate coverage reports")

add_feature_info("Documentation" ${project-name}_BUILD_DOCS "Generate Documentation")
add_feature_info("Unit Tests" ${project-name}_BUILD_TESTS "Build Unit Tests")

add_feature_info("Undefined Behavior Sanitizer"
  ${project-name}_ENABLE_UNDEFINED_BEHAVIOR_SANITIZER
  "Enable undefined behavior sanitizer")
add_feature_info("Address Sanitizer"
  ${project-name}_ENABLE_ADDRESS_SANITIZER
  "Enable address sanitizer")
add_feature_info("Safe Stack"
  ${project-name}_ENABLE_SAFE_STACK
  "Enable safe stack instrumentation pass")

set_package_properties(Threads PROPERTIES DESCRIPTION "System Threading Library")

set_package_properties(Coverage
  PROPERTIES
    DESCRIPTION "Code coverage"
    TYPE Development)
set_package_properties(AddressSanitizer
  PROPERTIES
    DESCRIPTION "Address Sanitizer"
    TYPE Development)
set_package_properties(SafeStack
  PROPERTIES
    DESCRIPTION "Safe Stack"
    TYPE Development)
set_package_properties(UndefinedBehaviorSanitizer
  PROPERTIES
    DESCRIPTION "Undefined Behavior Sanitizer"
    TYPE Development)
set_package_properties(ClangFormat
  PROPERTIES
    DESCRIPTION "A tool to format C, C++, and Protobuf code."
    TYPE Tool
    URL "https://clang.llvm.org/docs/ClangFormat.html")
set_package_properties(ClangTidy
  PROPERTIES
    DESCRIPTION "Clang based C++ 'linter' tool"
    TYPE Tool
    URL "https://clang.llvm.org/extra/clang-tidy")
set_package_properties(IWYU
  PROPERTIES
    DESCRIPTION "A tool to analyze #includes in C and C++ source files"
    TYPE Tool
    URL "https://include-what-you-use.org")
set_package_properties(Sphinx
  PROPERTIES
    DESCRIPTION "Sphinx Documentation Generator"
    TYPE Tool
    URL "https://sphinx-doc.org")
set_package_properties(SCCache
  PROPERTIES
    DESCRIPTION "Shared Compilation Cache"
    TYPE Tool
    URL "https://github.com/mozilla/sccache")

if (NOT TARGET netlify::tests)
  set(CATCH_BUILD_TESTING OFF)
  set(CATCH_ENABLE_WERROR OFF)
  set(CATCH_INSTALL_HELPERS OFF)
  set(CACHE_INSTALL_DOCS OFF)
  FetchContent_Declare(catch
    GIT_REPOSITORY https://github.com/catchorg/Catch2
    GIT_SHALLOW ON
    GIT_TAG v2.12.1)
  FetchContent_MakeAvailable(catch)
  file(GENERATE OUTPUT "${PROJECT_BINARY_DIR}/tests/catch.cxx"
    CONTENT [[
      #define CATCH_CONFIG_MAIN
      #include <catch2/catch.hpp>
    ]])
  add_library(netlify-tests)
  add_library(netlify::tests ALIAS netlify-tests)
  target_sources(netlify-tests PRIVATE "${PROJECT_BINARY_DIR}/tests/catch.cxx")
  target_precompile_headers(netlify-tests INTERFACE <catch2/catch.hpp>)
  target_link_libraries(netlify-tests PUBLIC Catch2::Catch2)
  target_compile_features(netlify-tests PUBLIC cxx_std_20)
  target_compile_options(netlify-tests
    PUBLIC
      ${--warn-strict-aliasing}
      ${--warn-uninitalized}
      ${--warn-useless-cast}
      ${--warn-cast-align}
      ${--warn-pedantic}
      ${--warn-default}
      ${--warn-extra})
endif()

# Add tests targets
# TODO: Move all general Catch related work into a separate section.
# We can then have a common netlify::test harness
if (${project-name}_BUILD_TESTS)
  add_library(netlify-${PROJECT_NAME}-tests INTERFACE)
  file(GLOB_RECURSE sources
    RELATIVE "${PROJECT_SOURCE_DIR}/tests"
    CONFIGURE_DEPENDS "${PROJECT_SOURCE_DIR}/tests/*.cxx")
  foreach (source IN LISTS sources)
    get_filename_component(module "${source}" DIRECTORY)
    get_filename_component(name "${source}" NAME_WLE)
    string(JOIN "-" target ${PROJECT_NAME} test ${module} ${name})
    string(JOIN "::" test-name test ${PROJECT_NAME} ${module} ${name})
    add_executable(${target})
    add_test(NAME ${test-name} COMMAND ${target})
    target_sources(${target} PRIVATE ${PROJECT_SOURCE_DIR}/tests/${source})
    target_link_libraries(${target}
      PRIVATE
        $<$<BOOL:${${project-name}_WITH_COVERAGE}>:Coverage::Coverage>
        netlify-${PROJECT_NAME}-tests
        netlify::tests)
  endforeach()
endif()

# Add documentation target
if (${project-name}_BUILD_DOCS)
  set(target ${PROJECT_NAME}-docs)
  if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
    set(target docs)
  endif()
  add_custom_target(${docs}
    COMMAND Sphinx::Build "${PROJECT_SOURCE_DIR}/docs" "${PROJECT_BINARY_DIR}/docs")
  set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_CLEAN_FILES "${PROJECT_BINARY_DIR}/docs")
endif()

unset(CMAKE_PROJECT_INCLUDE)
unset(project-name)
