//
//  definitions.h
//  Transformations
//
//  Created by Andrew Mengede on 20/12/21.
//

#ifndef definitions_h
#define definitions_h

#include <simd/simd.h>

#endif /* definitions_h */



typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewProj;
} CameraData;
