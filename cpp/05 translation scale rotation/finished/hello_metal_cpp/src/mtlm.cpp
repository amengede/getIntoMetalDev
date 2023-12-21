//
//  mtlm.cpp
//  hello_metal_cpp
//
//  Created by Andrew Mengede on 21/12/2023.
//

#include "mtlm.h"
#include <math.h>

simd::float4x4 mtlm::identity() {
    simd_float4 col0 = {1.0f, 0.0f, 0.0f, 0.0f};
    simd_float4 col1 = {0.0f, 1.0f, 0.0f, 0.0f};
    simd_float4 col2 = {0.0f, 0.0f, 1.0f, 0.0f};
    simd_float4 col3 = {0.0f, 0.0f, 0.0f, 1.0f};
    return simd_matrix(col0, col1, col2, col3);
}

simd::float4x4 mtlm::translation(simd::float3 dPos) {
    simd_float4 col0 = {1.0f, 0.0f, 0.0f, 0.0f};
    simd_float4 col1 = {0.0f, 1.0f, 0.0f, 0.0f};
    simd_float4 col2 = {0.0f, 0.0f, 1.0f, 0.0f};
    simd_float4 col3 = {dPos[0], dPos[1], dPos[2], 1.0f};
    return simd_matrix(col0, col1, col2, col3);
}

simd::float4x4 mtlm::z_rotation(float theta) {
    theta = theta * M_PI / 180.0f;
    float c = cosf(theta);
    float s = sinf(theta);
    simd_float4 col0 = {   c,    s, 0.0f, 0.0f};
    simd_float4 col1 = {  -s,    c, 0.0f, 0.0f};
    simd_float4 col2 = {0.0f, 0.0f, 1.0f, 0.0f};
    simd_float4 col3 = {0.0f, 0.0f, 0.0f, 1.0f};
    return simd_matrix(col0, col1, col2, col3);
}

simd::float4x4 mtlm::scale(float factor) {
    simd_float4 col0 = {factor,   0.0f,   0.0f, 0.0f};
    simd_float4 col1 = {  0.0f, factor,   0.0f, 0.0f};
    simd_float4 col2 = {  0.0f,   0.0f, factor, 0.0f};
    simd_float4 col3 = {  0.0f,   0.0f,   0.0f, 1.0f};
    return simd_matrix(col0, col1, col2, col3);
}
