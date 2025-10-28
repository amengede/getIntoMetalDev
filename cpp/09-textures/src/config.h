#pragma once
#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#include <Foundation/Foundation.hpp>
#include <Metal/Metal.hpp>
#include <QuartzCore/CAMetalLayer.hpp>
#include <QuartzCore/QuartzCore.hpp>
#include <AppKit/AppKit.hpp>
#include <simd/simd.h>

#include <iostream>
#include <fstream>
#include <sstream>

struct Vertex {
    simd::float3 pos;   //(x,y,z)
    simd::float3 color; //(r,g,b)
};

struct TexturedVertex {
    simd::float3 pos;   //(x,y,z)
    simd::float3 color; //(r,g,b)
    simd::float2 texCoord; //(u,v)
};
