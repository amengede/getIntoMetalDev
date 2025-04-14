#include "app.h"
#include "../backend/glfw_adapter.h"
#include "../backend/mtlm.h"
#include <iostream>

App::App() {
    glfwInit();
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    glfwWindow = glfwCreateWindow(800, 600, "Heavy", NULL, NULL);
    glfwSetInputMode(glfwWindow, GLFW_CURSOR, GLFW_CURSOR_HIDDEN);

    device = MTL::CreateSystemDefaultDevice();

    metalLayer = CA::MetalLayer::layer()->retain();
    metalLayer->setDevice(device);
    metalLayer->setPixelFormat(MTL::PixelFormat::PixelFormatBGRA8Unorm);
    metalLayer->setFramebufferOnly(false);

    window = get_ns_window(glfwWindow, metalLayer)->retain();

    renderer = new Renderer(device, metalLayer);

    camera_x = -10.0f;
    camera_y = 0.0f;
    camera_z = 5.0f;

    camera_yaw = 0.0f;
    camera_pitch = 0.0f;
}

App::~App() {
    window->release();
    delete renderer;
    glfwTerminate();
}

void App::run() {

    double cursor_x, cursor_y;
    float dx, dy;

    while (!glfwWindowShouldClose(glfwWindow)) {
        glfwPollEvents();

        if (glfwGetKey(glfwWindow, GLFW_KEY_W) == GLFW_PRESS) {
            camera_x += 0.1f;
        }

        if (glfwGetKey(glfwWindow, GLFW_KEY_S) == GLFW_PRESS) {
            camera_x -= 0.1f;
        }

        if (glfwGetKey(glfwWindow, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
            glfwSetWindowShouldClose(glfwWindow, GLFW_TRUE);
        }

        glfwGetCursorPos(glfwWindow, &cursor_x, &cursor_y);
        dx = -10.0f * static_cast<float>(cursor_x / 400.0 - 1.0);
        dy = -10.0f * static_cast<float>(cursor_y / 300.0 - 1.0);
        glfwSetCursorPos(glfwWindow, 400.0, 300.0);

        camera_pitch = std::min(89.0f, std::max(-89.0f, camera_pitch + dy));

        camera_yaw = camera_yaw + dx;
        if (camera_yaw < 0.0f) {
            camera_yaw += 360.0f;
        }
        if (camera_yaw > 360.0f) {
            camera_yaw -= 360.0f;
        }

        simd::float3 forwards = {
            cos(camera_yaw * 3.14159f / 180.0f) * cos(camera_pitch * 3.14159f / 180.0f), 
            sin(camera_yaw * 3.14159f / 180.0f) * cos(camera_pitch * 3.14159f / 180.0f), 
            sin(camera_pitch * 3.14159f / 180.0f)};
        
        simd::float3 up = {0.0f, 0.0f, 1.0f};
        simd::float3 right = simd::normalize(simd::cross(forwards, up));
        up = simd::normalize(simd::cross(right, forwards));
        simd::float3 pos = {camera_x, camera_y, camera_z};

        simd::float4x4 view = mtlm::camera_view(right, up, forwards, pos);

        renderer->update(view);
    }
}
