//
//  SettingsViewController.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 26/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import UIKit

class SettingsViewController: SubCompViewController {

    let settingsItems: [SettingsItem] = [.backgroundGray, .eccentricityFactor, .sizeFactor]
    let titleHeight: CGFloat = 30
    let itemHeight: CGFloat = 50
    
    var stackView: UIStackView = {
        let stackView               = UIStackView(frame: CGRect(origin: .zero, size: CGSize(width: 400, height: 500)))
        stackView.axis              = .vertical
        stackView.distribution      = .equalSpacing
        stackView.alignment         = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupStackView()
    }

    func setupStackView() {
        addViewWithInsets(stackView, superView: self.view, insets: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100))

        for item in settingsItems {
            self.prepareSettings(for: item)
        }
    }

    func prepareSettings(for item: SettingsItem) {
        let size    = CGSize(width: 200, height: 100)
        let settingView = self.createSettingBlock(for: item, with: size)
        self.stackView.addArrangedSubview(settingView)
    }

    func createSettingBlock(for item: SettingsItem, with size: CGSize) -> UIView {
        let settingBlock    = UIView()
        let settingControl  = UIView()

        settingBlock.translatesAutoresizingMaskIntoConstraints      = false
        settingControl.translatesAutoresizingMaskIntoConstraints    = false
        addHeightConstraint(size.height, to: settingBlock)
        addViewWithInsets(settingControl, superView: settingBlock, insets: UIEdgeInsets(top: 30, left: 10, bottom: 10, right: 10))
        settingBlock.layer.borderWidth   = 1
        settingBlock.layer.borderColor   = UIColor.black.cgColor
        settingBlock.layer.cornerRadius  = 5
        
        self.addTitle(to: settingBlock, title: item.displayName)
        
        if item == .backgroundGray || item == .sizeFactor || item == .eccentricityFactor {
            self.addSlider(to: settingBlock, type: item)
        }
//        else if item == .paddle2Type || item == .paddle1Type {
//            self.addSegmentedControl(to: settingBlock, type: item)
//        }
        
        return settingBlock
    }

    func addTitle(to block: UIView, title: String) {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints    = false
        titleLabel.text = title
        addHeightConstraint(titleHeight, to: titleLabel)
        block.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: block.topAnchor).isActive  = true
        titleLabel.leftAnchor.constraint(equalTo: block.leftAnchor, constant: 10).isActive = true
    }

    func addSlider(to block: UIView, type: SettingsItem) {
        let slider = UISlider()
        slider.accessibilityIdentifier = type.rawValue
        slider.translatesAutoresizingMaskIntoConstraints    = false
        addHeightConstraint(itemHeight, to: slider)
        block.addSubview(slider)
        slider.bottomAnchor.constraint(equalTo: block.bottomAnchor, constant: -10).isActive  = true
        slider.leftAnchor.constraint(equalTo: block.leftAnchor, constant: 10).isActive = true
        slider.rightAnchor.constraint(equalTo: block.rightAnchor, constant: -10).isActive = true

        switch type {
        case .backgroundGray: slider.value = Float(GeneralSettings.backgroundGray)
        case .eccentricityFactor: slider.value = Float(GeneralSettings.eccentricityFactor)
        case .sizeFactor: slider.value = Float(GeneralSettings.sizeFactor)
        default: break
        }

        slider.addTarget(self, action: #selector(SettingsViewController.sliderAction(_:)), for: .valueChanged)
    }
    
    func addSegmentedControl(to block: UIView, type: SettingsItem) {
//        let optionList = self.getPaddleList()
//        let segmentedControl = UISegmentedControl(items: optionList)
//
//        for (index, option) in optionList.enumerated() {
//            if type == .paddle1Type && GeneralSettings.paddle1Type.rawValue == option {
//                segmentedControl.selectedSegmentIndex = index
//            }
//            if type == .paddle2Type && GeneralSettings.paddle2Type.rawValue == option {
//                segmentedControl.selectedSegmentIndex = index
//            }
//        }
//
//        if #available(iOS 13.0, *) {
//            segmentedControl.selectedSegmentTintColor = .systemBlue
//            segmentedControl.setTitleTextAttributes([.font: UIFont.init(name: "Arial", size: 16)], for: .normal)
//            segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.init(name: "Arial", size: 20)], for: .selected)
//
//        } else {
//            // Fallback on earlier versions
//        }
//        segmentedControl.translatesAutoresizingMaskIntoConstraints    = false
//        segmentedControl.accessibilityIdentifier = type.rawValue
//        addHeightConstraint(itemHeight, to: segmentedControl)
//
//        block.addSubview(segmentedControl)
//        segmentedControl.bottomAnchor.constraint(equalTo: block.bottomAnchor, constant: -10).isActive  = true
//        segmentedControl.leftAnchor.constraint(equalTo: block.leftAnchor, constant: 10).isActive = true
//        segmentedControl.rightAnchor.constraint(equalTo: block.rightAnchor, constant: -10).isActive = true
//
//        segmentedControl.addTarget(self, action: #selector(Self.segmentAction(_:)), for: .valueChanged)
        
    }
    
    func getPaddleList() -> [String] {
        var optionList = [String]()
        for type in PaddleType.allCases {
            optionList.append(type.rawValue)
        }
        return optionList
    }
    
    @objc func segmentAction(_ sender: UISegmentedControl) {
        if let setting = SettingsItem(rawValue: sender.accessibilityIdentifier ?? "") {
//            if let paddleSelection = PaddleType(rawValue: sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "") {
//                if setting == .paddle1Type {
//                    GeneralSettings.paddle1Type = paddleSelection
//                } else if setting == .paddle2Type {
//                    GeneralSettings.paddle2Type = paddleSelection
//                }
//            }
        }
    }
    
    @objc func sliderAction(_ sender: UISlider){
        
        
        if let identifier = sender.accessibilityIdentifier, let item = SettingsItem(rawValue: identifier) {
            switch item {
            case .backgroundGray: GeneralSettings.backgroundGray = CGFloat(sender.value)
            case .eccentricityFactor: GeneralSettings.eccentricityFactor = CGFloat(sender.value)
            case .sizeFactor: GeneralSettings.sizeFactor = CGFloat(sender.value)
            default: break
            }
        }
//        let minimumValue    = CGFloat(sliderRange.min()!)
//        let sliderValue     = CGFloat(sender.value)
//        let newValue        = round((sliderValue - minimumValue)/sliderStep)*sliderStep+minimumValue
//        self.label.text     = title + " \(newValue)"
//        delegate?.setNewPropertyValue(ElementProperty(floatValue: newValue, type: selectionType))
    }
    
}
