//
//  KeyChainHelper.swift
//  SigninWithAppleExample
//
//  Created by Huiping Guo on 2020/01/21.
//  Copyright © 2020 Huiping Guo. All rights reserved.
//

import Foundation

struct KeyChainHelper {

    private static let accountStr = "USER_ACCOUNT"

    static func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else {
            return
        }

        let dic: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                  kSecAttrGeneric as String: key,
                                  kSecAttrAccount as String: accountStr,
                                  kSecValueData as String: data]

        var itemAddStatus: OSStatus?
        // 保存データが存在するかの確認
        let matchingStatus = SecItemCopyMatching(dic as CFDictionary, nil)
        if matchingStatus == errSecItemNotFound {
            itemAddStatus = SecItemAdd(dic as CFDictionary, nil)
        } else if matchingStatus == errSecSuccess {
            itemAddStatus = SecItemUpdate(dic as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        }
        // 保存・更新ステータス確認
        if itemAddStatus == errSecSuccess {
            print("正常終了")
        } else {
            print("保存失敗")
        }
    }

    static func getValue(key: String) -> String? {
        let dic: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                  kSecAttrGeneric as String: key,
                                  kSecReturnData as String: kCFBooleanTrue as Any]

        var data: AnyObject?
        let matchingStatus = withUnsafeMutablePointer(to: &data) {
            SecItemCopyMatching(dic as CFDictionary, UnsafeMutablePointer($0))
        }

        if matchingStatus == errSecSuccess {
            print("取得成功")
            if let getData = data as? Data,
                let getStr = String(data: getData, encoding: .utf8) {
                return getStr
            }

            return nil
        } else {
            return nil
        }
    }

    static func deleteKeyChain(key: String) {
        let dic: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                  kSecAttrGeneric as String: key,
                                  kSecAttrAccount as String: accountStr]

        if SecItemDelete(dic as CFDictionary) == errSecSuccess {
            print("削除成功")
        } else {
            print("削除失敗")
        }
    }
}
