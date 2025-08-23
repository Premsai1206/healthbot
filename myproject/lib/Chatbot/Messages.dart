import 'package:flutter/material.dart';
class MessagesScreen extends StatefulWidget {
  final List messages;

  const MessagesScreen({Key? key, required this.messages}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.black, // Set background color to a light grey
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: widget.messages.length,
        itemBuilder: (context, index) {
          bool isUserMessage = widget.messages[index]['isUserMessage'];
          Color backgroundColor = isUserMessage ? Colors.teal[200]! : Colors.amber[200]!;
          Color textColor = isUserMessage ? Colors.white : Colors.black;

          return Align(
            alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxWidth: screenWidth * 0.7, // Limit message width
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUserMessage ? 16 : 4),
                  topRight: Radius.circular(isUserMessage ? 4 : 16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                widget.messages[index]['message'].text.text[0],
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
