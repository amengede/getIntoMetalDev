#pragma once
#include "../config.h"
#include "../view/renderer.h"

class App {
    public:
        App();
        ~App();

        void run();

    private:
        GLFWwindow* glfwWindow;
        MTL::Device* device;
        CA::MetalLayer* metalLayer;
        NS::Window* window;
        Renderer* renderer;
};
