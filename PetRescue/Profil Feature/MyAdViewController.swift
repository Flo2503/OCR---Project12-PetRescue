//
//  MyAdViewController.swift
//  PetRescue
//
//  Created by Flo on 17/05/2020.
//  Copyright © 2020 Flo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class MyAdViewController: NavBarSetUp {

    private let userId = Auth.auth().currentUser!.uid.description
    private var ads: [AdManager] = []

    @IBOutlet weak var myAdTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.myAdTableView.tableFooterView = UIView()
        print(ads.description)
        AdManager.getMyAds(userId: userId, callback: { ads in
            self.ads = ads
        })
    }
}

extension MyAdViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ads.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "myAdCell", for: indexPath) as? MyAdTableViewCell else {
            return UITableViewCell()
        }
        let animal = ads[indexPath.row]
        cell.configure(name: animal.name, locality: animal.locality)
        AdManager.retrieveImage(url: animal.animalImage, callback: { image in
            if let image = image {
                cell.configureImage(image: image)
            }
        })
        return cell
    }
}