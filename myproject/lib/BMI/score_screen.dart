import 'package:flutter/material.dart';
import 'package:myproject/BMI/BMIPage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pretty_gauge/pretty_gauge.dart';
import 'package:share_plus/share_plus.dart';

class ScoreScreen extends StatelessWidget {
  final double bmiScore;
  final int age;

  String? bmiStatus;
  String? bmiInterpretation;
  Color? bmiStatusColor;

  ScoreScreen({Key? key, required this.bmiScore, required this.age})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    setBmiInterpretation();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "BMI Score",
          style: TextStyle(
            color: Colors.white, // Text color
            fontSize: 24, // Text size
            fontWeight: FontWeight.bold, // Text weight
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[800]!, // Darker shade of grey
                Colors.grey[600]!, // Lighter shade of grey
              ],
            ),
          ),
        ),
        elevation: 0, // No shadow
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Your Score",
              style: TextStyle(fontSize: 30, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            PrettyGauge(
              gaugeSize: 300,
              minValue: 0,
              maxValue: 40,
              segments: [
                GaugeSegment('UnderWeight', 18.5, Colors.red),
                GaugeSegment('Normal', 6.4, Colors.green),
                GaugeSegment('OverWeight', 5, Colors.orange),
                GaugeSegment('Obese', 10.1, Colors.pink),
              ],
              valueWidget: Text(
                bmiScore.toStringAsFixed(1),
                style: const TextStyle(fontSize: 40,color: Colors.white),
              ),
              currentValue: bmiScore.toDouble(),
              needleColor: Colors.blue,
            ),
            const SizedBox(height: 10),
            Text(
              bmiStatus!,
              style: TextStyle(fontSize: 20, color: bmiStatusColor!),
            ),
            const SizedBox(height: 10),
            Text(
              bmiInterpretation!,
              style: const TextStyle(fontSize: 15,color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context,PageTransition(type: PageTransitionType.rightToLeft, child: BMIPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, // Button color
                    textStyle: TextStyle(color: Colors.black), // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                    ),
                  ),

                  child: const Text("Re-calculate",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  void setBmiInterpretation() {
    if (bmiScore > 30) {
      bmiStatus = "Obese";
      bmiInterpretation = "Please work to reduce obesity";
      bmiStatusColor = Colors.pink;
    } else if (bmiScore >= 25) {
      bmiStatus = "Overweight";
      bmiInterpretation = "Do regular exercise & reduce the weight";
      bmiStatusColor = Colors.orange;
    } else if (bmiScore >= 18.5) {
      bmiStatus = "Normal";
      bmiInterpretation = "Enjoy, You are fit";
      bmiStatusColor = Colors.green;
    } else if (bmiScore < 18.5) {
      bmiStatus = "Underweight";
      bmiInterpretation = "Try to increase the weight";
      bmiStatusColor = Colors.red;
    }
  }
}
