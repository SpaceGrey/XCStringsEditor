//
//  AuxLanguageTip.swift
//  XCStringsEditor
//
//  Created by 王培屹 on 3/2/25.
//

import Foundation
import TipKit
struct AuxLanguageTip: Tip{
    var title: Text {
        Text("Select an Auxiliary Language")
    }
    var message: Text? {
        Text("You can select an auxiliary language translation and input with your default localization into the LLM to get a better result. ")
    }
    var image: Image? {
        Image(systemName: "translate")
    }
    var options: [Option] {
            Tips.MaxDisplayCount(1)
        }
}

