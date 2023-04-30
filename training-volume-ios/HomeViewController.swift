
import FirebaseFirestore
import FirebaseAuth
import UIKit

struct Routine {
    let id: String
    let name: String
    var workouts: [Workout]
    var isExpanded: Bool
}
struct Workout {
    let id: String
    let name: String
}

class RoutineTableViewCell: UITableViewCell {
    
    static let identifier = "RoutineTableViewCell"
    
    var routine: Routine? {
        didSet {
            updateUI()
        }
    }
    private let createWorkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Workout", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 5
        return button
    }()

    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)

        return label
    }()
    
    private let workoutsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(workoutsStackView)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        workoutsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            workoutsStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            workoutsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            workoutsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            workoutsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func updateUI() {
        guard let routine = routine else { return }
        
        nameLabel.text = routine.name
        
        workoutsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if routine.isExpanded {
            if routine.workouts.isEmpty {
                let label = UILabel()
                label.text = "No workouts in this routine."
                label.textColor = .gray
                workoutsStackView.addArrangedSubview(label)
                
                // Add the "Create Workout" button to the stack view
                workoutsStackView.addArrangedSubview(createWorkoutButton)
            } else {
                // ...
                print("hi")
            }
        }
    }
}

class HomeViewController: UIViewController {
    
    private var routines = [Routine]()
    private let db = Firestore.firestore()

    private var expandedIndexPaths: Set<IndexPath> = [] // Change this line

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
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
      
        view.addSubview(templatesLabel)
        view.addSubview(createRoutineButton)
        view.addSubview(tableView)
             
        setupTableView()
        fetchRoutines()
        setupUI()
    }
    
    private func fetchRoutines() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(userId).collection("routines").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }

            self.routines = documents.map { queryDocumentSnapshot -> Routine in
                let data = queryDocumentSnapshot.data()
                let id = queryDocumentSnapshot.documentID
                let name = data["name"] as? String ?? ""
                let workoutsData = data["workouts"] as? [[String: Any]] ?? []

                let workouts = workoutsData.map { workoutData -> Workout in
                    let workoutId = workoutData["id"] as? String ?? ""
                    let workoutName = workoutData["name"] as? String ?? ""
                    return Workout(id: workoutId, name: workoutName)
                }

                return Routine(id: id, name: name, workouts: workouts, isExpanded: false)
            }

            // Reload the routines table view
            self.tableView.reloadData()
        }
    }
    
    @objc func createRoutineButtonTapped() {
        let createRoutineVC = CreateRoutineViewController()
        createRoutineVC.modalPresentationStyle = .overFullScreen
        createRoutineVC.modalTransitionStyle = .crossDissolve
        self.present(createRoutineVC, animated: true, completion: nil)
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: templatesLabel.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RoutineTableViewCell.self, forCellReuseIdentifier: RoutineTableViewCell.identifier)
    }
    
    private func setupUI() {
        templatesLabel.translatesAutoresizingMaskIntoConstraints = false
        createRoutineButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            templatesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            templatesLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            createRoutineButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createRoutineButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.topAnchor.constraint(equalTo: templatesLabel.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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

