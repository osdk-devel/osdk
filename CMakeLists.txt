cmake_minimum_required(VERSION 3.10)
project(OSDK LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Find required tools
find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

# Directory setup
set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(LANG_DIR ${SRC_DIR}/lang)
set(BIN_DIR ${CMAKE_CURRENT_BINARY_DIR})

# Create output directories
file(MAKE_DIRECTORY ${BIN_DIR}/src)
file(MAKE_DIRECTORY ${BIN_DIR}/src/headers)

# CLEXER (Lexer)
set(CLEXER_L ${LANG_DIR}/clexer.l)
set(CLEXER_C ${BIN_DIR}/src/clexer.c)
set(CLEXER_H ${BIN_DIR}/src/headers/clexer.h)

# CPARSER (Parser - Bison)
set(CPARSER_Y ${LANG_DIR}/cparser.y)
set(CPARSER_C ${BIN_DIR}/src/cparser.c)
set(CPARSER_H ${BIN_DIR}/src/headers/cparser.h)

# Alternative: if your files are named differently
# set(CLEXER_L ${LANG_DIR}/lexer.l)
# set(CPARSER_Y ${LANG_DIR}/parser.y)

# Generate lexer
add_custom_command(
    OUTPUT ${CLEXER_C} ${CLEXER_H}
    COMMAND ${FLEX_EXECUTABLE}
            --outfile=${CLEXER_C}
            --header-file=${CLEXER_H}
            ${CLEXER_L}
    DEPENDS ${CLEXER_L}
    WORKING_DIRECTORY ${SRC_DIR}
    COMMENT "Generating clexer from ${CLEXER_L}"
    VERBATIM
)

# Generate parser with Bison
add_custom_command(
    OUTPUT ${CPARSER_C} ${CPARSER_H}
    COMMAND ${BISON_EXECUTABLE}
            --output=${CPARSER_C}
            --defines=${CPARSER_H}
            ${CPARSER_Y}
    DEPENDS ${CPARSER_Y}
    WORKING_DIRECTORY ${SRC_DIR}
    COMMENT "Generating cparser from ${CPARSER_Y}"
    VERBATIM
)

# Custom targets for generation
add_custom_target(generate_clexer DEPENDS ${CLEXER_C} ${CLEXER_H})
add_custom_target(generate_cparser DEPENDS ${CPARSER_C} ${CPARSER_H})
add_custom_target(generate_all DEPENDS generate_clexer generate_cparser)

# Main executable
add_executable(osdk
    ${SRC_DIR}/src/main.cpp
    ${CLEXER_C}
    ${CPARSER_C}
)

# Add dependencies
add_dependencies(osdk generate_all)

# Include directories
target_include_directories(osdk PRIVATE
    ${CMAKE_SOURCE_DIR}/src/include
    ${BIN_DIR}/src/headers          # Generated headers location
    ${BIN_DIR}/src                  # Alternative include path
    ${SRC_DIR}/src/headers          # Your source headers
)

# Link against Flex library if needed
target_link_libraries(osdk PRIVATE ${FLEX_LIBRARIES})

# Compiler flags
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(osdk PRIVATE -Wall -Wextra)
endif()

# Set output directory
set_target_properties(osdk PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${BIN_DIR}/bin
)

# Install target (optional)
install(TARGETS osdk DESTINATION bin)

# Print configuration info
message(STATUS "Source directory: ${SRC_DIR}")
message(STATUS "Binary directory: ${BIN_DIR}")
message(STATUS "Flex executable: ${FLEX_EXECUTABLE}")
message(STATUS "Bison executable: ${BISON_EXECUTABLE}")