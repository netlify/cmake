include(FindPackageHandleStandardArgs)
include(FindVersion)

find_library(TrafficServer_Management_LIBRARY NAMES tsmgmt PATH_SUFFIXES trafficserver)
find_library(TrafficServer_Config_LIBRARY NAMES tsconfig PATH_SUFFIXES trafficserver)
find_library(TrafficServer_CXX_LIBRARY NAMES tscppapi atscppapi PATH_SUFFIXES trafficserver)
find_library(TrafficServer_LIBRARY NAMES tscore tsutil PATH_SUFFIXES trafficserver)

find_path(TrafficServer_Management_INCLUDE_DIR NAMES ts/mgmtapi.h)
find_path(TrafficServer_Config_INCLUDE_DIR NAMES ts/ts.h)
find_path(TrafficServer_CXX_INCLUDE_DIR NAMES tscpp/api/Async.h atscppapi/Async.h)
find_path(TrafficServer_INCLUDE_DIR NAMES ts/ts.h)

find_program(TrafficServer_Control_EXECUTABLE NAMES traffic_ctl)
find_version(TrafficServer_Control_VERSION COMMAND "${TrafficServer_Control_EXECUTABLE}")

if (TrafficServer_Control_EXECUTABLE)
  set(TrafficServer_Control_FOUND YES)
endif()

if (TrafficServer_Control_VERSION)
  set(TrafficServer_VERSION "${TrafficServer_Control_VERSION}")
endif()

if (TrafficServer_Management_LIBRARY AND TrafficServer_Management_INCLUDE_DIR)
  set(TrafficServer_Management_FOUND YES)
endif()

if (TrafficServer_Config_LIBRARY AND TrafficServer_Config_INCLUDE_DIR)
  set(TrafficServer_Config_FOUND YES)
endif()

if (TrafficServer_CXX_LIBRARY AND TrafficServer_CXX_INCLUDE_DIR)
  set(TrafficServer_CXX_FOUND YES)
endif()

if (TrafficServer_LIBRARY AND TrafficServer_INCLUDE_DIR)
  set(TrafficServer_Core_FOUND YES)
endif()

find_package_handle_standard_args(TrafficServer
  REQUIRED_VARS TrafficServer_LIBRARY TrafficServer_INCLUDE_DIR
  VERSION_VAR TrafficServer_VERSION
  HANDLE_COMPONENTS)

if (TrafficServer_Core_FOUND AND NOT TARGET TrafficServer::Core)
  add_library(TrafficServer::Core IMPORTED UNKNOWN)
  target_include_directories(TrafficServer::Core
    INTERFACE
      ${TrafficServer_INCLUDE_DIR})
  set_property(TARGET TrafficServer::Core
    PROPERTY
      IMPORTED_LOCATION ${TrafficServer_LIBRARY})
  mark_as_advanced(TrafficServer_INCLUDE_DIR TrafficServer_LIBRARY)
endif()

if (TrafficServer_Management_FOUND AND NOT TARGET TrafficServer::Management)
  add_library(TrafficServer::Management IMPORTED UNKNOWN)
  target_include_directories(TrafficServer::Management
    INTERFACE
      ${TrafficServer_Management_INCLUDE_DIR})
  set_property(TARGET TrafficServer::Management
    PROPERTY
      IMPORTED_LOCATION ${TrafficServer_Management_LIBRARY})
  mark_as_advanced(TrafficServer_Management_INCLUDE_DIR TrafficServer_Management_LIBRARY)
endif()

if (TrafficServer_Config_FOUND AND NOT TARGET TrafficServer::Config)
  add_library(TrafficServer::Config IMPORTED UNKNOWN)
  target_include_directories(TrafficServer::Config
    INTERFACE
      ${TrafficServer_Config_INCLUDE_DIR})
  set_property(TARGET TrafficServer::Config
    PROPERTY
      IMPORTED_LOCATION ${TrafficServer_Config_LIBRARY})
  mark_as_advanced(TrafficServer_Config_INCLUDE_DIR TrafficServer_Config_LIBRARY)
endif()

if (TrafficServer_CXX_FOUND AND NOT TARGET TrafficServer::CXX)
  add_library(TrafficServer::CXX IMPORTED UNKNOWN)
  target_include_directories(TrafficServer::CXX
    INTERFACE
      ${TrafficServer_CXX_INCLUDE_DIR})
  set_property(TARGET TrafficServer::CXX
    PROPERTY
      IMPORTED_LOCATION ${TrafficServer_CXX_LIBRARY})
  mark_as_advanced(TrafficServer_CXX_INCLUDE_DIR TrafficServer_CXX_LIBRARY)
endif()

if (TrafficServer_Control_FOUND AND NOT TARGET TrafficServer::Control)
  add_executable(TrafficServer::Control IMPORTED)
  set_property(TARGET TrafficServer::Control
    PROPERTY
      IMPORTED_LOCATION ${TrafficServer_Control_EXECUTABLE})
  mark_as_advanced(TrafficServer_Control_EXECUTABLE)
endif()
