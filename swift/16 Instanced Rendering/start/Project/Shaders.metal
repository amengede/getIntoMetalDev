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
};

vertex Fragment vertexShader(
        const device Vertex *vertices [[ buffer(0) ]],
        unsigned int vid [[vertex_id]],
        constant matrix_float4x4 &model [[ buffer(1) ]],
        constant CameraParameters &camera [[ buffer(2) ]])
{
    
    Fragment output;
    Vertex vertex_in = vertices[vid];
    output.position = camera.projection * camera.view * model * vertex_in.position;
    output.texCoord = vertex_in.uv;
    output.normal = float3(model * float4(vertex_in.normal, 0.0));
    output.cameraPosition = camera.position;
    output.fragmentPosition = float3(model * vertex_in.position);
    
    return output;
}

fragment float4 fragmentShader(
    Fragment input [[stage_in]],
    texture2d_array<float> objectTexture [[texture(0)]],
    sampler samplerObject [[sampler(0)]],
    constant DirectionalLight &sun [[ buffer(0) ]],
    constant Spotlight &spotlight [[ buffer(1) ]],
    constant Pointlight *pointLights [[ buffer(2) ]],
    constant FragmentData &fragUBO [[ buffer(3) ]],
    constant float &materialIndex [[ buffer(4) ]])
{
    float3 baseColor = float3(objectTexture.sample(samplerObject, input.texCoord, materialIndex));
    float alpha = objectTexture.sample(samplerObject, input.texCoord, materialIndex).a;
    
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
