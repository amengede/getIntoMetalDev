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

    camera = new Camera();
    camera->setPosition({-10.0f, 0.0f, 5.0f});
    camera->setAngles(0.0f, 0.0f);
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

        simd::float3 dPos = {0.0f, 0.0f, 0.0f};

        if (glfwGetKey(glfwWindow, GLFW_KEY_W) == GLFW_PRESS) {
            dPos[2] += 0.1f;
        }

        if (glfwGetKey(glfwWindow, GLFW_KEY_S) == GLFW_PRESS) {
            dPos[2] -= 0.1f;
        }

        if (glfwGetKey(glfwWindow, GLFW_KEY_A) == GLFW_PRESS) {
            dPos[0] -= 0.1f;
        }

        if (glfwGetKey(glfwWindow, GLFW_KEY_D) == GLFW_PRESS) {
            dPos[0] += 0.1f;
        }

        if (glfwGetKey(glfwWindow, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
            glfwSetWindowShouldClose(glfwWindow, GLFW_TRUE);
        }

        camera->walk(dPos);

        glfwGetCursorPos(glfwWindow, &cursor_x, &cursor_y);
        dx = -10.0f * static_cast<float>(cursor_x / 400.0 - 1.0);
        dy = -10.0f * static_cast<float>(cursor_y / 300.0 - 1.0);
        glfwSetCursorPos(glfwWindow, 400.0, 300.0);

        camera->spin(dy, dx);

        renderer->update(camera->getViewTransform());
    }
}
