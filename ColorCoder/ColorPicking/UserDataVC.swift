//
//  CoderViewController.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 26/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import UIKit

class UserDataVC: UITableViewController, UserInfoDelegate {

    let userItems: [ExperimentProperty] = [.initials, .age, .sex, .targetSteps, .nodeSteps]
    let cellIdentifier = "TitleCell"
    var userInfo = [ExperimentProperty: String]()
    weak var gameControllerDelegate: GameControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(TitleCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.tableView.tableFooterView  = UIView()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.title = "Please enter User Data"
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userItems.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let selectedCell = self.tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? TitleCell {
            selectedCell.userInfDelegate = self
            selectedCell.userItem = userItems[indexPath.row]
            return selectedCell
        }
        return UITableViewCell()
    }
    
    func updateValue(for item: ExperimentProperty, with value: String) {
        userInfo[item] = value
        if userItems.allSatisfy({userInfo[$0] != nil || userInfo[$0] != ""}) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        self.gameControllerDelegate?.returnUserInfo(userInfo)
    }
    
}

protocol UserInfoDelegate: AnyObject {
    func updateValue(for item: ExperimentProperty, with value: String)
}

protocol GameControllerDelegate: AnyObject {
    func returnUserInfo(_ userInfo: [ExperimentProperty: String])
}


class TitleCell: UITableViewCell, UITextFieldDelegate {

    let titleLabel: UILabel
    var instructionLabel: UILabel!
    var userItem: ExperimentProperty! {
        didSet {
            self.titleText = userItem.displayName
            self.instructionLabel.text = self.userItem.instruction
            if userItem.hasDefault { self.textField.text = userItem.getDefault() }
        }
    }
    weak var userInfDelegate: UserInfoDelegate?
    var textField: UITextField!
    var titleText: String! {
        didSet { self.setTextToTitleLabel() } }

    required init?(coder aDecoder: NSCoder) {
        self.titleLabel = UILabel()
        super.init(coder: aDecoder)
        self.configureCell()
        
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.titleLabel = UILabel()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureCell()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }

    func configureCell() {
        
        self.addTitleLabel()
        self.addTextField()
        self.contentView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        self.constrainElementToContentView()
    }
    
    func addTitleLabel() {
        self.contentView.layer.borderWidth = 2
        self.contentView.layer.borderColor = UIColor(hue: 0.5, saturation: 1.0, brightness: 0.75, alpha: 1.0).cgColor
        self.contentView.layer.cornerRadius = 5
        self.titleLabel.textAlignment   = .right
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(titleLabel)

    }
    
    func constrainElementToContentView() {
        var placementConstraints = [NSLayoutConstraint]()
        placementConstraints.append(NSLayoutConstraint(item: self.contentView, attribute: .leadingMargin, relatedBy: .equal, toItem: titleLabel, attribute: .leading, multiplier: 1, constant: -20))
        placementConstraints.append(NSLayoutConstraint(item: self.contentView, attribute: .topMargin, relatedBy: .equal, toItem: titleLabel, attribute: .top, multiplier: 1, constant: -20))
        placementConstraints.append(NSLayoutConstraint(item: self.contentView, attribute: .trailingMargin, relatedBy: .equal, toItem: self.textField, attribute: .trailing, multiplier: 1, constant: 20))
        placementConstraints.append(NSLayoutConstraint(item: self.contentView, attribute: .bottomMargin, relatedBy: .equal, toItem: self.textField, attribute: .bottom, multiplier: 1, constant: 20))
        
        self.addConstraints(placementConstraints)
    }

    func addTextField() {
        self.textField = UITextField()
        self.textField.borderStyle = .roundedRect
        self.textField.isUserInteractionEnabled = true
        self.textField.delegate = self
        //self.textField.backgroundColor = .lightGray
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.addTarget(self, action: #selector(Self.textFieldDidChange(_:)), for: .editingChanged)
        self.contentView.addSubview(textField)
            //set constraint on label to keep text centered vertically
        

        
        self.instructionLabel = UILabel()
        self.instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.instructionLabel.textColor = .gray
        self.contentView.addSubview(instructionLabel)
        
        let constraints = [
            textField.widthAnchor.constraint(equalToConstant: 100),
            textField.heightAnchor.constraint(equalToConstant: 50),
            instructionLabel.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -20),
            instructionLabel.centerYAnchor.constraint(equalTo: textField.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let typedCharcterSet = CharacterSet(charactersIn: string)
        if self.userItem == .age {
            let allowedCharcterSet = CharacterSet(charactersIn: "1234567890")
            return allowedCharcterSet.isSuperset(of: typedCharcterSet)
        } else if self.userItem == .sex {
            let allowedCharcterSet = CharacterSet(charactersIn: "MFO")
            return allowedCharcterSet.isSuperset(of: typedCharcterSet)
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let newText = textField.text {
            self.userInfDelegate?.updateValue(for: userItem, with: newText)
        }
    }
    
    private func setTextToTitleLabel() {    //didset call
        titleLabel.text = titleText
        titleLabel.sizeToFit()
    }
}
