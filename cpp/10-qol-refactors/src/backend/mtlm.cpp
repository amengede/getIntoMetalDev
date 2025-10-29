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

simd::float4x4 mtlm::perspective_projection(
    float fovy, float aspect, float near, float far) {

    fovy = fovy * 3.14159f / 360.0f;

    float A = 1.0f / (tanf(fovy) * aspect);
    float B = 1.0f / (tanf(fovy));
    float C = far / (far - near);
    float D = -near * far / (far - near);

    simd_float4 col0 = {    A, 0.0f, 0.0f, 0.0f};
    simd_float4 col1 = { 0.0f,    B, 0.0f, 0.0f};
    simd_float4 col2 = { 0.0f, 0.0f,    C, 1.0f};
    simd_float4 col3 = { 0.0f, 0.0f,    D, 0.0f};
    return simd_matrix(col0, col1, col2, col3);
}

simd::float4x4 mtlm::camera_view(
    simd::float3 right, simd::float3 up,
    simd::float3 forwards, simd::float3 pos) {


    simd_float4 col0 = {right[0], up[0], forwards[0], 0.0f};
    simd_float4 col1 = {right[1], up[1], forwards[1], 0.0f};
    simd_float4 col2 = {right[2], up[2], forwards[2], 0.0f};
    simd_float4 col3 = {
        -simd::dot(right, pos),
        -simd::dot(up, pos),
        -simd::dot(forwards, pos), 1.0f};
    return simd_matrix(col0, col1, col2, col3);
}