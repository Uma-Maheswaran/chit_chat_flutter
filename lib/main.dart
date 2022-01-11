import 'package:flutter/material.dart';
import 'package:chat_app/themes/default_theme.dart';
import 'package:chat_app/pages/auth/sign_in_page.dart';
void main(){
  runApp(const ChitChat());
}

class ChitChat extends StatelessWidget {
  const ChitChat({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FriendlyChat',
      theme: themeData,
      home: const SignInPage(),
    );
  }
}


