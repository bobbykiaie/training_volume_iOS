import UIKit

class WorkoutDetailsViewController: UIViewController {
    
    var workout: Workout?
    var exerciseFields: [ExerciseFieldView] = []
    var muscleView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = workout?.name
        setupUI()
    }
    
    func createMuscleView() -> UIView {
        let muscleView = UIView()
        muscleView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a dictionary to keep track of each unique muscle and its set count
        var muscleCounts: [String: Int] = [:]
        
        for exerciseField in exerciseFields {
            let muscle = exerciseField.exercise?.muscle ?? ""
            muscleCounts[muscle, default: 0] += exerciseField.setCount
        }
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        muscleView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: muscleView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: muscleView.bottomAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: muscleView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: muscleView.trailingAnchor, constant: -20)
        ])
        
        for (muscle, count) in muscleCounts {
            let circleView = UIView()
            circleView.backgroundColor = .red
            circleView.layer.cornerRadius = 15  // Half of the width and height to make a circle
            circleView.translatesAutoresizingMaskIntoConstraints = false
            circleView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor).isActive = true
            
            let countLabel = UILabel()
            countLabel.text = String(count)
            countLabel.textColor = .white
            countLabel.textAlignment = .center
            countLabel.translatesAutoresizingMaskIntoConstraints = false
            circleView.addSubview(countLabel)
            
            NSLayoutConstraint.activate([
                countLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
                countLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor)
            ])
            
            let muscleLabel = UILabel()
            muscleLabel.text = muscle
            muscleLabel.textAlignment = .center
            muscleLabel.translatesAutoresizingMaskIntoConstraints = false

            let muscleCircleView = UIStackView()
            muscleCircleView.axis = .vertical
            muscleCircleView.alignment = .center
            muscleCircleView.spacing = 10
            muscleCircleView.addArrangedSubview(circleView)
            muscleCircleView.addArrangedSubview(muscleLabel)
            
            stackView.addArrangedSubview(muscleCircleView)
        }
        
        return muscleView
    }

    func setupUI() {
        guard let workout = self.workout else { return }
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.spacing = 20
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        for exercise in workout.exercises {
                    print(workout)
                    let exerciseFieldView = ExerciseFieldView(exercise: exercise)
                    exerciseFieldView.onAddSet = { [weak self] in
                        self?.muscleView?.removeFromSuperview()
                        self?.muscleView = self?.createMuscleView()
                        contentView.addArrangedSubview((self?.muscleView)!)
                    }
                    contentView.addArrangedSubview(exerciseFieldView)
                    self.exerciseFields.append(exerciseFieldView)
                }
                muscleView = createMuscleView()
                contentView.addArrangedSubview(muscleView!)
        
    }
    
    @objc func addSetButtonTapped() {
        // Add a set to your workout
        // ...
        
        // Update the muscle view
        createMuscleView()
    }
}
