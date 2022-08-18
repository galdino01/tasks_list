class Task {
  Task({required this.title, required this.dateNow, required this.checked});

  Task.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        dateNow = DateTime.parse(json['datenow']),
        checked = json['checked'];

  String title;
  DateTime dateNow;
  bool checked;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'datenow': dateNow.toIso8601String(),
      'checked': checked
    };
  }
}
