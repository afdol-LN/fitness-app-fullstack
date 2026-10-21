import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/activity_model.dart';
import 'package:flutter_application_1/widgets/exercise_icon_widget.dart';
class ActivityListWidget extends StatelessWidget {
  const ActivityListWidget({super.key, required this.activityModelstore, required this.onEditPress});
  final List<ActivityModel> activityModelstore;
  final Function(int) onEditPress;
  
  String _getImage(int exerciseId) {
    if (exerciseId == 1) {
      return "assets/walking.png";
    }
    if (exerciseId == 3) {

      return "assets/swimming-icon.png";
    }
    return "assets/running.png";
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: activityModelstore.isEmpty
          ? const Center(child: Text("ไม่มีข้อมูลกิจกรรม"))
          : ListView.builder(
              itemCount: activityModelstore.length,
              itemBuilder: (context, index) {
                ActivityModel item = activityModelstore[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    tileColor: const Color.fromARGB(255, 193, 216, 235),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundImage: AssetImage(_getImage(item.exerciseid)),
                    ),
                    title: Text(item.activityDate),
                    subtitle: Text(
                      "${item.exerciseName}, ${item.kcalExpense}",
                    ),
                    trailing:
                      IconButton(
                      onPressed: (){
                        onEditPress(item.activityId);
                      },
                      icon:const Icon(Icons.edit))
                  ),
                );
              },
            ),
    );
  }
}
