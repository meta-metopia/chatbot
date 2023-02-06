//
//  File.swift
//  
//
//  Created by Qiwei Li on 2/6/23.
//

import Foundation
import SotoS3
import Vapor

enum S3FileClientErrors: LocalizedError {
    case missingAccessKey
    case missingSecretKey
    case missingRegion
    case missingEndpoint
    case missingBucket
    case missingPublicEndpoint
}

class S3FileClient: S3FileProtocol {
    private let client: AWSClient
    private let s3: S3
    private let bucket: String
    private let publicEndpoint: String
    
    init() throws {
        guard let accessKey = Environment.get("AWS_ACCESS_KEY") else {
            throw S3FileClientErrors.missingAccessKey
        }
        
        guard let secretKey = Environment.get("AWS_SECRET_KEY") else {
            throw S3FileClientErrors.missingSecretKey
        }
        
        guard let region = Environment.get("AWS_REGION") else {
            throw S3FileClientErrors.missingRegion
        }
        
        guard let endpoint = Environment.get("AWS_ENDPOINT") else {
            throw S3FileClientErrors.missingEndpoint
        }
        
        guard let bucket = Environment.get("AWS_BUCKET") else {
            throw S3FileClientErrors.missingBucket
        }
        
        guard let publicEndpoint = Environment.get("AWS_PUBLIC_ENDPOINT") else {
            throw S3FileClientErrors.missingPublicEndpoint
        }
        
        client = AWSClient(credentialProvider: .static(accessKeyId: accessKey, secretAccessKey: secretKey), httpClientProvider: .createNew)
        
        s3 = S3(client: client, region: .init(rawValue: region) ,endpoint: endpoint)
        self.bucket = bucket
        self.publicEndpoint = publicEndpoint
    }
    
    func upload(from local: URL) async throws -> URL {
        let data = try Data(contentsOf: local)
        let key = local.lastPathComponent
        let putObjectRequest = S3.PutObjectRequest(acl: .publicRead, body: .data(data), bucket: bucket, key: key)
        _ = try await s3.putObject(putObjectRequest)
        return (URL(string: publicEndpoint)!.appending(component: bucket).appending(component: key))
    }
}
