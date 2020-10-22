include_guard(GLOBAL)
include(AddSphinxTarget)
include(FetchContent)
include(CTest)

# Dummy file is needed so that the PCH file is generated correctly.
# Otherwise the PCH fails to generate any symbols (because it is force included
# before `#define CATCH_CONFIG_MAIN`
# We also don't want clang-tidy to run on netlify::tests, so we disable 
# CXX_CLANG_TIDY entirely for the target
function (netlify_generate_test_harness)
  if (TARGET netlify::tests)
    return()
  endif()
  FetchContent_Declare(catch
    GIT_REPOSITORY https://github.com/catchorg/Catch2
    GIT_TAG v2.13.2)
  FetchContent_MakeAvailable(catch)
  set(catch-dummy "${PROJECT_BINARY_DIR}/tests/empty.cxx")
  set(catch-main "${PROJECT_BINARY_DIR}/tests/catch.cxx")
  file(GENERATE OUTPUT "${catch-dummy}" CONTENT "#include <catch2/catch.hpp>")
  file(GENERATE OUTPUT "${catch-main}"
    CONTENT [[
      #define CATCH_CONFIG_MAIN
      #include <catch2/catch.hpp>
    ]])
  add_library(netlify-tests EXCLUDE_FROM_ALL)
  add_library(netlify::tests ALIAS netlify-tests)
  target_precompile_headers(netlify-tests PUBLIC <catch2/catch.hpp>)
  target_sources(netlify-tests PRIVATE "${catch-dummy}" "${catch-main}")
  target_link_libraries(netlify-tests PUBLIC Catch2::Catch2)
  #target_link_libraries(netlify-tests PUBLIC $<$<BOOL:${project-name}_WITH_COVERAGE}>:Coverage::LLVM)
  target_compile_features(netlify-tests PUBLIC cxx_std_20)
  target_compile_options(netlify-tests
    PUBLIC
      ${--warn-uninitialized-const-reference}
      ${--warn-pointer-to-int-cast}
      ${--warn-double-promotion}
      ${--warn-strict-aliasing}
      ${--warn-old-style-cast}
      ${--warn-thread-safety}
      ${--warn-documentation}
      ${--warn-uninitialized}
      ${--warn-useless-cast}
      ${--warn-cast-align}
      ${--warn-lifetime}
      ${--warn-pedantic}
      ${--warn-unused}
      ${--warn-extra})
  set_property(SOURCE "${catch-main}" PROPERTY SKIP_PRECOMPILE_HEADERS YES)
  set_property(SOURCE "${catch-main}" "${catch-dummy}" PROPERTY CXX_CLANG_TIDY)
endfunction()

#[[ This generates all possible unit tests for a given project ]]
# TODO: cmake --build build --target tests does not yet
#       1. compile all tests
#       2. run said tests
function (netlify_generate_test_targets)
  string(MAKE_C_IDENTIFIER "${PROJECT_NAME}" project-name)
  string(TOUPPER "${project-name}" project-name)
  message(DEBUG "Generating unit test targets")
  add_library(netlify::tests::${PROJECT_NAME} INTERFACE IMPORTED)
  if (${project-name}_BUILD_TESTS)
    file(GLOB_RECURSE sources
      LIST_DIRECTORIES NO
      RELATIVE "${PROJECT_SOURCE_DIR}/tests"
      CONFIGURE_DEPENDS "${PROJECT_SOURCE_DIR}/tests/*.cxx")
    foreach (source IN LISTS sources)
      get_filename_component(module "${source}" DIRECTORY)
      get_filename_component(name "${source}" NAME_WLE)
      string(JOIN "-" target ${PROJECT_NAME} test ${module} ${name})
      string(JOIN "::" test-name test ${PROJECT_NAME} ${module} ${name})
      add_executable(${target})
      add_test(NAME ${test-name} COMMAND ${target})
      target_sources(${target} PRIVATE "${PROJECT_SOURCE_DIR}/tests/${source}")
      target_precompile_headers(${target} REUSE_FROM netlify::tests)
      target_link_libraries(${target} PRIVATE netlify::tests::${PROJECT_NAME} netlify::tests)
      # Not being used *yet*, but will come in handy
      set(coverage-file "${PROJECT_BINARY_DIR}/coverage/${target}.profraw")
      set_property(TEST ${test-name} PROPERTY ENVIRONMENT LLVM_PROFILE_FILE=${coverage-file})
    endforeach ()
  endif()
endfunction()

function (netlify_generate_docs_sphinx)
  string(MAKE_C_IDENTIFIER "${PROJECT_NAME}" project-name)
  string(TOUPPER "${project-name}" project-name)
  set(target sphinx::${PROJECT_NAME})
  add_sphinx_target(${target} HTML)
  set(sphinx.github.user $<TARGET_PROPERTY:${target},SPHINX_GITHUB_USER>)
  set(sphinx.github.repo $<TARGET_PROPERTY:${target},SPHINX_GITHUB_REPO>)
  set(genexp.github.user $<TARGET_GENEX_EVAL:${target},${sphinx.github.user}>)
  set(genexp.github.repo $<TARGET_GENEX_EVAL:${target},${sphinx.github.repo}>)

  set_property(TARGET ${target}
    APPEND PROPERTY SPHINX_BUILD_DEFINITIONS
      $<$<BOOL:${sphinx.github.user}>:github.user=${genexp.github.user}>
      $<$<BOOL:${sphinx.github.repo}>:github.repo=${genexp.github.repo}>)


  set_property(TARGET ${target} PROPERTY SPHINX_CONFIG_DIR "${PROJECT_BINARY_DIR}/sphinx-doc")
  if (${project-name}_BUILD_DOCS)
    foreach (filename IN ITEMS docutils.conf conf.py custom.css)
      set(output "${PROJECT_BINARY_DIR}/sphinx-doc/${filename}")
      configure_file("${NETLIFY_CMAKE_TEMPLATES}/sphinx/${filename}" "${output}" COPYONLY)
      list(APPEND docs-depends "${output}")
    endforeach ()
    if (TARGET docs)
      get_property(build-target TARGET ${target} PROPERTY 🈯::build::target)
      add_dependencies(docs ${build-target})
    endif()
  endif()
endfunction()
