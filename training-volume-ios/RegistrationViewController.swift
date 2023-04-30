//RegistrationViewController.swift
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore


protocol RegistrationViewControllerDelegate: AnyObject {
    func registrationViewControllerDidFinish(_ controller: RegistrationViewController)
}

class RegistrationViewController: UIViewController {
    weak var delegate: RegistrationViewControllerDelegate?


    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Your name"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email address"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirm Password"
        return label
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        submitButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, nameTextField, emailLabel, emailTextField, passwordLabel, passwordTextField, confirmPasswordLabel, confirmPasswordTextField, submitButton])
        stackView.axis = .vertical
        stackView.spacing = 8
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func registerTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            // Show an alert for incomplete form
            return
        }
        
        guard password == confirmPassword else {
            // Show an alert for mismatched passwords
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                // Show an error alert
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else { return }
            
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData([
                "name": name,
                "email": email
            ]) { error in
                if let error = error {
                    // Show an error alert
                    print("Error: \(error.localizedDescription)")
                    return
                }

                // Successfully created a new user and stored their information
                self.delegate?.registrationViewControllerDidFinish(self)
                self.dismiss(animated: true, completion: nil) // Dismiss the registration view controller
            }
        }
    }


}
