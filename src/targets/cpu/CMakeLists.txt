
# CheckCXXLinkerFlag.cmake

include(CheckCXXCompilerFlag)

add_library(migraphx_cpu
    allocate.cpp
    allocation_model.cpp
    binary.cpp
    concat.cpp
    convolution.cpp
    copy.cpp
    deconvolution.cpp
    dnnl.cpp
    eltwise.cpp
    erf.cpp
    fmod.cpp
    fuse_ops.cpp
    gather.cpp
    gemm.cpp
    layernorm.cpp
    logsoftmax.cpp
    lowering.cpp
    lrn.cpp
    mod.cpp
    preallocate.cpp
    pooling.cpp
    reduction.cpp
    reorder.cpp
    softmax.cpp
    sub.cpp
    target.cpp
    write_literals.cpp
)
set_target_properties(migraphx_cpu PROPERTIES EXPORT_NAME cpu)

find_package(dnnl REQUIRED)

target_link_libraries(migraphx_cpu PRIVATE DNNL::dnnl)

target_link_libraries(migraphx_cpu PRIVATE migraphx)

migraphx_generate_export_header(migraphx_cpu)

find_package(OpenMP)
target_link_libraries(migraphx_cpu PUBLIC OpenMP::OpenMP_CXX)

# Add library path to rpath to workaround issues with our broken packages
foreach(LIBRARY ${OpenMP_CXX_LIBRARIES})
    if(LIBRARY MATCHES "libomp")
        get_filename_component(LIBRARY_PATH "${LIBRARY}" PATH)
        target_link_libraries(migraphx_cpu PUBLIC -Wl,-rpath=${LIBRARY_PATH} -Wl,-rpath-link=${LIBRARY_PATH})
    endif()
endforeach()

install(
  TARGETS migraphx_cpu
  INCLUDE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
