# --- Custom targets for parser/lexer generation ---
# Note: Variables are inherited from parent CMakeLists.txt
message(STATUS "Lang: CLEXER_CPP = ${CLEXER_CPP}")
message(STATUS "Lang: CPARSER_CPP = ${CPARSER_CPP}")

add_custom_target(generate_clexer DEPENDS ${CLEXER_CPP} ${CLEXER_H})
add_custom_target(generate_cparser DEPENDS ${CPARSER_CPP} ${CPARSER_H})
add_custom_target(generate_all DEPENDS generate_clexer generate_cparser)
