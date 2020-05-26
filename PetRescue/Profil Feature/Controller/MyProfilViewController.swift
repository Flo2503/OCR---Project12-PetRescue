//
//  MyProfilViewController.swift
//  PetRescue
//
//  Created by Flo on 23/05/2020.
//  Copyright © 2020 Flo. All rights reserved.
//

import UIKit
import FirebaseAuth

class MyProfilViewController: UIViewController {

    private let userId = Auth.auth().currentUser?.uid
    private let cellTitle = ["Nom", "Prénom", "Adresse mail"]
    private var userInfo: [String] = []
    private var user: [UserManager] = []

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }

    private func getUser() {
        if let currentUser = userId {
            UserManager.retrieveUser(user: currentUser, callback: { currentUser in
                self.user = currentUser
                self.importDetails()
                self.tableView.reloadData()
            })
        }
    }

    private func importDetails() {
        userInfo.append(user[0].name)
        userInfo.append(user[0].firstName)
        userInfo.append(user[0].emailAddress)
    }
}

extension MyProfilViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellTitle.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myProfilCell", for: indexPath)
        cell.textLabel?.text = cellTitle[indexPath.row]
        //cell.detailTextLabel?.text = userInfo[indexPath.row]
        return cell
    }
}
