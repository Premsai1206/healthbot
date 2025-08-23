import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';

import 'Messages.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({ Key? key}) : super(key: key);
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}




class _ChatbotPageState extends State<ChatbotPage> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];

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
            color: Colors.white, // Text color
            fontSize: 24, // Text size
            fontWeight: FontWeight.bold, // Text weight
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0, // No shadow

        iconTheme: IconThemeData(color: Colors.white), // Transparent background
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(child: MessagesScreen(messages: messages)),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8
              ),

              child: Row(
                children: [
                  Expanded(child:
                  TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200], // Background color
                      hintText: 'Type your message here...',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14), // Padding
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none, // Remove border
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none, // Remove border
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none, // Remove border
                      ),
                      prefixIcon: Icon(Icons.message), // Icon on the left
                      suffixIcon: IconButton(
                        onPressed: () {
                          _controller.clear();
                        },
                        icon: Icon(Icons.clear), // Clear icon on the right
                      ),
                    ),
                  ),

                  ),
                  IconButton(
                    onPressed: () {
                      sendMessage(_controller.text);
                      _controller.clear();
                    },
                    icon: Icon(Icons.send, color: Colors.blue), // Change color to blue
                  )

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  sendMessage(String txt)async{
    if(txt.isEmpty){
      print('Message is empty');
    }
    else{
      setState(() {
        addMessage(Message(text: DialogText(text: [txt])
        ),true);
      });

      DetectIntentResponse response = await dialogFlowtter.detectIntent(queryInput: QueryInput(text: TextInput(text: txt)));
      if(response.message == null) return;
      setState(() {
        addMessage(response.message!);
      });
    }
  }
  addMessage(Message message,[bool isUserMessage = false]){
    messages.add({
      'message': message,
      'isUserMessage' : isUserMessage
    });
  }
}