//
//  ContentView.swift
//  reelsync
//
//  Created by Mirko Budszuhn on 12.11.21.
//

import SwiftUI

struct HomeView: View {
    var reelsyncViewModel: ReelsyncViewModel

    @State private var instagramUrl: String = ""
    @State private var isShowingReelDetailView = false

    @FocusState private var emailFieldIsFocused: Bool
    var body: some View {

        NavigationView {
            VStack {
                NavigationLink(
                    destination: ReelDetailView(
                        reelsyncViewModel: reelsyncViewModel
                    ),
                    isActive: $isShowingReelDetailView
                ) { EmptyView() }
                HStack {

                    Button(action: getUrlFromClipboard) {
                        Text("📄")
                    }
                    TextField(
                        "Instagram URL",
                        text: $instagramUrl
                    )
                        .focused($emailFieldIsFocused)
                        .onSubmit {
                            print(instagramUrl)
                        }
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: fetchSoundAction) {
                        Text("Fetch 🔎")
                    }
                }

            }.padding(20) .navigationTitle("Reel Sync")
        }
    }
    func getUrlFromClipboard() {
        let pasteText = UIPasteboard.general.string
        if pasteText != nil && !pasteText!.isEmpty {
            instagramUrl = pasteText!
        }
    }
    func fetchSoundAction() {
        reelsyncViewModel.fetchVideoTemplate(url: instagramUrl)
        self.isShowingReelDetailView = true
    }
    func fetchSound(url: String) {
        print(url)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            reelsyncViewModel: reelSyncViewModelFactory())
    }
}
