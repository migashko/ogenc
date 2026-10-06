function(ogenc_option target specific wname)
  if ( ARGC GREATER 4 )
    set(wopt ${ARGV4})
  elseif( ARGC GREATER 3 )
    set(wopt ${ARGV3})
  else()
    set(wopt ON)
  endif()

  set(opt_list "${target}_${specific}_options")

  if ( NOT "${target}" STREQUAL "ogenc" )
    if ( NOT DEFINED ${opt_list} )
      set(${opt_list} ${ogenc_${specific}_options})
    endif()
  endif()

  message(STATUS "OGENC ${specific} ${wname} для ${target}: ${wopt}" )

  if ( ${wopt} )
    list(APPEND ${opt_list} ${wname})
  elseif ( DEFINED ${opt_list} )
    list(REMOVE_ITEM ${opt_list} ${wname})
  endif()

  if ( DEFINED ${opt_list} AND NOT "${${opt_list}}" STREQUAL "" )
    list(SORT ${opt_list})
    list(REMOVE_DUPLICATES ${opt_list})
  endif()

  set(${opt_list} ${${opt_list}} PARENT_SCOPE)
  set(ogenc_option_return ${opt_list} PARENT_SCOPE)
endfunction()

macro(ogenc_warning wname)
  ogenc_option(ogenc "warning" ${wname} ${ARGN} )
endmacro()

macro(ogenc_optimize wname)
  ogenc_option(ogenc "optimize" ${wname} ${ARGN} )
endmacro()

function(update_ogenc)
  cmake_parse_arguments(args
    "ON;OFF;"
    ""
    "TARGETS;SOURCES;WARNINGS;OPTIMIZE;"
    ${ARGN}
  )

  set(value ON)

  if (args_ON AND args_OFF )
    message(FATAL_ERROR "Нельзя указывать ON и OFF одновременно")
  endif()

  if (args_OFF)
    set(value OFF)
  endif()

  # Списки таргета собираются только в paranoid; SOURCES — всегда (-Wno- нужен и на Extra).
  if ( PARANOID_WARNINGS )
    foreach(target ${args_TARGETS})
      foreach(opt ${args_WARNINGS})
        ogenc_option( ${target} "warning" ${opt} ${value} )
      endforeach()
      set(${ogenc_option_return} ${${ogenc_option_return}} PARENT_SCOPE)
      foreach(opt ${args_OPTIMIZE})
        ogenc_option( ${target} "optimize" ${opt} ${value} )
      endforeach()
      set(${ogenc_option_return} ${${ogenc_option_return}} PARENT_SCOPE)
    endforeach()
  endif()

  foreach(src ${args_SOURCES})
    if ( NOT IS_ABSOLUTE "${src}" )
      set(src "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
    endif()
    foreach(opt ${args_WARNINGS})
      if ( value )
        set(flag ${opt})
      else()
        string(REGEX REPLACE "^-W" "-Wno-" flag "${opt}")
      endif()
      set_property(SOURCE "${src}" APPEND PROPERTY COMPILE_OPTIONS "${flag}")
    endforeach()
  endforeach()
endfunction()
