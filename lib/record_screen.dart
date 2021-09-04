import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({Key? key}) : super(key: key);

  @override
  _RecordScreenState createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  IconData play = Icons.play_arrow;
  IconData pause = Icons.pause;
  bool isnull = true;
  FlutterSoundRecorder? flutterSoundRecorder;
  final audiosave = 'audio.aac';
  Future record() async {
    await flutterSoundRecorder!.startRecorder(toFile: audiosave);

    setState(() {
      isnull = false;
    });
  }

  Future stop() async {
    await flutterSoundRecorder!.startRecorder();
    setState(() {
      isnull = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          icon: Icon(isnull == true ? play : pause),
          onPressed: () {
            isnull == true ? record() : stop();
          },
          label: Text("Start"),
        ),
      ),
    );
  }
}
