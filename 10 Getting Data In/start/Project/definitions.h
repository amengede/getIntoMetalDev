//
//  definitions.h
//  HelloTriangle
//
//  Created by Andrew Mengede on 27/2/2022.
//

#ifndef definitions_h
#define definitions_h

#include <simd/simd.h>

struct Sphere {
    vector_float3 center;
    float radius;
};

struct Ray {
    vector_float3 origin;
    vector_float3 direction;
};

#endif /* definitions_h */
