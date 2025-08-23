import 'dart:math';

import 'package:flutter/material.dart';
import 'package:myproject/BMI/age_weight_widget.dart';
import 'package:myproject/BMI/gender_widget.dart';
import 'package:myproject/BMI/height_widget.dart';
import 'package:myproject/BMI/score_screen.dart';
import 'package:page_transition/page_transition.dart';

class BMIPage extends StatefulWidget {
  const BMIPage({Key? key}) : super(key: key);

  @override
  _BMIPageState createState() => _BMIPageState();
}

class _BMIPageState extends State<BMIPage> {
  int _gender = 0;
  int _height = 0;
  int _age = 0;
  int _weight = 0;
  double _bmiScore = 0;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          "BMI Calculator",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GenderWidget(
                  onChange: (genderVal) {
                    setState(() {
                      _gender = genderVal;
                    });
                  },
                  validator: (isValid) {
                    if (!isValid) {
                      return 'Please select your gender';
                    }
                    return null; // Return null when validation is successful
                  },
                ),
                SizedBox(height: 60,),
                _buildTextFormField(
                  initialValue: '',
                  labelText: 'Height (cm)',
                ),
                SizedBox(height: 20,),
                _buildTextFormField(
                  initialValue: '',
                  labelText: 'Age',
                ),
                SizedBox(height: 20,),
                _buildTextFormField(
                  initialValue: '',
                  labelText: 'Weight (kg)',
                ),
                SizedBox(height: 40,),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 60,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Calculate BMI here
                        calculateBmi();

                        // Navigate to the next screen
                        Navigator.push(
                          context,
                          PageTransition(
                            child: ScoreScreen(
                              bmiScore: _bmiScore,
                              age: _age,
                            ),
                            type: PageTransitionType.rightToLeft,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // Button color
                      textStyle: TextStyle(color: Colors.black), // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Rectangular border
                      ),
                    ),
                    child: Text("CALCULATE",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({required String initialValue, required String labelText}) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      style: TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $labelText';
        }
        return null; // Return null when validation is successful
      },
      onChanged: (value) {
        setState(() {
          switch (labelText) {
            case 'Height (cm)':
              _height = int.parse(value);
              break;
            case 'Age':
              _age = int.parse(value);
              break;
            case 'Weight (kg)':
              _weight = int.parse(value);
              break;
          }
        });
      },
    );
  }

  void calculateBmi() {
    setState(() {
      _bmiScore = _weight / pow(_height / 100, 2);
    });
  }
}
