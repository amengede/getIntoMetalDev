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

        float camera_x, camera_y, camera_z;
        float camera_pitch, camera_yaw;
};
