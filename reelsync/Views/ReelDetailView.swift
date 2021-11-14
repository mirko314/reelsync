//
//  ReelDetailView.swift
//  reelsync
//
//  Created by Mirko Budszuhn on 12.11.21.
//

import SwiftUI
import Foundation
import VideoEditorSDK
import AVKit

struct ReelDetailView: View {

    @ObservedObject var mediaItems = PickedMediaItems()
    @State private var showPhotoPicker = false
    @State private var showVideoSDK = false
    @ObservedObject var reelsyncViewModel: ReelsyncViewModel
    var body: some View {
        ScrollView {
            VStack {

                NavigationLink(destination: VideoSDKView(urls: videoAsset())) {
                    Text("Edit!")
                }
                Text("\(reelsyncViewModel.template?.sound.totalDuration ?? 0.0)s ")
                Text("Add \(reelsyncViewModel.template?.slots.count ?? 0) Photos to this sound")
//                reelsyncViewModel.fillableSlots.forEach { slot in
//                    MediaSlot(fillableSlot: slot)
//                }
                ForEach(reelsyncViewModel.fillableSlots) { object in
                    MediaSlot(fillableSlot: object)
                }

            }.frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .topLeading
              )
            .navigationTitle(reelsyncViewModel.template?.sound.name ?? "Some Reel")
                .sheet(isPresented: $showPhotoPicker, content: {
                    PhotoPicker(mediaItems: mediaItems) { _ in
                        print("didselectitems")
                        for (index, mediaItem) in mediaItems.items.enumerated() {
                            reelsyncViewModel.importMedia(slotIndex: index, media: mediaItem)
                        }
                        showPhotoPicker = false
                    }

                })
                .toolbar {
                    if reelsyncViewModel.allSlotsFilled {
                        Button(action: reelsyncViewModel.prepareMedia) {
                            Text("Prepare!")
                        }
                    } else {
                        if reelsyncViewModel.allSlotsReady {
                            NavigationLink(destination: VideoSDKView(urls: videoAsset())) {
                                Text("Edit!")
                            }

                        }
                        Button(action: {showPhotoPicker = true}) {
                            Text("Upload")
                        }
                    }
                }
        }
    }

    func videoAsset() -> [URL] {
        let slots = reelsyncViewModel.readySlots
        return slots.compactMap { $0.videoUrl! }
    }
}
struct MediaSlot: View {
    var fillableSlot: FillableSlot

    var body: some View {
        HStack {
            Image(uiImage: fillableSlot.media?.photo ?? UIImage())
                .resizable()
                .frame(width: 70, height: 70, alignment: Alignment.leading)
            Spacer()
            Text("Slot \(String(fillableSlot.slot.duration))s ").frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .leading
              )
            Spacer()
            FilledIndicator(isFilled: fillableSlot.isFilled)

        }.frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
    func openPhotoChooser() {

    }

}

struct FilledIndicator: View {
    var isFilled: Bool
    var body: some View {
        if isFilled {
            Text("☑️").padding(20)
        } else {
            Text("❌").padding(20)
        }
    }
}

struct ReelDetailViewPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            ReelDetailView(reelsyncViewModel: reelSyncViewModelFactory(factoryType: .imagesSelected))

        }
    }
}

struct ReelDetailViewPreviewsTwo: PreviewProvider {
    static var previews: some View {
        Group {
            ReelDetailView(reelsyncViewModel: reelSyncViewModelFactory(factoryType: .soundSelected))

        }
    }
}
