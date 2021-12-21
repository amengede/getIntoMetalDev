//
//  shaders.metal
//  Metal2
//
//  Created by Andrew Mengede on 12/12/21.
//

#include <metal_stdlib>
#include "definitions.h"
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
};

vertex float4 vertex_main(const VertexIn vertex_in [[ stage_in ]], constant CameraData &camera [[ buffer(1) ]]) {
    float4 position = camera.viewProj * camera.modelMatrix * vertex_in.position;
    return position;
}

fragment float4 fragment_main() {
    return float4(0,0,1,1);
}
