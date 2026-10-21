import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/activity_model.dart';

class KCalSummary extends StatelessWidget {
  const KCalSummary({super.key, required this.activityModelstore});

  final List<ActivityModel> activityModelstore;

  int get _sumKCal {
    return activityModelstore.fold<int>(
      0,
      (sum, activity) => sum + activity.kcalExpense,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Total Calories',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '$_sumKCal kcal',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
