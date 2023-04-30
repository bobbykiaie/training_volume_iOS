import UIKit
import FirebaseFirestore
import FirebaseAuth

class CreateRoutineViewController: UIViewController {

    let routineNameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Routine Name"
        return textField
    }()

    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        view.addSubview(routineNameTextField)
        routineNameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            routineNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            routineNameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            routineNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            routineNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: routineNameTextField.bottomAnchor, constant: 16),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    private func saveRoutineToFirestore(routineName: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let routine = [
            "name": routineName,
            "workouts": []
        ] as [String : Any]

        db.collection("users").document(userId).collection("routines").addDocument(data: routine) { error in
            if let error = error {
                print("Error adding routine: \(error)")
            } else {
                print("Routine added successfully")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @objc func saveButtonTapped() {
        if let routineName = routineNameTextField.text, !routineName.isEmpty {
            saveRoutineToFirestore(routineName: routineName)
        } else {
            // Show an error if the routine name is empty
        }
    }

}
