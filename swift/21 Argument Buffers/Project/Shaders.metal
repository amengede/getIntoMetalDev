//
//  Shaders.metal
//  HelloTriangle
//
//  Created by Andrew Mengede on 27/2/2022.
//

#include <metal_stdlib>
using namespace metal;

#include "definitions.h"

float3 applyDirectionalLight(float3 normal, DirectionalLight light, float3 baseColor, float3 fragCam);
float3 applySpotLight(float3 position, float3 normal, Spotlight light, float3 baseColor, float3 fragCam);
float3 applyPointLight(float3 position, float3 normal, Pointlight light, float3 baseColor, float3 fragCam);

struct Fragment {
    float4 position [[position]];
    float2 texCoord;
    float3 cameraPosition;
    float3 normal;
    float3 fragmentPosition;
    uint materialID;
};

struct GunFragment {
    float4 position [[position]];
    float2 texCoord;
};

struct Material {
    texture2d<float> albedo;
    sampler sampler;
};

vertex Fragment vertexShader(
        const device Vertex *vertices [[ buffer(0) ]],
        unsigned int vid [[vertex_id]],
        unsigned int iid [[ instance_id ]],
        const device InstancePayload *payloads [[ buffer(1) ]],
        constant CameraParameters &camera [[ buffer(2) ]])
{
    
    Fragment output;
    Vertex vertex_in = vertices[vid];
    output.position = camera.projection * camera.view * payloads[iid].model * vertex_in.position;
    output.texCoord = vertex_in.uv;
    output.normal = float3(payloads[iid].model * float4(vertex_in.normal, 0.0));
    output.cameraPosition = camera.position;
    output.fragmentPosition = float3(payloads[iid].model * vertex_in.position);
    output.materialID = uint(payloads[iid].color_texID.w);
    
    return output;
}

vertex GunFragment vertexShaderGun(
        const device Vertex *vertices [[ buffer(0) ]],
        unsigned int vid [[vertex_id]],
        constant matrix_float4x4 &model [[ buffer(1) ]],
        constant CameraParameters &camera [[ buffer(2) ]])
{
    Vertex vertex_in = vertices[vid];
    float4 clipSpacePos = camera.projection * camera.view * model * vertex_in.position;
    GunFragment output;
    output.position = clipSpacePos;
    // Normal warps the texture coordinates!
    float4 normal = camera.projection * camera.view * model * float4(vertex_in.normal,0);
    clipSpacePos = clipSpacePos + 0.2 * normal;
    // Apply perspective division, then map to [0,1] range
    float x = 0.5 * (1.0 + clipSpacePos.x / clipSpacePos.w);
    float y = 0.5 * -(1.0 + clipSpacePos.y / clipSpacePos.w);
    output.texCoord = float2(x,y);
    
    return output;
}

fragment float4 fragmentShaderGun(
    GunFragment input [[stage_in]],
    texture2d<float> worldTexture [[texture(0)]],
    sampler worldSampler [[sampler(0)]])
{
    return float4(1, 0, 0, 1) * worldTexture.sample(worldSampler, input.texCoord);
}

fragment float4 fragmentShader(
    Fragment input [[stage_in]],
    constant DirectionalLight &sun [[ buffer(0) ]],
    constant Spotlight &spotlight [[ buffer(1) ]],
    constant Pointlight *pointLights [[ buffer(2) ]],
    constant FragmentData &fragUBO [[ buffer(3) ]],
    const device Material *materials [[ buffer(4) ]])
{
    Material material = materials[input.materialID];
    float4 raw = material.albedo.sample(material.sampler, input.texCoord);
    float3 baseColor = raw.rgb;
    float alpha = raw.a;
    
    //directions
    float3 fragCam = normalize(input.cameraPosition - input.fragmentPosition);
    
    //ambient
    float3 color = 0.2 * baseColor;
    
    //sun
    color += applyDirectionalLight(input.normal, sun, baseColor, fragCam);
    
    //spotlight
    color += applySpotLight(input.fragmentPosition, input.normal, spotlight, baseColor, fragCam);
    
    for (uint i = 0; i < fragUBO.lightCount; ++i) {
        color += applyPointLight(input.fragmentPosition, input.normal, pointLights[i], baseColor, fragCam);
    }
    
    return float4(color, alpha);
}

float3 applyDirectionalLight(float3 normal, DirectionalLight light, float3 baseColor, float3 fragCam) {
    
    float3 result = float3(0.0);
    
    float3 halfVec = normalize(-light.forwards + fragCam);
    
    //diffuse
    float lightAmount = max(0.0, dot(normal, -light.forwards));
    result += lightAmount * baseColor * light.color;
    
    //specular
    lightAmount = pow(max(0.0, dot(normal, halfVec)), 64);
    result += lightAmount * baseColor * light.color;
    
    return result;
}

float3 applySpotLight(float3 position, float3 normal, Spotlight light, float3 baseColor, float3 fragCam) {
    
    float3 result = float3(0.0);
    
    float3 fragLight = normalize(light.position - position);
    float3 halfVec = normalize(fragLight + fragCam);
    
    //diffuse
    float lightAmount = max(0.0, dot(normal, fragLight)) * pow(max(0.0, dot(fragLight, light.forwards)),16);
    result += lightAmount * baseColor * light.color;
    
    //specular
    lightAmount = pow(max(0.0, dot(normal, halfVec)), 64) * pow(max(0.0, dot(fragLight, light.forwards)),16);
    result += lightAmount * baseColor * light.color;
    
    return result;
}



float3 applyPointLight(float3 position, float3 normal, Pointlight light, float3 baseColor, float3 fragCam) {
    
    float3 result = float3(0.0);
    
    //directions
    float3 fragLight = normalize(light.position - position);
    float3 halfVec = normalize(fragLight + fragCam);
    
    //diffuse
    float lightAmount = max(0.0, dot(normal, fragLight));
    result += lightAmount * baseColor * light.color;
    
    //specular
    lightAmount = pow(max(0.0, dot(normal, halfVec)), 64);
    result += lightAmount * baseColor * light.color;
    
    return result;
}
