//
//  reelsyncApp.swift
//  reelsync
//
//  Created by Mirko Budszuhn on 12.11.21.
//

import SwiftUI
// swiftlint:disable all
@main
struct ReelsyncApp: App {
    var reelsyncViewModel = ReelsyncViewModel(videoTimeline: VideoTimeline(initTemplate: VideoTemplate(
        sound: SoundMeta(name: "SomeSound ", authorName: "Authorname"),
        slots: [Slot(duration: 0.5), Slot(duration: 0.5), Slot(duration: 0.5), Slot(duration: 0.5), Slot(duration: 0.5), Slot(duration: 0.5)])))
    var body: some Scene {
        WindowGroup {
            HomeView(reelsyncViewModel: reelsyncViewModel)
        }
    }
}
