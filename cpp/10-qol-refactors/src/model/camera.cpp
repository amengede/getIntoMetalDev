#include "camera.h"
#include "../backend/mtlm.h"

void Camera::setPosition(simd::float3 pos) {
    this->position = pos;
}

void Camera::setAngles(float pitch, float yaw) {
    this->pitch = pitch;
    this->yaw = yaw;
    updateVectors();
}

void Camera::walk(simd::float3 dPos) {
    simd::float3 offset = dPos[0] * right
        + dPos[1] * up
        + dPos[2] * forwards;
    
    offset[2] = 0.0f;
    position += offset;
}

void Camera::spin(float dPitch, float dYaw) {
    pitch = std::min(89.0f, std::max(-89.0f, pitch + dPitch));

    yaw += dYaw;
    if (yaw < 0.0f) {
        yaw += 360.0f;
    }
    if (yaw > 360.0f) {
        yaw -= 360.0f;
    }

    updateVectors();
}

simd::float4x4 Camera::getViewTransform() {
    return mtlm::camera_view(right, up, forwards, position);
}

void Camera::updateVectors() {

    float yawRadians = yaw * 3.14159f / 180.0f;
    float pitchRadians = pitch * 3.14159f / 180.0f;
    
    forwards = {
        cos(yawRadians) * cos(pitchRadians), 
        sin(yawRadians) * cos(pitchRadians), 
        sin(pitchRadians)};
        
    simd::float3 tempUp = {0.0f, 0.0f, 1.0f};
    right = simd::normalize(simd::cross(forwards, tempUp));
    up = simd::normalize(simd::cross(right, forwards));
}