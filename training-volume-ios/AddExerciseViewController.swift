import UIKit

class AddExerciseViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    typealias OnSaveHandler = (Exercise) -> Void
    var onSave: OnSaveHandler?
    private let exercises: [Exercise] = [
        Exercise(id: "1", name: "Squats", sets: 4, reps: 10, muscle: "Quadriceps"),
        Exercise(id: "2", name: "Deadlifts", sets: 3, reps: 8, muscle: "Hamstrings"),
        Exercise(id: "3", name: "Bench Press", sets: 5, reps: 5, muscle: "Chest"),
        Exercise(id: "4", name: "Pull-Ups", sets: 3, reps: 10, muscle: "Back"),
        Exercise(id: "5", name: "Overhead Press", sets: 4, reps: 8, muscle: "Shoulders"),
        Exercise(id: "6", name: "Bicep Curls", sets: 3, reps: 12, muscle: "Biceps"),
        Exercise(id: "7", name: "Tricep Extensions", sets: 3, reps: 12, muscle: "Triceps"),
        Exercise(id: "8", name: "Leg Press", sets: 4, reps: 12, muscle: "Quadriceps"),
        Exercise(id: "9", name: "Calf Raises", sets: 3, reps: 15, muscle: "Calves"),
        Exercise(id: "10", name: "Lateral Raises", sets: 4, reps: 10, muscle: "Shoulders")

    ]
    private var selectedExercise: Exercise?

    
    private let muscleSearchField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Select muscle"
        return textField
    }()
    
    private let exerciseSearchField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Select exercise"
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 5
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(muscleSearchField)
        view.addSubview(exerciseSearchField)
        view.addSubview(saveButton)
        let pickerView = UIPickerView()
           pickerView.delegate = self
           pickerView.dataSource = self
           exerciseSearchField.inputView = pickerView

           // Set the text field delegate
           exerciseSearchField.delegate = self
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

        setupUI()
    }
    @objc private func saveButtonTapped() {
        guard let selectedExercise = selectedExercise else { return }
        onSave?(selectedExercise)
        dismiss(animated: true, completion: nil)
    }
    private func setupUI() {
        muscleSearchField.translatesAutoresizingMaskIntoConstraints = false
        exerciseSearchField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            muscleSearchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            muscleSearchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            muscleSearchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            exerciseSearchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            exerciseSearchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            exerciseSearchField.topAnchor.constraint(equalTo: muscleSearchField.bottomAnchor, constant: 8),
            
            saveButton.topAnchor.constraint(equalTo: exerciseSearchField.bottomAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return exercises.count
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return exercises[row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedExercise = exercises[row]
        exerciseSearchField.text = exercises[row].name
    }
    // MARK: - UITextFieldDelegate

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPickerView))
        view.addGestureRecognizer(tapGestureRecognizer)
        return true
    }

    @objc private func dismissPickerView() {
        view.endEditing(true)
        view.gestureRecognizers?.forEach { view.removeGestureRecognizer($0) }
    }


}
