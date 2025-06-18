import 'package:flutter/material.dart';

class Image1Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('image1')),
      body: Center(child: Image.asset('assets/images/image1.png')),
    );
  }
}
