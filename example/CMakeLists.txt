cmake_minimum_required(VERSION 3.10)
project(ogenc-demo)

include(../cmake/ogenc.cmake)

add_executable(demo1 demo1.cpp)
set_target_properties(demo1 PROPERTIES CXX_STANDARD 11 CXX_EXTENSIONS OFF)
target_ogenc_warnings(demo1)
