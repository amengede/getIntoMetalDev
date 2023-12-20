#include <metal_stdlib>
using namespace metal;

struct VertexInput {
    float2 position [[attribute(0)]];
    float3 color [[attribute(1)]];
};

struct VertexOutput {
    float4 position [[position]];
    half3 color;
};

VertexOutput vertex vertexMainGeneral(VertexInput input [[stage_in]]) {
    
    VertexOutput payload;
    payload.position = float4(input.position, 0.0, 1.0);
    payload.color = half3(input.color);
    return payload;
}

half4 fragment fragmentMainGeneral(VertexOutput frag [[stage_in]]) {
    return half4(frag.color, 1.0);
}
