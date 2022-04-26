//
//  ViewController.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 25/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import UIKit

class MenuViewController: BaseViewController, GameControllerDelegate {

    let buttonList: [ControlItem] = [.practice, .play, .settings, .about]
    
    var encapsulatingNC: UINavigationController?
    var userInfo: [ExperimentProperty: String]?

    @IBOutlet weak var controlStack: UIStackView! {
        didSet {
            self.setupControlButtons()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func setupControlButtons() {
        for controlItem in buttonList {
            let controlButton = self.createButton(for: controlItem)
            self.controlStack.addArrangedSubview(controlButton)
        }
    }

    func createButton(for controlItem: ControlItem) -> UIButton {
        let button = ControlButton(type: .custom)
        button.setTitle(controlItem.displayName, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.controlItem          = controlItem
        button.translatesAutoresizingMaskIntoConstraints    = false
        addHeightConstraint(50, to: button)
        button.layer.borderColor    = UIColor.black.cgColor
        button.layer.cornerRadius   = 10
        button.layer.borderWidth    = 1.5
        button.addTarget(self, action: #selector(MenuViewController.buttonPressed(_:)), for: .touchUpInside)
        return button
    }

    @objc func buttonPressed(_ sender: ControlButton) {
        switch sender.controlItem! {
        case .practice: self.pushGameController()
        case .play: self.runExperiment()
        case .settings: self.pushSettingsController()
        case .about: self.pushAboutController()
        }
    }

    func pushGameController() {
        let gameController  = GameViewController()
        gameController.experimentMode = .practice
        gameController.modalPresentationStyle = .fullScreen
        self.present(gameController, animated: true, completion: nil)
    }

    func runExperiment() {
        let observerQuestionaire = UserDataVC()
        observerQuestionaire.gameControllerDelegate = self
        observerQuestionaire.modalPresentationStyle = .formSheet
        self.encapsulatingNC = UINavigationController(rootViewController: observerQuestionaire)
        let rightButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(MenuViewController.finished(_:)))
        
        observerQuestionaire.navigationItem.setRightBarButton(rightButton, animated: false)
        self.present(self.encapsulatingNC!, animated: true, completion: nil)
    }
                                                                      
    @objc func finished(_ sender: UIBarButtonItem) {
        self.encapsulatingNC?.dismiss(animated: true)
        let gameController  = GameViewController()
        gameController.experimentMode = .experiment
        print("=================")
        print(self.userInfo)
        gameController.userInfo = self.userInfo
        gameController.modalPresentationStyle = .fullScreen
        self.present(gameController, animated: true, completion: nil)
    }
                                                                            
    
    func pushSettingsController() {
        let settingsController  = SettingsViewController()
        self.present(settingsController, animated: true, completion: nil)
    }

    func pushAboutController() {
        let aboutController     = AboutViewController()
        self.present(aboutController, animated: true, completion: nil)
    }
    
    func returnUserInfo(_ userInfo: [ExperimentProperty: String]) {
        self.userInfo = userInfo
    }
    
}

class ControlButton: UIButton {
    var controlItem: ControlItem!
}

enum ControlItem {
    case practice, play, settings, about

    var displayName: String {
        switch self {
        case .practice: return "Practice"
        case .play: return "Play"
        case .settings: return "Settings"
        case .about: return "About"
        }
    }

}
