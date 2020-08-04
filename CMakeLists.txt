cmake_minimum_required(VERSION 3.16)
include(FeatureSummary)

message(DEBUG "Netlify CMake Library has been included")

set(CMAKE_MESSAGE_CONTEXT_SHOW YES)
set(CMAKE_MESSAGE_CONTEXT netlify)

set(file-api "${CMAKE_BINARY_DIR}/.cmake/api/v1/query")
file(MAKE_DIRECTORY "${file-api}")
file(TOUCH
  "${file-api}/cmakeFiles-v1"
  "${file-api}/codemodel-v2"
  "${file-api}/cache-v2")

set(NETLIFY_CMAKE_PACKAGES "${CMAKE_CURRENT_SOURCE_DIR}/Packages"
  CACHE PATH "Netlify CMake Packages" FORCE)
set(NETLIFY_CMAKE_MODULES "${CMAKE_CURRENT_SOURCE_DIR}/Modules"
  CACHE PATH "Netlify CMake Modules" FORCE)
set(NETLIFY_CMAKE_TEMPLATES "${CMAKE_CURRENT_SOURCE_DIR}/Templates"
  CACHE PATH "Netlify Configuration Files Directory") 
set(NETLIFY_PROJECT_PRELUDE "${CMAKE_CURRENT_SOURCE_DIR}/Includes/Project.cmake"
  CACHE FILEPATH "Netlify CMake Project Prelude" FORCE)
set(NETLIFY_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/Includes/Toolchain.cmake"
  CACHE FILEPATH "Netlify's Specific Build Environment" FORCE)

if (NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  message(DEBUG "Setting default Netlify toolchain file")
  set(CMAKE_TOOLCHAIN_FILE ${NETLIFY_TOOLCHAIN_FILE} CACHE FILEPATH
    "Netlify's Default C++ Toolchain")
endif()

message(DEBUG "Disabling in-source builds and source directory changes")
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON CACHE BOOL "Prevents cmake -B. -S.")
set(CMAKE_DISABLE_SOURCE_CHANGES ON CACHE BOOL "Prevents writing files to CMAKE_CURRENT_SOURCE_DIR")
set(CMAKE_POLICY_DEFAULT_CMP0077 NEW CACHE STRING "option() honors normal variables")

message(DEBUG "Disabling export() interaction with find_package")
set(CMAKE_EXPORT_NO_PACKAGE_REGISTRY ON CACHE BOOL "")
set(CMAKE_EXPORT_PACKAGE_REGISTRY OFF CACHE BOOL "")

set(CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY ON CACHE BOOL "")
set(CMAKE_FIND_USE_PACKAGE_REGISTRY OFF CACHE BOOL "")

message(DEBUG "Setting FeatureSummary Properties")
set_property(GLOBAL APPEND PROPERTY FeatureSummary_PKG_TYPES Tool Sanitizers Development)
set_property(GLOBAL PROPERTY FeatureSummary_REQUIRED_DESCRIPTION "build dependencies")

set_property(GLOBAL PROPERTY FeatureSummary_Development_DESCRIPTION "development dependencies")
set_property(GLOBAL PROPERTY FeatureSummary_Sanitizers_DESCRIPTION "sanitizers")
set_property(GLOBAL PROPERTY FeatureSummary_Tool_DESCRIPTION "development tools")

set_property(GLOBAL PROPERTY CTEST_TARGETS_ADDED YES)

set_property(CACHE CMAKE_POLICY_DEFAULT_CMP0077 PROPERTY STRINGS NEW OLD)

mark_as_advanced(NETLIFY_CMAKE_PACKAGES NETLIFY_CMAKE_MODULES NETLIFY_PROJECT_PRELUDE)
mark_as_advanced(CMAKE_DISABLE_IN_SOURCE_BUILD CMAKE_DISABLE_SOURCE_CHANGES)
mark_as_advanced(CMAKE_POLICY_DEFAULT_CMP0077)

mark_as_advanced(CMAKE_EXPORT_NO_PACKAGE_REGISTRY CMAKE_EXPORT_PACKAGE_REGISTRY)
mark_as_advanced(CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY)
mark_as_advanced(CMAKE_FIND_USE_PACKAGE_REGISTRY)
