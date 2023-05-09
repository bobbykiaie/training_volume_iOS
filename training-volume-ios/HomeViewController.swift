import FirebaseFirestore
import FirebaseAuth
import UIKit

class HomeViewController: UIViewController {
    private var routines = [Routine]()
    private let db = Firestore.firestore()
    private var expandedIndexPaths: Set<IndexPath> = []
    
    private let templatesLabel: UILabel = {
        let label = UILabel()
        label.text = "Templates"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let createRoutineButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Routine", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = .systemRed
        button.tintColor = .white
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let routinesTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRoutines()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(templatesLabel)
        view.addSubview(createRoutineButton)
        view.addSubview(routinesTableView)

        setupTableView()
        setupUI()
    }
    
    private func fetchRoutines() {
        let user = Auth.auth().currentUser
        if let user = user {
            db.collection("users").document(user.uid).collection("routines").order(by: "name").getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching routines: \(error)")
                } else if let snapshot = snapshot {
                    let routines = snapshot.documents.compactMap { document -> Routine? in
                        do {
                            let data = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                            var routine = try JSONDecoder().decode(Routine.self, from: data)
                            routine.id = document.documentID

                            if let workoutsArray = document.data()["workouts"] as? [[String: Any]] {
                                for (index, workoutData) in workoutsArray.enumerated() {
                                    if let exercisesData = try? JSONSerialization.data(withJSONObject: workoutData["exercises"] as? [[String: Any]] ?? [], options: []) {
                                        let exercises = try JSONDecoder().decode([Exercise].self, from: exercisesData)
                                        routine.workouts[index].exercises = exercises
                                    }
                                }
                            }
                            print(routine)
                            return routine
                        } catch {
                            print("Error decoding routine: \(error)")
                            return nil
                        }
                    }
                    
                    self?.routines = routines
                    DispatchQueue.main.async {
                        self?.routinesTableView.reloadData()
                    }
                }
            }
        }
    }

    func updateRoutine(_ routine: Routine) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let routineId = routine.id else {
            print("Error: routine ID is missing")
            return
        }
        let routineRef = db.collection("users").document(userId).collection("routines").document(routineId)

        routineRef.getDocument { document, error in
            if let document = document, document.exists {
                if var routineData = document.data() {
                    routineData["workouts"] = routine.workouts.map { workout -> [String: Any] in
                        return [
                            "id": workout.id,
                            "name": workout.name,
                            "exercises": workout.exercises.map { exercise -> [String: Any] in
                                return [
                                    "id": exercise.id,
                                    "name": exercise.name,
                                    "sets": exercise.sets,
                                    "reps": exercise.reps,
                                    "muscle": exercise.muscle
                                ]
                            }
                        ]
                    }
                    
                    routineRef.updateData(routineData) { error in
                        if let error = error {
                            print("Error updating routine: \(error)")
                        } else {
                            print("Routine successfully updated")
                        }
                    }
                }
            } else {
                print("Error fetching routine document: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }

    @objc func createRoutineButtonTapped() {
        let createRoutineVC = CreateRoutineViewController()
        createRoutineVC.modalPresentationStyle = .formSheet

        createRoutineVC.onRoutineCreated = { [weak self] in
            self?.fetchRoutines()
        }
        self.present(createRoutineVC, animated: true, completion: nil)
    }

    private func setupTableView() {
        routinesTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            routinesTableView.topAnchor.constraint(equalTo: templatesLabel.bottomAnchor),
            routinesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            routinesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            routinesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        routinesTableView.dataSource = self
        routinesTableView.delegate = self
        routinesTableView.register(RoutineTableViewCell.self, forCellReuseIdentifier: RoutineTableViewCell.identifier)
    }
    
    private func setupUI() {
        templatesLabel.translatesAutoresizingMaskIntoConstraints = false
        createRoutineButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            templatesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            templatesLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            createRoutineButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createRoutineButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            routinesTableView.topAnchor.constraint(equalTo: templatesLabel.bottomAnchor),
            routinesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            routinesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            routinesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        createRoutineButton.addTarget(self, action: #selector(createRoutineButtonTapped), for: .touchUpInside)
    }
    }


extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routines.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RoutineTableViewCell.identifier, for: indexPath) as! RoutineTableViewCell
        cell.routine = routines[indexPath.row]

        cell.onCreateWorkoutTapped = { [weak self] (routine: Routine) in
            let createWorkoutVC = CreateWorkoutViewController()
            createWorkoutVC.routine = routine
            createWorkoutVC.delegate = self
            self?.navigationController?.pushViewController(createWorkoutVC, animated: true)
        }

        cell.onWorkoutTapped = { [weak self] (workout: Workout) in
            print("Workout tapped: \(workout.name)")
            let workoutDetailsVC = WorkoutDetailsViewController()
            workoutDetailsVC.workout = workout
            self?.navigationController?.pushViewController(workoutDetailsVC, animated: true)
        }


        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let routine = routines[indexPath.row]
        let cellHeight: CGFloat
        if routine.isExpanded {
            let workoutsCount = routine.workouts.isEmpty ? 1 : routine.workouts.count
            cellHeight = CGFloat(50 + workoutsCount * 44 + 50)
        } else {
           
            cellHeight = 70 // Increase the height to fit the routine name when collapsed
        }
        return cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.deselectRow(at: indexPath, animated: true)
        
        if expandedIndexPaths.contains(indexPath) {
            // Collapse the cell
            routines[indexPath.row].isExpanded = false
            expandedIndexPaths.remove(indexPath)
        } else {
            // Expand the cell
            routines[indexPath.row].isExpanded = true
            expandedIndexPaths.insert(indexPath)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    }


extension HomeViewController: CreateWorkoutDelegate {
    func didCreateWorkout(_ workout: Workout, forRoutine routine: Routine) {
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            var updatedRoutine = routine
            updatedRoutine.workouts.append(workout)
            routines[index] = updatedRoutine

            if let indexPath = expandedIndexPaths.first(where: { $0.row == index }) {
                routinesTableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }

    func workoutSaved() {
        DispatchQueue.main.async {
            self.routinesTableView.reloadData()
        }
    }
}

extension HomeViewController: CreateRoutineDelegate {
    func routineCreated() {
        fetchRoutines()
    }
}
