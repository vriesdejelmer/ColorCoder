//
//  AboutViewController.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 26/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import UIKit

class AboutViewController: SubCompViewController {

    lazy var aboutView: UIView = {
        let aView = UIView()
        aView.translatesAutoresizingMaskIntoConstraints = false
        aView.layer.cornerRadius = 5
        aView.layer.borderColor  = UIColor.lightGray.cgColor
        aView.layer.borderWidth  = 1.5
        aView.addSubview(aboutLabel)
        addEqualityConstraints(aboutLabel, superView: aView, for: [.leftMargin, .rightMargin, .topMargin], offsets: [16, -16, 16])
        return aView
    }()

    lazy var aboutLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.contentMode  = .topLeft
        aLabel.sizeToFit()
        aLabel.translatesAutoresizingMaskIntoConstraints    = false
        aLabel.numberOfLines    = 0
        aLabel.text = GeneralSettings.aboutText
        return aLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addAboutView()
    }

    func addAboutView() {
        addViewWithInsets(aboutView, superView: self.view, insets: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100))
    }

}
