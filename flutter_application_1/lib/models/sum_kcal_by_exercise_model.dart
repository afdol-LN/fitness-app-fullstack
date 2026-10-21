import 'package:flutter/material.dart';

class SumKCalByExerciseModel {
  int exerciseId = 0;
  String exerciseName = "";
  double sumKCal = 0.00;

  SumKCalByExerciseModel({
    required this.exerciseId,
    required this.exerciseName,
    required this.sumKCal,
  });

  factory SumKCalByExerciseModel.fromJson(Map<String, dynamic> json) {
    return SumKCalByExerciseModel(
      exerciseId: json['ex_id'] as int,
      exerciseName: json['ex_name'] as String,
      sumKCal: json['sum_kcal'] is num 
              ? (json['sum_kacal']as num).toDouble()
              : double.tryParse(json['sum_kcal']?.toString() ?? '') ?? 0.0,
    );
  }
}


class sumKCalByExerciseResponse{
  bool isError = false;
  List<SumKCalByExerciseModel> data = [];
  String errorMessage = "";

  sumKCalByExerciseResponse({
    required this.isError,
    required this.data,
    required this.errorMessage,
  });

  factory sumKCalByExerciseResponse.fromJson(Map<String, dynamic> json){
    return sumKCalByExerciseResponse(
      isError: json['isError'], 
      data: (json['data'] as List)
          .map((item) => SumKCalByExerciseModel.fromJson(item) )
          .toList(),
      errorMessage: json['errorMessage']
    );
  }
}