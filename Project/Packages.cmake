#[[ This file holds all calls related to finding packages, dependencies, etc.]]

set(THREADS_PREFER_PTHREAD_FLAG YES)

message(DEBUG "Searching for Sanitizers")
find_package(UndefinedBehaviorSanitizer)
find_package(AddressSanitizer)
find_package(MemorySanitizer)
find_package(ThreadSanitizer)
find_package(SafeStack)

message(DEBUG "Searching for Dependencies")
find_package(Coverage COMPONENTS LLVM QUIET) # TODO: Enable this
find_package(Threads REQUIRED)

message(DEBUG "Searching for Development Tools")
find_package(Sphinx COMPONENTS Build)
find_package(ClangFormat)
find_package(ClangCheck)
find_package(ClangTidy)
find_package(SCCache)

set_package_properties(Threads PROPERTIES DESCRIPTION "System Threading Library")

set_package_properties(UndefinedBehaviorSanitizer PROPERTIES TYPE Sanitizers)
set_package_properties(AddressSanitizer PROPERTIES TYPE Sanitizers)
set_package_properties(ThreadSanitizer PROPERTIES TYPE Sanitizers)
set_package_properties(MemorySanitizer PROPERTIES TYPE Sanitizers)
set_package_properties(SafeStack PROPERTIES TYPE Sanitizers)

set_package_properties(Coverage PROPERTIES TYPE Development)

set_package_properties(ClangFormat PROPERTIES TYPE Tool)
set_package_properties(ClangCheck PROPERTIES TYPE Tool)
set_package_properties(ClangTidy PROPERTIES TYPE Tool)
set_package_properties(SCCache PROPERTIES TYPE Tool)
set_package_properties(Sphinx PROPERTIES TYPE Tool)
