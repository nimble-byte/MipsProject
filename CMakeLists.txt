cmake_minimum_required(VERSION 3.6)
project(RA_MIPS_Taylor)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES Csrc/main.cpp)
add_executable(RA_MIPS_Taylor ${SOURCE_FILES})