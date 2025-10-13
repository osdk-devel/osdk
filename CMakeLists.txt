cmake_minimum_required(VERSION 3.10)
project(OSDK LANGUAGES CXX)

add_executable(osdk src/main.cpp)
target_include_directories(osdk PRIVATE ${CMAKE_SOURCE_DIR}/src/include)