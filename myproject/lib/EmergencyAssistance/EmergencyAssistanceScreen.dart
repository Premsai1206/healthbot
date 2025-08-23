import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myproject/components/icons.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyAssistanceScreen extends StatefulWidget {
  @override
  _EmergencyAssistanceScreenState createState() =>
      _EmergencyAssistanceScreenState();
}

class _EmergencyAssistanceScreenState extends State<EmergencyAssistanceScreen> {
  String _location = 'Location not available';
  bool _locationUnknown = true;

  @override
  void initState() {
    super.initState();
    Geolocator.requestPermission();
    Geolocator.checkPermission();
    _getLocation();
  }

  Future<void> _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _location = '${position.latitude},${position.longitude}';
      _locationUnknown = false; // Location is available
    });
  }

  void _callEmergencyNumber() {
    const emergencyNumber = '108'; // Change this to your country's emergency number
    launch('tel:$emergencyNumber');
  }

  void _shareLocationWithOtherApps() {
    String message =
        'https://www.google.com/maps/search/?api=1&query=$_location';
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Emergency Assistance',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10),
              Image.asset(
                AppAssets.icEmergencyCall,
                height: 150,
                width: 150,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _callEmergencyNumber,
                icon: Icon(Icons.phone, color: Colors.black),
                label: Text(
                  'Call Emergency Services',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: Size(50, 70), // Adjust the height here
                ),
              ),
              SizedBox(height: 20),
              Image.asset(
                AppAssets.icMap,
                height: 150,
                width: 150,
              ),
              Text(
                'Your Current Location:',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                _location,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              if (_locationUnknown)
                ElevatedButton.icon(
                  onPressed: _getLocation,
                  icon: Icon(Icons.location_on, color: Colors.black),
                  label: Text(
                    'Get Location',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    minimumSize: Size(50, 60), // Adjust the height here
                  ),
                ),
              if (!_locationUnknown)
                ElevatedButton.icon(
                  onPressed: _shareLocationWithOtherApps,
                  icon: Icon(Icons.share, color: Colors.black),
                  label: Text(
                    'Share Location',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    minimumSize: Size(50, 60), // Adjust the height here
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
