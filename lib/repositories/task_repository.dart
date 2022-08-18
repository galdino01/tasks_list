import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:tasks_list/models/task.dart';

const _taskLiskKey = 'task_list';

class TaskRepository {
  late SharedPreferences _sharedPreferences;

  Future<List<Task>> getTaskList() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    final String jsonString =
        _sharedPreferences.getString(_taskLiskKey) ?? '[]';
    final List jsonDecoded = json.decode(jsonString) as List;

    return jsonDecoded.map((item) => Task.fromJson(item)).toList();
  }

  void saveTaskList(List<Task> tasks) {
    final String jsonString = json.encode(tasks);
    _sharedPreferences.setString(_taskLiskKey, jsonString);
  }
}
