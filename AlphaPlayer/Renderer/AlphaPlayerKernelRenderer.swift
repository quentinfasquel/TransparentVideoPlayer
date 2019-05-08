//
//  AlphaPlayerKernelRenderer.swift
//  AlphaPlayer
//
//  Created by Quentin Fasquel on 06/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import CoreVideo
import Metal

public class AlphaPlayerKernelRenderer: BasePlayerRenderer, AlphaPlayerRendererProtocol {
    
    private var computePipeline: MTLComputePipelineState!
    
    internal override func setupMetal(device: MTLDevice) {
        let bundle = Bundle(for: type(of: self))
        let defaultLibrary = try! device.makeDefaultLibrary(bundle: bundle)
        let kernel = defaultLibrary.makeFunction(name: "kernel_alphaFrame")!
        computePipeline = try! device.makeComputePipelineState(function: kernel)
        commandQueue = device.makeCommandQueue()
    }
    
    @discardableResult
    public func render(_ rgbPixelBuffer: CVPixelBuffer, _ alphaPixelBuffer: CVPixelBuffer) -> MTLCommandBuffer? {
        guard let outputTexture = currentTexture else {
            print("Skip renderring no texture")
            return nil
        }
        
        guard let videoTexture0 = makeTextureFromCVPixelBuffer(pixelBuffer: rgbPixelBuffer),
            let videoTexture1 = makeTextureFromCVPixelBuffer(pixelBuffer: alphaPixelBuffer) else {
                print("video texture cannot be created")
                return nil
        }
        
        let blockDim = 2
        
        var numBlocksInWidth = videoTexture0.width / blockDim
        if videoTexture0.width % blockDim != 0 {
            numBlocksInWidth += 1
        }
        
        var numBlocksInHeight = videoTexture0.height / blockDim
        if videoTexture0.height % blockDim != 0 {
            numBlocksInHeight += 1
        }
        
        let threadsPerThreadgroup = MTLSize(width: blockDim, height: blockDim, depth: 1)
        let threadsPerGrid = MTLSize(width: numBlocksInWidth, height: numBlocksInHeight, depth: 1)
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let encoder = commandBuffer.makeComputeCommandEncoder()!
        encoder.setComputePipelineState(computePipeline)
        encoder.setTexture(videoTexture0, index: 0)
        encoder.setTexture(videoTexture1, index: 1)
        encoder.setTexture(outputTexture, index: 2)
        encoder.dispatchThreadgroups(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
        
        return commandBuffer
    }
}
