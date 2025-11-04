class Exercise {
  final String id;
  final String name;
  final String muscleGroup;

  Exercise({required this.id, required this.name, required this.muscleGroup});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'muscleGroup': muscleGroup};
  }

  factory Exercise.fromMap(Map<String, dynamic> map, String id) {
    return Exercise(
      id: id,
      name: map['name'] ?? '',
      muscleGroup: map['muscleGroup'] ?? '',
    );
  }
}
