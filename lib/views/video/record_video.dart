import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:hydraledger_recorder/views/image/image_preview.dart';
import 'package:hydraledger_recorder/widget/my_snackbar.dart';
import 'package:hydraledger_recorder/widget/select_button.dart';
import 'package:video_player/video_player.dart';

class RecordVideo extends StatefulWidget {
  final PersistentTabController controller;

  RecordVideo({required this.controller, super.key});

  @override
  State<RecordVideo> createState() => _RecordVideoState();
}

class _RecordVideoState extends State<RecordVideo> {
  List<CameraDescription> _cameras = <CameraDescription>[];
  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  // double _minAvailableExposureOffset = 0.0;
  // double _maxAvailableExposureOffset = 0.0;
  // double _currentExposureOffset = 0.0;
  // late AnimationController _flashModeControlRowAnimationController;
  // late Animation<double> _flashModeControlRowAnimation;
  // late AnimationController _exposureModeControlRowAnimationController;
  // late Animation<double> _exposureModeControlRowAnimation;
  // late AnimationController _focusModeControlRowAnimationController;
  // late Animation<double> _focusModeControlRowAnimation;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  bool isRecording = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    setup();
  }

  void setup() async {
    if (!await Permission.camera.request().isGranted)
      await Permission.camera.request();
    if (!await Permission.microphone.request().isGranted)
      await Permission.microphone.request();
    var availCameras = await availableCameras();
    await onNewCameraSelected(availCameras[0]);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double statusBarheight = MediaQuery.of(context).padding.top;
    return Container(
      height: size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            height: (size.height - 230) / 1.3,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.black,
              border: Border.all(
                color: controller != null && controller!.value.isRecordingVideo
                    ? Colors.redAccent
                    : Colors.white,
                width: 3.0,
              ),
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: _cameraPreviewWidget()),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: SelectButton(
              bTitle: isRecording
                  ? 'Stop Video Recording'
                  : 'Start Video Recording',
              onPressed: () async {
                final CameraController? cameraController = controller;

                if (cameraController!.value.isRecordingVideo) {
                  isRecording = false;
                  videoFile = await stopVideoRecording();
                } else {
                  isRecording = true;
                  startVideoRecording();
                }
              },
            ),
          ),
          SizedBox(height: 8),
          Visibility(
            visible: videoFile != null,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: SelectButton(
                bTitle: 'Save',
                onPressed: () {
                  if (videoFile != null) {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: ImagePreviewScreen(
                        path: videoFile!.path,
                        fileType: 'video',
                        controller: widget.controller,
                      ),
                    );
                    // nameRecord.nameRecord(
                    //   context: context,
                    //   fileType: 'video',
                    //   filePath: videoFile!.path,
                    //   audioFile: File(videoFile!.path),
                    //   //imageFile: XFile(path),
                    //   recordDate: DateTime.now().toString(),
                    // );
                  } else {
                    snackbarShow(context: context, text: 'Record Video First');
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? oldController = controller;
    if (oldController != null) {
      controller = null;
      await oldController.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {}
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        ...<Future<Object?>>[],
        cameraController
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {}

    if (mounted) {
      setState(() {});
    }
  }

  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return InkWell(
        onTap: () {
          onNewCameraSelected(const CameraDescription(
              name: '0',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90));
        },
        child: const Text(
          '',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller!,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onTapDown: (TapDownDetails details) =>
                  onViewFinderTap(details, constraints),
            );
          }),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      snackbarShow(context: context, text: 'Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      //_showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      //_showCameraException(e);
      return null;
    }
  }
}
