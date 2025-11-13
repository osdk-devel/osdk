cmake_minimum_required(VERSION 3.10)
project(sosdk VERSION 1.0.0 LANGUAGES C CXX)

# Set alpha version as a variable for use in the code
set(PROJECT_VERSION_FULL "${CMAKE_PROJECT_VERSION}-alpha1")
set(PROJECT_VERSION_SUFFIX "alpha1")

# --- Compiler standards ---
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# --- Required packages ---
find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

# --- Directory setup ---
set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(LANG_DIR ${SRC_DIR}/lang)
set(BIN_DIR ${CMAKE_CURRENT_BINARY_DIR})

# --- Output directories ---
file(MAKE_DIRECTORY ${BIN_DIR}/src)
file(MAKE_DIRECTORY ${BIN_DIR}/src/headers)

# --- Input files ---
set(CLEXER_L ${LANG_DIR}/clexer.l)
set(CPARSER_Y ${LANG_DIR}/cparser.y)

# --- Generated output files ---
set(CLEXER_CPP ${BIN_DIR}/src/clexer.cpp)
set(CLEXER_H   ${BIN_DIR}/src/headers/clexer.h)
set(CPARSER_CPP ${BIN_DIR}/src/cparser.cpp)
set(CPARSER_H   ${BIN_DIR}/src/headers/cparser.h)

# --- Generate lexer (Flex) ---
add_custom_command(
    OUTPUT ${CLEXER_CPP} ${CLEXER_H}
    COMMAND ${FLEX_EXECUTABLE}
            --outfile=${CLEXER_CPP}
            --header-file=${CLEXER_H}
            ${CLEXER_L}
    DEPENDS ${CLEXER_L}
    COMMENT "Generating clexer from ${CLEXER_L}"
    VERBATIM
)

# --- Generate parser (Bison) ---
add_custom_command(
    OUTPUT ${CPARSER_CPP} ${CPARSER_H}
    COMMAND ${BISON_EXECUTABLE}
            --output=${CPARSER_CPP}
            --defines=${CPARSER_H}
            ${CPARSER_Y}
    DEPENDS ${CPARSER_Y}
    COMMENT "Generating cparser from ${CPARSER_Y}"
    VERBATIM
)

# --- Mark generated files as GENERATED ---
set_source_files_properties(
    ${CLEXER_CPP} ${CLEXER_H}
    ${CPARSER_CPP} ${CPARSER_H}
    PROPERTIES GENERATED TRUE
)

# --- Custom targets for parser/lexer generation ---
add_custom_target(generate_clexer DEPENDS ${CLEXER_CPP} ${CLEXER_H})
add_custom_target(generate_cparser DEPENDS ${CPARSER_CPP} ${CPARSER_H})
add_custom_target(generate_all DEPENDS generate_clexer generate_cparser)

# --- Add subdirectories ---
add_subdirectory(src)

# --- Installation (optional) ---
install(TARGETS sosdk DESTINATION bin)

# --- Info ---
message(STATUS "Source directory: ${SRC_DIR}")
message(STATUS "Binary directory: ${BIN_DIR}")
message(STATUS "Flex executable: ${FLEX_EXECUTABLE}")
message(STATUS "Bison executable: ${BISON_EXECUTABLE}")
message(STATUS "OSDK Version: ${PROJECT_VERSION_FULL}")