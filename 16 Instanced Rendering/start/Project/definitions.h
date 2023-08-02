//
//  definitions.h
//  HelloTriangle
//
//  Created by Andrew Mengede on 27/2/2022.
//

#ifndef definitions_h
#define definitions_h

#include <simd/simd.h>

struct InstancePayload {
    matrix_float4x4 model;
    vector_int4 textureID;
};

struct Vertex {
    vector_float4 position;
    vector_float2 uv;
    vector_float3 normal;
};

struct SimpleVertex {
    vector_float2 position;
};

struct CameraParameters {
    matrix_float4x4 view;
    matrix_float4x4 projection;
    vector_float3 position;
};

struct DirectionalLight {
    vector_float3 forwards;
    vector_float3 color;
};

struct Spotlight {
    vector_float3 position;
    vector_float3 forwards;
    vector_float3 color;
};

struct Pointlight {
    vector_float3 position;
    vector_float3 color;
};

enum lightType {
    UNDEFINED,
    DIRECTIONAL,
    SPOTLIGHT,
    POINTLIGHT
};

struct FragmentData {
    uint lightCount;
};

enum meshTypes {
    GROUND,
    CUBE,
    MOUSE,
    LIGHT
};

#define OBJECT_TYPE_GROUND 0
#define OBJECT_TYPE_CUBE 1
#define OBJECT_TYPE_MOUSE 2
#define OBJECT_TYPE_POINT_LIGHT 3

#endif /* definitions_h */
