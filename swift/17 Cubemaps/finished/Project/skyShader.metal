//
//  skyShader.metal
//  Project
//
//  Created by Andrew Mengede on 29/7/2024.
//

#include <metal_stdlib>
using namespace metal;
#include "definitions.h"

struct FragmentSky {
    float4 position [[position]];
    float3 direction;
};

vertex FragmentSky vertexShaderSky (
        const device SimpleVertex *vertices [[ buffer(0) ]],
        constant CameraFrame &camera [[ buffer(1) ]],
        unsigned int vid [[vertex_id]]) {
    
    FragmentSky output;
    SimpleVertex vertex_in = vertices[vid];
    
    float2 screenPosNDC = vertex_in.position;
    
    output.position = float4(vertex_in.position, 1, 1);
    //tan(pi/8)
    float dy = 0.414;
    float dx = dy * camera.aspect;
    output.direction = normalize(camera.forwards
            - dx * camera.right * screenPosNDC.x
            + dy * camera.up * screenPosNDC.y);
    
    return output;
}

fragment float4 fragmentShaderSky (
    FragmentSky input [[stage_in]],
    texturecube<float> skyMaterial [[texture(0)]],
    sampler skySampler [[sampler(0)]]) {
    
    return skyMaterial.sample(skySampler, input.direction);
}
