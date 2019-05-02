//
//  AlphaPlayerItemVideoOutput.swift
//  TestComposition
//
//  Created by Quentin Fasquel on 29/04/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation
import Metal
import QuartzCore.CAMetalLayer
import UIKit

///
protocol AlphaPlayerItemVideoOutputProtocol  { // add Video
    var rgbOutput: AVPlayerItemVideoOutput { get } // input
    var alphaOutput: AVPlayerItemVideoOutput { get } // input
    // naturalSize?

    @discardableResult
    func render(_ rgbPixelBuffer: CVPixelBuffer, _ alphaPixelBuffer: CVPixelBuffer) -> MTLCommandBuffer?
}

///
/// Renders into a Metal texture
///
public class AlphaPlayerItemVideoOutput: NSObject, AVPlayerItemOutputPullDelegate, AlphaPlayerItemVideoOutputProtocol {

    private let queue: DispatchQueue = DispatchQueue(label: "blop") // item output pull delegate
    public let rgbOutput: AVPlayerItemVideoOutput
    public let alphaOutput: AVPlayerItemVideoOutput

    // state
    var rgbItemReady: Bool = false
    var alphaItemReady: Bool = false
    
    let device: MTLDevice
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    
    var currentTexture: MTLTexture?
    var textureCache: CVMetalTextureCache!
    var onReadyToPlay: (() -> Void)?
    
    required init(device metalDevice: MTLDevice) {
        let attributes: [String: Any] = [
//            String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]
            String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA]

        device = metalDevice
        rgbOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: attributes)
        alphaOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: attributes)

        super.init()

        setupMetal(device: device)

        rgbOutput.setDelegate(self, queue: queue)
        alphaOutput.setDelegate(self, queue: queue)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupMetal(device: MTLDevice) {
        let bundle = Bundle(for: type(of: self))
        let defaultLibrary = try! device.makeDefaultLibrary(bundle: bundle)
//        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
//        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "mapTexture")
        let fragmentProgram = defaultLibrary.makeFunction(name: "alphaFrame")

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()
        
        // CoreVideo Metal Texture cache
        
        let result = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)
        if result != kCVReturnSuccess {
            assertionFailure("Unable to allocate video mixer texture cache")
        }
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
        passDescriptor.colorAttachments[0].clearColor = .init(red: 1.0, green: 0, blue: 0, alpha: 1.0)
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)!
        encoder.setRenderPipelineState(pipelineState)
        encoder.setFragmentTexture(videoTexture0, index: 0) // rgb
        encoder.setFragmentTexture(videoTexture1, index: 1) // alpha
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
        encoder.endEncoding()

        return commandBuffer
    }
    
    public func makeTextureFromCVPixelBuffer(pixelBuffer: CVPixelBuffer) -> MTLTexture? {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        // Create a Metal texture from the image buffer
        var cvTextureOut: CVMetalTexture?

        CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault, textureCache, pixelBuffer, nil, .bgra8Unorm, width, height, 0, &cvTextureOut)
        guard let cvTexture = cvTextureOut, let texture = CVMetalTextureGetTexture(cvTexture) else {
            print("Video mixer failed to create preview texture")
            CVMetalTextureCacheFlush(textureCache, 0)
            return nil
        }
        
        return texture
    }
    
    // MARK: - AVPlayerItemOutputPullDelegate
    
    public func outputMediaDataWillChange(_ sender: AVPlayerItemOutput) {
        switch sender {
        case rgbOutput:
            rgbItemReady = true
        case alphaOutput:
            alphaItemReady = true
        default:
            return // unexpected
        }
        
        if rgbItemReady && alphaItemReady {
            onReadyToPlay?()
        }
    }
}
