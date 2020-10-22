#[[ This file holds all settings related to declaring build options ]]
include(CMakeDependentOption)

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

list(APPEND sphinx-doc-requirements "CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME")
list(APPEND sphinx-doc-requirements "TARGET Sphinx::Build")
list(APPEND sphinx-doc-requirements "IS_DIRECTORY ${PROJECT_SOURCE_DIR}/docs")
list(APPEND sphinx-doc-requirements "EXISTS ${PROJECT_SOURCE_DIR}/docs/index.rst")

cmake_dependent_option(${project-name}_BUILD_TESTS
  "Build ${PROJECT_NAME} unit tests" ON
  "CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME;BUILD_TESTING" OFF)
cmake_dependent_option(${project-name}_BUILD_DOCS
  "Build ${PROJECT_NAME} documentation" ON
  "${sphinx-doc-requirements}" OFF)

cmake_dependent_option(${project-name}_FORMAT_CHECK
  "Run clang-format on ${PROJECT_NAME}" ON
  "CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME;TARGET Clang::Format::Git" OFF)
#cmake_dependent_option(${project-name}_FORMAT_FIX
#  "Run clang-format --force on ${PROJECT_NAME}" OFF
#  "${project-name}_FORMAT_CHECK" OFF)

cmake_dependent_option(${project-name}_WITH_COVERAGE
  "Build ${PROJECT_NAME} Tests with Code Coverage" ON
  "${project-name}_BUILD_TESTS;TARGET LLVM::Coverage" OFF)
# Currently, MSAN is always disabled because we don't have a fully instrumented
# toolchain.
cmake_dependent_option(${project-name}_WITH_SAFE_STACK
  "Build ${PROJECT_NAME} With Safe Stack instrumentation pass" OFF
  "${safe-stack-requirements}" OFF)
cmake_dependent_option(${project-name}_WITH_UBSAN
  "Build ${PROJECT_NAME} with UndefinedBehaviorSanitizer" OFF
  "TARGET Sanitizer::UndefinedBehavior" OFF)
cmake_dependent_option(${project-name}_WITH_ASAN
  "Build ${PROJECT_NAME} with AddressSanitizer" OFF
  "TARGET Sanitizer::Address" OFF)
cmake_dependent_option(${project-name}_WITH_TSAN
  "Build ${PROJECT_NAME} with ThreadSanitizer" OFF
  "${thread-san-requirements}" OFF)
cmake_dependent_option(${project-name}_WITH_MSAN
  "Build ${PROJECT_NAME} with MemorySanitizer" OFF
  "${memory-san-requirements};NO" OFF)

# Setup Feature Summary Descriptions Here
add_feature_info("Documentation" ${project-name}_BUILD_DOCS "Generate Documentation")
add_feature_info("Unit Tests" ${project-name}_BUILD_TESTS "Enable Unit Tests")

add_feature_info("Format" ${project-name}_FORMAT_CHECK "Run clang format")

add_feature_info("Safe Stack" ${project-name}_WITH_SAFE_STACK "Enable Safe Stack instrumentation pass")
add_feature_info("UBSan" ${project-name}_WITH_UBSAN "Enable UndefinedBehaviorSanitizer")
add_feature_info("ASan" ${project-name}_WITH_ASAN "Enable AddressSanitizer")
add_feature_info("TSan" ${project-name}_WITH_TSAN "Enable ThreadSanitizer")
add_feature_info("MSan" ${project-name}_WITH_MSAN "Enable MemorySanitizer")
