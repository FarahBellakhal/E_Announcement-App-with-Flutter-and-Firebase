import 'package:flutter/material.dart';
import 'components/body.dart';
//mot de passe oublié
class ForgotPasswordScreen extends StatelessWidget {
  static const String routeName = "/forgot_password";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Body(),
    );
  }
}
