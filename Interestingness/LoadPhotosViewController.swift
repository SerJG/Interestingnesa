//
//  LoadPhotosViewController.swift
//  Interestingness
//
//  Created by Sergii Gordiienko on 29.01.2022.
//

import UIKit

class LoadPhotosViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var requestBtn: UIButton!
    
    private let viewModel: LoadPhotosViewModel
    
    /// Navigation callback
    var transitionToDetails: ((_ filesize: Int,_  time: TimeInterval)->Void)?
    
    // MARK: - Life cycle
    init?(coder: NSCoder, viewModel: LoadPhotosViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViewModelCallbacks()
    }
    
    // MARK: UI
    private func setupViewModelCallbacks() {
        
        self.viewModel.onLoadImageUpdate = { [unowned self] in
            self.updateLabelText()
        }
        
        self.viewModel.onLoadFinish = { [unowned self] filesize, time in
            self.inactiveLoadingUI()
            if let transitionToDetails = self.transitionToDetails {
                transitionToDetails(filesize, time)
            }
        }
        
        self.viewModel.onError = { [unowned self] error in
            self.inactiveLoadingUI()
            self.displayError(error)
        }
    }
    
    private func activeLoadingUI() {
        self.requestBtn.isEnabled = false
        self.statusLabel.isHidden = false
        self.startSpinner()
        self.updateLabelText()
    }
    
    private func inactiveLoadingUI() {
        self.requestBtn.isEnabled = true
        self.stopSpinner()
    }
    
    private func startSpinner() {
        self.activityIndicator.startAnimating()
    }
    
    private func stopSpinner() {
        self.activityIndicator.stopAnimating()
    }
    
    private func updateLabelText() {
        let loaded = self.viewModel.numberOfLoadedImages()
        let total = self.viewModel.numberOfRequestedPhotos
        let bytes = self.viewModel.totalRecievedBytes
        self.statusLabel.text = "\(loaded) of \(total) images downloaded (\(bytes) bytes)."
    }
    
    func displayError(_ error: PhotosLoadError) {
        // TODO: proper handler for error types
        let alert = UIAlertController(title: "Ooops", message: "🤷🏻‍♂️", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: User actions
    @IBAction func onRequestButtonAction(_ sender: UIButton) {
        self.activeLoadingUI()
        self.viewModel.requestPhotos()
    }
    
}
