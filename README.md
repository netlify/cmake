# Overview

This is the common set of CMake based modules used by all C++ projects at
Netlify. For the most part, these include `FindXXX.cmake` files, but also
support a few specific functions. Some of these will be removed in the future
once Netlify migrates to using IXM for its projects, and this will instead work
as a _Project Blueprint_ for Netlify's internal projects.

## Minimum Supported Platform

These are the only settings where these modules are used.

 * Ubuntu 20.04
 * Clang 10
 * C++2a
 * CMake 3.16

Any other compilers, operating systems, or languages are not guaranteed to be
supported.

# Roadmap

The following features are not yet (fully) implemented, but are currently planned

 * [ ] Better IXM Integration (This is reliant on IXM being released)
 * [x] Custom Toolchain File (To ensure Clang, LLD, libc++, etc.)
 * [ ] Profile Guidance Code Generation
 * [x] Sanitizer Support

# Usage

This project is intended to be acquired via [FetchContent][1]. Thus, the
following code should go at the top of every project's root `CMakeLists.txt`
file.

```cmake
cmake_minimum_required(VERSION 3.16)
include(FetchContent)
FetchContent_Declare(cmake GIT_REPOSITORY https://github.com/netlify/cmake)
FetchContent_MakeAvailable(cmake)
```

This will pull in the Netlify CMake Library, set several internal values,
prepare various properties, etc.

If using additional CMake libraries via `FetchContent`, simply declare more
of them before calling `FetchContent_MakeAvailable`.

## Projects

Most projects will do the following

```cmake
cmake_minimum_required(VERSION 3.16)
include(FetchContent)
FetchContent_Declare(cmake GIT_REPOSITORY https://github.com/netlify/cmake)
FetchContent_MakeAvailable(cmake)
set(CMAKE_PROJECT_INCLUDE ${NETLIFY_PROJECT_PRELUDE})
project(<project-name-here> LANGUAGES CXX)
```

This will attempt to set and find the most common flags and variables for
our given target.

# Behavior

Netlify's CMake modules perform the following operations when first included.
This is done to ensure that we have a guaranteed behavior across all of our
projects. However, this might disrupt others workflows. The changes these
modules do are mentioned below:

 * CTest is included, but the CDash related targets are _disabled_.
 * `CMAKE_EXPORT_COMPILE_COMMANDS` is set to `YES`.
 * `CMAKE_POLICY_DEFAULT_CMP0077` is set to `NEW`.
 * In-Source builds are _disabled_ with a hard error
 * The `Catch2` Unit Testing library is declared.
 * Color diagnostics are enabled _by default_.
 * `-Og` and `-ggdb` are enabled _by default_ for Debug based builds.

[1]: https://cmake.org/cmake/help/latest/module/FetchContent.html
