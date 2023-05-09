import UIKit

protocol CreateWorkoutDelegate: AnyObject {
    func didCreateWorkout(_ workout: Workout, forRoutine routine: Routine)
    func updateRoutine(_ routine: Routine)
    func workoutSaved()
}


class CreateWorkoutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: CreateWorkoutDelegate?
    private var selectedExercises: [Exercise] = []
    var routine: Routine?
    var onWorkoutCreated: ((Workout) -> Void)?
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedExercises.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseCell", for: indexPath)
        let exercise = selectedExercises[indexPath.row]
        cell.textLabel?.text = "\(exercise.name) - \(exercise.sets) sets x \(exercise.reps) reps"
        return cell
    }
    
    
    private let workoutNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Workout Name"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let workoutNameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter workout name"
        return textField
    }()
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    private let addExerciseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Exercise", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 5
        return button
    }()

    private let exercisesTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(workoutNameTextField)
        view.addSubview(addExerciseButton)
        view.addSubview(exercisesTableView)

        setupUI()
        setupTableView()

        // Add the target for the "Add Exercise" button
        addExerciseButton.addTarget(self, action: #selector(addExerciseButtonTapped), for: .touchUpInside)
    }
    @objc private func saveButtonTapped() {
        // Get the workout name from the workoutNameTextField
        guard let workoutName = workoutNameTextField.text, !workoutName.isEmpty else {
            print("Workout name is empty.")
            return
        }

        // Create a new workout with the given name and exercises
        let workout = Workout(id: UUID().uuidString, name: workoutName, exercises: selectedExercises)

        // Send the workout to the HomeViewController
        if let routine = routine {
            delegate?.didCreateWorkout(workout, forRoutine: routine)
        }


        // Update the routine and save the new workout in Firestore
        if let routine = routine {
            var updatedRoutine = routine
            updatedRoutine.workouts.append(workout)
            delegate?.updateRoutine(updatedRoutine)
        }
       
        print("went past the delegate")
        // Pop the current view controller

        self.dismiss(animated: true) {
            self.onWorkoutCreated?(workout)
            self.navigationController?.popToRootViewController(animated: true)
            }
//        self.navigationController?.popViewController(animated: true)
    }



    
    @objc private func addExerciseButtonTapped() {
        let addExerciseVC = AddExerciseViewController()

        // Configure the completion handler
        addExerciseVC.onSave = { [weak self] exercise in
            self?.selectedExercises.append(exercise)
            self?.exercisesTableView.reloadData()
        }

        // Present the AddExerciseViewController
        addExerciseVC.modalPresentationStyle = .popover
        self.present(addExerciseVC, animated: true, completion: nil)
    }

    
    private func setupTableView() {
            exercisesTableView.dataSource = self
            exercisesTableView.delegate = self
            exercisesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "exerciseCell")
        }

    
    private func setupUI() {
        view.addSubview(workoutNameLabel) // Add this line
        workoutNameLabel.translatesAutoresizingMaskIntoConstraints = false
        workoutNameTextField.translatesAutoresizingMaskIntoConstraints = false
        addExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        exercisesTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
               saveButton.translatesAutoresizingMaskIntoConstraints = false
               NSLayoutConstraint.activate([
                   saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                   saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
               ])

        NSLayoutConstraint.activate([
            workoutNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            workoutNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),

            workoutNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            workoutNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            workoutNameTextField.topAnchor.constraint(equalTo: workoutNameLabel.bottomAnchor, constant: 8),

            addExerciseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addExerciseButton.topAnchor.constraint(equalTo: workoutNameTextField.bottomAnchor, constant: 16),

            exercisesTableView.topAnchor.constraint(equalTo: addExerciseButton.bottomAnchor, constant: 16),
            exercisesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            exercisesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            exercisesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

}
