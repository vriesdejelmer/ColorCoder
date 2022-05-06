//
//  UserProfileController.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 05/05/2022.
//  Copyright © 2022 Jelmer de Vries. All rights reserved.
//

import UIKit

class UserProfileController: UIViewController, UITableViewDataSource, UITableViewDelegate, UserInfoDelegate {

    var tableView: UITableView!
    let userItems: [ExperimentParameter] = [.initials, .age, .sex]
    let cellIdentifier = "TitleCell"
    var createButton: UIButton!
    var dataDelegate: DataDelegate?
    var userInfo = [ExperimentParameter: String]() {
        didSet {
            self.parent?.navigationItem.rightBarButtonItem?.isEnabled = self.allUserItemsFilled
        }
    }
    var allUserItemsFilled: Bool {
        if self.userItems.allSatisfy({userInfo[$0] != nil && userInfo[$0] != ""}) { return true }
        return false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.setupTableView()
        self.addCreateButton()
        
        self.setupConstraints()
        self.title = "New User"
    }
    
    func addCreateButton() {
        self.createButton = UIButton(type: .custom)
        self.createButton.layer.borderColor = UIColor.systemGreen.cgColor
        self.createButton.layer.borderWidth = 4
        self.createButton.layer.cornerRadius = 10
        self.createButton.setTitle("Create User", for: .normal)
        self.createButton.setTitleColor(.black, for: .normal)
        self.createButton.translatesAutoresizingMaskIntoConstraints = false
        self.createButton.addTarget(self, action: #selector(UserProfileController.createUser(_:)), for: .touchUpInside)
        self.view.addSubview(self.createButton)
    }
    
    @objc func createUser(_ sender: UIButton) {
        if let initials = self.userInfo[.initials] {

            if self.dataDelegate?.isExistingUser(initials) ?? false {
                let userExistsAlert = UIAlertController(title: "User Exists", message: "This user already exists. If you created a profile before, you can start/continue the experiment. If this isn't you, please chose different initials", preferredStyle: .alert)
                
                userExistsAlert.addAction(UIAlertAction(title: "Great!", style: .default))
                self.present(userExistsAlert, animated: true)
            } else if let profile = self.dataDelegate?.createUserProfile(for: self.userInfo) {
                let userCreatedAlert = UIAlertController(title: "User Created", message: "You have created a new user (with initials: \(profile.initials)), you can now select this user and run an experiment", preferredStyle: .alert)
                
                userCreatedAlert.addAction(UIAlertAction(title: "Great!", style: .default) {_ in
                    self.dismiss(animated: true)
                })
                
                self.present(userCreatedAlert, animated: true)
            } else {
                let creatingUnsuccessful = UIAlertController(title: "Problem creating user", message: "We had an issue creating this profile, please try again.", preferredStyle: .alert)
                creatingUnsuccessful.addAction(UIAlertAction(title: "Hmmmmm", style: .default) {_ in
                    self.dismiss(animated: true)
                })
                self.present(creatingUnsuccessful, animated: true)
            }
        }
        
        
        
    }
    
    func setupTableView() {
        self.tableView = UITableView()
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.layer.cornerRadius = 15
        self.tableView.register(TitleCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.tableView.tableFooterView  = UIView()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.view.addSubview(tableView)
        
    }
    
    func setupConstraints() {
        let tableViewConstraints = [NSLayoutConstraint(item: self.createButton!, attribute: .top, relatedBy: .equal, toItem: self.tableView, attribute: .bottom, multiplier: 1, constant: 20),
        NSLayoutConstraint(item: self.view!, attribute: .leadingMargin, relatedBy: .equal, toItem: self.tableView, attribute: .leading, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: self.view!, attribute: .trailingMargin, relatedBy: .equal, toItem: self.tableView, attribute: .trailing, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: self.view!, attribute: .topMargin, relatedBy: .equal, toItem: self.tableView, attribute: .top, multiplier: 1, constant: 0)]
        self.view.addConstraints(tableViewConstraints)
        
        let buttonConstraints = [NSLayoutConstraint(item: self.view!, attribute: .bottomMargin, relatedBy: .equal, toItem: self.createButton, attribute: .bottom, multiplier: 1, constant: 20),
        NSLayoutConstraint(item: self.view!, attribute: .trailingMargin, relatedBy: .equal, toItem: self.createButton, attribute: .trailing, multiplier: 1, constant: 0)]
        self.view.addConstraints(buttonConstraints)
                               
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let selectedCell = self.tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? TitleCell {
            selectedCell.userInfDelegate = self
            selectedCell.userItem = userItems[indexPath.row]
            return selectedCell
        }
        return UITableViewCell()
    }
    
    func updateValue(for item: ExperimentParameter, with value: String) {
        userInfo[item] = value
    }
    
}
