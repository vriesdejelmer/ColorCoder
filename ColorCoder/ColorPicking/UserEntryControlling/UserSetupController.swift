////
////  UserInfoController.swift
////  ColorCoder
////
////  Created by Jelmer de Vries on 03/05/2022.
////  Copyright © 2022 Jelmer de Vries. All rights reserved.
////
//
//import UIKit
//
//class UserSetupController: UITabBarController, UITabBarControllerDelegate {
//    
//    var rightButton: UIBarButtonItem!
//    var activeUserProfiles: [String]! {
//        didSet { self.observerSelection.users = activeUserProfiles }
//    }
//    var observerQuestionaire: ExperimentEntryController!
//    var observerSelection: UserSelectionController!
//    weak var dataDelegate: DataDelegate?
//    weak var runDelegate: ExperimentRunDelegate?
//    
//    override func viewDidLoad() {
//        self.title = "User Selection"
//        
//        self.observerQuestionaire = ExperimentEntryController()
//        self.observerSelection = UserSelectionController()
//        
//        self.addChild(observerQuestionaire)
//        self.addChild(observerSelection)
//        
//        self.delegate = self
//        
//        self.rightButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(UserSetupController.finished(_:)))
//        self.rightButton.isEnabled = false
//        self.navigationItem.setRightBarButton(rightButton, animated: false)
//    }
//    
//    @objc func finished(_ button: UIBarButtonItem) {
//        
//        if let userEntry = self.selectedViewController as? ExperimentEntryController {
//            if self.dataDelegate?.isExistingUser(userEntry.expInfo[.initials]!) ?? false {
//                let userExists = UIAlertController(title: "This user already exists", message: "Duplicate initials are not possible. If you have already created a profile on this ipad, please select the \"Existing User\" tab at the bottom. Else select different initials", preferredStyle: .alert)
//
//                userExists.addAction(UIAlertAction(title: "Understood", style: .default))
//
//                self.present(userExists, animated: false)
//                
//            } else {
//                self.dismiss(animated: true) {
//                    var expInfo = userEntry.expInfo
//                    expInfo[.backgroundShade] = "\(GeneralSettings.backgroundGray)"
//                    expInfo[.nodeDiameter] = "\(GeneralSettings.nodeDiameter)"
//                    expInfo[.nodeEccentricity] = "\(GeneralSettings.nodeEccentricity)"
//                    //self.runDelegate?.startExperiment(userEntry.expInfo)
//                }
//            }
//        }
//        else if let userSel = self.selectedViewController as? UserSelectionController, let selectedUser = userSel.selectedUser {
//            self.dismiss(animated: true) {
//                let initialDict: [ExperimentParameter: String] = [.initials: selectedUser]
//                //self.runDelegate?.startExperiment(initialDict)
//            }
//        }
//    }
//    
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        if let userEntry = viewController as? ExperimentEntryController {
//            //self.rightButton.isEnabled = userEntry.allUserItemsFilled
//        } else if let userSel = viewController as? UserSelectionController {
//            self.rightButton.isEnabled = userSel.userSelected
//        }
//    }
//    
//}
