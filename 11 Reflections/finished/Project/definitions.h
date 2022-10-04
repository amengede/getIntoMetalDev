//
//  definitions.h
//  HelloTriangle
//
//  Created by Andrew Mengede on 27/2/2022.
//

#ifndef definitions_h
#define definitions_h

#include <simd/simd.h>

struct Shader_Camera {
    vector_float3 position;
    vector_float3 forwards;
    vector_float3 right;
    vector_float3 up;
};

struct Shader_Sphere {
    vector_float3 center;
    float radius;
    vector_float3 color;
    float reflectance;
};

struct Shader_Ray {
    vector_float3 origin;
    vector_float3 direction;
};

struct Shader_SceneData {
    vector_float3 camera_pos;
    float sphereCount;
    vector_float3 camera_forwards;
    float maxBounces;
    vector_float3 camera_right;
    vector_float3 camera_up;
};

struct Shader_RenderState {
    float t;
    vector_float3 color;
    float hit;
    vector_float3 normal;
    vector_float3 position;
    float reflectance;
};

#endif /* definitions_h */
