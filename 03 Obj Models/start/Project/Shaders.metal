//
//  Shaders.metal
//  HelloTriangle
//
//  Created by Andrew Mengede on 27/2/2022.
//

#include <metal_stdlib>
using namespace metal;

#include "definitions.h"

struct Fragment {
    float4 position [[position]];
    float4 color;
};

vertex Fragment vertexShader(
        const device Vertex *vertexArray [[buffer(0)]],
        unsigned int vid [[vertex_id]],
        constant matrix_float4x4 &model [[ buffer(1) ]],
        constant CameraParameters &camera [[ buffer(2) ]])
{
    
    Vertex input = vertexArray[vid];
    
    Fragment output;
    output.position = camera.projection * camera.view * model * float4(input.position.x, input.position.y, input.position.z, 1);
    output.color = input.color;
    
    return output;
}

fragment float4 fragmentShader(Fragment input [[stage_in]]) {
    return input.color;
}
