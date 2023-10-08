//
//  unlitShaders.metal
//  Project
//
//  Created by Andrew Mengede on 4/8/2022.
//

#include <metal_stdlib>
using namespace metal;

#include "definitions.h"

struct FragmentUnlit {
    float4 position [[position]];
    float2 texCoord;
    float3 tint;
    float materialID;
};

vertex FragmentUnlit vertexShaderUnlit (
        const device Vertex *vertices [[ buffer(0) ]],
        const device InstancePayload *payloads [[ buffer(1) ]],
        constant CameraParameters &camera [[ buffer(2) ]],
        unsigned int vid [[vertex_id]],
        unsigned int iid [[instance_id]])
{
    
    FragmentUnlit output;
    Vertex vertex_in = vertices[vid];
    output.position = camera.projection * camera.view * payloads[iid].model * vertex_in.position;
    output.texCoord = vertex_in.uv;
    output.tint = payloads[iid].color_texID.xyz;
    output.materialID = payloads[iid].color_texID.w;
    
    return output;
}

fragment float4 fragmentShaderUnlit (
    FragmentUnlit input [[stage_in]],
    texture2d_array<float> objectTexture [[texture(0)]],
    sampler samplerObject [[sampler(0)]])
{
    float3 baseColor = float3(objectTexture.sample(samplerObject, input.texCoord, input.materialID));
    float alpha = objectTexture.sample(samplerObject, input.texCoord, input.materialID).a;
    
    return float4(input.tint * baseColor, alpha);
}
