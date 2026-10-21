import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/activity_model.dart';
import 'package:flutter_application_1/screens/activities_list_screen.dart';
import 'package:flutter_application_1/widgets/exercise_icon_widget.dart';

class ExerciseButtonWidget extends StatelessWidget {
  const ExerciseButtonWidget({
    super.key,
    required this.exerciseId,
    required this.activityModelstore,
  });
  final int exerciseId;
  final List<ActivityModel> activityModelstore;

  int _sumKCal() {
    var thisExerciseActivities = activityModelstore.where(
      (act) => act.exerciseid == exerciseId,
    );
    int totalKCal = thisExerciseActivities.fold(
      0,
      (sum, act) => sum + act.kcalExpense,
    );

    return totalKCal;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context)=> ActivitiesListScreen(exerciseId: exerciseId)
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ExerciseIconWidget(exerciseId: exerciseId, size: 48),
            ),
            Text("${_sumKCal()} Kcal")
          ],
        ),
      ),
    );
  }
}
