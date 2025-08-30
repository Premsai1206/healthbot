import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';

import 'Messages.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  double? userHeight; // in cm
  double? userWeight; // in kg

  @override
  void initState() {
    DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MediBot',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(child: MessagesScreen(messages: messages)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: 'Type your message here...',
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.message),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _controller.clear();
                          },
                          icon: Icon(Icons.clear),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      sendMessage(_controller.text);
                      _controller.clear();
                    },
                    icon: Icon(Icons.send, color: Colors.blue),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  sendMessage(String txt) async {
    if (txt.isEmpty) return;

    setState(() {
      addMessage(Message(text: DialogText(text: [txt])), true);
    });

    DetectIntentResponse response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(text: TextInput(text: txt)),
    );

    String? intentName = response.queryResult?.intent?.displayName;
    print("🎯 Detected Intent: $intentName");
    print("📥 User said: $txt");

    // --- Capture Height ---
    if (intentName == "GetHeight") {
      var heightParam = response.queryResult?.parameters?['height'];
      print("🧾 Parameters: ${response.queryResult?.parameters}");

      if (heightParam != null) {
        userHeight = double.tryParse(heightParam.toString());
        print("👉 Captured Height: $userHeight cm (from Dialogflow param)");
      } else {
        print("⚠️ Height param not found in Dialogflow response");
      }
    }

    // --- Capture Weight ---
    if (intentName == "GetWeight") {
      var weightParam = response.queryResult?.parameters?['weight'];
      if (weightParam != null) {
        userWeight = double.tryParse(weightParam.toString());
        print("👉 Captured Weight: $userWeight kg (from Dialogflow param)");
      } else {
        print("⚠️ Weight param not found in Dialogflow response");
      }

      print("👉 Stored Height so far: $userHeight");

      if (userHeight != null && userWeight != null) {
        double bmi = calculateBMI(userHeight!, userWeight!);
        print("✅ Calculated BMI: $bmi (Weight: $userWeight, Height: $userHeight)");

        // Send BMI value back to Dialogflow for recommendations
        String bmiMessage = "";

        if (bmi < 18.5) {
          bmiMessage = "BMI is $bmi, you are underweight";
        } else if (bmi >= 18.5 && bmi < 25) {
          bmiMessage = "BMI is $bmi, you are normal weight";
        } else if (bmi >= 25 && bmi < 30) {
          bmiMessage = "BMI is $bmi, you are overweight";
        } else {
          bmiMessage = "BMI is $bmi, you are obese";
        }

        DetectIntentResponse bmiResponse = await dialogFlowtter.detectIntent(
          queryInput: QueryInput(text: TextInput(text: bmiMessage)),
        );
        if (bmiResponse.message != null) {
          setState(() {
            addMessage(bmiResponse.message!);
          });

          setState(() {
            addMessage(
              Message(text: DialogText(text: ["Your BMI is ${bmi.toStringAsFixed(2)}"])),
            );
          });

        }
      } else {
        print("⚠️ Missing values. Height: $userHeight, Weight: $userWeight");
      }
    }

    // --- Add normal Dialogflow response ---
    if (response.message != null) {
      setState(() {
        addMessage(response.message!);
      });
    }
  }

  double calculateBMI(double heightCm, double weightKg) {
    double heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({
      'message': message,
      'isUserMessage': isUserMessage,
    });
  }
}
