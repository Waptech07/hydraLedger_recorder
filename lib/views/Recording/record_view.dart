// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:hydraledger_recorder/constants/color_constants.dart';
import 'package:hydraledger_recorder/views/Recording/stop_record_view.dart';

class RecordView extends StatefulWidget {
  final PersistentTabController controller;

  RecordView({required this.controller, Key? key}) : super(key: key);

  @override
  State<RecordView> createState() => _RecordViewState();
}

String? patho;
File? audioFileo;
String? fileName;

class _RecordViewState extends State<RecordView> {
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  int typeindex = 0;
  late final RecorderController recorderController;

  @override
  void initState() {
    super.initState();
    recorderController = RecorderController();
    initRecorder();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    recorderController.dispose();
    super.dispose();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw "Microphone permission not granted";
    }
    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(
      const Duration(
        milliseconds: 500,
      ),
    );
  }

  Future record() async {
    //if (!isRecorderReady) return;
    recorderController.record();
    fileName =
        'Record-${DateFormat("dd-MM-yyyy_HH-mm-ss").format(DateTime.now())}';
    await recorder.startRecorder(toFile: fileName);
  }

  Future stop() async {
    //if (!isRecorderReady) return;
    recorderController.stop();
    patho = await recorder.stopRecorder();
    audioFileo = File(patho!);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StopRecordView(
          previousPath: patho,
          previousFile: audioFileo,
          fileName2: fileName,
          controller: widget.controller,
        ),
      ),
    );
    //print("recorded audio: $audioFileo");
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffFFFFFF),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: height * 0.017, left: 16, right: 16),
            child: Column(
              children: [
                ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: SvgPicture.asset("assets/icons/back_arrow.svg",
                        color: const Color(0xff7F0D51)),
                  ),
                  title: const Padding(
                    padding: EdgeInsets.only(
                      left: 25,
                    ),
                    child: Text(
                      'Voice Recorder',
                      style: TextStyle(
                          color: Color(0xff484848),
                          fontSize: 24,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: height * 0.025),
                  child: const Image(
                      image: AssetImage("assets/image/recorder_icon.png")),
                ),
                StreamBuilder<RecordingDisposition>(
                  stream: recorder.onProgress,
                  builder: (context, snapshot) {
                    final duration = snapshot.hasData
                        ? snapshot.data!.duration
                        : Duration.zero;
                    String twoDigits(int n) => n.toString().padLeft(2, '0');
                    final twoDigitsMinutes =
                        twoDigits(duration.inMinutes.remainder(60));
                    final twoDigitsSeconds =
                        twoDigits(duration.inSeconds.remainder(60));
                    final twoDigitsHours =
                        twoDigits(duration.inHours.remainder(60));
                    return Padding(
                      padding: EdgeInsets.only(top: height * 0.05),
                      child: Text(
                        '$twoDigitsHours:$twoDigitsMinutes:$twoDigitsSeconds',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff484848)),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: height * 0.02),
                  child: Text(
                    DateFormat("yyyy/MM/dd").format(DateTime.now()),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff484848)),
                  ),
                ),
                AudioWaveforms(
                  size: Size(MediaQuery.of(context).size.width, 50.0),
                  recorderController: recorderController,
                  enableGesture: true,
                  waveStyle: const WaveStyle(
                    waveColor: kColorGold,
                    showDurationLabel: true,
                    durationStyle: TextStyle(color: kColorGold),
                    spacing: 6.0,
                    durationLinesColor: Colors.black26,
                    showBottom: false,
                    extendWaveform: false,
                    showMiddleLine: false,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(bottom: height * 0.045),
          child: Container(
            alignment: Alignment.center,
            width: 60,
            height: 60,
            child: InkWell(
              onTap: () async {
                if (recorder.isRecording) {
                  await stop();
                } else {
                  await record();
                }
                setState(() {});
              },
              child: Image(
                image: const AssetImage("assets/image/record_button.png"),
                color: recorder.isRecording ? kColorGold : Colors.black26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
