//
//  AlphaPlayerItem.metal
//  TestComposition
//
//  Created by Quentin Fasquel on 28/04/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

//vertex float4 basic_vertex(
//  const device packed_float3* vertex_array [[ buffer(0) ]],
//  unsigned int vid [[ vertex_id ]] ) {
//
//    return float4(vertex_array[vid], 1.0);
//}
//
//fragment half4 basic_fragment() {
//    return half4(1.0);
//}

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
} TextureMappingVertex;

vertex TextureMappingVertex mapTexture(unsigned int vid [[ vertex_id ]]) {
    float4x4 position = float4x4(float4( -1.0, -1.0, 0.0, 1.0 ), /// (x, y, depth, W)
                                 float4(  1.0, -1.0, 0.0, 1.0 ),
                                 float4( -1.0,  1.0, 0.0, 1.0 ),
                                 float4(  1.0,  1.0, 0.0, 1.0 ));
    
    float4x2 textureCoordinates = float4x2(float2( 0.0, 1.0 ), /// (u, v)
                                           float2( 1.0, 1.0 ),
                                           float2( 0.0, 0.0 ),
                                           float2( 1.0, 0.0 ));
    TextureMappingVertex out;
    out.position = position[vid];
    out.textureCoordinate = textureCoordinates[vid];

    return out;
}

fragment half4 displayTexture(TextureMappingVertex in [[ stage_in ]],
                              texture2d<float, access::sample> texture [[ texture(0) ]]) {
//    constexpr sampler textureSampler(address::clamp_to_edge, filter::linear);
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    
    return half4(texture.sample(textureSampler, in.textureCoordinate));
}

fragment half4 alphaFrame(TextureMappingVertex in [[ stage_in ]],
                          texture2d<float, access::sample> textureRGB [[ texture(0) ]],
                          texture2d<float, access::sample> textureAlpha [[ texture(1) ]]) {
    //    constexpr sampler textureSampler(address::clamp_to_edge, filter::linear);
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    
    half4 colorFrame = half4(textureRGB.sample(textureSampler, in.textureCoordinate));
    half4 alphaFrame = half4(textureAlpha.sample(textureSampler, in.textureCoordinate));

    return half4(colorFrame.rgb, alphaFrame.r);
}
