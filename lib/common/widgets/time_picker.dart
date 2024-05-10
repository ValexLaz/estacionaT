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
  
  _CustomTimePickerState()
      : selectedTime = TimeOfDay(hour: 1, minute: 1);
      
  void initState() {
    super.initState();
    selectedTime = widget.startTime; // Setting initial time
  }

  void _onTimeSelected(int hourIndex, int minuteIndex) {
    setState(() {
      selectedTime = TimeOfDay(hour: widget.startTime.hour + hourIndex, minute: minuteIndex);
    });
    widget.onTimeSelected?.call(selectedTime);
  }

  void _showTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Column(
            children: [
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
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onTimeSelected?.call(selectedTime);
                },
                child: Text('Confirmar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHourPicker() {
    final int numberOfHours = widget.endTime.hour - widget.startTime.hour + 1;
    return CupertinoPicker(
      scrollController: FixedExtentScrollController(initialItem: selectedTime.hour - widget.startTime.hour),
      itemExtent: 36,
      onSelectedItemChanged: (index) {
        _onTimeSelected(index, selectedTime.minute);
      },
      children: List.generate(numberOfHours, (index) {
        return Center(child: Text('${widget.startTime.hour + index}'));
      }),
    );
  }

  Widget _buildMinutePicker() {
    return CupertinoPicker(
      scrollController: FixedExtentScrollController(initialItem: selectedTime.minute),
      itemExtent: 36,
      onSelectedItemChanged: (index) {
        _onTimeSelected(selectedTime.hour - widget.startTime.hour, index);
      },
      children: List.generate(60, (index) {
        return Center(child: Text('$index'));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTimePicker(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: Text(
          '${selectedTime.format(context)}',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
