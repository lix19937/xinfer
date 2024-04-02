
cmake_minimum_required(VERSION 3.15 FATAL_ERROR)

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR "The binary and source directroy cannot be the same")
endif()

# Setup valid strings for build type
if (NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_CONFIGURATION_TYPES "Debug;Release;RelWithDebInfo;MinSizeRel" CACHE STRING "Configs")
endif()

get_property(MIGRAPHX_GENERATOR_IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
# This has to be initialized before the project() command appears
# Set the default of CMAKE_BUILD_TYPE to be release, unless user specifies with -D.  MSVC_IDE does not use CMAKE_BUILD_TYPE
if(NOT MIGRAPHX_GENERATOR_IS_MULTI_CONFIG)
    set(CMAKE_BUILD_TYPE Release CACHE STRING
        "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel.")
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${CMAKE_CONFIGURATION_TYPES})
endif()

set(CMAKE_INSTALL_PREFIX "/opt/rocm" CACHE PATH "")

set(CMAKE_BUILD_RPATH "${CMAKE_BINARY_DIR}/lib")

project(migraphx LANGUAGES C CXX)

# from gf
include(CTest)

find_package(Threads REQUIRED)

option(MIGRAPHX_ENABLE_PYTHON "Enable python bindings" OFF)

find_path(HALF_INCLUDE_DIR half.hpp PATH_SUFFIXES half)
if (NOT HALF_INCLUDE_DIR)
    message(FATAL_ERROR "Could not find half.hpp - Please check that the install path of half.hpp has been added to CMAKE_PREFIX_PATH")
else()
	message(STATUS "half.hpp is at ${HALF_INCLUDE_DIR}")
endif()

# from gf
include(CheckTypeSize)

set(CMAKE_REQUIRED_INCLUDES ${HALF_INCLUDE_DIR})
set(CMAKE_EXTRA_INCLUDE_FILES half.hpp)
check_type_size("half_float::detail::expr" HALF_EXPR LANGUAGE CXX)

set(CMAKE_REQUIRED_INCLUDES)
set(CMAKE_EXTRA_INCLUDE_FILES)


option(BUILD_DEV "Build for development purpose only" OFF)

#

set(MIGRAPHX_SO_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR})

option( BUILD_SHARED_LIBS "Build as a shared library" ON )

include(CheckCXXCompilerFlag)

check_cxx_compiler_flag("--cuda-host-only -x hip" HAS_HIP)
if(HAS_HIP)
    message(STATUS "Enable gpu backend")
    set(MIGRAPHX_ENABLE_GPU On CACHE BOOL "")
else()
    set(MIGRAPHX_ENABLE_GPU Off CACHE BOOL "")
endif()

# Disable cpu backend by default    CPU: intel  support  
set(MIGRAPHX_ENABLE_CPU Off CACHE BOOL "")

# Disable fpga backend by default
set(MIGRAPHX_ENABLE_FPGA Off CACHE BOOL "")

set(CMAKE_CXX_STANDARD_DEFAULT "")
add_compile_options($<$<COMPILE_LANGUAGE:CXX>:-std=c++17>)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(EnableCompilerWarnings)


if(CMAKE_CXX_COMPILER MATCHES ".*clang\\+\\+")
    set(MIGRAPHX_TIDY_ERRORS ERRORS * -readability-inconsistent-declaration-parameter-name)
# Enable tidy on hip
elseif(MIGRAPHX_ENABLE_GPU)
    set(MIGRAPHX_TIDY_ERRORS ALL)
endif()


set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
add_subdirectory(src)

add_subdirectory(test)

add_subdirectory(tools)
