//
//  SceneDelegate.swift
//  ValifySDKApp
//
//  Created by Peter Samir on 29/08/2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let homeViewController = HomeViewController()
        window?.rootViewController = homeViewController
        window?.makeKeyAndVisible()
    }
}

