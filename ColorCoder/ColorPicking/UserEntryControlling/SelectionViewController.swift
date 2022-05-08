//
//  SelectionViewController.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 08/05/2022.
//  Copyright © 2022 Jelmer de Vries. All rights reserved.
//

import UIKit

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
