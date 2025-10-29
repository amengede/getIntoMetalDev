#pragma once
#include "../config.h"
#include "../model/camera.h"
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
        Camera* camera;
};
