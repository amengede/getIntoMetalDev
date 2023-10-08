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
};

struct Shader_Ray {
    vector_float3 origin;
    vector_float3 direction;
};

struct Shader_SceneData {
    float sphereCount;
    vector_float3 camera_pos;
    vector_float3 camera_forwards;
    vector_float3 camera_right;
    vector_float3 camera_up;
};

struct Shader_RenderState {
    float t;
    vector_float3 color;
    float hit;
};

#endif /* definitions_h */
