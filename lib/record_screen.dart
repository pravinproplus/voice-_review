import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

final pathaudio = 'audio.aac';

class RecordScreen {
  FlutterSoundRecorder? audiorecord;
  bool inirecord = false;
  bool get isrecord => audiorecord!.isRecording;
  Future init() async {
    audiorecord = FlutterSoundRecorder();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('allow micro phone');
    }
    await audiorecord!.openAudioSession();
    inirecord = true;
  }

  void dispose() {
    audiorecord!.closeAudioSession();
    audiorecord = null;
    inirecord = false;
  }

  Future record() async {
    if (!inirecord) return;
    await audiorecord!.startRecorder(toFile: pathaudio);
  }

  Future stop() async {
    if (!inirecord) return;
    await audiorecord!.stopRecorder();
  }

  Future togglerecord() async {
    if (audiorecord!.isStopped) {
      await record();
    } else {
      await stop();
    }
  }
}
