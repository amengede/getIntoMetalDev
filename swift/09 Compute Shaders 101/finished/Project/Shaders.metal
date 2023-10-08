//
//  Shaders.metal
//  Project
//
//  Created by Andrew Mengede on 13/8/2022.
//

#include <metal_stdlib>
#include "definitions.h"

using namespace metal;

bool hit(Ray ray, Sphere sphere);
float distance_to_sphere(Sphere sphere, Ray ray);

kernel void ray_tracing_kernel(texture2d<float, access::write> color_buffer [[texture(0)]],
                    uint2 grid_index [[thread_position_in_grid]]) {
    int width = color_buffer.get_width();
    int height = color_buffer.get_height();
    
    float horizontal_coefficient = (float(grid_index[0]) - width / 2) / width;
    float vertical_coefficient = (float(grid_index[1]) - height / 2) / width;
    float3 forwards = float3(1.0, 0.0, 0.0);
    float3 right = float3(0.0, -1.0, 0.0);
    float3 up = float3(0.0, 0.0, 1.0);
    
    Sphere mySphere;
    mySphere.center = float3(3.0, 0.0, 0.0);
    mySphere.radius = 1.0;
    
    Ray myRay;
    myRay.origin = float3(0.0, 0.0, 0.0);
    myRay.direction = normalize(forwards + horizontal_coefficient * right + vertical_coefficient * up);
    
    float4 color = float4(0.0, 0.0, 0.0, 1.0);
    
    if (hit(myRay, mySphere)) {
        color = float4(1.0, 0.1, 0.3, 1.0);
    }
  
    color_buffer.write(color, grid_index);
}

bool hit(Ray ray, Sphere sphere) {
    
    float a = dot(ray.direction, ray.direction);
    float b = 2.0 * dot(ray.direction, ray.origin - sphere.center);
    float c = dot(ray.origin - sphere.center, ray.origin - sphere.center) - sphere.radius * sphere.radius;
    float discriminant = b * b - 4.0 * a * c;

    return discriminant > 0;
    
}
