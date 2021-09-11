import 'dart:async';
import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

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

  bool _play = false;
  File? file;
  bool _record = false;
  String? filePath = '/storage/emulated/0/Download/audio.wav';
  TextEditingController cmnt = TextEditingController();

  @override
  void initState() {
    super.initState();
    startIt();
  }

//audio session and get permission method
  void startIt() async {
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

//file upload methd
  Future addnetwork(String cmt) async {
    try {
      file = File(filePath!);
      Map data = {
        'file': file,
        'comment': cmt,
      };

      print(file);
      http.Response response =
          await http.post(Uri.parse('Url link'), //Your Url link
              body: data);
      var jsondata = response.body;
      print('success');
      print(jsondata);
      delete();
    } catch (e) {
      print(e);
    }
  }

//file delete method
  void delete() {
    final dir = Directory(filePath!);
    dir.deleteSync(recursive: true);
    print('successfully deleted');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        delete();
      }),
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
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your comment',
              ),
              controller: cmnt,
            ),
            Container(
              width: double.maxFinite,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton.icon(
                    onPressed: () => addnetwork(cmnt.text),
                    icon: Icon(Icons.upload),
                    label: Text('upload')),
              ),
            )
          ],
        ),
      ),
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
  }

  Future<void> stopPlaying() async {
    audioPlayer.stop();
  }
}
