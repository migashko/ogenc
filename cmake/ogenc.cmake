#
# Автор: Vladimir Migashko <migashko@gmail.com>, (C) 2021-2026
#
# SPDX-License-Identifier: MIT
#
# https://github.com/migashko/ogenc
# 

macro(ogenc_env OPT_NAME TEXT VALUE )
  if (DEFINED ENV{${OPT_NAME}} AND NOT DEFINED ${OPT_NAME})
    set(${OPT_NAME} $ENV{${OPT_NAME}} CACHE STRING "${TEXT}" FORCE)
  else()
    option(${OPT_NAME} "${TEXT}" ${VALUE})
  endif()
endmacro()

ogenc_env(EXTRA_WARNINGS "Уровень Extra (-Wextra -Wpedantic …)" ON)
ogenc_env(DISABLE_WARNINGS "Отключить предупреждения ogenc (игнорирует EXTRA_WARNINGS и PARANOID_WARNINGS)" OFF)
ogenc_env(PARANOID_WARNINGS "Параноидальный уровень предупреждений" OFF)
ogenc_env(OGENC_WARNINGS "Синоним PARANOID_WARNINGS" OFF)
ogenc_env(OGENC_OPTIMIZE "Подключить каталог флагов оптимизации ogenc" OFF)
ogenc_env(OGENC_WERROR "Трактовать предупреждения как ошибки (-Werror)" ON)
ogenc_env(APOCALYPTIC_WARNINGS "Включить PARANOID_WARNINGS (в т.ч. для зависимостей, через обёртку add_subdirectory)" OFF)

if (APOCALYPTIC_WARNINGS)
  set(PARANOID_WARNINGS ON)
endif()

if ( PARANOID_WARNINGS OR OGENC_WARNINGS )
  set(PARANOID_WARNINGS ON)
  set(OGENC_WARNINGS ON)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/ogenc/ogenc-option.cmake)

if ( PARANOID_WARNINGS )
  include(${CMAKE_CURRENT_LIST_DIR}/ogenc/gen/warnings-g++.cmake)
  include(${CMAKE_CURRENT_LIST_DIR}/ogenc/gen/warnings-clang++.cmake)
  if ( EXISTS "${CMAKE_CURRENT_LIST_DIR}/ogenc/gen/warnings-apple-clang++.cmake" )
    include(${CMAKE_CURRENT_LIST_DIR}/ogenc/gen/warnings-apple-clang++.cmake)
  endif()
endif()

if ( OGENC_OPTIMIZE )
  include(${CMAKE_CURRENT_LIST_DIR}/ogenc/gen/optimize-g++.cmake)
  include(${CMAKE_CURRENT_LIST_DIR}/ogenc/gen/optimize-clang++.cmake)
  if ( EXISTS "${CMAKE_CURRENT_LIST_DIR}/ogenc/gen/optimize-apple-clang++.cmake" )
    include(${CMAKE_CURRENT_LIST_DIR}/ogenc/gen/optimize-apple-clang++.cmake)
  endif()
endif()

function(target_ogenc_warnings target)  
  if ( NOT DISABLE_WARNINGS )
    if ( OGENC_WERROR )
      target_compile_options(${target} PRIVATE -Werror)
    endif()
    target_compile_options(${target} PRIVATE -Wall)
    if ( EXTRA_WARNINGS OR PARANOID_WARNINGS)
      target_compile_options(${target} PRIVATE -Wextra -Wpedantic -Wformat -pedantic-errors)
      if ( PARANOID_WARNINGS )
        if ( DEFINED ${target}_warning_options )
          target_compile_options(${target} PRIVATE ${${target}_warning_options} )
        else()
          target_compile_options(${target} PRIVATE ${ogenc_warning_options} )
        endif()
      endif()
    endif()
  endif()
endfunction()

function(target_ogenc_optimize target)
  if ( OGENC_OPTIMIZE )
    target_compile_options(${target} PRIVATE ${ogenc_optimize_options} )
  endif()
endfunction()
