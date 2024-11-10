import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart' as wave;
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:hydraledger_recorder/constants/color_constants.dart';
import 'package:hydraledger_recorder/views/image/image_preview.dart';

import 'name_record.dart';

class StopRecordView extends StatefulWidget {
  StopRecordView(
      {this.previousPath,
      this.previousFile,
      this.fileName2,
      this.isFromRecordList,
      this.path1,
      required this.controller,
      Key? key})
      : super(key: key);
  String? previousPath;
  String? fileName2;
  String? path1;
  bool? isFromRecordList;
  File? previousFile;
  final PersistentTabController controller;

  @override
  State<StopRecordView> createState() => _StopRecordViewState();
}

class _StopRecordViewState extends State<StopRecordView> {
  var audioPlayer = audio.AudioPlayer();
  bool isPlaying = false;
  bool iscompleted = false;
  bool iconHidden = false;
  String? path1;
  File? newFile;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Timer? animationTimer;
  bool? isRecorderReady;
  // final nameRecord = NameRecord();
  wave.RecorderController recorderController = wave.RecorderController();

  @override
  void initState() {
    super.initState();
    print("initing Recorder...");
    initRecorder();
    path1 = widget.path1;
    print("path1: $path1");
    if (widget.isFromRecordList == true) initRecorder();
    path1 != null
        ? setAudio().then((value) {
            setState(() {});
          })
        : null;
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == audio.PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        iscompleted = true;
        position = newPosition;
      });
    });
  }

  @override
  void dispose() {
    recorderController.dispose();
    animationTimer?.cancel();
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  Future initRecorder() async {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw "Microphone permission not granted";
    }
  }

  Future record() async {
    print("Starting to record...");
    widget.fileName2 =
        '${(await getApplicationDocumentsDirectory()).path}/Recording-${DateFormat("dd-MM-yyyy_HH-mm-ss").format(DateTime.now())}.aac';
    audioPlayer.stop();
    isRecorderReady = false;
    if (await recorderController.checkPermission()) {
      recorderController.record();
    } else {
      print("Permission not granted");
      Permission.microphone.request();
    }
  }

  Future stop() async {
    //if (!isRecorderReady) return;
    isRecorderReady = true;
    audioPlayer.stop();
    path1 = await recorderController.stop();
    print("Got path: $path1");
    newFile = File(path1!);
    print("Written bytes: ${newFile!.lengthSync()}");

    audioPlayer.setReleaseMode(audio.ReleaseMode.stop);
    audioPlayer.setSourceDeviceFile(path1!);
    // final audioFile = File(path1!);
    // print("recorded audio: $audioFile");
  }

  Future setAudio() async {
    audioPlayer.setReleaseMode(audio.ReleaseMode.stop);

    widget.isFromRecordList == true
        ? audioPlayer.setSourceDeviceFile(widget.path1!)
        : audioPlayer.setSourceDeviceFile(path1 ?? widget.previousPath!);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double myheight =
        height - (AppBar().preferredSize.height + statusBarHeight);
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: statusBarHeight + 15,
          ),
          Visibility(
            visible: widget.isFromRecordList == true ? true : false,
            child: AppBar(
              backgroundColor: const Color(0xffFFFFFF),
              elevation: 0,
              toolbarHeight: 50,
              title: const Text(
                "Record Preview",
                style: TextStyle(
                    color: Color(0xff484848),
                    fontSize: 24,
                    fontWeight: FontWeight.w600),
              ),
              leading: MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: SvgPicture.asset("assets/icons/back_arrow.svg",
                    color: const Color(0xff7F0D51)),
              ),
            ),
          ),
          Column(
            children: [
              AnimatedOpacity(
                opacity: iconHidden ? 0.2 : 1,
                duration: const Duration(milliseconds: 1000),
                child: GestureDetector(
                  onTap: () async {
                    if (recorderController.isRecording) {
                      await stop();
                      animationTimer?.cancel();
                    } else {
                      audioPlayer.stop();
                      await record();
                      animationTimer = Timer.periodic(
                          const Duration(milliseconds: 1100), (timer) {
                        setState(() {
                          iconHidden = !iconHidden;
                        });
                      });
                    }
                    setState(() {});
                  },
                  child: Image(
                    image: const AssetImage('assets/image/recorder_icon.png'),
                    height: myheight * 0.33,
                  ),
                ),
              ),
              widget.isFromRecordList == true || !recorderController.isRecording
                  ? const SizedBox()
                  : const SizedBox(),
              /*StreamBuilder<Amplitude>(
                          stream: recorderController.,
                          builder: (context, snapshot) {
                            final duration = snapshot.hasData
                                ? snapshot.data!.current
                                : Duration.zero;
                            String twoDigits(int n) => n.toString().padLeft(2, '0');
                            final twoDigitsMinutes =
                                twoDigits(duration.inMinutes.remainder(60));
                            final twoDigitsSeconds =
                                twoDigits(duration.inSeconds.remainder(60));
                            final twoDigitsHours =
                                twoDigits(duration.inHours.remainder(60));
                            return Text(
                              '$twoDigitsHours:$twoDigitsMinutes:$twoDigitsSeconds',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff484848)),
                            );*/

              recorderController.isRecording
                  ? wave.AudioWaveforms(
                      size: Size(width, myheight * 0.10),
                      recorderController: recorderController,
                      enableGesture: true,
                      waveStyle: const wave.WaveStyle(
                        waveColor: kColorGold,
                        showDurationLabel: true,
                        durationStyle: TextStyle(color: kColorGold),
                        spacing: 6.0,
                        durationLinesColor: Colors.black26,
                        showBottom: false,
                        extendWaveform: false,
                        showMiddleLine: false,
                      ),
                    )
                  : Slider(
                      thumbColor: kColorGold,
                      activeColor: kColorGold,
                      inactiveColor: kColorGold.withOpacity(0.3),
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      value: position.inSeconds.toDouble(),
                      onChanged: (value) async {
                        final position = Duration(seconds: value.toInt());
                        await audioPlayer.seek(position);
                        await audioPlayer.resume();
                      },
                    ),
              const SizedBox(
                height: 10,
              ),
              !recorderController.isRecording
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(position.toString().substring(0, 7)),
                          Text(duration.toString().substring(0, 7)),
                        ],
                      ),
                    )
                  : const SizedBox(),
              !recorderController.isRecording
                  ? Text(
                      DateFormat('yyyy/MM/dd').format(DateTime.now()),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff484848)),
                    )
                  : const SizedBox(),
              // !recorder.isRecording
              //     ? path1 != null
              //         ? Padding(
              //             padding: EdgeInsets.only(top: 5),
              //             child: Text(
              //               basename(path1 ?? patho!),
              //               style: const TextStyle(
              //                   fontSize: 14,
              //                   fontWeight: FontWeight.w600,
              //                   color: Color(0xff484848)),
              //             ),
              //           )
              //         : const SizedBox()
              //     : const SizedBox(),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: widget.isFromRecordList == true
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceAround,
                children: [
                  path1 != null && !recorderController.isRecording
                      ? InkWell(
                          onTap: () async {
                            // if (isRecorderReady == true || isRecorderReady == null) {
                            //   setAudio();
                            // }
                            // if(iscompleted){
                            //   await audioPlayer.setSourceDeviceFile(path1??widget.previousPath!);
                            // }
                            // else
                            if (isPlaying) {
                              isPlaying = false;
                              await audioPlayer.pause();
                            } else {
                              await audioPlayer.resume();
                            }
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => PlayView(),
                            //   ),
                            // );
                          },
                          child: isPlaying
                              ? Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/play_btn.svg",
                                      color: const Color(0xff919191),
                                    ),
                                    SvgPicture.asset(
                                      "assets/icons/play_btn.svg",
                                      color: const Color(0xff919191),
                                    ),
                                  ],
                                )
                              : SvgPicture.asset(
                                  'assets/icons/forward_triangel.svg',
                                  color: const Color(0xff919191),
                                ),
                        )
                      : const SizedBox(),
                  widget.isFromRecordList == true
                      ? const SizedBox()
                      : Container(
                          alignment: Alignment.center,
                          width: 60,
                          height: 60,
                          child: InkWell(
                            onTap: () async {
                              if (recorderController.isRecording) {
                                await stop();
                                animationTimer?.cancel();
                              } else {
                                audioPlayer.stop();
                                await record();
                                animationTimer = Timer.periodic(
                                    const Duration(milliseconds: 1100),
                                    (timer) {
                                  setState(() {
                                    iconHidden = !iconHidden;
                                  });
                                });
                              }
                              setState(() {});
                            },
                            child: Image(
                              image: const AssetImage(
                                  'assets/image/record_button.png'),
                              color: recorderController.isRecording
                                  ? kColorGold
                                  : Colors.black26,
                            ),
                          )),
                  widget.isFromRecordList == true
                      ? const SizedBox.shrink()
                      : path1 != null && !recorderController.isRecording
                          ? InkWell(
                              onTap: () async {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: ImagePreviewScreen(
                                    path: newFile!.path,
                                    controller: widget.controller,
                                  ),
                                );
                                // var res = await nameRecord.nameRecord(
                                //     context: context,
                                //     filePath:
                                //         newFile!.path ?? widget.previousPath,
                                //     audioFile: newFile ?? widget.previousFile,
                                //     recordDuration: duration.toString(),
                                //     recordDate:
                                //         DateTime.now().toIso8601String());
                                // if (res == true) {}
                              },
                              child: SvgPicture.asset(
                                'assets/icons/rounded_rect.svg',
                                color: const Color(0xff919191),
                              ),
                            )
                          : const SizedBox(),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
