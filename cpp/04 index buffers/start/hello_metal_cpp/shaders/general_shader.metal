#include <metal_stdlib>
using namespace metal;

struct VertexInput {
    float2 position;
    float3 color;
};

struct VertexOutput {
    float4 position [[position]];
    half3 color;
};

VertexOutput vertex vertexMainGeneral(
    uint vertexID [[vertex_id]],
    device const VertexInput* vertices [[buffer(0)]]) {
    
    VertexOutput payload;
    VertexInput vert = vertices[vertexID];
    payload.position = float4(vert.position, 0.0, 1.0);
    payload.color = half3(vert.color);
    return payload;
}

half4 fragment fragmentMainGeneral(VertexOutput frag [[stage_in]]) {
    return half4(frag.color, 1.0);
}
