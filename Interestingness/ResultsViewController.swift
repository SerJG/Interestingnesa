//
//  ResultsViewController.swift
//  Interestingness
//
//  Created by Sergii Gordiienko on 29.01.2022.
//

import UIKit

class ResultsViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var filesizeLabel: UILabel!
    @IBOutlet weak var durationTimeLabel: UILabel!
    
    // MARK: Properties
    private let viewModel: ResultsViewModel
    
    // MARK: - Life cycle
    init?(coder: NSCoder, viewModel: ResultsViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.updateUI()
    }

    // MARK: UI
    private func updateUI() {
        self.filesizeLabel.text = "Total files size: \(self.viewModel.bytesLoaded) bytes"
        let durationFormated = String(format: "%.3f", self.viewModel.duration)
        self.durationTimeLabel.text = "Duration: \(durationFormated) seconds"
    }
    // MARK: User actions
    @IBAction func onDoneAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

