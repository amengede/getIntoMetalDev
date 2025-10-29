#pragma once
#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#define GLFW_EXPOSE_NATIVE_COCOA
#include <GLFW/glfw3native.h>
#include <AppKit/AppKit.hpp>
#include <QuartzCore/CAMetalLayer.hpp>

/**
 * @brief Get a NextStep window from GLFW
 * 
 * @param glfwWindow GLFW window
 * @param layer Metal layer to render to
 * 
 * @returns A Nextstep window which cocoa can render to
 */
NS::Window* get_ns_window(GLFWwindow* glfwWindow, CA::MetalLayer* layer);