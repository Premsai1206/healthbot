import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myproject/components/icons.dart';
import 'package:myproject/Login/homepage.dart';
import 'package:myproject/Login/signup.dart';
import 'package:myproject/Login/ForgotPasswordPage.dart';
import 'package:page_transition/page_transition.dart';

import '../components/my_textfield.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false; // variable to control loader visibility

  Future<void> resendVerificationEmail(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {

        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Verification email sent. Please check your inbox.'),
        ));
      }
    } catch (error) {
      print('Error resending verification email: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
        Text('Failed to resend verification email. Please try again later.'),
      ));
    }
  }

  void showEmailVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Please verify your email before logging in.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> signIn(BuildContext context) async {
    setState(() {
      _isLoading = true; // Show loader when sign-in process starts
    });

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        await user.reload();
        if (user.emailVerified ||
            user.providerData.any((info) => info.providerId == 'google.com')) {
          // Proceed with navigation to the desired page
          // For example:
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: Homepage(), // Replace HomeScreen() with your actual home screen widget
            ),
          );


        } else {
          showEmailVerificationDialog(context);
        }
      }
    } catch (error) {
      print('Error signing in: $error');
      String errorMessage = 'An error occurred, please try again later.';
      if (error is FirebaseAuthException) {
        switch (error.code) {
          case 'invalid-email':
            errorMessage = 'Invalid email address format. Please check your email.';
            break;
          default:
            errorMessage =
            'Invalid email or password. Please check your credentials and try again.';
        }
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loader when sign-in process completes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset(AppAssets.icSignIn,
                height: 100,
                width: 100,),
                const SizedBox(height: 50),
                Text(
                  'Unlock Your Health Hub: Sign In and Discover More',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: 300, // Adjust the width according to your preference
                  child: TextField(
                    controller: email,
                    decoration: InputDecoration(
                      hintText: 'Enter your Email',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0), // Rounded corners
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.email), // Icon before hint text
                    ),
                    obscureText: false,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 300, // Adjust the width according to your preference
                  child: TextField(
                    controller: password,
                    decoration: InputDecoration(
                      hintText: 'Enter your Password',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0), // Rounded corners
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.lock), // Icon before hint text
                    ),
                    obscureText: true,
                  ),
                ),

                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,PageTransition(child: ForgotPasswordPage(), type: PageTransitionType.rightToLeft)

                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.grey[600],
                          fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),


              SizedBox(height: 10,),
                _isLoading // Display loader if _isLoading is true
                    ? CircularProgressIndicator()
                    : SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => signIn(context),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () => resendVerificationEmail(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Email not verified yet?',
                        style: TextStyle(color: Colors.grey[600],fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Verify now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
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
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
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
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final GoogleSignIn googleSignIn = GoogleSignIn();
                        final GoogleSignInAccount? googleSignInAccount =
                        await googleSignIn.signIn();
                        if (googleSignInAccount != null) {
                          final GoogleSignInAuthentication googleSignInAuthentication =
                          await googleSignInAccount.authentication;

                          final AuthCredential credential = GoogleAuthProvider.credential(
                            accessToken: googleSignInAuthentication.accessToken,
                            idToken: googleSignInAuthentication.idToken,
                          );

                          UserCredential userCredential =
                          await FirebaseAuth.instance.signInWithCredential(credential);
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/google.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,PageTransition(child: SignUp(), type: PageTransitionType.bottomToTop)

                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member?',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Register now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
