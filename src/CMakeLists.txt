# --- Mark generated sources ---
set_source_files_properties(
    ${CPARSER_CPP}
    ${CLEXER_CPP}
    PROPERTIES GENERATED TRUE
)

# --- Main executable ---
add_executable(sosdk
    ${SRC_DIR}/src/main.cpp
    ${CPARSER_CPP}
    ${CLEXER_CPP}
)

# --- Make sure parser and lexer are built first ---
add_dependencies(sosdk generate_all)

# --- Include directories ---
target_include_directories(sosdk PRIVATE
    ${BIN_DIR}/src/headers    # Generated headers
    ${BIN_DIR}/src
    ${SRC_DIR}/src/headers    # Your own headers
    ${SRC_DIR}/src/include    # Optional include folder
)

# --- Link with Flex library (for yywrap, yylex linkage) ---
# On Linux, this ensures -lfl is linked
target_link_libraries(sosdk PRIVATE ${FLEX_LIBRARIES})
if(NOT FLEX_LIBRARIES)
    target_link_libraries(sosdk PRIVATE fl)
endif()

# --- Compiler warnings ---
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(sosdk PRIVATE -Wall -Wextra -Wno-unused-parameter)
endif()

# --- Define VERSION macro for code ---
target_compile_definitions(sosdk PRIVATE VERSION="${PROJECT_VERSION_FULL}")

# --- Output binary directory ---
set_target_properties(sosdk PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${BIN_DIR}/bin
)
