import 'dart:async';
import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterSoundRecorder? _myRecorder;
  final audioPlayer = AssetsAudioPlayer();
  String? filePath;
  String dd = "max2";
  bool _play = false;
  var audio;
  bool _record = false;

  @override
  void initState() {
    super.initState();
    startIt();
  }

  void startIt() async {
    filePath = '/sdcard/Download/$dd.wav';
    _myRecorder = FlutterSoundRecorder();

    await _myRecorder!.openAudioSession(
        focus: AudioFocus.requestFocusAndStopOthers,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);
    await _myRecorder!.setSubscriptionDuration(Duration(milliseconds: 10));

    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title!,
          style: TextStyle(color: Colors.red),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 10.0,
              ),
              onPressed: () {
                setState(() {
                  _record = !_record;
                });
                if (_record) record();
                if (!_record) stopRecord();
              },
              icon: _record
                  ? Icon(
                      Icons.stop,
                    )
                  : Icon(Icons.mic),
              label: _record
                  ? Text(
                      "Stop",
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    )
                  : Text(
                      "Start",
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 10.0,
              ),
              onPressed: () {
                setState(() {
                  _play = !_play;
                });
                if (_play) startPlaying();
                if (!_play) stopPlaying();
              },
              icon: _play
                  ? Icon(
                      Icons.stop,
                    )
                  : Icon(Icons.play_arrow),
              label: _play
                  ? Text(
                      "Stop",
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    )
                  : Text(
                      " Play",
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
            ),
            Text(audio.toString()),
          ],
        ),
      ),
    );
  }

  ElevatedButton buildElevatedButton(
      {IconData? icon, Color? iconColor, Function()? f}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(5.0),
        side: BorderSide(
          color: Colors.orange,
          width: 3.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        primary: Colors.white,
        elevation: 10.0,
      ),
      onPressed: f,
      icon: Icon(
        icon,
        color: iconColor,
        size: 35.0,
      ),
      label: Text(''),
    );
  }

  Future<void> record() async {
    Directory dir = Directory(path.dirname(filePath!));
    if (!dir.existsSync()) {
      dir.createSync();
    }
    _myRecorder!.openAudioSession();
    await _myRecorder!.startRecorder(
      toFile: filePath,
      codec: Codec.pcm16WAV,
    );
  }

  Future stopRecord() async {
    _myRecorder!.closeAudioSession();
    return await _myRecorder!.stopRecorder();
  }

  Future<void> startPlaying() async {
    audioPlayer.open(
      Audio.file(filePath!),
      autoStart: true,
      showNotification: true,
    );
    setState(() {
      audio = Audio(filePath!);
    });
  }

  Future<void> stopPlaying() async {
    audioPlayer.stop();
  }
}
