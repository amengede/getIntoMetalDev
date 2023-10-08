//
//  definitions.h
//  HelloTriangle
//
//  Created by Andrew Mengede on 27/2/2022.
//

#ifndef definitions_h
#define definitions_h

#include <simd/simd.h>


struct Vertex {
    vector_float4 position;
    vector_float2 uv;
    vector_float3 normal;
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

#endif /* definitions_h */
