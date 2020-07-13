include(FindPackageHandleStandardArgs)

find_library(Brotli_Encode_LIBRARY NAMES brotlienc)
find_library(Brotli_Decode_LIBRARY NAMES brotlidec)
find_library(Brotli_LIBRARY NAMES brotlicommon)
find_path(Brotli_INCLUDE_DIR NAMES brotli/decode.h)

if (Brotli_Decode_LIBRARY)
  set(Brotli_Decode_FOUND YES)
endif()

if (Brotli_Encode_LIBRARY)
  set(Brotli_Encode_FOUND YES)
endif()

find_package_handle_standard_args(Brotli
  REQUIRED_VARS Brotli_LIBRARY Brotli_INCLUDE_DIR
  HANDLE_COMPONENTS)

if (Brotli_FOUND AND NOT TARGET Brotli::Brotli)
  add_library(Brotli::Brotli IMPORTED UNKNOWN)
  target_include_directories(Brotli::Brotli INTERFACE ${Brotli_INCLUDE_DIR})
  set_property(TARGET Brotli::Brotli PROPERTY IMPORTED_LOCATION ${Brotli_LIBRARY})
  mark_as_advanced(Brotli_LIBRARY Brotli_INCLUDE_DIR)
endif()

if (Brotli_Decode_FOUND AND NOT TARGET Brotli::Decode)
  add_library(Brotli::Decode IMPORTED UNKNOWN)
  target_link_libraries(Brotli::Decode INTERFACE Brotli::Brotli)
  set_property(TARGET Brotli::Decode PROPERTY IMPORTED_LOCATION ${Brotli_Decode_LIBRARY})
  mark_as_advanced(Brotli_Decode_LIBRARY)
endif()

if (Brotli_Encode_FOUND AND NOT TARGET Brotli::Encode)
  add_library(Brotli::Encode IMPORTED UNKNOWN)
  target_link_libraries(Brotli::Encode INTERFACE Brotli::Brotli)
  set_property(TARGET Brotli::Encode PROPERTY IMPORTED_LOCATION ${Brotli_Encode_LIBRARY})
  mark_as_advanced(Brotli_Encode_LIBRARY)
endif()
