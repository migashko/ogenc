cmake_minimum_required(VERSION 3.10)
project(ogenc-demo)

include(../cmake/ogenc.cmake)

# 1. Globally: drop the flag from the paranoid set for every target.
#    Meaningful when PARANOID_WARNINGS=ON; call after include(ogenc.cmake).
ogenc_warning(-Wzero-as-null-pointer-constant OFF)

add_executable(demo1 demo1.cpp demo1_target.cpp demo1_tu.cpp)
set_target_properties(demo1 PROPERTIES CXX_STANDARD 11 CXX_EXTENSIONS OFF)

# 2. For the whole target (paranoid only): -Wswitch-enum is removed from every demo1 source.
update_ogenc(
  TARGETS demo1
  WARNINGS -Wswitch-enum
  OFF
)

# 3. For one translation unit (any level): the other demo1 sources
#    are still built with -Wfloat-equal.
update_ogenc(
  SOURCES demo1_tu.cpp
  WARNINGS -Wfloat-equal
  OFF
)

target_ogenc_warnings(demo1)
