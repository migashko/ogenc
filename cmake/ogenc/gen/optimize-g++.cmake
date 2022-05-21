if ( "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" )
  if( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 4.8 OR CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL 4.8 )
    include(${CMAKE_CURRENT_LIST_DIR}/optimize-g++-4.8.cmake)
  endif()
  if( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 5.3 OR CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL 5.3 )
    include(${CMAKE_CURRENT_LIST_DIR}/optimize-g++-5.3.cmake)
  endif()
  if( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 6.2 OR CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL 6.2 )
    include(${CMAKE_CURRENT_LIST_DIR}/optimize-g++-6.2.cmake)
  endif()
  if( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 7.4 OR CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL 7.4 )
    include(${CMAKE_CURRENT_LIST_DIR}/optimize-g++-7.4.cmake)
  endif()
  if( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 7.5 OR CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL 7.5 )
    include(${CMAKE_CURRENT_LIST_DIR}/optimize-g++-7.5.cmake)
  endif()
  if( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 8.2 OR CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL 8.2 )
    include(${CMAKE_CURRENT_LIST_DIR}/optimize-g++-8.2.cmake)
  endif()
  if( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 8.3 OR CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL 8.3 )
    include(${CMAKE_CURRENT_LIST_DIR}/optimize-g++-8.3.cmake)
  endif()
  if( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 9.3 OR CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL 9.3 )
    include(${CMAKE_CURRENT_LIST_DIR}/optimize-g++-9.3.cmake)
  endif()
  if( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 10.2 OR CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL 10.2 )
    include(${CMAKE_CURRENT_LIST_DIR}/optimize-g++-10.2.cmake)
  endif()
  if( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 10.3 OR CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL 10.3 )
    include(${CMAKE_CURRENT_LIST_DIR}/optimize-g++-10.3.cmake)
  endif()
  if( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 11.1 OR CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL 11.1 )
    include(${CMAKE_CURRENT_LIST_DIR}/optimize-g++-11.1.cmake)
  endif()
  if( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 11.2 OR CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL 11.2 )
    include(${CMAKE_CURRENT_LIST_DIR}/optimize-g++-11.2.cmake)
  endif()
  if( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 12.1 OR CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL 12.1 )
    include(${CMAKE_CURRENT_LIST_DIR}/optimize-g++-12.1.cmake)
  endif()
endif()

