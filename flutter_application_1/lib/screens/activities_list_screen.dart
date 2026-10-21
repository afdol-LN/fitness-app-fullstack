import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/activity_model.dart';
import 'package:flutter_application_1/screens/activities-screen.dart';
import 'package:flutter_application_1/utils/app_api.dart';
import 'package:flutter_application_1/widgets/activity_list_widget.dart';
import 'package:flutter_application_1/widgets/exercise_icon_widget.dart';

class ActivitiesListScreen extends StatefulWidget {
  const ActivitiesListScreen({super.key, required this.exerciseId});

  final int exerciseId;

  @override
  State<ActivitiesListScreen> createState() => _ActivityListScreen();
}

class _ActivityListScreen extends State<ActivitiesListScreen> {
  List<ActivityModel> store = [];

  void _fetchdata() async {
    print(widget.exerciseId);
    var response = await AppAPI.get(
      "/activity/get_by_exerciseId/${widget.exerciseId}",
    );
    Map<String, dynamic> json = jsonDecode(response.body);
    ActivityResponse activityResponse = ActivityResponse.fromJson(json);

    setState(() {
      store = activityResponse.data;
    });
  }

  @override
  void initState() {
    _fetchdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ExerciseIconWidget(exerciseId: widget.exerciseId, size: 32),
        ),
      ),
      body: ActivityListWidget(
        activityModelstore: store,
        onEditPress: (actId) async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivityScreen(
                activityId: actId,
                exerciseId: widget.exerciseId,
              ),
            ),
          );
          _fetchdata();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ActivityScreen(activityId: 0, exerciseId: widget.exerciseId),
            ),
          );
          _fetchdata();
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
