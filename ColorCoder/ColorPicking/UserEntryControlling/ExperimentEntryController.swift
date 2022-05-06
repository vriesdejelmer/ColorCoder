//
//  CoderViewController.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 26/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import UIKit

class ExperimentEntryController: UIViewController, UserInfoDelegate, UITableViewDelegate, UITableViewDataSource, ChoiceDelegate {

    var rightButton: UIBarButtonItem!
    var tableView: UITableView!
    let userItems: [ExperimentParameter] = [.targetSteps, .nodeSteps, .nodeDiameter, .nodeEccentricity, .backgroundShade]
    var expInfo: [ExperimentParameter: String] = [.targetSteps: "35", .nodeSteps: "35", .nodeDiameter: "\(GeneralSettings.nodeDiameter)", .nodeEccentricity: "\(GeneralSettings.nodeEccentricity)", .backgroundShade: "\(GeneralSettings.backgroundGray)"]
    let cellIdentifier = "TitleCell"
    var expData: ExperimentData?

    
    weak var dataDelegate: DataDelegate?
    weak var runDelegate: ExperimentRunDelegate?
    
    var users: [String]!
    var userSelButton: UIButton!
    var versionSelection: UISegmentedControl!
    var selectionController: SelectionViewController?
    var userSelectionLabel: UILabel!
    var selectedUser: String? {
        didSet { self.newUserSelected(selectedUser!) }
    }
    var userSelected: Bool = false {
        didSet { self.parent?.navigationItem.rightBarButtonItem?.isEnabled = userSelected }
    }
    
    var cellsEnabled = true {
        didSet {
            for cell in self.tableView.visibleCells {
                cell.isUserInteractionEnabled = cellsEnabled
            }
        }
    }
    
    func newUserSelected(_ userInitials: String) {
        self.userSelButton.setTitle(userInitials, for: .normal)
         if let expData = self.dataDelegate?.hasUnfinishedVersions(for: userInitials) {
            self.cellsEnabled = false
            self.populateTable(with: expData)
            self.versionSelection.isEnabled = true
            self.versionSelection.selectedSegmentIndex = 1
            self.expData = expData
        } else {
            self.cellsEnabled = true
            self.versionSelection.isEnabled = false
        }
        self.expInfo[.initials] = userInitials
        self.rightButton.isEnabled = true
    }
    
