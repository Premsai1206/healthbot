import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:myproject/components/icons.dart';

class OTPScreen extends StatefulWidget {
  String verificationId;
  TextEditingController nameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  String? selectedCity;
  String? selectedBloodGroup;
  String? selectedGender;
  TextEditingController ageController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  OTPScreen({
    required this.verificationId,
    required this.phoneController,
    required this.selectedCity,
    required this.ageController,
    required this.selectedGender,
    required this.locationController,
    required this.nameController,
    required this.selectedBloodGroup,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late TextEditingController otpController1;
  late TextEditingController otpController2;
  late TextEditingController otpController3;
  late TextEditingController otpController4;
  late TextEditingController otpController5;
  late TextEditingController otpController6;
  late Timer _timer;
  int _start = 60;
  bool allOTPFilled = false;
  late FocusNode focusNode1;
  late FocusNode focusNode2;
  late FocusNode focusNode3;
  late FocusNode focusNode4;
  late FocusNode focusNode5;
  late FocusNode focusNode6;
  int _resendTimer = 60; // Initial countdown value for resend OTP
  bool _resendActive = false; // Indicates if resend OTP button is active

  @override
  void initState() {
    super.initState();
    otpController1 = TextEditingController();
    otpController2 = TextEditingController();
    otpController3 = TextEditingController();
    otpController4 = TextEditingController();
    otpController5 = TextEditingController();
    otpController6 = TextEditingController();
    focusNode1 = FocusNode();
    focusNode2 = FocusNode();
    focusNode3 = FocusNode();
    focusNode4 = FocusNode();
    focusNode5 = FocusNode();
    focusNode6 = FocusNode();
    startTimer();
    startResendTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void startResendTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_resendTimer == 0) {
          setState(() {
            _resendActive = true; // Activate resend OTP button
            timer.cancel();
          });
        } else {
          setState(() {
            _resendTimer--;
          });
        }
      },
    );
  }

  void resetResendTimer() {
    setState(() {
      _resendTimer = 60; // Reset countdown timer
      _resendActive = false; // Deactivate resend OTP button
    });
  }
  void resendOTP() {
    setState(() {
      _start = 60; // Reset the countdown timer for new OTP
    });
    resetResendTimer(); // Reset the resend timer
    startTimer(); // Start the countdown timer for new OTP
    // Resend OTP logic here...
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91${widget.phoneController.text}',
      timeout: Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        print('Resend OTP verification failed: ${e.message}');
        showAlert('Resend OTP verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          widget.verificationId = verificationId; // Update verification ID
        });
        // No need to navigate to a new OTP screen, just display a message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP Resent Successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          widget.verificationId = verificationId; // Update verification ID
        });
      },
    );
  }
  @override
  void dispose() {
    _timer.cancel();
    otpController1.dispose();
    otpController2.dispose();
    otpController3.dispose();
    otpController4.dispose();
    otpController5.dispose();
    otpController6.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();
    focusNode5.dispose();
    focusNode6.dispose();
    super.dispose();
  }

  void checkAllOTPFilled() {
    if (otpController1.text.isNotEmpty &&
        otpController2.text.isNotEmpty &&
        otpController3.text.isNotEmpty &&
        otpController4.text.isNotEmpty &&
        otpController5.text.isNotEmpty &&
        otpController6.text.isNotEmpty) {
      setState(() {
        allOTPFilled = true;
      });
    } else {
      setState(() {
        allOTPFilled = false;
      });
    }
  }

  Future<void> addDonorDetails() async {
    try {

      await FirebaseFirestore.instance.collection('donors').add({
        'name': widget.nameController.text,
        'gender': widget.selectedGender,
        'location': widget.locationController.text,
        'city': widget.selectedCity,
        'bloodGroup': widget.selectedBloodGroup,
        'phoneNumber': widget.phoneController.text,
        'age': widget.ageController.text,
      });
      Navigator.pop(context);
      print('Donor details added to Firestore');
    } catch (e) {
      print('Error adding donor details to Firestore: $e');
    }
  }


  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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
    ).then((_) {
      // Reload the page after the alert dialog is closed
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPScreen(
            verificationId: widget.verificationId,
            phoneController: widget.phoneController,
            selectedCity: widget.selectedCity,
            ageController: widget.ageController,
            selectedGender: widget.selectedGender,
            locationController: widget.locationController,
            nameController: widget.nameController,
            selectedBloodGroup: widget.selectedBloodGroup,
          ),
        ),
      );
    });
  }

  void handleBackspace() {
    if (otpController6.text.isNotEmpty) {
      otpController6.clear();
    } else if (otpController5.text.isNotEmpty) {
      otpController5.clear();
    } else if (otpController4.text.isNotEmpty) {
      otpController4.clear();
    } else if (otpController3.text.isNotEmpty) {
      otpController3.clear();
    } else if (otpController2.text.isNotEmpty) {
      otpController2.clear();
    } else if (otpController1.text.isNotEmpty) {
      otpController1.clear();
    }
    checkAllOTPFilled(); // Check if all OTP fields are filled after clearing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "OTP Verification",
          style: TextStyle(color: Colors.white), // Set text color of app bar title
        ),
        centerTitle: true,
        backgroundColor: Colors.black, // Set background color of app bar
        iconTheme: IconThemeData(color: Colors.white), // Set back button color
      ),
      backgroundColor: Colors.black, // Set background color of the entire screen
      body: GestureDetector(
        onTap: () {
          // Set focus to the first OTP controller when tapped anywhere on the screen
          FocusScope.of(context).requestFocus(focusNode1);
        },
        child: Column(
          children: [
            SizedBox(height: 20,),
            Image.asset(AppAssets.icOTP,
              height: 200,
              width: 200,),
            SizedBox(height: 20,),
            Text(
              "OTP sent to +91 ${widget.phoneController.text}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Set text color to white
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Colors.grey[400],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Enter 6 digit OTP',
                      style: TextStyle(color: Colors.grey[700]), // Set text color to white
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (RawKeyEvent event) {
                if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
                  // Handle backspace key press
                  handleBackspace();
                }
              },
              child: SizedBox.shrink(), // Invisible widget to capture keyboard events
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  otpField(otpController1, focusNode1),
                  otpField(otpController2, focusNode2),
                  otpField(otpController3, focusNode3),
                  otpField(otpController4, focusNode4),
                  otpField(otpController5, focusNode5),
                  otpField(otpController6, focusNode6),
                ],
              ),
            ),
            allOTPFilled
                ? Container(
              width: 190,
              padding: EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextButton(
                onPressed: () {
                  String otp = otpController1.text +
                      otpController2.text +
                      otpController3.text +
                      otpController4.text +
                      otpController5.text +
                      otpController6.text;

                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                    verificationId: widget.verificationId,
                    smsCode: otp,
                  );
                  FirebaseAuth.instance.signInWithCredential(credential).then(
                        (value) async {
                      await addDonorDetails();
                      Navigator.pop(context);
                      print('OTP verified successfully');
                    },
                  ).catchError((error) {
                    print('Error verifying OTP: $error');
                    showAlert('Incorrect OTP is entered');
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.blueGrey), // Background color
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), // Text color
                ),
                child: Text(
                  'OTP',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
            )
                : SizedBox(),
            TextButton(
              onPressed: _resendActive ? resendOTP : null,
              child: Text(
                _resendTimer > 0
                    ? 'Resend OTP in $_resendTimer seconds'
                    : 'Resend OTP', // Display countdown or static text
                style: TextStyle(
                  color: _resendActive ? Colors.blue : Colors.grey, // Adjust text color based on button state
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget otpField(TextEditingController controller, FocusNode? focusNode) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        onChanged: (value) {
          checkAllOTPFilled(); // Check if all OTP fields are filled whenever there's a change
          if (value.isNotEmpty) {
            focusNode?.nextFocus();
          }
        },
        style: TextStyle(color: Colors.white), // Set text color to white
        decoration: InputDecoration(
          counter: Offstage(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white, // Set border color to white
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}
