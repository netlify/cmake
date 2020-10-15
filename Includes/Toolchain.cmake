list(APPEND CMAKE_MESSAGE_CONTEXT toolchain)

find_program(LLVM_OBJCOPY_EXECUTABLE NAMES llvm-objcopy-10)
find_program(LLVM_OBJDUMP_EXECUTABLE NAMES llvm-objdump-10)
find_program(LLVM_RANLIB_EXECUTABLE NAMES llvm-ranlib-10)
find_program(LLVM_AR_EXECUTABLE NAMES llvm-ar-10)
find_program(LLVM_NM_EXECUTABLE NAMES llvm-nm-10)

#find_program(LLD_LINKER_EXECUTABLE NAMES lld-10)

find_program(SCCACHE_EXECUTABLE NAMES sccache)

find_program(ClangFormat_EXECUTABLE NAMES clang-format-10)
find_program(ClangCheck_EXECUTABLE NAMES clang-check-10)
find_program(ClangTidy_EXECUTABLE NAMES clang-tidy-10)


find_program(CMAKE_CXX_COMPILER clang++-10)
find_program(CMAKE_C_COMPILER clang-10)

if (NOT CMAKE_CXX_COMPILER OR NOT CMAKE_C_COMPILER)
  message(FATAL_ERROR "Netlify's Toolchain requires Clang 10")
endif()

set(CMAKE_SYSTEM_NAME "Linux")

set(CMAKE_VISIBILITY_INLINES_HIDDEN YES)
set(CMAKE_CXX_STANDARD_REQUIRED YES)
set(CMAKE_C_STANDARD_REQUIRED YES)

set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_C_VISIBILITY_PRESET hidden)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_C_STANDARD 11)

if (LLVM_OBJDUMP_EXECUTABLE)
  set(CMAKE_OBJDUMP ${LLVM_OBJDUMP_EXECUTABLE} CACHE FILEPATH "Path to objdump")
endif()

if (LLVM_OBJCOPY_EXECUTABLE)
  set(CMAKE_OBJCOPY ${LLVM_OBJCOPY_EXECUTABLE} CACHE FILEPATH "Path to objcopy")
endif()

if (LLVM_RANLIB_EXECUTABLE)
  set(CMAKE_RANLIB ${LLVM_RANLIB_EXECUTABLE} CACHE FILEPATH "Path to ranlib")
endif()

if (LLVM_AR_EXECUTABLE)
  set(CMAKE_AR ${LLVM_AR_EXECUTABLE} CACHE FILEPATH "Path to ar")
endif()

if (LLVM_NM_EXECUTABLE)
  set(CMAKE_NM ${LLVM_NM_EXECUTABLE} CACHE FILEPATH "Path to nm")
endif()

# TODO: At some point, we need to move to libc++, however, we cannot do that
# until we move off of all C++ libraries built with libstdc++

if (LLD_LINKER_EXECUTABLE)
  set(CMAKE_MODULE_LINKER_FLAGS_INIT -fuse-ld=lld)
  set(CMAKE_SHARED_LINKER_FLAGS_INIT -fuse-ld=lld)
  set(CMAKE_EXE_LINKER_FLAGS_INIT -fuse-ld=lld)
endif()

if (SCCACHE_EXECUTABLE)
  set(CMAKE_CXX_COMPILER_LAUNCHER "${SCCACHE_EXECUTABLE}")
  set(CMAKE_C_COMPILER_LAUNCHER "${SCCACHE_EXECUTABLE}")
endif()

list(POP_BACK CMAKE_MESSAGE_CONTEXT)
