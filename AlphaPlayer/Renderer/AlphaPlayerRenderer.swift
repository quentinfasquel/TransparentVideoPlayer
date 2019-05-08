//
//  AlphaPlayerRenderer.swift
//  AlphaPlayer
//
//  Created by Quentin Fasquel on 05/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import CoreVideo
import Metal

///
public protocol AlphaPlayerRendererProtocol: AnyObject {
    var currentTexture: MTLTexture? { get set }
    
    init(device: MTLDevice)
    
    func render(_ rgbPixelBuffer: CVPixelBuffer, _ alphaPixelBuffer: CVPixelBuffer) -> MTLCommandBuffer?
}

///
public class AlphaPlayerRenderer: BasePlayerRenderer, AlphaPlayerRendererProtocol {

    private var pipelineState: MTLRenderPipelineState!

    internal override func setupMetal(device: MTLDevice) {
        // TODO: Allow output texture with different pixelFormat?
        
        let bundle = Bundle(for: type(of: self))
        let defaultLibrary = try! device.makeDefaultLibrary(bundle: bundle)
        let vertexProgram = defaultLibrary.makeFunction(name: "vertex_mapTexture")
        let fragmentProgram = defaultLibrary.makeFunction(name: "fragment_alphaFrame")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)

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

        // Rendering
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = outputTexture
        passDescriptor.colorAttachments[0].loadAction = .clear
        passDescriptor.colorAttachments[0].storeAction = .store
        passDescriptor.colorAttachments[0].clearColor = .init(red: 0, green: 0, blue: 0, alpha: 1.0)
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)!
        encoder.setRenderPipelineState(pipelineState)
        encoder.setFragmentTexture(videoTexture0, index: 0) // rgb
        encoder.setFragmentTexture(videoTexture1, index: 1) // alpha
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
        encoder.endEncoding()
        
        return commandBuffer
    }

}

