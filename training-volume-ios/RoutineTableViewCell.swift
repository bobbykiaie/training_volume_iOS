//
//  RoutineTableViewCell.swift
//  training-volume-ios
//
//  Created by Babak Kiaie on 5/6/23.
//

import UIKit

class RoutineTableViewCell: UITableViewCell, CreateWorkoutDelegate {
    func didCreateWorkout(_ workout: Workout, forRoutine routine: Routine) {
        print("nothing")
    }
    
    func updateRoutine(_ routine: Routine) {
        print("nothing")
    }
    
    func workoutSaved() {
        DispatchQueue.main.async {
            self.updateUI()

        }
    }
    
    
    static let identifier = "RoutineTableViewCell"
    var onCreateWorkoutTapped: ((Routine) -> Void)?
    var onWorkoutTapped: ((Workout) -> Void)?

    var onWorkoutExpansionChanged: (() -> Void)?
    
    var routine: Routine? {
        didSet {
            updateUI()
        }
    }
    @objc func workoutLabelTapped(_ sender: UITapGestureRecognizer) {
        if let index = workoutsStackView.arrangedSubviews.firstIndex(of: sender.view!),
           let workout = routine?.workouts[index] {
            // Toggle the expanded state of the workout
          
            // Execute the onWorkoutTapped closure
            onWorkoutTapped?(workout)

            // Update the UI to reflect the new state
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
        
        // Add the target to the createWorkoutButton
        createWorkoutButton.addTarget(self, action: #selector(createWorkoutButtonTapped), for: .touchUpInside)
    }

    @objc func createWorkoutButtonTapped() {
        if let routine = routine {
            onCreateWorkoutTapped?(routine)
        }
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
                routine.workouts.forEach { workout in
                    let workoutLabel = UILabel()
                    workoutLabel.text = workout.name
                    workoutLabel.font = UIFont.systemFont(ofSize: 16)
                    workoutLabel.textColor = .black

                    // Add tap gesture recognizer to the workout label
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(workoutLabelTapped(_:)))
                    workoutLabel.addGestureRecognizer(tapGesture)
                    workoutLabel.isUserInteractionEnabled = true

                    workoutsStackView.addArrangedSubview(workoutLabel)

                    // Show exercises if the workout is expanded
                
                }

                // Add the "Create Workout" button to the stack view
                workoutsStackView.addArrangedSubview(createWorkoutButton)
            }
        }
    }


}
