//
//  ViewController.swift
//  SigninWithAppleExample
//
//  Created by Huiping Guo on 2020/01/21.
//  Copyright © 2020 Huiping Guo. All rights reserved.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController {

    @IBOutlet var loginProviderStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSigninWithAppleButton()
    }
    
    
    func configureSigninWithAppleButton() {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .default, authorizationButtonStyle: .black)
        
        button.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        
        loginProviderStackView.addArrangedSubview(button)
    }
    
    @objc func handleAuthorizationAppleIDButtonPress() {
        request()
    }
    
    func request() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email,.fullName]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func checkAppleUserLoginStatus(completion: @escaping ((Bool) -> Void)) {
        guard let appleUserID = KeyChainHelper.getValue(key: "APPLE_USER_ID") else {
            completion(false)
            return
        }

        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: appleUserID) { credentialState, _ in
            completion(credentialState == .authorized)
        }
    }
    
    func login(identityToken: String) {
        
    }
    
    func register(identityToken: String, email: String, nickName: String) {
        
    }
}


extension ViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }

        // user id token
        let identityTokenString: String?

        if let identityToken = credentials.identityToken {
            identityTokenString = String(bytes: identityToken, encoding: .utf8)
        } else {
            identityTokenString = nil
        }

        // save user id to keychain, will use it to check user login status
        KeyChainHelper.save(key: "APPLE_USER_ID", value: credentials.user)

        // save user data to keychain, can only get user data first time.
        if let nickName = credentials.fullName?.nickname, let email = credentials.email {
            KeyChainHelper.save(key: "APPLE_USER_NICKNAME", value: nickName)
            KeyChainHelper.save(key: "APPLE_USER_EMAIL", value: email)
            
            register(identityToken: identityTokenString, email: email, nickName: nickName)
        } else {
            login(identityToken: identityTokenString)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // error
    }
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindow!
    }
}
