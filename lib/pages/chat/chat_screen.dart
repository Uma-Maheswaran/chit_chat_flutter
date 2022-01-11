import 'package:chat_app/pages/auth/sign_in_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/pages/chat/chat_message.dart';

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
  final FocusNode _focusNode = FocusNode();
  bool _isSigningOut = false;
  final List<ChatMessage> _messages = [];
  bool _isComposing = false;
  late final User _currentUser;

  @override
  void initState() {
    _currentUser = widget.user;
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
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('data').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                List<Map<String, dynamic>> data =
                    snapshot.data!.docs.map((e) => e.data()).toList();
                if (kDebugMode) {
                  print(data);
                }
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    return ChatMessage(
                      text: data[i]['text'],
                      user: _currentUser,
                      animationController: AnimationController(
                        duration: const Duration(milliseconds: 600),
                        vsync: this,
                      ),
                    );
                  },
                );
              },
            ),
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

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    FirebaseFirestore.instance.collection('data').add({'text': text});
    var message = ChatMessage(
      text: text,
      user: _currentUser,
      animationController: AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    setState(() {
      _messages.insert(0, message);
    });
    _focusNode.requestFocus();
    message.animationController.forward();
  }

  @override
  void dispose() {
    for (var message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
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
