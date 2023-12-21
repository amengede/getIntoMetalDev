//
//  triangle.metal
//  hello_metal_cpp
//
//  Created by Andrew Mengede on 2/11/2023.
//

#include <metal_stdlib>
using namespace metal;

struct VertexPayload {              //Mesh Vertex Type
    float4 position [[position]];   //Qualified attribute
    half3 color;                    //Half precision, faster
    
    /*
     See the metal spec, page 68, table 2.11: Mesh Vertex Attributes
     For more builtin variables we can set besides position.
    */
};

constant float4 positions[] = {
    float4(-0.75, -0.75, 0.0, 1.0), //bottom left: red
    float4( 0.75, -0.75, 0.0, 1.0), //bottom right: green
    float4(  0.0,  0.75, 0.0, 1.0), //center top: blue
};

constant half3 colors[] = {
    half3(1.0, 0.0, 0.0), //bottom left: red
    half3(0.0, 1.0, 0.0), //bottom right: green
    half3(0.0, 0.0, 1.0), //center top: blue
};

/*
    The vertex qualifier registers this function in the vertex stage of the Metal API.
    
    Currently we're just taking the Vertex ID, it'll be reset at the start of the draw call
    and increment for each successive invocation.
    
    See page 99 of the metal spec,
    table 5.2: Attributes for vertex function input arguments,
    for more info.
*/
VertexPayload vertex vertexMain(uint vertexID [[vertex_id]]) {
    VertexPayload payload;
    payload.position = positions[vertexID];
    payload.color = colors[vertexID];
    return payload;
}

/*
    The vertex qualifier registers this function in the vertex stage of the Metal API.
 
    See page 104 of the metal spec,
    table 5.5: Attributes for fragment function input arguments,
    for more info.
*/
half4 fragment fragmentMain(VertexPayload frag [[stage_in]]) {
    return half4(frag.color, 1.0);
}
