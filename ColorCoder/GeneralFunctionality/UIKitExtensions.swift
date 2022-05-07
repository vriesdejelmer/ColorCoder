//
//  UIKitExtensions.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 28/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import UIKit

extension UIImage {

    func getCustomShape(for size: CGSize, with clippingPath: UIBezierPath) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        let copiedPath = clippingPath.copy() as! UIBezierPath
        copiedPath.apply(CGAffineTransform(translationX: copiedPath.bounds.size.width/2, y: copiedPath.bounds.size.height/2))
        let rect    = CGRect(origin: .zero, size: size)
        guard let cgImage = self.cgImage?.cropping(to: rect)
            else { return nil }
        copiedPath.addClip()
        
        UIImage(cgImage: cgImage, scale: 1, orientation: self.imageOrientation).draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()

    }
}
    
//    func getCustomShape(for size: CGSize, with clippingPath: UIBezierPath) -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(size, false, scale)
//        defer { UIGraphicsEndImageContext() }
//
//        if let context = UIGraphicsGetCurrentContext() {
//            context.translateBy(x: self.size.width/2, y: self.size.height/2)
//            let rect    = CGRect(origin: .zero, size: size)
//            guard let cgImage = self.cgImage//.cropping(to: rect)
//                else { return nil }
//            clippingPath.addClip()
//
//            UIImage(cgImage: cgImage, scale: 1, orientation: self.imageOrientation).draw(in: rect)
//            return UIGraphicsGetImageFromCurrentImageContext()
//        }
//        return nil
//    }

class BaseViewController: UIViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

class SubCompViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor   = .white
        self.addExitButton()
    }

    func addExitButton() {
        let exitButton = ExitButton()
        exitButton.translatesAutoresizingMaskIntoConstraints    = false
        addSizeConstraint(CGSize(width: 40, height: 40), to: exitButton)
        self.view.addSubview(exitButton)
        exitButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive  = true
        exitButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive    = true

        exitButton.addTarget(self, action: #selector(SettingsViewController.closeController), for: .touchUpInside)
    }

    @objc func closeController() {
        self.dismiss(animated: true, completion: nil)
    }

}


extension CGRect {
    public var center: CGPoint {
        return CGPoint(x: (self.maxX + self.minX)/2, y: (self.maxY + self.minY)/2)
    }
    
}


extension UIViewController {
    func showAlert(with title: String, message: String, buttonText: String, isDismissing: Bool) {
        let generalAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        generalAlert.addAction(UIAlertAction(title: buttonText, style: .default) {_ in
            if isDismissing { self.dismiss(animated: true) }
        })
        self.present(generalAlert, animated: true)
    }
}

extension Array {
  init(repeating: [Element], count: Int) {
    self.init([[Element]](repeating: repeating, count: count).flatMap{$0})
  }

  func repeated(count: Int) -> [Element] {
    return [Element](repeating: self, count: count)
  }
}
