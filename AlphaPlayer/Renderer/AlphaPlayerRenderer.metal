//
//  AlphaPlayerItem.metal
//  AlphaPlayer
//
//  Created by Quentin Fasquel on 28/04/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
} TextureMappingVertex;

vertex TextureMappingVertex vertex_mapTexture(unsigned int vid [[ vertex_id ]])
{
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

fragment float4 displayTexture(TextureMappingVertex in [[ stage_in ]],
                              texture2d<float, access::sample> texture [[ texture(0) ]])
{
//    constexpr sampler textureSampler(address::clamp_to_edge, filter::linear);
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    
    return float4(texture.sample(textureSampler, in.textureCoordinate));
}

fragment float4 fragment_alphaFrame(TextureMappingVertex in [[ stage_in ]],
                          texture2d<float, access::sample> textureRGB [[ texture(0) ]],
                          texture2d<float, access::sample> textureAlpha [[ texture(1) ]])
{
//    constexpr sampler textureSampler(address::clamp_to_edge, filter::linear);
//    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    constexpr sampler textureSampler(mag_filter::nearest, min_filter::nearest);
    
    float4 colorFrame = float4(textureRGB.sample(textureSampler, in.textureCoordinate));
    float alpha = float4(textureAlpha.sample(textureSampler, in.textureCoordinate)).r;

    return alpha > 0 ? float4(colorFrame.rgb, alpha) : float4(0);
}

kernel void kernel_alphaFrame(texture2d<half, access::read> textureRGB [[ texture(0) ]],
                        texture2d<half, access::read> textureAlpha [[ texture(1) ]],
                        texture2d<float, access::write> outTexture [[ texture(2) ]],
                        ushort2 gid [[ thread_position_in_grid ]])
{
    // Check if the pixel is within the bounds of the output texture
    if ((gid.x >= outTexture.get_width()) || (gid.y >= outTexture.get_height())) {
        // Return early if the pixel is out of bounds
        return;
    }

    float3 rgb = float4(textureRGB.read(gid)).rgb;
    float alpha = textureAlpha.read(gid).r;

    float4 pixel = alpha > 0 ? float4(rgb, alpha) : float4(0);
    outTexture.write(pixel, gid);
}
