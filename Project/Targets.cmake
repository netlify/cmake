#[[ All project specific (and global) targets are listed here ]]
include(Functions)

if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
  message(DEBUG "Generating top-level 'tests' and 'docs' targets")
  add_custom_target(tests) # used to build *and* run tests
  add_custom_target(docs)
endif()

message(DEBUG "Add sanitizer link options")
set_property(DIRECTORY APPEND PROPERTY LINK_LIBRARIES
  $<$<BOOL:${${project-name}_WITH_SAFE_STACK}>:Sanitizer::SafeStack>
  $<$<BOOL:${${project-name}_WITH_UBSAN}>:Sanitizer::UndefinedBehavior>
  $<$<BOOL:${${project-name}_WITH_ASAN}>:Sanitizer::Address>
  $<$<BOOL:${${project-name}_WITH_MSAN}>:Sanitizer::Memory>
  $<$<BOOL:${${project-name}_WITH_TSAN}>:Sanitizer::Thread>)

message(DEBUG "Add common compile options")
add_compile_options($<$<AND:$<COMPILE_LANG_AND_ID:CXX,Clang>,$<CONFIG:Debug>>:-ggdb3>)
add_compile_options($<$<AND:$<COMPILE_LANG_AND_ID:CXX,Clang>,$<CONFIG:Debug>>:-Og>)
add_compile_options($<$<COMPILE_LANG_AND_ID:CXX,Clang>:-fcolor-diagnostics>)
add_compile_options($<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wall>)

netlify_generate_test_harness()
netlify_generate_test_targets()
netlify_generate_docs_sphinx()
