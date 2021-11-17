//
//  ReelDetailView.swift
//  reelsync
//
//  Created by Mirko Budszuhn on 12.11.21.
//

import AVKit
import Foundation
import SwiftUI
// import VideoEditorSDK

struct ReelDetailView: View {

  @ObservedObject var mediaItems = PickedMediaItems()
  @State private var showPhotoPicker = false
  @State private var showVideoSDK = false
  @State private var showProgressBar = false
  @ObservedObject var reelsyncViewModel: ReelsyncViewModel
  var body: some View {
    ScrollView {
      VStack {
          TemplateInfoHeader(template: reelsyncViewModel.template!)
          if reelsyncViewModel.isPreparingMedia {
          ProgressView(
            "Preparing…",
            value: Double(reelsyncViewModel.readySlots.count),
            total: Double(reelsyncViewModel.template?.slots.count ?? 0)

          ).padding(20)}
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
      .sheet(
        isPresented: $showPhotoPicker,
        content: {
          PhotoPicker(mediaItems: mediaItems) { _ in
            print("didselectitems")
              DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

                for (index, mediaItem) in mediaItems.items.enumerated() {

                        reelsyncViewModel.importMedia(slotIndex: index, media: mediaItem)

                }
              }
          print("finishselectitems")
            showPhotoPicker = false
          }

        }
      )
      .toolbar {

        if reelsyncViewModel.allSlotsReady {
          NavigationLink(destination: VideoSDKView(urls: videoAsset())) {
            Text("Edit!")
          }

        } else {
          if reelsyncViewModel.allSlotsFilled {
            Button("Prepare") {
            showProgressBar = true
              async {
                await reelsyncViewModel.prepareMedia()
              }
            }
          } else {

            Button(action: { showPhotoPicker = true }) {
              Text("Upload")
            }
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

struct TemplateInfoHeader: View {
  var template: VideoTemplate

  var body: some View {
      HStack {
          Rectangle().frame(width: 70, height: 70, alignment: .leading).background(Color.green)
          VStack {
              Text("\(String(template.sound.totalDuration) )s ")
              Text("Add \(template.slots.count) Photos to this sound")
          }.frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .leading
          )
      }.padding(.leading, 10)
  }
}

struct MediaSlot: View {
  var fillableSlot: FillableSlot

  var body: some View {
    HStack {
      Image(uiImage: fillableSlot.media?.photo ?? UIImage())
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 70, height: 70, alignment: .center)
        .clipped()
        .background(Color.gray)
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
    ).padding(.leading, 10)
  }
  func openPhotoChooser() {

  }

}

struct FilledIndicator: View {
  var isFilled: Bool
  var body: some View {
    if isFilled {
      Image(systemName: "checkmark.circle").padding(20).font(Font.system(.title))
    } else {
      Image(systemName: "circle").padding(20).font(Font.system(.title))
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
