cmake_minimum_required(VERSION 3.10)
project(ogenc-demo)

include(../cmake/ogenc.cmake)

# 1. Глобально: убрать флаг из набора paranoid для всех таргетов.
#    Имеет смысл при PARANOID_WARNINGS=ON; вызывать после include(ogenc.cmake).
ogenc_warning(-Wzero-as-null-pointer-constant OFF)

add_executable(demo1 demo1.cpp demo1_target.cpp demo1_tu.cpp)
set_target_properties(demo1 PROPERTIES CXX_STANDARD 11 CXX_EXTENSIONS OFF)

# 2–3. Для цели (paranoid) и для единиц трансляции (любой уровень).
#      Одни и те же WARNINGS применяются ко всем TARGETS и SOURCES.
update_ogenc(
  TARGETS demo1
  SOURCES demo1_tu.cpp
  WARNINGS -Wswitch-enum -Wfloat-equal
  OFF
)

target_ogenc_warnings(demo1)