    func populateTable(with expData: ExperimentData) {
        expInfo[.backgroundShade] = "\(expData.backgroundShade)"
        expInfo[.nodeDiameter] = "\(expData.stimulusDiameter)"
        expInfo[.nodeEccentricity] = "\(expData.centerDistance)"
        expInfo[.targetSteps] = "\(expData.targetSteps)"
        expInfo[.nodeSteps] = "\(expData.nodeSteps)"
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addUserSelection()
        self.addNewVersionSwitch()
        self.setupTableView()
        
        self.view.backgroundColor = .white
        self.title = "Start Experiment"
        
        self.rightButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ExperimentEntryController.finished(_:)))
        self.rightButton.isEnabled = false
        self.navigationItem.setRightBarButton(rightButton, animated: false)
    }
    
    func addNewVersionSwitch() {
        let newVersionLabel = UILabel()
        newVersionLabel.text = "Continue Previous Version:"
        newVersionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(newVersionLabel)
        
        self.versionSelection = UISegmentedControl(items: ["No", "Yes"])
        self.versionSelection.translatesAutoresizingMaskIntoConstraints = false
        self.versionSelection.selectedSegmentIndex = 0
        self.versionSelection.selectedSegmentTintColor = .systemGreen
        self.versionSelection.addTarget(self, action: #selector(ExperimentEntryController.versionSwitch(_:)), for: .valueChanged)
        self.versionSelection.isEnabled = false
        self.view.addSubview(self.versionSelection)
        self.constrainLabelSwitch(newVersionLabel, self.versionSelection)
    }
    
    @objc func versionSwitch(_ sender: UISegmentedControl) {
        self.cellsEnabled = sender.selectedSegmentIndex == 0
    }
    
    func setupTableView() {
        self.tableView = UITableView()
        
        self.tableView.register(TitleCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.tableView.tableFooterView  = UIView()
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.layer.cornerRadius = 20
        self.tableView.delegate = self
        self.view.addSubview(tableView)
        
        self.constraintTable()
        
    }
    
    func constraintTable() {
        let tableViewConstraints = [NSLayoutConstraint(item: self.view!, attribute: .bottomMargin, relatedBy: .equal, toItem: self.tableView, attribute: .bottom, multiplier: 1, constant: 20),
        NSLayoutConstraint(item: self.view!, attribute: .leadingMargin, relatedBy: .equal, toItem: self.tableView, attribute: .leading, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: self.view!, attribute: .trailingMargin, relatedBy: .equal, toItem: self.tableView, attribute: .trailing, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: self.versionSelection!, attribute: .bottom, relatedBy: .equal, toItem: self.tableView, attribute: .top, multiplier: 1, constant: -30)]
        self.view.addConstraints(tableViewConstraints)
   }
    
    func constrainLabelButton(_ label: UILabel, _ button: UIButton) {
        let placementConstraints = [
            NSLayoutConstraint(item: self.view!, attribute: .leadingMargin, relatedBy: .equal, toItem: label, attribute: .leading, multiplier: 1, constant: -50),
        NSLayoutConstraint(item: self.view!, attribute: .trailingMargin, relatedBy: .equal, toItem: button, attribute: .trailing, multiplier: 1, constant: 50),
        NSLayoutConstraint(item: self.view!, attribute: .topMargin, relatedBy: .equal, toItem: label, attribute: .top, multiplier: 1, constant: -50),
        NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: button, attribute: .centerY, multiplier: 1, constant: 0)]
        self.view.addConstraints(placementConstraints)
        
        let buttonConstraints = [ self.userSelButton.heightAnchor.constraint(equalToConstant: 45),
                                  self.userSelButton.widthAnchor.constraint(equalToConstant: 150)]
        
        self.userSelButton.addConstraints(buttonConstraints)
    }
    
    
    func constrainLabelSwitch(_ label: UILabel, _ switchControl: UISegmentedControl) {
        let placementConstraints = [
            NSLayoutConstraint(item: self.view!, attribute: .leadingMargin, relatedBy: .equal, toItem: label, attribute: .leading, multiplier: 1, constant: -50),
            NSLayoutConstraint(item: self.view!, attribute: .trailingMargin, relatedBy: .equal, toItem: switchControl, attribute: .trailing, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: self.userSelButton!, attribute: .topMargin, relatedBy: .equal, toItem: switchControl, attribute: .top, multiplier: 1, constant: -50),
        NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: switchControl, attribute: .centerY, multiplier: 1, constant: 0)]

        
        self.view.addConstraints(placementConstraints)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expInfo.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let selectedCell = self.tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? TitleCell {
            selectedCell.userInfDelegate = self
            selectedCell.userItem = userItems[indexPath.row]
            selectedCell.isUserInteractionEnabled = self.cellsEnabled
            selectedCell.titleText = userItems[indexPath.row].displayName
            if let setValue = expInfo[selectedCell.userItem] {
                selectedCell.textField.text = setValue
            }
            return selectedCell
        }
        return UITableViewCell()
    }
    
    func updateValue(for item: ExperimentParameter, with value: String) {
        expInfo[item] = value
    }
    
    private func addUserSelection() {
        let userInstrLabel = UILabel()
        userInstrLabel.text = "Selected User:"
        userInstrLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(userInstrLabel)
        
        self.userSelButton = UIButton()
        self.userSelButton.layer.borderColor = UIColor.systemGreen.cgColor
        self.userSelButton.layer.borderWidth = 4
        self.userSelButton.layer.cornerRadius = 10
        self.userSelButton.setTitle("Select User", for: .normal)
        self.userSelButton.setTitleColor(.black, for: .normal)
        self.userSelButton.translatesAutoresizingMaskIntoConstraints = false
        self.userSelButton.addTarget(self, action: #selector(ExperimentEntryController.showPopup(_:)), for: .touchUpInside)
        self.view.addSubview(self.userSelButton)
        self.constrainLabelButton(userInstrLabel, self.userSelButton)
    }

    @objc func showPopup(_ control: UIButton) {
        self.selectionController = SelectionViewController()
        self.selectionController!.users = users
        self.selectionController!.modalPresentationStyle = .popover
        self.selectionController!.popoverPresentationController?.permittedArrowDirections = [.up]
        self.selectionController!.popoverPresentationController?.sourceView = self.userSelButton
        self.selectionController!.popoverPresentationController?.sourceRect = self.userSelButton.bounds
        self.selectionController!.choiceDelegate = self
        self.present(selectionController!, animated: true, completion: nil)
    }
        
    func selected(_ selectedIndex: Int) {
        self.selectedUser = users[selectedIndex]
        self.selectionController?.dismiss(animated: true)
        self.selectionController = nil
    }
    
    @objc func finished(_ button: UIBarButtonItem) {
        
        let continueVersion = self.versionSelection.selectedSegmentIndex == 1
        
        let experimentData: ExperimentData
        if continueVersion, let expData = self.expData {
            experimentData = expData
        } else {
            expInfo[.version] = String(dataDelegate?.nextVersion(for: expInfo[.initials]!) ?? 0)
            experimentData = ExperimentData(expInfo)
        }
        
        self.dismiss(animated: true) {
            self.runDelegate?.startExperiment(experimentData)
        }
    }
    
}

class TitleCell: UITableViewCell, UITextFieldDelegate {

    let titleLabel: UILabel
    var instructionLabel: UILabel!
    override var isUserInteractionEnabled: Bool {
        didSet {
            self.contentView.isUserInteractionEnabled = self.isUserInteractionEnabled
            if self.isUserInteractionEnabled {
                self.contentView.alpha = 1.0
            } else {
                self.contentView.alpha = 0.5
            }
        }
    }
    var userItem: ExperimentParameter! {
        didSet {
            self.titleText = userItem.displayName
            self.instructionLabel.text = self.userItem.instruction
        }
    }
    weak var userInfDelegate: UserInfoDelegate?
    var textField: UITextField!
    var titleText: String! {
        didSet { self.setTextToTitleLabel() } }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.titleLabel = UILabel()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureCell()
        self.backgroundColor = .lightGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }

    func configureCell() {
        
        self.addTitleLabel()
        self.addTextField()
        self.contentView.backgroundColor = .white
        self.constrainElementToContentView()
    }
    
    func addTitleLabel() {
        self.contentView.layer.borderWidth = 2
        self.contentView.layer.borderColor = UIColor(hue: 0.5, saturation: 1.0, brightness: 0.75, alpha: 1.0).cgColor
        self.contentView.layer.cornerRadius = 15
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
        self.textField.autocapitalizationType = .allCharacters
        self.textField.autocorrectionType = .no
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


protocol UserInfoDelegate: AnyObject {
    func updateValue(for item: ExperimentParameter, with value: String)
}

class SelectionViewController: UITableViewController {
    
    var users: [String]!
    weak var choiceDelegate: ChoiceDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
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
