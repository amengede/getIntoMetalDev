#pragma once
#include "../config.h"

/**
 * @brief a camera!
 */
class Camera {
    public:

        /**
         * @brief set the camera's position
         * @param pos position for the camera
         */
        void setPosition(simd::float3 pos);

        /**
         * @brief set the camera's angles
         * @param pitch new pitch (vertical look)
         * @param yaw new yaw (horizontal look)
         */
        void setAngles(float pitch, float yaw);

        /**
         * @brief move the camera
         * @param dPos coefficients to move in the
         *  right, up, forwards directions
         */
        void walk(simd::float3 dPos);

        /**
         * @brief spin the camera
         * @param dPitch change to the camera's pitch
         * @param dYaw change to the camera's yaw
         */
        void spin(float dPitch, float dYaw);

        /**
         * @brief get the camera's view transform
         */
        simd::float4x4 getViewTransform();

    private:

        /**
         * @brief update the camera's frame of reference
         */
        void updateVectors();

        simd::float3 position = {0.0f, 0.0f, 0.0f};
        float pitch = 0.0f, yaw = 0.0f;
        simd::float3 right = {0.0f, -1.0f, 0.0f};
        simd::float3 up = {0.0f, 0.0f, 1.0f};
        simd::float3 forwards = {1.0f, 0.0f, 0.0f};
};
