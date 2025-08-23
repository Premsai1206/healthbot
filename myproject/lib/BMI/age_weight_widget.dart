import 'package:flutter/material.dart';
class AgeWeightWidget extends StatefulWidget {
  final Function(int) onChange;
  final String title;
  final int initValue;
  final int min;
  final int max;

  const AgeWeightWidget({
    Key? key,
    required this.onChange,
    required this.title,
    required this.initValue,
    required this.min,
    required this.max,
  }) : super(key: key);

  @override
  _AgeWeightWidgetState createState() => _AgeWeightWidgetState();
}

class _AgeWeightWidgetState extends State<AgeWeightWidget> {
  int _value = 0;

  @override
  void initState() {
    super.initState();
    _value = widget.initValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(),
        color: Colors.white,
        child: Column(
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: 25, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _value.toString(),
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.title == "Age" ? "years" : "kg",
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                )
              ],
            ),
            Slider(
              min: widget.min.toDouble(),
              max: widget.max.toDouble(),
              value: _value.toDouble(),
              onChanged: (value) {
                setState(() {
                  _value = value.toInt();
                });
                widget.onChange(_value);
              },
            )
          ],
        ),
      ),
    );
  }
}
