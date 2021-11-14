//
//  MainViewModel.swift
//  reelsync
//
//  Created by Mirko Budszuhn on 12.11.21.
//

import Foundation
import SwiftUI

class ReelsyncViewModel: ObservableObject {
    @Published private var model: VideoTimeline?
    @Published var shouldShowDetailView = false
    //
    //    static func createReelMaker(videoTimeline: VideoTimeline) {
    //
    //    }
    init(videoTimeline: VideoTimeline?) {
        model  = videoTimeline
    }

    var template: VideoTemplate? {
        model?.template
    }

    var fillableSlots: [FillableSlot] {
        model?.fillableSlots ?? []
    }
    var filledSlotsCount: Int {
        model?.fillableSlots.filter {$0.isFilled}.count ?? 0
    }
    var readySlots: [FillableSlot] {
        model?.fillableSlots.filter {$0.isPrepared} ?? []
    }
    var allSlotsFilled: Bool {
        filledSlotsCount == fillableSlots.count
    }
    var allSlotsReady: Bool {
        readySlots.count == fillableSlots.count
    }

    func importMedia(slotIndex: Int, media: PhotoPickerModel) {
        print("importing ", media, slotIndex)
        model?.importMedia(slotIndex: slotIndex, media: media)
        self.objectWillChange.send()
    }
    func prepareMedia() {
        print("preparing images")
        model?.convertAllPhotos()
    }

    func fetchVideoTemplate(url: String) {
        let template = fetchTemplateByUrl(url: url)
        loadVideoTemplate(videoTemplate: template)
        shouldShowDetailView = true
    }

    func loadVideoTemplate(videoTemplate: VideoTemplate) {
        model = VideoTimeline(initTemplate: videoTemplate)
    }
}

enum ReelSyncViewModelType {
    case home
    case soundSelected
    case imagesSelected
}

func reelSyncViewModelFactory(
    factoryType: ReelSyncViewModelType = ReelSyncViewModelType.soundSelected
) -> ReelsyncViewModel {
    switch factoryType {
    case .home:
        return ReelsyncViewModel(videoTimeline: nil)

    case .soundSelected:
        return ReelsyncViewModel(
            videoTimeline: VideoTimeline(
                initTemplate: VideoTemplate(
                    sound: SoundMeta(name: "SomeSound ", authorName: "Authorname"),
                    slots: Array(repeating: Slot(duration: 0.5), count: 8)
                )
            )
        )
    case .imagesSelected:
        let model = ReelsyncViewModel(
            videoTimeline: VideoTimeline(
                initTemplate: VideoTemplate(
                    sound: SoundMeta(name: "SomeSound ", authorName: "Authorname"),
                    slots: Array(repeating: Slot(duration: 0.5), count: 8)
                )
            )

        )

        let photoNames = (1..<9).map { "SampleImg\($0)" }
        let photos = photoNames.map {
            PhotoPickerModel(
                with: UIImage(
                    named: $0)!
            )

        }
        for index in photos.indices {
            model.importMedia(slotIndex: index, media: photos[index])
        }
        return model
    }
}
