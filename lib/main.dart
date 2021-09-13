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
  Duration? duration = Duration();
  Duration? position = Duration();
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

//audio record method
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

//stop record method
  Future stopRecord() async {
    _myRecorder!.closeAudioSession();
    return await _myRecorder!.stopRecorder();
  }

//audio play method
  Future<void> startPlaying() async {
    audioPlayer.open(
      Audio.file(filePath!),
      autoStart: true,
      showNotification: true,
    );
    audioPlayer.current;
    audioPlayer.current.listen((playingAudio) {
      final songDuration = playingAudio!.audio.duration;
      print("Here you have a duration $songDuration");
      setState(() {
        duration = songDuration;
      });
    });
    audioPlayer.currentPosition.listen((event) {
      setState(() {
        position = event;

        print(position);
      });
    });
  }

//stop playing method
  Future<void> stopPlaying() async {
    audioPlayer.stop();
  }
  //inside a stateful widget

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.delete),
          onPressed: () {
            delete();
          }),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: h / 12,
              width: w / 1.2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Row(
                    children: [
                      Container(
                        height: h / 15,
                        width: w / 8,
                        child: IconButton(
                          iconSize: 30.0,
                          onPressed: () {
                            setState(() {
                              _play = !_play;
                            });
                            if (_play) {
                              startPlaying();
                            }

                            if (!_play) {
                              stopPlaying();
                            }
                          },
                          icon: _play == false
                              ? Icon(Icons.play_arrow)
                              : Icon(Icons.pause),
                        ),
                      ),
                      Slider.adaptive(
                          min: 00.0,
                          max: duration!.inSeconds.toDouble(),
                          value: position!.inSeconds.toDouble(),
                          onChanged: (double value) {
                            setState(() {
                              value = position!.inSeconds.toDouble();
                              _play = !_play;
                            });
                          })
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onLongPress: () {
                setState(() {
                  _record = !_record;
                });
                record();
              },
              onLongPressUp: () {
                setState(() {
                  _record = !_record;
                });
                stopRecord();
              },
              child: Container(
                height: h / 15,
                width: w / 8,
                decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4)),
                child: _record == false ? Icon(Icons.mic) : Icon(Icons.pause),
              ),
            ),
            SizedBox(
              height: 20,
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
            ),
          ],
        ),
      ),
    );
  }
}
