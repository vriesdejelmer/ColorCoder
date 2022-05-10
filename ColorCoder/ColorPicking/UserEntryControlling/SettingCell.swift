//
//  SettingCell.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 08/05/2022.
//  Copyright © 2022 Jelmer de Vries. All rights reserved.
//

import UIKit

protocol SettingCellProtocol: UITableViewCell {
    var type: InputCellType { get }
    
    var titleLabel: UILabel { get }
    var instructionLabel: UILabel! { get }
    var isUserInteractionEnabled: Bool { get set }
    var userItem: ExperimentParameter! { get set }
    var inputItem: UIControl { get }
    var userInfDelegate: UserInfoDelegate? { get set }
    var titleText: String! { get set }
    func addInputField()
    func setInput(to value: String)
}

class SettingCell: UITableViewCell {
    var titleLabel: UILabel
    var instructionLabel: UILabel!
    var userInfDelegate: UserInfoDelegate?
    
    var titleText: String! {
        didSet { self.setTextToTitleLabel() }
    }
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.titleLabel = UILabel()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .lightGray
        (self as? SettingCellProtocol)?.configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError(GeneralSettings.Constants.CoderNotInitialzed)
    }
    
    func setTextToTitleLabel() {    //didset call
        titleLabel.text = titleText
        titleLabel.sizeToFit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
}
    
extension SettingCellProtocol {
    
    func configureCell() {
        self.addTitleLabel()
        self.addInputField()
        
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
        placementConstraints.append(NSLayoutConstraint(item: self.contentView, attribute: .trailingMargin, relatedBy: .equal, toItem: self.inputItem, attribute: .trailing, multiplier: 1, constant: 20))
        placementConstraints.append(NSLayoutConstraint(item: self.contentView, attribute: .bottomMargin, relatedBy: .equal, toItem: self.inputItem, attribute: .bottom, multiplier: 1, constant: 20))
        
        self.addConstraints(placementConstraints)
    }

}

//class OrientationCell: SegmentSettingCell {
//    override var itemSelection: [String]! { return [ScreenOrientation.horizontal.rawValue, ScreenOrientation.vertical.rawValue] }
//}
//
//class NodeOrderingCell: SegmentSettingCell {
//    override var itemSelection: [String]! { return [NodeOrdering.leftToRight.rawValue, NodeOrdering.shuffled.rawValue] }
//}

class SegmentSettingCell: SettingCell, SettingCellProtocol {
    
    var type: InputCellType { return .switchCell }
    var inputItem: UIControl { return self.segmentedControl }
    var segmentedControl: UISegmentedControl!
    
    var itemSelection = ["1", "2"]
    
    override var userItem: ExperimentParameter! {
        didSet {
            //THIS is definitely an ugly hack!
            if userItem == .screenOrientation {
                self.itemSelection = [ScreenOrientation.horizontal.rawValue, ScreenOrientation.vertical.rawValue]
            } else {
                self.itemSelection = [NodeOrdering.leftToRight.rawValue, NodeOrdering.shuffled.rawValue]
            }
            self.segmentedControl.setTitle(self.itemSelection[0], forSegmentAt: 0)
            self.segmentedControl.setTitle(self.itemSelection[1], forSegmentAt: 1)
        }
    }
    
    func setInput(to value: String) {
        if value == itemSelection[0] {
            self.segmentedControl.selectedSegmentIndex = 0
        } else if value == itemSelection[1] {
            self.segmentedControl.selectedSegmentIndex = 1
        }
    }
    
    @objc func segmentChange(_ sender: UISegmentedControl) {
        self.userInfDelegate?.updateValue(for: userItem, with: self.itemSelection[sender.selectedSegmentIndex])
    }
    
    func addInputField() {
        self.segmentedControl = UISegmentedControl(items: self.itemSelection)
        self.segmentedControl.addTarget(self, action: #selector(Self.segmentChange(_:)), for: .valueChanged)
        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControl.selectedSegmentTintColor = .systemGreen
        self.contentView.addSubview(self.segmentedControl)
        
        self.instructionLabel = UILabel()
        self.instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.instructionLabel.textColor = .gray
        self.contentView.addSubview(instructionLabel)
        
        let constraints = [
            segmentedControl.widthAnchor.constraint(equalToConstant: 100),
            segmentedControl.heightAnchor.constraint(equalToConstant: 50),
            instructionLabel.trailingAnchor.constraint(equalTo: segmentedControl.leadingAnchor, constant: -20),
            instructionLabel.centerYAnchor.constraint(equalTo: segmentedControl.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
    }
}

class TextSettingCell: SettingCell, SettingCellProtocol, UITextFieldDelegate {
    
    var type: InputCellType { return .textCell }
    
    var inputItem: UIControl { return self.textField }
    var textField: UITextField!
    
    func setInput(to value: String) {
        self.textField.text = value
    }
    
    func addInputField() {
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

}


protocol UserInfoDelegate: AnyObject {
    func updateValue(for item: ExperimentParameter, with value: String)
}

enum InputCellType {
    case textCell, switchCell
}
