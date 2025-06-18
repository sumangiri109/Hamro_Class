import 'package:flutter/material.dart';

class LogoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Logo')),
      body: Center(child: Image.asset('assets/images/logo.png')),
    );
  }
}
