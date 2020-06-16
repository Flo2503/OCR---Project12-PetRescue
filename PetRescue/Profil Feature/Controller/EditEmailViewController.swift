//
//  EditEmailViewController.swift
//  PetRescue
//
//  Created by Flo on 02/06/2020.
//  Copyright © 2020 Flo. All rights reserved.
//

import UIKit

class EditEmailViewController: UIViewController {
    // MARK: - Properties
    private let invalidEmaildAlert = "Adresse mail non valide"
    private let emailUpdateAlert = "Adresse mail modifiée avec succès"
    private let networkErrorAlert = "Erreur réseau, merci de réessayer"
    // MARK: - Outlets
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var newEmailAddress: UITextField!
    @IBOutlet weak var validateButton: UIButton!
    // MARK: - Actions
    ///Check email is valid and text field isn't empty, call "editEmail"
    @IBAction func tapValidateButton(_ sender: Any) {
        let isValidEmail = InputValuesManager.isValidEmailAddress(emailAddressString: newEmailAddress.text)

        if isValidEmail &&
            fieldIsNotEmpty([newEmailAddress]) {
            editEmail()
        } else {
            label.text = invalidEmaildAlert
            validateButton.layer.backgroundColor = UIColor.red.cgColor
        }
    }
    ///Dismiss keyboard
    @IBAction func dismissKeyboard(_ sender: Any) {
        newEmailAddress.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ItemSetUp.buttonSetUp([validateButton])
        ItemSetUp.textFieldSetUp([newEmailAddress])
    }
    ///Check text field isn't empty
    private func fieldIsNotEmpty(_ textField: [UITextField]) -> Bool {
        for item in textField {
            guard !item.text!.isEmpty else {
                return false
            }
        }
        return true
    }
    ///Call "updateEmail" allowing to edit user mail in realtime database
    private func editEmail() {
        if let newEmail = newEmailAddress.text {
            self.validateButton.isEnabled = false
            self.validateButton.layer.backgroundColor = Colors.customGreenLight.cgColor
            UserManager.updateEmail(email: newEmail, callback: { success in
                if success {
                    self.validateButton.layer.backgroundColor = Colors.customGreen.cgColor
                    self.label.text = self.emailUpdateAlert
                } else {
                    self.label.text = self.networkErrorAlert
                    self.validateButton.isEnabled = true
                    self.validateButton.layer.backgroundColor = UIColor.red.cgColor
                }
            })
        }
    }
}