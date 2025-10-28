#pragma once
#include <simd/simd.h>

/**
 * @brief Metal Maths library
 */
namespace mtlm {

    /**
     * @returns a 4x4 identity matrix
     */
    simd::float4x4 identity();

    /**
     * @brief Make a translation transform
     * @param dPos translation vector
     * @return 4x4 transform matrix
     */
    simd::float4x4 translation(simd::float3 dPos);

    /**
     * @brief Make a rotation around the z axis
     * @param theta angle (in degrees)
     * @return 4x4 transform matrix
     */
    simd::float4x4 z_rotation(float theta);

    /**
     * @brief Make a 4x4 scale transform matrix
     * @param factor scale factor
     * @return 4x4 transform matrix
     */
    simd::float4x4 scale(float factor);

    /**
     * @brief Make a perpspective projection
     * @param fovy field of view angle (in degrees)
     * @param aspect aspect ratio (w/h)
     * @param near near clipping distance
     * @param far far clipping distance
     * @return 4x4 transform matrix
     */
    simd::float4x4 perspective_projection(
        float fovy, float aspect, float near, float far);

    /**
     * @brief Make a view transform
     * @param right camera's right vector
     * @param up camera's up vector
     * @param forwards camera's forwards vector
     * @param pos camera's position
     * @return 4x4 transform matrix
     */
    simd::float4x4 camera_view(
        simd::float3 right, simd::float3 up,
        simd::float3 forwards, simd::float3 pos);
}
