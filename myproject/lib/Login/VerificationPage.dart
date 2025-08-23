import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myproject/components/icons.dart';
import 'package:myproject/Login/homepage.dart';

import 'login.dart';

class VerificationPage extends StatefulWidget {
  final String email;

  const VerificationPage({Key? key, required this.email}) : super(key: key);

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  late Timer _timer;
  bool _isResendButtonEnabled = false;
  int _resendButtonCooldown = 60;

  @override
  void initState() {
    super.initState();
    _startResendButtonCooldown();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startResendButtonCooldown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendButtonCooldown > 0) {
          _resendButtonCooldown--;
        } else {
          _isResendButtonEnabled = true;
          timer.cancel(); // Cancel the timer when countdown reaches 0
        }
      });
    });
  }

  Future<void> _resendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
      setState(() {
        _isResendButtonEnabled = false;
        _resendButtonCooldown = 60;
      });
      _startResendButtonCooldown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black, // Set background color to black
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20,),
            Image.asset(AppAssets.icemail,
              height: 150,
              width: 150,),
            SizedBox(height: 10,),
            Text(
              'Verification email has been sent to:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Set text color to white
              ),
            ),
            SizedBox(height: 10),
            Text(
              widget.email,
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                color: Colors.white, // Set text color to white
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'We have just sent an email verification link to your email. Please check your email and click on that link to verify your email address.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white, // Set text color to white
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Once you\'re verified, you will be directly navigated to the home page.' ,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontStyle: FontStyle.italic// Set text color to white
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _isResendButtonEnabled ? _resendVerificationEmail : null,
              child: Text(
                _isResendButtonEnabled ? 'Resend Email' : 'Resend Email in $_resendButtonCooldown second(s)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isResendButtonEnabled ? Colors.blue : Colors.grey, // Change color based on button state
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
