cmake_minimum_required(VERSION 2.8)
project(vsomeip-fuzzing)

set(CMAKE_CXX_COMPILER "/usr/bin/g++")

option(USE_GCC "Set gcc compiler support for AFL coverage report generation" OFF)
option(COVERAGE "Set gcc compiler flags for AFL coverage report generation" OFF)

if (USE_GCC)
  message("-- Enable gcc compiler support for AFL coverage reports")
  add_definitions(-DCOMPILE_WITH_GCC)
endif()

if (COVERAGE)
  message("-- Set gcc compiler flags for AFL coverage reports")
  set(GCC_COVERAGE_COMPILE_FLAGS "-fprofile-arcs -ftest-coverage")
  set(GCC_COVERAGE_LINK_FLAGS "-lgcov")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${GCC_COVERAGE_COMPILE_FLAGS}")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${GCC_COVERAGE_LINK_FLAGS}")
endif()


set(Boost_INCLUDE_DIR "/usr/include")
set(Boost_LIBRARY_DIR "/usr/lib/x86_64-linux-gnu")

find_package(vsomeip3 3.1.14 REQUIRED)
find_package(Boost 1.74.0 COMPONENTS system thread log REQUIRED)

include_directories(
  ${VSOMEIP_INCLUDE_DIRS}
  ${Boost_INCLUDE_DIR}
  /vsomeip/implementation
)

add_executable(
  fuzzing
  fuzzing.cpp
  /vsomeip/implementation/configuration/src/configuration_impl.cpp
  /vsomeip/implementation/plugin/src/plugin_manager_impl.cpp
)

target_link_libraries(fuzzing vsomeip3 dl ${Boost_LIBRARIES})
