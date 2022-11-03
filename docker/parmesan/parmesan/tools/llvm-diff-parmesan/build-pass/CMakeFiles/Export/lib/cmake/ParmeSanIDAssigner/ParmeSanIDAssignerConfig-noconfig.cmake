#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "ParmeSanIDAssigner::LLVMIDAssigner" for configuration ""
set_property(TARGET ParmeSanIDAssigner::LLVMIDAssigner APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(ParmeSanIDAssigner::LLVMIDAssigner PROPERTIES
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libLLVMIDAssigner.so.7"
  IMPORTED_SONAME_NOCONFIG "libLLVMIDAssigner.so.7"
  )

list(APPEND _IMPORT_CHECK_TARGETS ParmeSanIDAssigner::LLVMIDAssigner )
list(APPEND _IMPORT_CHECK_FILES_FOR_ParmeSanIDAssigner::LLVMIDAssigner "${_IMPORT_PREFIX}/lib/libLLVMIDAssigner.so.7" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
