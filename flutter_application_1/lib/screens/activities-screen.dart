import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/models/activity_model.dart';
import 'package:flutter_application_1/utils/app_api.dart';
import 'package:flutter_application_1/widgets/datetime_picker_widget.dart';
import 'package:flutter_application_1/widgets/exercise_icon_widget.dart';
import 'package:intl/intl.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({
    super.key,
    required this.activityId,
    required this.exerciseId,
  });

  final int exerciseId;
  final int activityId;

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String titleText = "";

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _seelctTime = TimeOfDay.now();

  int kcalExpense = 0;
  final TextEditingController _kcalValueController = TextEditingController();
  Future<(bool, String)> _doCreateActivity() async {
    DateTime activityDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _seelctTime.hour,
      _seelctTime.minute,
    );
    Map<String, dynamic> postBody = {
      "exercise_id": widget.exerciseId,
      "activity_date": DateFormat('dd-MM-yyyy HH:mm:ss').format(activityDate),
      "kcal_expense": kcalExpense,
    };

    final response = await AppAPI.post("/activity/create", postBody);
    final json = jsonDecode(response.body);
    return (json["isError"] as bool, json["errorMessage"] as String);
  }

  Future<(bool, String)> _doUpdateactivity() async {
    DateTime activityDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _seelctTime.hour,
      _seelctTime.minute,
    );
    Map<String, dynamic> postBody = {
      "activity_date": DateFormat('dd-MM-yyyy HH:mm:ss').format(activityDate),
      "kcal_expense": kcalExpense,
      "activity_id": widget.activityId,
    };
    final response = await AppAPI.post("/activity/update", postBody);
    final json = jsonDecode(response.body);
    return (json["isError"] as bool, json["errorMessage"] as String);
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<ActivityModel> _getActivityModel() async {
    var resposne = await AppAPI.get('/activity/${widget.activityId}');
    Map<String, dynamic> json = jsonDecode(resposne.body);
    ActivityResponse store = ActivityResponse.fromJson(json);
    ActivityModel model = store.data[0];

    return model;
  }

  Future<void> showConfirmDialog(
    BuildContext context,
    Function onConfirm,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการทำรายการ'),
          content: const Text('คุณต้องการลบข้อมูลนี้ใช่หรือไม่?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('ยืนยัน', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  Future<(bool, String)> _doDeleteActivity() async {
    Map<String, dynamic> postBody = {"activity_id": widget.activityId};

    final response = await AppAPI.post("/activity/delete", postBody);
    final json = jsonDecode(response.body);
    return (json['isError'] as bool, json["errorMessage"] as String);
  }

  Future<void> _initData() async {
    if (widget.activityId == 0) {
      setState(() {
        titleText = "เพิ่มการออกกำลังกาย";
        _kcalValueController.text = "0";
      });
    } else {
      ActivityModel model = await _getActivityModel();

      setState(() {
        titleText = "แก้ใขการออกกำลังกาย";
        _selectedDate = model.getActivityDateTime(model.activityDate);
        _seelctTime = TimeOfDay.fromDateTime(
          model.getActivityDateTime(model.activityDate),
        );
        kcalExpense = model.kcalExpense;
        _kcalValueController.text = model.kcalExpense.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row( 
            children: [
              ExerciseIconWidget(exerciseId: widget.exerciseId, size: 32),
              Text(titleText),
            ],
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.00),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {
                    showConfirmDialog(context, () async {
                      var (isError, errorMessage) = await _doDeleteActivity();

                      if (!isError) {
                        Navigator.pop(context);
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(content: Text(errorMessage));
                          },
                        );
                      }
                    });
                  },
                  icon: const Icon(Icons.delete),
                  color: Colors.redAccent,
                  splashColor: Colors.red.withValues(alpha: 0.1),
                ),
              ),
              DatetimePickerWidget(
                label: "Date and time",
                selectedDate: _selectedDate,
                selectedTime: _seelctTime,
                onDateSelected: (newDate) {
                  setState(() {
                    _selectedDate = newDate;
                  });
                },
                onTimeSelected: (newTime) {
                  setState(() {
                    _seelctTime = newTime;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text("Kcal"),
              TextFormField(
                controller: _kcalValueController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    kcalExpense = int.tryParse(value) ?? 0;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  var isError = false;
                  var errorMessage = "";

                  if (widget.activityId == 0) {
                    (isError, errorMessage) = await _doCreateActivity();
                  } else {
                    (isError, errorMessage) = await _doUpdateactivity();
                  }
                  if (!isError) {
                    Navigator.pop(context);
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(content: Text(errorMessage));
                      },
                    );
                  }
                },
                child: Text("บันทึก"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
