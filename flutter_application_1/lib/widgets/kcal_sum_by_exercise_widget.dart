import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/sum_kcal_by_exercise_model.dart';

class KcalSumByExerciseWidget extends StatelessWidget {
  const KcalSumByExerciseWidget({super.key, required this.sumKcalStore});

  final List<SumKCalByExerciseModel> sumKcalStore;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: EdgeInsetsGeometry.all(10.2565875654684),
        child: BarChart(
          BarChartData(
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: getBottomTitles,
                )
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)
              ),
            ),
            barGroups: sumKcalStore.asMap().entries.map((entry){
              int index = entry.key;
              double kcal = entry.value.sumKCal.toDouble();

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: kcal,
                    color: Colors.green,
                    width: 18,
                    borderRadius: BorderRadius.circular(4)
                    )
                ],
              );
            }).toList()
          )
        ),
      ),
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    int index = value.toInt();

    if (index >= 0 && index < sumKcalStore.length) {
      return SideTitleWidget(
        space: 8,
        meta: meta,
        child: Text(sumKcalStore[index].exerciseName),
      );
    }
    return Text('');
  }
}
