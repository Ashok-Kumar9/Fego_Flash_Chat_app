import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fego_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();

  late final user;
  late String textMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.popAndPushNamed(context, LoginScreen.id);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilderWidget(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: (value) {
                        textMessage = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.clear();
                      _firestore.collection('messages').add({
                        'text': textMessage,
                        'sender': _auth.currentUser!.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StreamBuilderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        return Expanded(
          child: ListView(
            reverse: true,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: snapshot.data!.docs.reversed.map((e) {
              Map<String, dynamic> data = e.data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: ChatBubble(
                  chatText: data['text'],
                  sender: data['sender'],
                  amI: _auth.currentUser!.email == data['sender'],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class ChatBubble extends StatelessWidget {
  ChatBubble({required this.chatText, required this.sender, required this.amI});

  final String chatText;
  final String sender;
  final bool amI;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          amI ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          sender,
          style: TextStyle(fontSize: 10.0, color: Colors.black54),
        ),
        SizedBox(
          height: 5.0,
        ),
        Material(
          color: amI ? Colors.lightBlueAccent : Colors.white,
          elevation: 5.0,
          borderRadius: amI
              ? BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  bottomLeft: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0))
              : BorderRadius.only(
                  topRight: Radius.circular(12.0),
                  bottomLeft: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0)),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
            child: Text(
              chatText,
              style: TextStyle(fontSize: 18.0, color: amI ? Colors.white : Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}
