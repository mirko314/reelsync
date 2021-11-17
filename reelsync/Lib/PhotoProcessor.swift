//
//  PhotoProcessor.swift
//  reelsync
//
//  Created by Mirko Budszuhn on 12.11.21.
//
// https://newbedev.com/how-do-i-export-uiimage-array-as-a-movie

// swiftlint:disable

import Foundation
import AVKit
import Photos
import PhotosUI

// swiftlint:disable all

extension UIImage {

func crop(to:CGSize) -> UIImage {

    guard let cgimage = self.cgImage else { return self }

    let contextImage: UIImage = UIImage(cgImage: cgimage)

    guard let newCgImage = contextImage.cgImage else { return self }

    let contextSize: CGSize = contextImage.size

    //Set to square
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    let cropAspect: CGFloat = to.width / to.height

    var cropWidth: CGFloat = to.width
    var cropHeight: CGFloat = to.height

    if to.width > to.height { //Landscape
        cropWidth = contextSize.width
        cropHeight = contextSize.width / cropAspect
        posY = (contextSize.height - cropHeight) / 2
    } else if to.width < to.height { //Portrait
        cropHeight = contextSize.height
        cropWidth = contextSize.height * cropAspect
        posX = (contextSize.width - cropWidth) / 2
    } else { //Square
        if contextSize.width >= contextSize.height { //Square on landscape (or square)
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2
        }else{ //Square on portrait
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
        }
    }

    let rect: CGRect = CGRect(x: posX, y: posY, width: cropWidth, height: cropHeight)

    // Create bitmap image from context using the rect
    guard let imageRef: CGImage = newCgImage.cropping(to: rect) else { return self}

    // Create a new image based on the imageRef and rotate back to the original orientation
    let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)

    UIGraphicsBeginImageContextWithOptions(to, false, self.scale)
    cropped.draw(in: CGRect(x: 0, y: 0, width: to.width, height: to.height))
    let resized = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return resized ?? self
  }
}


func saveVideoToLibrary(videoURL: URL) {

    PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
    }) { saved, error in

        if let error = error {
            print("Error saving video to librayr: \(error.localizedDescription)")
        }
        if saved {
            print("Video save to library")

        }
    }
}
//  func buildVideoFromImageArray(framesArray:[UIImage]) {
func buildVideoFromImageArray(framesArray: [UIImage], videoOutputURL: URL, frameDuration: Double = 5, outputWidth: CGFloat?, outputHeight: CGFloat?) async -> URL? {
    
    return await withCheckedContinuation { continuation in
    print("START BUILDING VIDEO ")
    //    Somehow videos are broken with only one frame, so alwazys add 2
    var images = framesArray + [framesArray[framesArray.count - 1]]
    guard images[0] != nil  else {
        print("images not found")
        return
    }
    let outputSize = CGSize(width: (outputWidth ?? images[0].size.width), height: (outputHeight ?? images[0].size.height))
    

    if FileManager.default.fileExists(atPath: videoOutputURL.path) {
        do {
            try FileManager.default.removeItem(atPath: videoOutputURL.path)
        } catch {
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }

    guard let videoWriter = try? AVAssetWriter(outputURL: videoOutputURL, fileType: AVFileType.mp4) else {
        fatalError("AVAssetWriter error")
    }

    let outputSettings = [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: NSNumber(value: Float(outputSize.width)), AVVideoHeightKey: NSNumber(value: Float(outputSize.height))] as [String: Any]

    guard videoWriter.canApply(outputSettings: outputSettings, forMediaType: AVMediaType.video) else {
        fatalError("Negative : Can't apply the Output settings...")
    }

    let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: outputSettings)
    let sourcePixelBufferAttributesDictionary = [
        kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
        kCVPixelBufferWidthKey as String: NSNumber(value: Float(outputSize.width)),
        kCVPixelBufferHeightKey as String: NSNumber(value: Float(outputSize.height))
    ]
    let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)

    if videoWriter.canAdd(videoWriterInput) {
        videoWriter.add(videoWriterInput)
    }

    if videoWriter.startWriting() {
        videoWriter.startSession(atSourceTime: CMTime.zero)
        assert(pixelBufferAdaptor.pixelBufferPool != nil)

        let media_queue = DispatchQueue(__label: "mediaInputQueue", attr: nil)

        videoWriterInput.requestMediaDataWhenReady(on: media_queue, using: { () -> Void in
            let fps: Int32 = 30

            var frameCount: Int64 = 0
            var appendSucceeded = true

            while !images.isEmpty {
                if videoWriterInput.isReadyForMoreMediaData {
                    let nextPhoto = images.remove(at: 0).crop(to: outputSize)

                    let presentationTime = CMTimeMakeWithSeconds((Double(frameCount) * frameDuration / 2), preferredTimescale: fps)

                    var pixelBuffer: CVPixelBuffer?
                    let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferAdaptor.pixelBufferPool!, &pixelBuffer)

                    if let pixelBuffer = pixelBuffer, status == 0 {
                        let managedPixelBuffer = pixelBuffer

                        CVPixelBufferLockBaseAddress(managedPixelBuffer, [])

                        let data = CVPixelBufferGetBaseAddress(managedPixelBuffer)
                        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
                        let context = CGContext(data: data, width: Int(outputSize.width), height: Int(outputSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(managedPixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)

                        context?.clear(CGRect(x: 0, y: 0, width: outputSize.width, height: outputSize.height))

                        let horizontalRatio = CGFloat(outputSize.width) / nextPhoto.size.width
                        let verticalRatio = CGFloat(outputSize.height) / nextPhoto.size.height

                        let aspectRatio = min(horizontalRatio, verticalRatio) // ScaleAspectFit

                        let newSize = CGSize(width: nextPhoto.size.width * aspectRatio, height: nextPhoto.size.height * aspectRatio)

                        let x = newSize.width < outputSize.width ? (outputSize.width - newSize.width) / 2 : 0
                        let y = newSize.height < outputSize.height ? (outputSize.height - newSize.height) / 2 : 0

                        context?.draw(nextPhoto.cgImage!, in: CGRect(x: x, y: y, width: newSize.width, height: newSize.height))

                        CVPixelBufferUnlockBaseAddress(managedPixelBuffer, [])

                        appendSucceeded = pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                        if frameCount == 0 {
                            //                          appendSucceeded = pixelBufferAdaptor.append(pixelBuffer,
//                        withPresentationTime: CMTimeMultiply(CMTimeMake(value: frameCount, timescale: fps), multiplier: frameDuration - 1))
                        }
                        frameCount += 1
                    } else {
                        print("Failed to allocate pixel buffer")
                        appendSucceeded = false
                    }
                }
                if !appendSucceeded {
                    break
                }
                //                frameCount += 1
            }
            videoWriterInput.markAsFinished()

            return videoWriter.finishWriting(completionHandler: {
                
                DispatchQueue.main.sync {
                    continuation.resume(returning: videoOutputURL)
                }
                
//                onComplete(videoOutputURL)
            })
        })
    }
    }
}
