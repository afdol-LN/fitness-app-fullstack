import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/activity_model.dart';
import 'package:flutter_application_1/models/sum_kcal_by_exercise_model.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:flutter_application_1/utils/app_api.dart';
import 'package:flutter_application_1/utils/route_observer.dart';

import 'package:flutter_application_1/widgets/activity_list_widget.dart';
import 'package:flutter_application_1/widgets/exercise_button_widget.dart';
import 'package:flutter_application_1/widgets/kcal_sum_by_exercise_widget.dart';
import 'package:flutter_application_1/widgets/kcal_summary_widget.dart';
import 'package:flutter_application_1/widgets/profile_avatar_widget.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  List<ActivityModel> activityModelStore = [];
  List<SumKCalByExerciseModel> sumKCalOfExerciseStore = [];
  String? _imageFileName;
  bool _isLoading = true;

  void _fetchdata() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? imageFileName = prefs.getString("image_url");
      final response = await Future.wait([
        AppAPI.get("/activity/getActivityByUserId"),
        AppAPI.get("/activity/sum_kcal_by_exercise"),
      ]);
      final response1 = response[0];
      final response2 = response[1];

      Map<String, dynamic> jsonOfActivityResponse = jsonDecode(response1.body);
      ActivityResponse activityResponse = ActivityResponse.fromJson(
        jsonOfActivityResponse,
      );
      Map<String, dynamic> jsonOfSumKcal = jsonDecode(response2.body);
      sumKCalByExerciseResponse sumOfExerciseKcal = sumKCalByExerciseResponse
          .fromJson(jsonOfSumKcal);

      setState(() {
        activityModelStore = activityResponse.data;
        sumKCalOfExerciseStore = sumOfExerciseKcal.data;
        _imageFileName = imageFileName;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Fetch activity error: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _fetchdata();
  }

  @override
  void initState() {
    // TODO: implement initState
    _fetchdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            (_isLoading)
                ? SizedBox.shrink()
                : ProfileAvatarWidget(
                    size: 40,
                    imageFileName: _imageFileName,
                    onAvatarTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ),
                      );
                    },
                  ),
            // KCalSummary(activityModelstore: activityModelStore),
            KcalSumByExerciseWidget(sumKcalStore: sumKCalOfExerciseStore),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                padding: const EdgeInsets.all(10),
                children: [
                  ExerciseButtonWidget(
                    exerciseId: 1,
                    activityModelstore: activityModelStore,
                  ),
                  ExerciseButtonWidget(
                    exerciseId: 2,
                    activityModelstore: activityModelStore,
                  ),
                  ExerciseButtonWidget(
                    exerciseId: 3,
                    activityModelstore: activityModelStore,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
