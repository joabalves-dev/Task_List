import 'dart:convert';

import 'package:list_task/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Repo_Tasks {
  final String keySharedPref = 'tasks_list';

  late SharedPreferences sharedPreferences;

  void saveTasksList(List<Task> tasks) {
    final jsonString = json.encode(tasks);
    sharedPreferences.setString(keySharedPref, jsonString);
  }

  Future<List<Task>> getTasksList() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString =
        sharedPreferences.getString(keySharedPref) ?? '[]';
    final List jsonDecoded = json.decode(jsonString) as List;
    return jsonDecoded.map((e) => Task.fromJson(e)).toList();
  }
}
