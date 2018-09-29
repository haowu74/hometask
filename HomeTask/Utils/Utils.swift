//
//  Utils.swift
//  HomeTask
//
//  Created by Hao Wu on 30/9/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import Foundation
import CommonCrypto

class Utils {

    public static func getHash(_ string: String) -> String {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}
