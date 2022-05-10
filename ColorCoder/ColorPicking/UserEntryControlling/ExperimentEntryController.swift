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
    let userItems: [ExperimentParameter] = [.nodeOrdering, .screenOrientation, .targetSteps, .nodeSteps, .nodeDiameter, .nodeEccentricity, .backgroundShade]
    var expInfo: [ExperimentParameter: String] = [.targetSteps: "\(GeneralSettings.DefaultParams.targetSteps)", .nodeSteps: "\(GeneralSettings.DefaultParams.nodeSteps)", .nodeDiameter: "\(GeneralSettings.nodeDiameter)", .nodeEccentricity: "\(GeneralSettings.nodeEccentricity)", .backgroundShade: "\(GeneralSettings.backgroundGray)", .nodeOrdering: "\(GeneralSettings.nodeOrdering.rawValue)", .screenOrientation: "\(GeneralSettings.screenRotation.rawValue)"]
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
        expInfo[.nodeOrdering] = "\(expData.nodeOrdering.rawValue)"
        expInfo[.screenOrientation] = "\(expData.screenOrientation.rawValue)"
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addUserSelection()
        self.addNewVersionSwitch()
        self.setupTableView()
        
        self.view.backgroundColor = .white
        self.title = "Start Experiment"
        
        self.rightButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(ExperimentEntryController.finished(_:)))
        self.rightButton.isEnabled = false
        self.rightButton.tintColor = .systemGreen
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
        if let expData = self.expData {
            self.populateTable(with: expData)
        }
        
    }
    
    func setupTableView() {
        self.tableView = UITableView()
        
        self.tableView.register(TextSettingCell.self, forCellReuseIdentifier: GeneralSettings.Constants.TextCell)
        self.tableView.register(SegmentSettingCell.self, forCellReuseIdentifier: GeneralSettings.Constants.SegmentCell)
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
        return userItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let userItem = userItems[indexPath.row]
        
        let selectedCell: SettingCellProtocol?
        if userItem.getCellType() == .switchCell {
            selectedCell = self.tableView.dequeueReusableCell(withIdentifier: GeneralSettings.Constants.SegmentCell, for: indexPath) as? SettingCellProtocol
        } else {
            selectedCell = self.tableView.dequeueReusableCell(withIdentifier: GeneralSettings.Constants.TextCell, for: indexPath) as? SettingCellProtocol
        }
        
        if let cell = selectedCell {
            cell.userItem = userItem
            cell.userInfDelegate = self
            cell.isUserInteractionEnabled = self.cellsEnabled
            if let setValue = expInfo[userItem] {
                cell.setInput(to: setValue)
            }
            return cell
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
