import 'package:intl/intl.dart';

class ActivityModel {
  int activityId = 0;
  int exerciseid = 0;
  String exerciseName = "";
  int kcalExpense = 0;
  String activityDate ="";

  ActivityModel({
    required this.activityId,
    required this.exerciseid,
    required this.exerciseName,
    required this.kcalExpense,
    required this.activityDate,
  });

  DateTime getActivityDateTime(inputDate){
    DateFormat dateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');
    DateTime dateTime = dateFormat.parse(inputDate);
    return dateTime;
  }

  factory ActivityModel.fromJson(Map<String, dynamic> json){
    return ActivityModel(
      activityId: json['act_id'] is int ? json['act_id'] : int.tryParse(json['act_id']?.toString() ?? '') ?? 0,
      exerciseid: json['ex_id'] is int ? json['ex_id'] : int.tryParse(json['ex_id']?.toString() ?? '') ?? 0,
      exerciseName: (json['ex_name'] ?? "").toString(),
      kcalExpense: json['kcal_expense'] is int ? json['kcal_expense'] : int.tryParse(json['kcal_expense']?.toString() ?? '') ?? 0,
      activityDate: (json['act_date'] ?? "").toString(),
    );
  }

}


class ActivityResponse{
  bool isError = false;
  List<ActivityModel> data = [];
  String errorMessage = "";

  ActivityResponse({
    required this.isError,
    required this.data,
    required this.errorMessage,
  });

  factory ActivityResponse.fromJson(Map<String,dynamic> json){
    return ActivityResponse(
      isError : json['isError'] ?? false,
      data : (json['data'] as List? ?? [])
          .map((item) => ActivityModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      errorMessage : (json['errorMessage'] ?? "").toString(),
    );
  }
}