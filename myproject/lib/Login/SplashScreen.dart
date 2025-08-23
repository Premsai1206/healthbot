import 'package:flutter/material.dart';
import 'package:myproject/Login/wrapper.dart';
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add any initialization tasks here
    // For example, loading data or assets
    _navigateToIntroPage(); // Navigate to the intro page after a delay
  }

  void _navigateToIntroPage() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => Wrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/health-insurance.png',
            width:250,
            height: 250),
            SizedBox(height: 20),
            Text(
              'HealthGuard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8,),
            Text(
              'Your Trusted Shield for Better Health',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic
              ),
            ),
          ],
        ),
      ),
    );
  }
}