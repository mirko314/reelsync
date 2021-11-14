//
//  ReelDatabase.swift
//  reelsync
//
//  Created by Mirko Budszuhn on 12.11.21.
//

import Foundation

func fetchTemplateByUrl(url: String) -> VideoTemplate {
    //     return dummy data for now
    return VideoTemplate(sound: SoundMeta(name: "Original Audio", authorName: "lumadeline", totalDuration: 8), slots: Array(repeating: Slot(duration: 1), count: 8) )
}
