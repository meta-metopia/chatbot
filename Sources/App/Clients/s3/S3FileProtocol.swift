//
//  File.swift
//  
//
//  Created by Qiwei Li on 2/6/23.
//

import Foundation

protocol S3FileProtocol {
    func upload(from local: URL) async throws -> URL
}
