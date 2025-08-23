import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myproject/Login/homepage.dart';
import 'package:myproject/Login/login.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while waiting for authentication state
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final user = snapshot.data;
          if (user != null) {
            // User is logged in
            if (user.emailVerified||user.providerData.any((info) => info.providerId == 'google.com')) {
              // Email is verified, navigate to homepage
              return Homepage();
            } else {
              // Email is not verified, navigate to login page
              return Login();
            }
          } else {
            // User is not logged in, navigate to login page
            return Login();
          }
        },
      ),
    );
  }
}
