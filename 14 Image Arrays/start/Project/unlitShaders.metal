//
//  unlitShaders.metal
//  Project
//
//  Created by Andrew Mengede on 4/8/2022.
//

#include <metal_stdlib>
using namespace metal;

#include "definitions.h"

/*
struct VertexUnlit {
    float4 position [[ attribute(0) ]];
    float2 texCoord [[ attribute(1) ]];
};
*/

struct FragmentUnlit {
    float4 position [[position]];
    float2 texCoord;
};

vertex FragmentUnlit vertexShaderUnlit (
        const device Vertex *vertices [[ buffer(0) ]],
        constant matrix_float4x4 &model [[ buffer(1) ]],
        constant CameraParameters &camera [[ buffer(2) ]],
        unsigned int vid [[vertex_id]])
{
    
    FragmentUnlit output;
    Vertex vertex_in = vertices[vid];
    output.position = camera.projection * camera.view * model * vertex_in.position;
    output.texCoord = vertex_in.uv;
    
    return output;
}

fragment float4 fragmentShaderUnlit (
    FragmentUnlit input [[stage_in]],
    texture2d<float> objectTexture [[texture(0)]],
    sampler samplerObject [[sampler(0)]],
    constant float3 &tint [[ buffer(0) ]])
{
    float3 baseColor = float3(objectTexture.sample(samplerObject, input.texCoord));
    float alpha = objectTexture.sample(samplerObject, input.texCoord).a;
    
    return float4(tint * baseColor, alpha);
}
