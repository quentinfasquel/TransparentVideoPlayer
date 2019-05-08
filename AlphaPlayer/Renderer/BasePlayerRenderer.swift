//
//  BasePlayerRenderer.swift
//  AlphaPlayer
//
//  Created by Quentin Fasquel on 06/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import CoreVideo
import Metal
import QuartzCore.CAMetalLayer

///
public class BasePlayerRenderer {
    public let device: MTLDevice
    public var currentTexture: MTLTexture?
    
    internal var commandQueue: MTLCommandQueue!
    internal var textureCache: CVMetalTextureCache!
    
    public required init(device metalDevice: MTLDevice) {
        device = metalDevice
        setupMetal(device: device)
        setupTextureCache()
    }
    
    internal func setupMetal(device: MTLDevice) {
        //
    }
    
    private func setupTextureCache() {
        let result = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)
        if result != kCVReturnSuccess {
            assertionFailure("Unable to allocate video mixer texture cache")
        }
    }
    
    // MARK: - Texture
    
    private func checkMatrixAttachment(of pixelBuffer: CVPixelBuffer, _ value: CFString) -> Bool {
        let attachment = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, nil)
        guard let colorAttachment = attachment?.takeUnretainedValue() else {
            // Throw error?
            return false
        }
        
        return (colorAttachment as! CFString) == value
    }
    
//    private func checkTransferFunctionAttachment(of pixelBuffer: CVPixelBuffer, _ value: CFString) -> Bool {
//        let attachment = CVBufferGetAttachment(pixelBuffer, kCVImageBufferTransferFunctionKey, nil)
//        guard let transferFunctionAttachment = attachment?.takeUnretainedValue() else {
//            // Throw error?
//            return false
//        }
//
//        return (transferFunctionAttachment as! CFString) == value
//    }
    
    public func makeTextureFromCVPixelBuffer(pixelBuffer: CVPixelBuffer) -> MTLTexture? {
        // TODO: Assert pixelBuffer has the expected yCbCr matrix attachment
//        let isB709 = checkMatrixAttachment(of: pixelBuffer, kCVImageBufferYCbCrMatrix_ITU_R_709_2)
//        print("isB709", isB709)
//            NSLog(@"unsupported YCbCrMatrix \"%@\", only BT.709 matrix is supported", matrixKeyAttachment);
        // TODO: Check transfer function?
//        let isB709Gamma = checkTransferFunctionAttachment(of: pixelBuffer, kCVImageBufferTransferFunction_ITU_R_709_2)
//        let isSRGBGamma = checkTransferFunctionAttachment(of: pixelBuffer, kCVImageBufferTransferFunction_sRGB)
//        let isLinearGamma = checkTransferFunctionAttachment(of: pixelBuffer, kCVImageBufferTransferFunction_Linear)
        
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
}
