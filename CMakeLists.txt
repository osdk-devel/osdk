cmake_minimum_required(VERSION 3.10)
project(OSDK VERSION 1.0 LANGUAGES C CXX)

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

# --- Custom build targets ---
add_custom_target(generate_clexer DEPENDS ${CLEXER_CPP} ${CLEXER_H})
add_custom_target(generate_cparser DEPENDS ${CPARSER_CPP} ${CPARSER_H})
add_custom_target(generate_all DEPENDS generate_clexer generate_cparser)

# --- Main executable ---
add_executable(osdk
    ${SRC_DIR}/src/main.cpp
    ${CPARSER_CPP}
    ${CLEXER_CPP}
)

# --- Make sure parser and lexer are built first ---
add_dependencies(osdk generate_all)

# --- Include directories ---
target_include_directories(osdk PRIVATE
    ${BIN_DIR}/src/headers    # Generated headers
    ${BIN_DIR}/src
    ${SRC_DIR}/src/headers    # Your own headers
    ${SRC_DIR}/src/include    # Optional include folder
)

# --- Link with Flex library (for yywrap, yylex linkage) ---
# On Linux, this ensures -lfl is linked
target_link_libraries(osdk PRIVATE ${FLEX_LIBRARIES})
if(NOT FLEX_LIBRARIES)
    target_link_libraries(osdk PRIVATE fl)
endif()

# --- Compiler warnings ---
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(osdk PRIVATE -Wall -Wextra -Wno-unused-parameter)
endif()

# --- Define VERSION macro for code ---
target_compile_definitions(osdk PRIVATE VERSION="${CMAKE_PROJECT_VERSION}")

# --- Output binary directory ---
set_target_properties(osdk PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${BIN_DIR}/bin
)

# --- Installation (optional) ---
install(TARGETS osdk DESTINATION bin)

# --- Info ---
message(STATUS "Source directory: ${SRC_DIR}")
message(STATUS "Binary directory: ${BIN_DIR}")
message(STATUS "Flex executable: ${FLEX_EXECUTABLE}")
message(STATUS "Bison executable: ${BISON_EXECUTABLE}")