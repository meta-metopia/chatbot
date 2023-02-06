//
//  File.swift
//  
//
//  Created by Qiwei Li on 2/5/23.
//

import Foundation

protocol TextToSpeechProtocol {
    func setup() async throws
    func toAudio(_ text: String, fileName: String) async throws -> URL
    func cleanup() async throws
}
