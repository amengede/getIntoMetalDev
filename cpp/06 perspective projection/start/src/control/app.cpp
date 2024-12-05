#include "app.h"
#include "../backend/glfw_adapter.h"

App::App() {
    glfwInit();
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    glfwWindow = glfwCreateWindow(800, 600, "Heavy", NULL, NULL);

    device = MTL::CreateSystemDefaultDevice();

    metalLayer = CA::MetalLayer::layer()->retain();
    metalLayer->setDevice(device);
    metalLayer->setPixelFormat(MTL::PixelFormat::PixelFormatBGRA8Unorm);

    window = get_ns_window(glfwWindow, metalLayer)->retain();

    renderer = new Renderer(device, metalLayer);
}

App::~App() {
    window->release();
    delete renderer;
    glfwTerminate();
}

void App::run() {

    while (!glfwWindowShouldClose(glfwWindow)) {
        glfwPollEvents();

        renderer->update();
    }
}
