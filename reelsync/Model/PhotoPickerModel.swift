//
//  PhotoPickerModel.swift
//  reelsync
//
//  Created by Mirko Budszuhn on 12.11.21.
//

import Foundation
import SwiftUI
import Photos

struct PhotoPickerModel: Identifiable {
    enum MediaType {
        case photo, video, livePhoto
    }

    var id: String
    var photo: UIImage?
    var url: URL?
    var livePhoto: PHLivePhoto?
    var mediaType: MediaType = .photo
    init(with photo: UIImage) {
        id = UUID().uuidString
        self.photo = photo
        mediaType = .photo
    }
    init(with videoURL: URL) {
        id = UUID().uuidString
        url = videoURL
        mediaType = .video
    }

    init(with livePhoto: PHLivePhoto) {
        id = UUID().uuidString
        self.livePhoto = livePhoto
        mediaType = .livePhoto
    }
}
class PickedMediaItems: ObservableObject {

    @Published var items = [PhotoPickerModel]()
    func append(item: PhotoPickerModel) {
        items.append(item)
    }
}
