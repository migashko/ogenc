cmake_minimum_required(VERSION 3.10)
project(ogenc-demo)

include(../cmake/ogenc.cmake)

# 1. Глобально: убрать флаг из набора paranoid для всех таргетов.
#    Имеет смысл при PARANOID_WARNINGS=ON; вызывать после include(ogenc.cmake).
ogenc_warning(-Wzero-as-null-pointer-constant OFF)

add_executable(demo1 demo1.cpp demo1_target.cpp demo1_tu.cpp)
set_target_properties(demo1 PROPERTIES CXX_STANDARD 11 CXX_EXTENSIONS OFF)

# 2. Для цели: копия глобального списка минус указанные флаги.
#    Работает только при PARANOID_WARNINGS=ON; до target_ogenc_warnings.
update_ogenc(
  TARGETS demo1
  WARNINGS -Wswitch-enum
  OFF
)

target_ogenc_warnings(demo1)

# 3. Для единицы трансляции: обычный CMake, ogenc отдельного API не даёт.
set_source_files_properties(demo1_tu.cpp PROPERTIES
  COMPILE_OPTIONS -Wno-float-equal
)
