//
//  SceneDelegate.swift
//  Interestingness
//
//  Created by Sergii Gordiienko on 29.01.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let coordinator = Coordinator()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        self.window = UIWindow(windowScene: scene)
        
        let rootVC = self.coordinator.rootViewController()
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
    }
}

class Coordinator {
    
    func rootViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: UIStoryboard.mainStoryboardID, bundle: nil)
        let loadImagesVC = storyboard.instantiateViewController(identifier: LoadPhotosViewController.storyboardID, creator: { coder -> LoadPhotosViewController? in
            let imageProvider = PhotosProvider()
            let vm = LoadPhotosViewModel(imageProvider: imageProvider)
            imageProvider.delegate = vm
            return LoadPhotosViewController(coder: coder, viewModel: vm)
        }) as LoadPhotosViewController
        
        loadImagesVC.transitionToDetails = { [unowned loadImagesVC, unowned self] (bytes:Int, time: TimeInterval) in
            let resultsVC = self.resultsViewController(filesize: bytes, duration: time)
            loadImagesVC.present(resultsVC, animated: true, completion: nil)
        }
        
        let navigatioVC = UINavigationController(rootViewController: loadImagesVC)
        return navigatioVC
    }
    
    private func resultsViewController(filesize: Int, duration time: TimeInterval) -> UIViewController  {
        let storyboard = UIStoryboard(name: UIStoryboard.mainStoryboardID, bundle: nil)
        let resultsVC = storyboard.instantiateViewController(identifier: ResultsViewController.storyboardID, creator: { coder -> ResultsViewController? in
            let vm = ResultsViewModel(duration: time, bytesLoaded: filesize)
            return ResultsViewController(coder: coder, viewModel: vm)
        })
        
        let navigatioVC = UINavigationController(rootViewController: resultsVC)
        return navigatioVC
    }
}
