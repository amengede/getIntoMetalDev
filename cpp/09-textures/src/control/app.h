#pragma once
#include "../config.h"
#include "../view/renderer.h"

/**
 * @brief our App!
 */
class App {
    public:
        /**
         * @brief constructor
         */
        App();

        /**
         * @brief destructor
         */
        ~App();

        /**
         * @brief run the main loop
         */
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
