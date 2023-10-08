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

Shader_RenderState trace(Shader_Ray ray, float sphereCount, const device Shader_Sphere* spheres);

float3 rayColor(float2 xy, Shader_Ray ray, constant Shader_SceneData &sceneData, const device Shader_Sphere* spheres);

constant float PHI = 1.61803398874989484820459;  // Φ = Golden Ratio
constant float PI = 3.141592653589793238;

float gold_noise(float2 xy, float seed) {
    return fract(tan(distance(xy*PHI, xy)*seed)*xy.x);
}

float3 randomVec(float2 xy, float seed) {
    float radius = gold_noise(xy, seed);
    float theta = 2.0 * PI * gold_noise(xy, seed + 1.0);
    float phi = PI * gold_noise(xy, seed + 2.0);
    
    return float3(
                  radius * cos(theta) * cos(phi),
                  radius * sin(theta) * cos(phi),
                  radius * sin(phi)
                  );
}

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
    
    float3 color = rayColor(float2(horizontal_coefficient, vertical_coefficient), myRay, sceneData, spheres);
  
    color_buffer.write(float4(color, 1.0), grid_index);
}

float3 rayColor(float2 xy, Shader_Ray ray, constant Shader_SceneData &sceneData, const device Shader_Sphere* spheres) {
    
    float3 color = float3(1.0);
    float3 tempColor = float3(0.0);
    
    //Initial trace
    Shader_RenderState result = trace(ray, sceneData.sphereCount, spheres);
    color = color * result.color;
    
    for (int i = 0; i < sceneData.maxBounces; ++i) {
        
        //Early exit
        if (!result.hit) {
            break;
        }
        
        //Bounces
        float3 origin = result.position;
        float3 matteDirection = result.normal + randomVec(xy, i);
        float3 reflectedDirection = reflect(ray.direction, result.normal);
        float reflectance = result.reflectance;
        //Use reflectance of surface to blend between matte and reflect
        ray.origin = origin;
        ray.direction = matteDirection;// + result.reflectance * reflectedDirection;
        result = trace(ray, sceneData.sphereCount, spheres);
        tempColor = (1.0 - reflectance) * result.color;
        ray.direction = reflectedDirection;
        result = trace(ray, sceneData.sphereCount, spheres);
        tempColor = tempColor + reflectance * result.color;
        color = color * tempColor;
    }
    
    return color;
}

Shader_RenderState trace(Shader_Ray ray, float sphereCount, const device Shader_Sphere* spheres) {
    
    float3 color = float3(1.0);
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
    
    renderState.color = color;
    
    return renderState;
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
            renderState.position = ray.origin + t * ray.direction;
            renderState.normal = normalize(renderState.position - sphere.center);
            renderState.reflectance = sphere.reflectance;
            return renderState;
        }
    }
    
    renderState.hit = 0;
    return renderState;
}
