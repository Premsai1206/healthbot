import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myproject/components/icons.dart';
import 'package:myproject/Login/login.dart';
import 'package:page_transition/page_transition.dart';

import 'VerificationPage.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? _passwordStrength;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isPasswordStrong(String value) {
    return value.length >= 8;
  }

  void _updatePasswordStrength(String value) {
    setState(() {
      _passwordStrength = _isPasswordStrong(value) ? 'Strong' : 'Weak';
    });
  }

  Future<void> signUp(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Send verification email using FCM
      await userCredential.user!.sendEmailVerification();

      // Navigate to verification page only if user creation was successful
      Navigator.push(
        context,PageTransition(child: VerificationPage(email: userCredential.user!.email!), type: PageTransitionType.rightToLeftWithFade)

      );

    } on FirebaseAuthException catch (e) {
      // Handle authentication errors
      if (e.code == 'weak-password') {
        // Handle weak password error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('The password provided is too weak.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        // Handle email already in use error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('The account already exists for that email.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Handle other errors
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('An unexpected error occurred. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {

     return Scaffold(
       appBar: AppBar(
         backgroundColor: Colors.black,
       ),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(AppAssets.icSignUp,height: 150,width: 150,),
                    SizedBox(height: 10,),
                    Text(
                      'Start Your HealthGuard Journey: Empowering You Towards a Healthier Future!',
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0), // Rounded corners
                        ),
                        filled: true,
                        fillColor: Colors.grey[200], // Fill color
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                        prefixIcon: Icon(Icons.email),// Padding
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                
                    SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      onChanged: _updatePasswordStrength,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0), // Rounded corners
                        ),
                        filled: true,
                        fillColor: Colors.grey[200], // Fill color
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0), // Padding
                        prefixIcon: Icon(Icons.lock), // Password icon as prefix
                        suffixText: _passwordStrength ?? '',
                        suffixStyle: TextStyle(color: _passwordStrength == 'Strong' ? Colors.green : Colors.red), // Color based on password strength
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (!_isPasswordStrong(value)) {
                          return 'Password is too weak';
                        }
                        return null;
                      },
                    ),
                
                    SizedBox(height: 10),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Confirm your password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0), // Rounded corners
                        ),
                        filled: true,
                        fillColor: Colors.grey[200], // Fill color
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0), // Padding
                        prefixIcon: Icon(Icons.lock), // Lock icon as prefix
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10,),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 105,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => signUp(context),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

    );
  }
}
