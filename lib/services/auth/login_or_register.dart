import 'package:flutter/material.dart';
import 'package:orderly/screens/chat/login_page.dart';
import 'package:orderly/screens/chat/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  //intialy show login page
  bool showLoginPage = true;

  //toggle btw login and register
  void togglePage() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onTap: togglePage);
    } else {
      return RegisterPage(
        onTap: togglePage,
      );
    }
  }
}
