import 'package:flutter/material.dart';
import 'package:voice_review/record_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final record = RecordScreen();

  Widget start() {
    final isrecord = record.isrecord;
    final icon = isrecord ? Icons.stop : Icons.mic;
    final text = isrecord ? 'stop' : 'start';
    final primary = isrecord ? Colors.red : Colors.white;
    final onprimary = isrecord ? Colors.white : Colors.black;
    return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            primary: primary, onPrimary: onprimary, minimumSize: Size(170, 50)),
        onPressed: () async {
          final isrecord = await record.togglerecord();
          setState(() {});
        },
        icon: Icon(icon),
        label: Text(text));
  }

  @override
  void initState() {
    super.initState();
    record.init();
  }

  @override
  void dispose() {
    record.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('recorder'),
      ),
      body: Center(
        child: start(),
      ),
    );
  }
}
