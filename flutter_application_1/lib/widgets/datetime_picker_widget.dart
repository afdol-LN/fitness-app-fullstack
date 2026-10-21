
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DatetimePickerWidget extends StatelessWidget{
  final String label;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<TimeOfDay> onTimeSelected; 
  const DatetimePickerWidget({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateSelected,
    required this.onTimeSelected
  });
  
  Future<void> _pickDate(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100)
    );
    if(picked != null){
      onDateSelected(picked);
    }
  }
  Future<void> _pickTime(BuildContext context) async{
    final TimeOfDay? picked = await showTimePicker(
     context: context,
     initialTime: selectedTime
     );
     if(picked != null){
      onTimeSelected(picked);
     }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _pickDate(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.blue,
                        size: 20
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: InkWell(
                onTap: ()=>_pickTime(context),
                borderRadius: BorderRadius.circular(12),
                child:  Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        selectedTime.format(context),
                        style: const TextStyle(fontSize: 15),
                      ),
                      const Icon(
                        Icons.access_time,
                        color: Colors.blue,
                        size: 20,
                      )
                    ],
                  ),
                )
              ),
            )
          ],
        )
      ],
    );
  }
}