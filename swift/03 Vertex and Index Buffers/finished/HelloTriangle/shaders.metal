//
//  shaders.metal
//  HelloTriangle
//
//  Created by Andrew Mengede on 18/4/2024.
//

#include <metal_stdlib>
#include "definitions.h"
using namespace metal;

struct VertexPayload {
    float4 position [[position]];
    half3 color;
};

VertexPayload vertex vertexMain(
    const device Vertex *vertices [[buffer(0)]],
    uint vertexID [[vertex_id]]) {
    
    Vertex v = vertices[vertexID];
    VertexPayload payload;
    payload.position = v.position;
    payload.color = half3(v.color);
    return payload;
}

half4 fragment fragmentMain(VertexPayload frag [[stage_in]]) {
    return half4(frag.color, 1.0);
}
