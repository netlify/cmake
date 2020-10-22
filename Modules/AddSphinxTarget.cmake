include_guard(GLOBAL)

# This generates the targets, but does nothing with them
function (add_sphinx_target name type)
  set(possible HTML EPUB MAN LATEX JSON XML)
  if (NOT "${type}" IN_LIST possible)
    message(FATAL_ERROR "add_sphinx_target: '${type}' is invalid. Use one of ${possible}")
  endif()

  string(REPLACE "::" "-" build-name ${name})
  string(JOIN "-" build-target sphinx build ${build-name})
  set(target ${name})

  add_library(${target} UNKNOWN IMPORTED)
  set_property(TARGET ${target} PROPERTY 🈯::build::target ${build-target})

  # Technically all build options, but we want to stick with cmake conventions
  # for these specific settings
  set(source-dir $<TARGET_PROPERTY:${target},SPHINX_SOURCE_DIR>)
  set(binary-dir $<TARGET_PROPERTY:${target},SPHINX_BINARY_DIR>)
  set(config-dir $<TARGET_PROPERTY:${target},SPHINX_CONFIG_DIR>)
  set(cache-dir $<TARGET_PROPERTY:${target},SPHINX_CACHE_DIR>)
  set(work-dir $<TARGET_PROPERTY:${target},SPHINX_WORKING_DIRECTORY>)

  # build configuration
  set(build-definitions $<TARGET_PROPERTY:${target},SPHINX_BUILD_DEFINITIONS>)
  set(build-nitpick $<TARGET_PROPERTY:${target},SPINX_BUILD_NITPICK>)
  set(build-values $<TARGET_PROPERTY:${target},SPHINX_BUILD_VALUES>)
  set(build-tag $<TARGET_PROPERTY:${target},SPHINX_BUILD_TAG>)

  # These are technically added to SPHINX_BUILD_DEFINITIONS, but are important
  # enough to be set on the target itself
  set(project-copyright $<TARGET_PROPERTY:${target},SPHINX_PROJECT_COPYRIGHT>)
  set(project-version $<TARGET_PROPERTY:${target},SPHINX_PROJECT_VERSION>)
  set(project-release $<TARGET_PROPERTY:${target},SPHINX_PROJECT_RELEASE>)
  set(project-project $<TARGET_PROPERTY:${target},SPHINX_PROJECT_NAME>)
  set(project-author $<TARGET_PROPERTY:${target},SPHINX_PROJECT_AUTHOR>)

  # console configuration
  set(console-breakpoint $<TARGET_PROPERTY:${target},SPHINX_CONSOLE_BREAKPOINT>)
  set(console-traceback $<TARGET_PROPERTY:${target},SPHINX_CONSOLE_TRACEBACK>)
  set(console-continue $<TARGET_PROPERTY:${target},SPHINX_CONSOLE_CONTINUE>)
  set(console-logfile $<TARGET_PROPERTY:${target},SPHINX_CONSOLE_LOGFILE>)
  set(console-silent $<TARGET_PROPERTY:${target},SPHINX_CONSOLE_SILENT>)
  set(console-quiet $<TARGET_PROPERTY:${target},SPHINX_CONSOLE_QUIET>)
  set(console-color $<TARGET_PROPERTY:${target},SPHINX_CONSOLE_COLOR>)
  set(console-error $<TARGET_PROPERTY:${target},SPHINX_CONSOLE_ERROR>)

  # Protects against us accidentally adding CMAKE_CURRENT_BINARY_DIR to ADDITIONAL_CLEAN_FILES
  string(CONCAT check-binary-dir $<AND:
    $<NOT:
      $<STREQUAL:
        $<IF:$<BOOL:${binary-dir}>,${binary-dir},"">, # Empty string in case missing property
        ${CMAKE_CURRENT_BINARY_DIR}
      >
    >,
    $<BOOL:${binary-dir}>
  >)

  set(source-dir-genexp $<TARGET_GENEX_EVAL:${target},${source-dir}>)
  set(binary-dir-genexp $<TARGET_GENEX_EVAL:${target},${binary-dir}>)
  set(work-dir-genexp $<TARGET_GENEX_EVAL:${target},${work-dir}>)

  set(config-dir-genexp -c$<TARGET_GENEX_EVAL:${target},${config-dir}>)
  set(cache-dir-genexp -d$<TARGET_GENEX_EVAL:${target},${cache-dir}>)

  set(build-definitions-genexp -D$<JOIN:$<TARGET_GENEX_EVAL:${target},${build-definitions}>,$<SEMICOLON>-D>)
  set(build-nitpick-genexp -n$<TARGET_GENEX_EVAL:${target},${build-nitpick}>)
  set(build-values-genexp -A$<JOIN:$<TARGET_GENEX_EVAL:${target},${build-values}>,$<SEMICOLON>-A>)
  set(build-tag-genexp -t$<TARGET_GENEX_EVAL:${target},${build-tag}>)

  set(console-logfile-genexp -W$<TARGET_GENEX_EVAL:${target},${console-logfile}>)

  add_custom_target(${build-target}
    COMMAND Sphinx::Build
      $<IF:$<BOOL:${source-dir}>,${source-dir-genexp},${CMAKE_CURRENT_SOURCE_DIR}/docs>
      $<IF:$<BOOL:${binary-dir}>,${binary-dir-genexp},${CMAKE_CURRENT_BINARY_DIR}/docs>
      $<$<BOOL:${config-dir}>:${config-dir-genexp}>
      $<$<BOOL:${cache-dir}>:${cache-dir-genexp}>
      -b$<LOWER_CASE:${type}>

      $<$<BOOL:${build-definitions}>:${build-definitions-genexp}>
      $<$<BOOL:${build-nitpick}>:${build-nitpick-genexp}>
      $<$<BOOL:${build-values}>:${build-values-genexp}>
      $<$<BOOL:${build-tag}>:${build-tag-genexp}>

      $<$<BOOL:${console-logfile}>:${console-logfile-genexp}>

      $<$<BOOL:${console-breakpoint}>:-P>
      $<$<BOOL:${console-traceback}>:-T>
      $<$<BOOL:${console-continue}>:--keep-going>
      $<$<BOOL:${console-silent}>:-q>
      $<$<BOOL:${console-quiet}>:-Q>
      $<$<BOOL:${console-color}>:--color>
      $<$<BOOL:${console-error}>:-W>
    WORKING_DIRECTORY $<$<BOOL:${work-dir}>:${work-dir-genexp}>
    COMMAND_EXPAND_LISTS
    USES_TERMINAL
    VERBATIM)

  set_property(TARGET ${target}
    PROPERTY ADDITIONAL_CLEAN_FILES
      $<$<BOOL:${check-binary-dir}>:${binary-dir}>)

  set_property(TARGET ${target} APPEND
    PROPERTY SPHINX_BUILD_DEFINITIONS
      version=$<IF:$<BOOL:${project-version}>,${project-version},${PROJECT_VERSION}>
      project=$<IF:$<BOOL:${project-name}>,${project-name},${PROJECT_NAME}>
      $<$<BOOL:${project-copyright}>:copyright=${project-copyright}>
      $<$<BOOL:${project-release}>:release=${project-release}>
      $<$<BOOL:${project-author}>:author=${project-author}>)
endfunction()
