//
//  config.h
//  hello_metal_cpp
//
//  Created by Andrew Mengede on 15/9/2023.
//

#pragma once
#include <Metal/Metal.hpp>
#include <AppKit/AppKit.hpp>
#include <MetalKit/MetalKit.hpp>
#include <simd/simd.h>

#include <iostream>
#include <fstream>
#include <sstream>

struct Vertex {
    simd::float4 pos;   //(x,y)
    simd::float4 color; //(r,g,b)
};
