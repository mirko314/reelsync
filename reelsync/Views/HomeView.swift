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
//    var gridLayout = Array(repeating: LazyVGrid.init(LazyVGrid.flexible()), count: 8)

    @FocusState private var emailFieldIsFocused: Bool
    var body: some View {

        NavigationView {
            VStack(alignment: .leading) {
                NavigationLink(
                    destination: ReelDetailView(
                        reelsyncViewModel: reelsyncViewModel
                    ),
                    isActive: $isShowingReelDetailView
                ) { EmptyView() }
                HStack {
                    Button(action: getUrlFromClipboard) {
                        Image(systemName: "doc.on.clipboard")

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
                        Text("Fetch")
                        Image(systemName: "magnifyingglass.circle")
                    }
                }
                VStack {
                    Text("Trending Audio").font(.largeTitle)

                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 20))
                    ], spacing: 20) {
                        ForEach((1...100).map { "Item \($0)" }, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: 20, height: 20)
//                            Text(item)
                        }
                    }
                }

                Text("Reel Ideas").font(.largeTitle)
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
