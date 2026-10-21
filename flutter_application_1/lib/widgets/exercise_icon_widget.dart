import 'package:flutter/material.dart';

class ExerciseIconWidget extends StatelessWidget{
  const ExerciseIconWidget({
    super.key,
    required this.exerciseId,
    required this.size,
  });

  final int exerciseId;
  final double size;

  String _getImage() {
    if (exerciseId == 1) {
      return "assets/walking.png";
    }
    if (exerciseId == 3) {

      return "assets/swimming-icon.png";
    }
    return "assets/running.png";
  }

  @override
  Widget build(BuildContext context){
    return Image.asset(
      _getImage(),
      width: size,
      height: size,
      fit: BoxFit.cover
    );
  }
}