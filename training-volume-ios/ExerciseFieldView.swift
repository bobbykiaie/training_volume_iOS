import UIKit

class ExerciseFieldView: UIView {
    let exerciseNameLabel = UILabel()
    let addSetButton = UIButton(type: .system)
    var setViews: [UIView] = []
    var exercise: Exercise? {
          didSet {
              exerciseNameLabel.text = exercise?.name
          }
      }
    var setCount: Int {
           return setViews.count
       }
    init(exercise: Exercise) {
        self.exercise = exercise
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    var onAddSet: (() -> Void)?
    private func setupUI() {
    
        self.layer.cornerRadius = 5

        exerciseNameLabel.text = exercise?.name
        exerciseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(exerciseNameLabel)

        addSetButton.setTitle("Add Set", for: .normal)
        addSetButton.addTarget(self, action: #selector(addSetButtonTapped), for: .touchUpInside)
        addSetButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(addSetButton)

        NSLayoutConstraint.activate([
            exerciseNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            exerciseNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            exerciseNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),

            addSetButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
        ])

        // Call the addSetButtonTapped() function to add the initial fields
        addSetButtonTapped()
    }

    
    @objc func addSetButtonTapped() {
        let setView = UIView()
        
        let weightTextField = UITextField()
        weightTextField.placeholder = "Weight"
        weightTextField.borderStyle = .roundedRect
        setView.addSubview(weightTextField)
        
        let repsTextField = UITextField()
        repsTextField.placeholder = "Reps"
        repsTextField.borderStyle = .roundedRect
        setView.addSubview(repsTextField)
        
        let checkmarkButton = UIButton(type: .system)
        checkmarkButton.setTitle("X", for: .normal) // use "X" as placeholder
        setView.addSubview(checkmarkButton)
        
        setView.translatesAutoresizingMaskIntoConstraints = false
        weightTextField.translatesAutoresizingMaskIntoConstraints = false
        repsTextField.translatesAutoresizingMaskIntoConstraints = false
        checkmarkButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            weightTextField.topAnchor.constraint(equalTo: setView.topAnchor),
            weightTextField.leadingAnchor.constraint(equalTo: setView.leadingAnchor),
            weightTextField.widthAnchor.constraint(equalTo: setView.widthAnchor, multiplier: 0.4), // use 40% of setView's width
            weightTextField.bottomAnchor.constraint(equalTo: setView.bottomAnchor),
            
            repsTextField.topAnchor.constraint(equalTo: setView.topAnchor),
            repsTextField.leadingAnchor.constraint(equalTo: weightTextField.trailingAnchor, constant: 10),
            repsTextField.widthAnchor.constraint(equalTo: weightTextField.widthAnchor),
            repsTextField.bottomAnchor.constraint(equalTo: setView.bottomAnchor),
            
            checkmarkButton.topAnchor.constraint(equalTo: setView.topAnchor),
            checkmarkButton.leadingAnchor.constraint(equalTo: repsTextField.trailingAnchor, constant: 10),
            checkmarkButton.trailingAnchor.constraint(equalTo: setView.trailingAnchor),
            checkmarkButton.bottomAnchor.constraint(equalTo: setView.bottomAnchor)
        ])
        
        setViews.append(setView)
        addSubview(setView)
        
        setView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = setView.topAnchor.constraint(equalTo: setViews.count > 1 ? setViews[setViews.count - 2].bottomAnchor : exerciseNameLabel.bottomAnchor, constant: 10)
        topConstraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            topConstraint,
            setView.leadingAnchor.constraint(equalTo: leadingAnchor),
            setView.trailingAnchor.constraint(equalTo: trailingAnchor),
            setView.heightAnchor.constraint(equalToConstant: 30) // Adjust as needed
        ])
        
        // Remove previous constraints of addSetButton
        addSetButton.removeFromSuperview()
        addSubview(addSetButton)
        addSetButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addSetButton.topAnchor.constraint(equalTo: setView.bottomAnchor, constant: 10),
            addSetButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            addSetButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            self.bottomAnchor.constraint(equalTo: addSetButton.bottomAnchor, constant: 10) // This line ensures that the ExerciseFieldView expands to fit all the setViews and the addSetButton
        ])
        onAddSet?()
    }

}
