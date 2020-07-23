include_guard(DIRECTORY)

list(PREPEND CMAKE_MODULE_PATH "${NETLIFY_CMAKE_PACKAGES}")
list(PREPEND CMAKE_MODULE_PATH "${NETLIFY_CMAKE_MODULES}")
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
list(APPEND CMAKE_MESSAGE_CONTEXT "${PROJECT_NAME}")

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

message(DEBUG "Searching for Sanitizers")
# Build Dependencies
find_package(UndefinedBehaviorSanitizer)
find_package(AddressSanitizer)
find_package(MemorySanitizer)
find_package(ThreadSanitizer)
find_package(SafeStack)

find_package(Coverage COMPONENTS LLVM QUIET)
find_package(Threads REQUIRED)

message(DEBUG "Searching for tools")
# Build Tooling Dependencies
find_package(ClangFormat COMPONENTS Git)
find_package(ClangCheck)
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

if (TARGET Clang::Tidy AND NOT CMAKE_CXX_CLANG_TIDY)
  get_property(CMAKE_CXX_CLANG_TIDY TARGET Clang::Tidy PROPERTY IMPORTED_LOCATION)
endif()

string(MAKE_C_IDENTIFIER "${PROJECT_NAME}" project-name)
string(TOUPPER "${project-name}" project-name)

# TODO:
# It will be easier and more correct to just make these mutually exclusive
list(APPEND safe-stack-requirements "TARGET Sanitizer::SafeStack")
list(APPEND safe-stack-requirements "NOT ${project-name}_WITH_ASAN")
list(APPEND safe-stack-requirements "NOT ${project-name}_WITH_TSAN")
list(APPEND safe-stack-requirements "NOT ${project-name}_WITH_MSAN")

list(APPEND thread-san-requirements "TARGET Sanitizer::Thread")
list(APPEND thread-san-requirements "NOT ${project-name}_WITH_SAFE_STACK")
list(APPEND thread-san-requirements "NOT ${project-name}_WITH_ASAN")
list(APPEND thread-san-requirements "NOT ${project-name}_WITH_MSAN")

list(APPEND memory-san-requirements "TARGET Sanitizer::Memory")
list(APPEND memory-san-requirements "NOT ${project-name}_WITH_SAFE_STACK")
list(APPEND memory-san-requirements "NOT ${project-name}_WITH_ASAN")
list(APPEND memory-san-requirements "NOT ${project-name}_WITH_TSAN")

cmake_dependent_option(${project-name}_BUILD_TESTS
  "Build ${PROJECT_NAME} unit tests" ON
  "CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME;BUILD_TESTING" OFF)
cmake_dependent_option(${project-name}_BUILD_DOCS
  "Build ${PROJECT_NAME} documentation" ON
  "CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME;TARGET Sphinx::Build" OFF)

cmake_dependent_option(${project-name}_WITH_COVERAGE
  "Build ${PROJECT_NAME} Tests with Code Coverage" ON
  "${project-name}_BUILD_TESTS;TARGET LLVM::Coverage" OFF)

cmake_dependent_option(${project-name}_WITH_SAFE_STACK
  "Build ${PROJECT_NAME} With Safe Stack instrumentation pass" OFF
  "${safe-stack-requirements}" OFF)
cmake_dependent_option(${project-name}_WITH_UBSAN
  "Build ${PROJECT_NAME} with UndefinedBehaviorSanitizer" OFF
  "TARGET Sanitizer::UndefinedBehavior" OFF)
cmake_dependent_option(${project-name}_WITH_ASAN
  "Build ${PROJECT_NAME} with AddressSanitizer" OFF
  "TARGET Sanitizer::Address" OFF)
# Temporarily disabled until we are on libc++ everywhere
cmake_dependent_option(${project-name}_WITH_TSAN
  "Build ${PROJECT_NAME} with ThreadSanitizer" OFF
  "${thread-san-requirements}" OFF)
# Requires a fully instrumented set of libraries and toolchains. Disabled until
# we can do that.
#cmake_dependent_option(${project-name}_WITH_MSAN
#  "Build ${PROJECT_NAME} with MemorySanitizer" OFF
#  "TARGET Sanitizer::Memory;NOT ${project-name}_WITH_ASAN" OFF)

# Temporarily disabled until it can be enabled in a clean and useful way
#cmake_dependent_option(${project-name}_WITH_LTO
#  "Build ${PROJECT_NAME} with Link Time Optimization" ON
#  "CMAKE_BUILD_TYPE STREQUAL \"Release\";NETLIFY_IPO_SUPPORTED" OFF)

message(DEBUG "Checking common compiler diagnostics")
check_compiler_diagnostic(strict-aliasing)
check_compiler_diagnostic(thread-safety)
check_compiler_diagnostic(documentation)
check_compiler_diagnostic(uninitialized)
check_compiler_diagnostic(useless-cast)
check_compiler_diagnostic(cast-align)
check_compiler_diagnostic(lifetime)
check_compiler_diagnostic(pedantic)
check_compiler_diagnostic(extra)

# Setup Feature Summary Descriptions Here
add_feature_info("Documentation" ${project-name}_BUILD_DOCS "Generate Documentation")
add_feature_info("Unit Tests" ${project-name}_BUILD_TESTS "Enable Unit Tests")

