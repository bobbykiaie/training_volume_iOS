
struct Routine: Decodable {
    var id: String?
    var name: String
    var workouts: [Workout]
    var isExpanded: Bool

    init(id: String? = nil, name: String, workouts: [Workout], isExpanded: Bool = false) {
        self.id = id
        self.name = name
        self.workouts = workouts
        self.isExpanded = isExpanded
    }
    
    // Add a custom decoding initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        workouts = try container.decode([Workout].self, forKey: .workouts)
        
        // Provide a default value if the key is missing
        isExpanded = container.contains(.isExpanded) ? try container.decode(Bool.self, forKey: .isExpanded) : false
    }
    
    // Define CodingKeys
    private enum CodingKeys: String, CodingKey {
        case id, name, workouts, isExpanded
    }
}
struct Workout: Decodable {
    let id: String
    let name: String
    var exercises: [Exercise]

    init(id: String, name: String, exercises: [Exercise]) {
        self.id = id
        self.name = name
        self.exercises = exercises
    }
}

struct Exercise: Decodable {
    let id: String
    let name: String
    let sets: Int
    let reps: Int
    let muscle: String
 
}
