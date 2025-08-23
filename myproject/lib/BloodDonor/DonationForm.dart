import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myproject/BloodDonor/OTPScreen.dart';
import '../components/MyDropdownField.dart';
import '../components/my_textfield.dart';

class DonationForm extends StatefulWidget {
  const DonationForm({super.key});

  @override
  State<DonationForm> createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final locationController = TextEditingController();
  String? selectedCity;
  String? selectedBloodGroup;
  String? selectedGender;
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  late String verificationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final existingDocs = await FirebaseFirestore.instance
          .collection('donors')
          .where('phoneNumber', isEqualTo: phoneController.text)
          .get();

      if (existingDocs.docs.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('User exists.'),
              content: Text('Please use a different phone number.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException e) {
          print('Verification Failed: ${e.message}');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Verification Failed'),
                content: Text('Try again later'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            this.verificationId = verificationId;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                verificationId: verificationId,
                phoneController: phoneController,
                selectedCity: selectedCity,
                ageController: ageController,
                selectedGender: selectedGender,
                locationController: locationController,
                nameController: nameController,
                selectedBloodGroup: selectedBloodGroup,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            this.verificationId = verificationId;
          });
        },
        timeout: Duration(seconds: 60),
      );
    } catch (e) {
      print('Error occurred while verifying phone number: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while verifying your phone number.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blood Donation Form"),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 70),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10.0),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(
                      hintText: 'Location',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Location is required';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10.0),
                MyDropdownField(
                  items: <String>[
                    'Hyderabad',
                    'Mumbai',
                    'Delhi',
                    'Bangalore',
                    'Chennai'
                  ],
                  value: selectedCity,
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                    });
                  },
                  validator: (value) { // Add validator
                    if (value == null || value.isEmpty) {
                      return 'City is required';
                    }
                    return null;
                  },
                  hintText: 'City',

                ),
                SizedBox(height: 10.0),
                MyDropdownField(
                  items: <String>[
                    'Male',
                    'Female',
                    'Other',
                  ],
                  value: selectedGender,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                  validator: (value) { // Add validator
                    if (value == null || value.isEmpty) {
                      return 'Gender is required';
                    }
                    return null;
                  },
                  hintText: 'Gender',

                ),
                SizedBox(height: 10.0),
                MyDropdownField(
                  items: <String>[
                    'A+',
                    'A-',
                    'B+',
                    'B-',
                    'AB+',
                    'AB-',
                    'O+',
                    'O-'
                  ],
                  value: selectedBloodGroup,
                  onChanged: (value) {
                    setState(() {
                      selectedBloodGroup = value;
                    });
                  },
                  validator: (value) { // Add validator
                    if (value == null || value.isEmpty) {
                      return 'Blood group is required';
                    }
                    return null;
                  },
                  hintText: 'Blood Group',

                ),
                SizedBox(height: 10.0),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    obscureText: false,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone number is required';
                      } else if (value.length != 10) {
                        return 'Phone number should be 10 digits';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10.0),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: ageController,
                    decoration: InputDecoration(
                      hintText: 'Age',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    obscureText: false,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Age is required';
                      }
                      else if(int.parse(value)<21 && int.parse(value)>65){
                        return 'Age should be between 21 and 65 to donate blood';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 60.0),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : TextButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        verifyPhoneNumber(phoneController.text);
                      }
                    },
                    style: ButtonStyle(
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                    ),
                    child: Text(
                      'Become A Donor',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}