
class Habit {
  final String id;
  final String name;

  Habit({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
    );
  }

  String getName() {
    return name;
  }
}