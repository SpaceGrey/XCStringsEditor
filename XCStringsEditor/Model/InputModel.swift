//
//  SourceModel.swift
//  XCStringsEditor
//
//  Created by 王培屹 on 13/9/24.
//

import Foundation
struct InputModel{
    let text:String,source: String, target: String, format: String = "text", model: String = "base"
    let auxSource: String?
    let auxText: String?
    init(sourceLanguage:String,auxLanguage:String? = nil, item:LocalizeItem){
        self.text = item.sourceString
        self.auxText = item.auxTranslation
        self.source = sourceLanguage
        self.target = item.language.code
        self.auxSource = auxLanguage
    }
    init(text:String,source:String,target:String){
        self.text = text
        self.source = source
        self.target = target
        self.auxSource = nil
        self.auxText = nil
    }
}
