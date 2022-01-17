import 'dart:convert';

import 'package:chat_app/pages/auth/sign_in_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/pages/chat/chat_message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatScreen extends StatefulWidget {
  final User user;
  const ChatScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  ScrollController listScrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isSigningOut = false;
  final List<ChatMessage> _messages = [];
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  bool _isComposing = false;
  late final User _currentUser;
  late WebSocketChannel _channel;
  final List<Map<String, dynamic>> list = [];

  @override
  void initState() {
    _currentUser = widget.user;
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://chit-chat-115.herokuapp.com/websocket'),
    );
    _channel.stream.listen((event) => setState(() {
      print(json.decode(event));
      list.add(json.decode(event));
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text("Chit Chat"),
        actions: <Widget>[
          _isSigningOut
              ? const CircularProgressIndicator()
              : TextButton(
            child: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.logout_rounded),
              onPressed: _signOut,
            ),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          Flexible(
              child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/1.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: list.length,
                    reverse: false,
                    controller: listScrollController,
                    itemBuilder: (context, i) {
                      print(list[i]);
                      return ChatMessage(
                        text: list[i]['message'],
                        user: _currentUser,
                        // animationController: AnimationController(
                        //   duration: const Duration(milliseconds: 600),
                        //   vsync: this,
                        // ),
                        displayName:list[i]['user'] ,
                      );
                    },
                  )
              )),
          const Divider(height: 1.0),
          Container(
            color: Colors.black87,
            //decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: const IconThemeData(color: Colors.white70),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText2,
                controller: _textController,
                onChanged: (text) => {
                  setState(() {
                    _isComposing = text.isNotEmpty;
                  })
                },
                onSubmitted: _isComposing ? _handleSubmitted : null,
                focusNode: _focusNode,
                decoration: const InputDecoration.collapsed(
                    hintText: 'Send a message',
                    hintStyle: TextStyle(fontFamily: 'Georgia')),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isComposing
                    ? () => {_handleSubmitted(_textController.text)}
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget slideIt(BuildContext context, int index, animation) {
  //   Map<String,dynamic> item = list[index];
  //   TextStyle? textStyle = Theme.of(context).textTheme.headline4;
  //   return SlideTransition(
  //     position: Tween<Offset>(
  //       begin: const Offset(-1, 0),
  //       end: const Offset(0, 0),
  //     ).animate(animation),
  //     child: SizedBox( // Actual widget to display
  //       //height: 128.0,
  //       child: ChatMessage(
  //         text: item['message'],
  //         user: _currentUser,
  //         displayName: item['user'],
  //       ))
  //     );
  // }

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    FirebaseFirestore.instance.collection('data').add({'text': text});

    var params = {
      "user": _currentUser.displayName,
      "message": text,
    };
    const jsonEncoder = JsonEncoder();
    _channel.sink.add(jsonEncoder.convert(params));
    _focusNode.requestFocus();
  }


  Future<void> _signOut() async {
    try {
      setState(() {
        _isSigningOut = true;
      });
      await FirebaseAuth.instance.signOut();
      setState(() {
        _isSigningOut = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SignInPage(),
        ),
      );
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }
}
