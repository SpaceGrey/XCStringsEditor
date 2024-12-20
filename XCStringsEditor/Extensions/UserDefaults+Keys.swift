//
//  UserDefaults+Keys.swift
//  XCStringsEditor
//
//  Created by William Alexander on 14/06/2024.
//

import Foundation

extension UserDefaults {
    
    enum Keys {
        static var googleTranslateAPIKey = "GoogleTranslateAPIKey"
        static var deeplAPIKey = "DeeplAPIKey"
        static var translationService = "TranslateService"
        static var baiduAPIKey = "BaiduAPIKey"
        static var baiduAppID = "BaiduAppID"
        static var llmAPIKey = "LLMAPIKey"
        static var llmURL = "LLMURL"
        static var llmModel = "LLMModel"
    }
    
    var googleTranslateAPIKey: String {
        string(forKey: Keys.googleTranslateAPIKey) ?? ""
    }
    var llmAPIKey: String {
        string(forKey: Keys.llmAPIKey) ?? ""
    }
    var llmURL: String {
        string(forKey: Keys.llmURL) ?? ""
    }
    var llmModel: String {
        string(forKey: Keys.llmModel) ?? ""
    }
    var deeplAPIKey: String {
        string(forKey: Keys.deeplAPIKey) ?? ""
    }
    var baiduAPIKey: String {
        string(forKey: Keys.baiduAPIKey) ?? ""
    }
    var baiduAppID: String {
        string(forKey: Keys.baiduAppID) ?? ""
    }
    
    var translationService: TranslateService {
        guard 
            let rawValue = string(forKey: Keys.translationService),
            let translationService = TranslateService(rawValue: rawValue)
        else {
            return .google
        }
        return translationService
    }
}