add_feature_info("Safe Stack" ${project-name}_WITH_SAFE_STACK "Enable Safe Stack instrumentation pass")
add_feature_info("UBSan" ${project-name}_WITH_UBSAN "Enable UndefinedBehaviorSanitizer")
add_feature_info("ASan" ${project-name}_WITH_ASAN "Enable AddressSanitizer")
add_feature_info("TSan" ${project-name}_WITH_TSAN "Enable ThreadSanitizer")
add_feature_info("MSan" ${project-name}_WITH_MSAN "Enable MemorySanitizer")

set_package_properties(Threads PROPERTIES DESCRIPTION "System Threading Library")

set_package_properties(UndefinedBehaviorSanitizer PROPERTIES TYPE Sanitizers)
set_package_properties(AddressSanitizer PROPERTIES TYPE Sanitizers)
set_package_properties(ThreadSanitizer PROPERTIES TYPE Sanitizers)
set_package_properties(MemorySanitizer PROPERTIES TYPE Sanitizers)
set_package_properties(SafeStack PROPERTIES TYPE Sanitizers)

set_package_properties(Coverage PROPERTIES TYPE Development)

set_package_properties(ClangFormat PROPERTIES TYPE Tool)
set_package_properties(ClangTidy PROPERTIES TYPE Tool)
set_package_properties(SCCache PROPERTIES TYPE Tool)
set_package_properties(Sphinx PROPERTIES TYPE Tool)
set_package_properties(IWYU PROPERTIES TYPE Tool)

set_property(DIRECTORY APPEND PROPERTY LINK_LIBRARIES
  $<$<BOOL:${${project-name}_WITH_SAFE_STACK}>:Sanitizer::SafeStack>

  $<$<BOOL:${${project-name}_WITH_UBSAN}>:Sanitizer::UndefinedBehavior>
  $<$<BOOL:${${project-name}_WITH_ASAN}>:Sanitizer::Address>
  #[[$<$<BOOL:${${project-name}_WITH_MSAN}>:Sanitizer::Memory>]]
  $<$<BOOL:${${project-name}_WITH_TSAN}>:Sanitizer::Thread>)

message(DEBUG "Add common compile options")
add_compile_options($<$<AND:$<COMPILE_LANG_AND_ID:CXX,Clang>,$<CONFIG:Debug>>:-ggdb3>)
add_compile_options($<$<AND:$<COMPILE_LANG_AND_ID:CXX,Clang>,$<CONFIG:Debug>>:-Og>)
add_compile_options($<$<COMPILE_LANG_AND_ID:CXX,Clang>:-fcolor-diagnostics>)
add_compile_options($<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wall>)

if (NOT TARGET Catch2::Catch2)
  set(CATCH_BUILD_TESTING OFF)
  set(CATCH_ENABLE_WERROR OFF)
  set(CATCH_INSTALL_HELPERS OFF)
  set(CACHE_INSTALL_DOCS OFF)
  FetchContent_Declare(catch
    GIT_REPOSITORY https://github.com/catchorg/Catch2
    GIT_SHALLOW ON
    GIT_TAG v2.12.1)
  FetchContent_MakeAvailable(catch)
endif()

# Dummy file is needed so that the PCH file is actually generated.
# But we can't use it for the CATCH_CONFIG_MAIN file, because
# otherwise it generates *no symbols* (because it was included BEFORE
# CATCH_CONFIG_MAIN).
# This is why I just want to write my own unit testing library :(
if (NOT TARGET netlify::tests)
  message(DEBUG "Generate netlify::tests target")
  set(catch-dummy "${PROJECT_BINARY_DIR}/tests/empty.cxx")
  set(catch-main "${PROJECT_BINARY_DIR}/tests/catch.cxx")
  file(GENERATE OUTPUT "${catch-dummy}" CONTENT "#include <catch2/catch.hpp>")
  file(GENERATE OUTPUT "${catch-main}"
    CONTENT [[
      #define CATCH_CONFIG_MAIN
      #include <catch2/catch.hpp>
    ]])
  add_library(netlify-tests)
  add_library(netlify::tests ALIAS netlify-tests)
  target_sources(netlify-tests PRIVATE "${catch-dummy}" "${catch-main}")
  target_precompile_headers(netlify-tests PUBLIC <catch2/catch.hpp>)
  target_link_libraries(netlify-tests
      PUBLIC
      #        $<$<BOOL:${${project-name}_WITH_COVERAGE}>:Coverage::LLVM>
        Catch2::Catch2)
  set_property(SOURCE "${catch-main}" PROPERTY SKIP_PRECOMPILE_HEADERS YES)
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


if (${project-name}_BUILD_TESTS)
  message(DEBUG "Generating unit test targets")
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
    set_property(TEST ${test-name} PROPERTY
      ENVIRONMENT
        LLVM_PROFILE_FILE=${PROJECT_BINARY_DIR}/profile/${target}.profraw)
    target_sources(${target} PRIVATE ${PROJECT_SOURCE_DIR}/tests/${source})
    target_precompile_headers(${target} REUSE_FROM netlify-tests)
    target_link_libraries(${target}
      PRIVATE
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
