class ApplicationDailyUsage {
  String name;
  String packageName;
  String category;
  DateTime date;
  List<int> hourlyUsageInSeconds;

  ApplicationDailyUsage({
    required this.name,
    required this.packageName,
    required this.category,
    required this.date,
    List<int>? hourlyUsageInSeconds,
  }) : hourlyUsageInSeconds = hourlyUsageInSeconds ?? List.filled(24, 0);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'packageName': packageName,
      'category': category,
      'date': date.toIso8601String(),
      'hourlyUsageInSeconds': hourlyUsageInSeconds,
    };
  }

}
