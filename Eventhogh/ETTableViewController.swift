//
//  ETTableViewController.swift
//  Eventhogh
//
//  Created by Gareth Fong on 16/3/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import UIKit
class ETTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath)
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //tableView.reloadData()
    }
    
}
