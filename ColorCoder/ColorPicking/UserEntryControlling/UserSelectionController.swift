//
//  CoderViewController.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 26/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import UIKit

class UserSelectionController: UIViewController, ChoiceDelegate {

    var users: [String]!
    var userSelButton: UIButton!
    var selectionController: SelectionViewController?
    var userSelLabel: UILabel!
    var selectedUser: String? {
        didSet {
            self.userSelLabel.text = self.selectedUser
            self.userSelected = (self.selectedUser != nil)
        }
    }
    var userSelected: Bool = false {
        didSet { self.parent?.navigationItem.rightBarButtonItem?.isEnabled = userSelected }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "Existing User"
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.setupLabels()
        self.setupSelectionButton()
    }
    
    private func setupLabels() {
        let userInstrLabel = UILabel()
        userInstrLabel.text = "Selected User:"
        userInstrLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(userInstrLabel)
        
        self.userSelLabel = UILabel()
        self.userSelLabel.text = "Select User via button, please"
        self.userSelLabel.textColor = .gray
        self.userSelLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(userSelLabel)
        self.constrainLabels(userInstrLabel, userSelLabel)
        
    }
    
    private func setupSelectionButton() {
        self.userSelButton = UIButton()
        self.userSelButton.layer.borderColor = UIColor.systemBlue.cgColor
        self.userSelButton.layer.borderWidth = 4
        self.userSelButton.layer.cornerRadius = 10
        self.userSelButton.setTitle("Select User", for: .normal)
        self.userSelButton.setTitleColor(.black, for: .normal)
        self.userSelButton.translatesAutoresizingMaskIntoConstraints = false
        self.userSelButton.addTarget(self, action: #selector(UserSelectionController.showPopup(_:)), for: .touchUpInside)
        self.view.addSubview(self.userSelButton)
        self.constrainButton()
    }

    @objc func showPopup(_ control: UIButton) {
        self.selectionController = SelectionViewController()
        self.selectionController!.users = users
        self.selectionController!.modalPresentationStyle = .popover
        self.selectionController!.popoverPresentationController?.sourceView = self.userSelButton
        self.selectionController!.popoverPresentationController?.sourceRect = self.userSelButton.frame
        self.selectionController!.choiceDelegate = self
        self.present(selectionController!, animated: true, completion: nil)
    }

    func constrainLabels(_ label1: UILabel, _ label2: UILabel) {
        var placementConstraints = [NSLayoutConstraint]()
        placementConstraints.append(NSLayoutConstraint(item: self.view!, attribute: .leadingMargin, relatedBy: .equal, toItem: label1, attribute: .leading, multiplier: 1, constant: -50))
        placementConstraints.append(NSLayoutConstraint(item: self.view!, attribute: .trailingMargin, relatedBy: .equal, toItem: label2, attribute: .trailing, multiplier: 1, constant: 50))
        placementConstraints.append(NSLayoutConstraint(item: self.view!, attribute: .topMargin, relatedBy: .equal, toItem: label1, attribute: .top, multiplier: 1, constant: -50))
        placementConstraints.append(NSLayoutConstraint(item: label1, attribute: .centerY, relatedBy: .equal, toItem: label2, attribute: .centerY, multiplier: 1, constant: 0))

        
        self.view.addConstraints(placementConstraints)
    }
    
    func constrainButton() {
        var placementConstraints = [NSLayoutConstraint]()
        placementConstraints.append(NSLayoutConstraint(item: self.view!, attribute: .centerX, relatedBy: .equal, toItem: self.userSelButton, attribute: .centerX, multiplier: 1, constant: 0))
        placementConstraints.append(NSLayoutConstraint(item: self.view!, attribute: .centerY, relatedBy: .equal, toItem: self.userSelButton, attribute: .centerY, multiplier: 1, constant: 0))
        
        NSLayoutConstraint.activate([
            self.userSelButton.heightAnchor.constraint(equalToConstant: 60),
            self.userSelButton.widthAnchor.constraint(equalToConstant: 150)])
        
        self.view.addConstraints(placementConstraints)
    }
    
    func selected(_ selectedIndex: Int) {
        self.selectedUser = users[selectedIndex]
        self.userSelLabel.textColor = .systemBlue
        
        self.selectionController?.dismiss(animated: true)
        self.selectionController = nil
    }
    
    
}


class SelectionViewController: UITableViewController {
    
    var users: [String]!
    weak var choiceDelegate: ChoiceDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let reusableCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") {
            reusableCell.textLabel?.text = self.users[indexPath.row]
            return reusableCell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choiceDelegate?.selected(indexPath.row)
    }
}
