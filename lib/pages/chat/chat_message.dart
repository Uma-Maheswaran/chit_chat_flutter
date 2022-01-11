import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/pages/user/user_details.dart';
class ChatMessage extends StatelessWidget {
  final String text;
  final User user;
  final AnimationController animationController;
  const ChatMessage(
      {required this.text, Key? key,required this.user,required this.animationController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
          parent: animationController, curve: Curves.easeInToLinear),
      axisAlignment: 0.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child:  CircleAvatar(
                backgroundColor: Colors.white60,
                child: Text(user.displayName![0]),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName??"Anonymous user",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: Text(text),
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