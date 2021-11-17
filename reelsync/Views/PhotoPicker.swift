//
//  PhotoPicker.swift
//  PHPickerDemo
//
//  Created by Gabriel Theodoropoulos.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController

    @ObservedObject var mediaItems: PickedMediaItems
    var didFinishPicking: (_ didSelectItems: Bool) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .any(of: [.images])
        config.selectionLimit = 0 // context.coordinator.
        config.preferredAssetRepresentationMode = .current

        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(with: self)
    }

    class Coordinator: PHPickerViewControllerDelegate {
        var photoPicker: PhotoPicker

        init(with photoPicker: PhotoPicker) {
            self.photoPicker = photoPicker
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            photoPicker.didFinishPicking(!results.isEmpty)

            guard !results.isEmpty else {
                return
            }

            for result in results {
                let itemProvider = result.itemProvider

                guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first,
                      let utType = UTType(typeIdentifier)
                else { continue }

                if utType.conforms(to: .image) {
                    self.getPhoto(from: itemProvider, isLivePhoto: false)
                } else if utType.conforms(to: .movie) {
                    self.getVideo(from: itemProvider, typeIdentifier: typeIdentifier)
                } else {
                    self.getPhoto(from: itemProvider, isLivePhoto: true)
                }
            }
            print("selected \(results.count) images")

        }

        private func getPhoto(from itemProvider: NSItemProvider, isLivePhoto: Bool) {
            let objectType: NSItemProviderReading.Type = !isLivePhoto ? UIImage.self : PHLivePhoto.self

            if itemProvider.canLoadObject(ofClass: objectType) {
                itemProvider.loadObject(ofClass: objectType) { object, error in
                    if let error = error {
                        print(error.localizedDescription)
                    }

                    if !isLivePhoto {
                        if let image = object as? UIImage {
                            DispatchQueue.main.async {
                                self.photoPicker.mediaItems.append(item: PhotoPickerModel(with: image))
                            }
                        }
                    } else {
                        if let livePhoto = object as? PHLivePhoto {
                            let livePhotoResources = PHAssetResource.assetResources(for: livePhoto)

                            // Extract still images from Live Photo properties(HEIC format)
                            if let imageUrl = livePhoto.value(forKey: "imageURL") as? URL {
                                do {
                                    let data: Data = try Data(contentsOf: imageUrl)

                                    var image = UIImage(data: data)
                                    guard image != nil else {
                                        return
                                    }
                                  DispatchQueue.main.async {
                                      self.photoPicker.mediaItems.append(item: PhotoPickerModel(with: image!))
                                  }
                                } catch {

                                }

//                                [UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]]

                            }

                                // Generate Data from URL (can be obtained because it refers to the data in HEIC
//                                        let data:Data = try Data(contentsOf: imageUrl)

                                // Generate a path and save the image
                                // data.write(to: URL)

                            for resource in livePhotoResources {

                                }
//                                let fileManager = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first.appendingPathComponent(UUID().uuidString() + "")
//                                let urls = fileManager
//                                guard let documentDirectory = urls.first else {
//                                    fatalError("documentDir Error")
//                                }
//                                return documentDirectory
//                                PHAssetResourceManager.defaultManager().writeDataForAssetResource(resource,
//                                    toFile: fileURL, options: nil, completionHandler:
//                                  {
//
//                                     // Video file has been written to path specified via fileURL
//                                    if resource.type == PHAssetResourceType.pairedVideo {
//                                        print("Retreiving live photo data for : paired video")
//                                    }
//
//                                    if resource.type == PHAssetResourceType.photo {
//                                        print("Retreiving live photo data for : photo")
//                                    }

//
//                            DispatchQueue.main.async {
//
//                                self.photoPicker.mediaItems.append(item: PhotoPickerModel(with: livePhoto))
//                            }
                        }
                    }
                }
            }
        }

        private func getVideo(from itemProvider: NSItemProvider, typeIdentifier: String) {
            itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                if let error = error {
                    print(error.localizedDescription)
                }

                guard let url = url else { return }

                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                guard let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent) else { return }

                do {
                    if FileManager.default.fileExists(atPath: targetURL.path) {
                        try FileManager.default.removeItem(at: targetURL)
                    }

                    try FileManager.default.copyItem(at: url, to: targetURL)

                    DispatchQueue.main.async {
                        self.photoPicker.mediaItems.append(item: PhotoPickerModel(with: targetURL))
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
