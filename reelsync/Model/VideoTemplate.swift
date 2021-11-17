//
//  VideoTemplate.swift
//  reelsync
//
//  Created by Mirko Budszuhn on 12.11.21.
//

import Foundation
import UIKit

// Get this from API

struct VideoTemplate {
    var sound: SoundMeta
    var slots: [Slot] = []
}
struct VideoTimeline {
    var template: VideoTemplate
    var fillableSlots: [FillableSlot]

    init(initTemplate: VideoTemplate) {
        fillableSlots = initTemplate.slots.map { FillableSlot(slot: $0) }
        template = initTemplate
    }

    mutating func importMedia(slotIndex: Int, media: PhotoPickerModel) {
        guard slotIndex < fillableSlots.count else {
            return
        }
        fillableSlots[slotIndex].media = media
//        = media.setMedia(media: media)
    }
    mutating func convertAllPhotos() {
        for index in fillableSlots.indices {
            fillableSlots[index].generateVideo()
        }
    }
}

enum MediaType {
    case photo
    case video
}

struct Slot: Identifiable {
    let id = UUID().uuidString
    var duration: Double
    var preferredMediaType = MediaType.photo
}

struct FillableSlot: Identifiable {
    let id = UUID().uuidString
    var slot: Slot
    var media: PhotoPickerModel?
    var videoUrl: URL?

    var fileName: String {
        String(self.id) + ".mp4"
    }

    func calculateVideoPath() -> URL? {
        guard let photo = media?.photo else {
            print("NO PHOTO FOUND", media)
            return nil
        }
//        THIS SHOULD HAPPEN AFTER BUILDING IT BUT DOES NOT WORK CAUSE "escaping"
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        guard let documentDirectory = urls.first else {
            fatalError("documentDir Error")
        }
        return documentDirectory.appendingPathComponent(fileName)
    }

    mutating func setMedia(media: PhotoPickerModel) {
        self.media = media
    }
    mutating func generateVideo() {
//        buildVideoFromImageArray(framesArray: [photo], videoOutputURL: filename, frameDuration: self.slot.duration, onComplete: { videoUrl in
//            print("VIDEO GENERATED", videoUrl)
////            self.videoUrl = videoUrl
//        })
//        print("END generateVideo", videoOutputURL)
//        self.videoUrl = videoOutputURL
    }

    var isFilled: Bool {
        return media != nil
    }
    var isPrepared: Bool {
        return videoUrl != nil
    }
}
