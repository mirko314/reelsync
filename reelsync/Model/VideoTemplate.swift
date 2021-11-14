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
        fillableSlots[slotIndex].setMedia(media: media)
        print("importing", slotIndex, media)
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

    mutating func setMedia(media: PhotoPickerModel) {
        self.media = media
    }
    mutating func generateVideo() {
        let filename = String(self.id) + ".mp4"
        guard let photo = media?.photo else {
            print("NO PHOTO FOUND", media)
            return
        }
//        THIS SHOULD HAPPEN AFTER BUILDING IT BUT DOES NOT WORK CAUSE "escaping"
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        guard let documentDirectory = urls.first else {
            fatalError("documentDir Error")
        }

        let videoOutputURL = documentDirectory.appendingPathComponent(filename)

        buildVideoFromImageArray(framesArray: [photo], videoPath: filename, frameDuration: self.slot.duration, onComplete: { videoUrl in
            print("VIDEO GENERATED", videoUrl)
//            self.videoUrl = videoUrl
        })
        print("END generateVideo", videoOutputURL)
        self.videoUrl = videoOutputURL
    }

    var isFilled: Bool {
        return media != nil
    }
    var isPrepared: Bool {
        return videoUrl != nil
    }
}
