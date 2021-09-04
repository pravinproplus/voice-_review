import 'package:flutter/material.dart';
import 'package:voice_review/record_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('recorder'),
      ),
      body: RecordScreen(),
    );
  }
}
