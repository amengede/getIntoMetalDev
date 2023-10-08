//
//  Shaders.metal
//  Project
//
//  Created by Andrew Mengede on 13/8/2022.
//

#include <metal_stdlib>
#include "definitions.h"

using namespace metal;

Shader_RenderState hit(Shader_Ray ray, Shader_Sphere sphere, float tMin, float tMax, Shader_RenderState renderState);

float3 rayColor(Shader_Ray ray, float sphereCount, const device Shader_Sphere* spheres);

kernel void ray_tracing_kernel(texture2d<float, access::write> color_buffer [[texture(0)]],
    const device Shader_Sphere *spheres [[buffer(0)]],
    constant Shader_SceneData &sceneData [[buffer(1)]],
    uint2 grid_index [[thread_position_in_grid]]) {
    // Bytes (less than ~4kb): constant Shader_Sphere *spheres [[buffer(0)]]
    // Buffer (bigger): const device Shader_Sphere *spheres [[buffer(0)]]
    
    int width = color_buffer.get_width();
    int height = color_buffer.get_height();
    
    float horizontal_coefficient = (float(grid_index[0]) - width / 2) / width;
    float vertical_coefficient = (float(grid_index[1]) - height / 2) / width;
    float3 forwards = sceneData.camera_forwards;
    float3 right = sceneData.camera_right;
    float3 up = sceneData.camera_up;
    
    Shader_Ray myRay;
    myRay.origin = sceneData.camera_pos;
    myRay.direction = normalize(forwards + horizontal_coefficient * right + vertical_coefficient * up);
    
    float3 color = rayColor(myRay, sceneData.sphereCount, spheres);
  
    color_buffer.write(float4(color, 1.0), grid_index);
}

float3 rayColor(Shader_Ray ray, float sphereCount, const device Shader_Sphere* spheres) {
    
    float3 color = float3(0.0);
    
    float nearestHit = 9999;
    Shader_RenderState renderState;
    renderState.hit = 0.0;
    
    for (int i = 0; i < sphereCount; ++i) {
        
        Shader_RenderState newRenderState = hit(ray, spheres[i], 0.001, nearestHit, renderState);
        
        if (newRenderState.hit > 0.1) {
            nearestHit = newRenderState.t;
            renderState = newRenderState;
            color = renderState.color;
        }
    }
    
    return color;
}

Shader_RenderState hit(Shader_Ray ray, Shader_Sphere sphere, float tMin, float tMax, Shader_RenderState renderState) {
    
    float3 co = ray.origin - sphere.center;
    float a = dot(ray.direction, ray.direction);
    float b = 2.0 * dot(ray.direction, co);
    float c = dot(co, co) - sphere.radius * sphere.radius;
    float discriminant = b * b - 4.0 * a * c;

    if (discriminant > 0) {
        
        float t = (-b - sqrt(discriminant)) / (2.0 * a);
        
        if (t > tMin && t < tMax) {
            renderState.t = t;
            renderState.color = sphere.color;
            renderState.hit = 1.0;
            return renderState;
        }
    }
    
    renderState.hit = 0;
    return renderState;
}
