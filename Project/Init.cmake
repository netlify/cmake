# NOTE: This is very VERY close to what an IXM blueprint looks like
# Using this layout will make using IXM a lot easier once it's available.
include_guard(DIRECTORY)
unset(CMAKE_PROJECT_INCLUDE)

list(PREPEND CMAKE_MODULE_PATH "${NETLIFY_CMAKE_PACKAGES}")
list(PREPEND CMAKE_MODULE_PATH "${NETLIFY_CMAKE_MODULES}")
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

list(APPEND CMAKE_MESSAGE_CONTEXT "${PROJECT_NAME}")

include(CMakePrintHelpers)
include(GNUInstallDirs)

# This is where project-name is created (and then reused)
# Temporarily disabled until we can confirm it works with tools
if (FALSE AND CMAKE_VERSION VERSION_LESS 3.19)
  list(APPEND CMAKE_CXX_COMPILE_OPTIONS_CREATE_PCH -fpch-instantiate-templates)
endif()

list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")
string(MAKE_C_IDENTIFIER "${PROJECT_NAME}" project-name)
string(TOUPPER "${project-name}" project-name)

include(Diagnostics)
include(Packages)
include(Settings)
include(Targets)

unset(project-name)
list(POP_FRONT CMAKE_MODULE_PATH)

set(CMAKE_EXPORT_COMPILE_COMMANDS YES)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_C_STANDARD 11)

if (TARGET SCCache::SCCache AND NOT CMAKE_CXX_COMPILER_LAUNCHER)
  get_property(CMAKE_CXX_COMPILER_LAUNCHER TARGET SCCache::SCCache PROPERTY IMPORTED_LOCATION)
endif()

if (TARGET SCCache::SCCache AND NOT CMAKE_C_COMPILER_LAUNCHER)
  get_property(CMAKE_C_COMPILER_LAUNCHER TARGET SCCache::SCCache PROPERTY IMPORTED_LOCATION)
endif()

if (TARGET Clang::Tidy AND NOT CMAKE_CXX_CLANG_TIDY)
  get_property(CMAKE_CXX_CLANG_TIDY TARGET Clang::Tidy PROPERTY IMPORTED_LOCATION)
  if (EXISTS "${PROJECT_SOURCE_DIR}/.clang-format")
    list(APPEND CMAKE_CXX_CLANG_TIDY "--format-style=file")
  endif()
endif()

# TODO: This needs to be revisited as it doesn't work, but more importantly
# clang-format just straight up breaks with any type of modern code. It can't
# really be trusted.
#if (${project-name}_FORMAT_CHECK AND NOT TARGET fmt)
#  unset(format-dependencies)
#  unset(format-sources)
#  if (EXISTS "${PROJECT_SOURCE_DIR}/.clang-format")
#    set(format-dependencies DEPENDS "${PROJECT_SOURCE_DIR}/.clang-format")
#    set(format-sources SOURCES "${PROJECT_SOURCE_DIR}/.clang-format")
#  endif()
#  add_custom_target(fmt
#    COMMAND Clang::Format::Git
#      $<IF:$<BOOL:${${project-name}_FORMAT_FIX}>,--force,--diff>
#      --commit $<TARGET_PROPERTY:Clang::Format::Git,GIT_EMPTY_TREE_HASH>
#      --binary $<TARGET_PROPERTY:Clang::Format,IMPORTED_LOCATION>
#    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
#    ${format-dependencies}
#    ${format-sources}
#    COMMAND_EXPAND_LISTS
#    USES_TERMINAL
#    VERBATIM)
#endif()
