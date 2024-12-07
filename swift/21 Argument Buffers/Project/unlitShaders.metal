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
    uint materialID;
};

struct Material {
    texture2d<float> albedo;
    sampler sampler;
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
    output.materialID = uint(payloads[iid].color_texID.w);
    
    return output;
}

fragment float4 fragmentShaderUnlit (
    FragmentUnlit input [[stage_in]],
    const device Material *materials [[ buffer(4) ]])
{
    Material material = materials[input.materialID];
    float4 raw = material.albedo.sample(material.sampler, input.texCoord);
    float3 baseColor = raw.rgb;
    float alpha = raw.a;
    
    return float4(input.tint * baseColor, alpha);
}
