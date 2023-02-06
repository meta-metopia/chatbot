//
//  File.swift
//  
//
//  Created by Qiwei Li on 2/5/23.
//

import Foundation
import AzureTextToSpeech
import Logging


class AzureTextToSpeechClient: TextToSpeechProtocol {
    let azureTextToSpeech = AzureTextToSpeech()
    let logger = Logger(label: "azure.speech")
    let resourceKey: String
    
    init(resourceKey: String) {
        self.resourceKey = resourceKey
    }
    
    func setup() async throws {
        logger.info("Starting azure authentication process")
        try await self.azureTextToSpeech.authorize(resourceKey: resourceKey, region: .eastAsia)
        let voice = AzureVoice(shortName: "zh-CN-XiaoyanNeural", locale: "zh-CN", gender: "female")
        await self.azureTextToSpeech.pickVoice(voice: voice)
        await self.azureTextToSpeech.pickFormat(format: .ogg48kHz16bitMonoOpus)
        logger.info("Finished azure authentication process")
    }
    
    func cleanup() async throws {
        
    }
    
    func toAudio(_ text: String, fileName: String) async throws -> URL {
        logger.debug("Starting audio generation")
        let downloadDest = URL(fileURLWithPath: fileName)
        try await self.azureTextToSpeech.generateForDownload(text: text, destination: downloadDest, onStart: {
            
        }, onDownload: { _ in
            
        })
        logger.debug("Audio generation success. Dest: \(downloadDest)")
        return downloadDest
    }
}
