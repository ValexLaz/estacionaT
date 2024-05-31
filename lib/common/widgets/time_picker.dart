import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final void Function(TimeOfDay)? onTimeSelected;

  const CustomTimePicker({
    Key? key,
    required this.startTime,
    required this.endTime,
    this.onTimeSelected,
  }) : super(key: key);

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  TimeOfDay selectedTime;

  _CustomTimePickerState() : selectedTime = TimeOfDay(hour: 1, minute: 1);

  void initState() {
    super.initState();
    selectedTime = widget.startTime; // Setting initial time
  }

  void _onTimeSelected(int hourIndex, int minuteIndex) {
    setState(() {
      selectedTime = TimeOfDay(
          hour: widget.startTime.hour + hourIndex, minute: minuteIndex);
    });
    widget.onTimeSelected?.call(selectedTime);
  }



  Widget _buildHourPicker() {
    final int numberOfHours = widget.endTime.hour - widget.startTime.hour + 1;
    return CupertinoPicker.builder(
      scrollController: FixedExtentScrollController(
          initialItem: selectedTime.hour - widget.startTime.hour),
      itemExtent: 36,
      magnification: 1.5,
      diameterRatio: 2.0,
      useMagnifier: true,
   
      onSelectedItemChanged: (index) {
        _onTimeSelected(index, selectedTime.minute);
      },
      childCount: numberOfHours,
      itemBuilder: (BuildContext context, int index) {
        final bool isSelected =
            index == selectedTime.hour - widget.startTime.hour;
        return Center(
          
          child: Text(
            '${widget.startTime.hour + index}',
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.grey,
              fontSize: isSelected ? 20 : 16,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinutePicker() {
    return CupertinoPicker.builder(
      scrollController:
          FixedExtentScrollController(initialItem: selectedTime.minute),
      itemExtent: 36,
      magnification: 1.5,
      diameterRatio: 2.0,
      useMagnifier: true,
      onSelectedItemChanged: (index) {
        _onTimeSelected(selectedTime.hour - widget.startTime.hour, index);
      },
      childCount: 60,
      itemBuilder: (BuildContext context, int index) {
        final bool isSelected = index == selectedTime.minute;
        return Center(
          child: Text(
            '$index',
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.grey,
              fontSize: isSelected ? 20 : 16,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
          height: 100,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Hora"),
                  Text("Minuto")
                ],
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildHourPicker(),
                    ),
                    Expanded(
                      child: _buildMinutePicker(),
                    ),
                  ],
                ),
              ),
              
            ],
          ),
        );
     
  }
}
