#include <metal_stdlib>
using namespace metal;

struct VertexInput {
    float3 position [[attribute(0)]];
    float3 color [[attribute(1)]];
    float2 texCoord [[attribute(2)]];
};

struct VertexOutput {
    float4 position [[position]];
    half3 color;
    float2 texCoord;
};

VertexOutput vertex vertexMainGeneral(
    VertexInput input [[stage_in]],
    constant float4x4& transform [[buffer(1)]],
    constant float4x4& projection [[buffer(2)]],
    constant float4x4& view [[buffer(3)]]) {
    
    VertexOutput payload;
    half3 pos = half3(input.position);
    payload.position = float4(half4x4(projection) * half4x4(view) * half4x4(transform) * half4(pos, 1.0));
    payload.color = half3(input.color);
    payload.texCoord = input.texCoord;
    return payload;
}

half4 fragment fragmentMainGeneral(VertexOutput frag [[stage_in]],
    texture2d<float> material [[texture(0)]],
    sampler samplerObject [[sampler(0)]]) {
    return half4(material.sample(samplerObject, frag.texCoord)) * half4(frag.color, 1.0);
}
