import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hash/hash.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:video_player/video_player.dart';
import 'package:voice_recorder/helpers.dart';
import 'package:voice_recorder/models/vocie_save_model.dart';
import 'package:voice_recorder/services/event_upload/event_upload_http.dart';
import 'package:voice_recorder/services/event_upload/update_cid_http.dart';
import 'package:voice_recorder/services/sqflite_service.dart';
import 'package:voice_recorder/state/auth_state.dart';
import 'package:voice_recorder/utils/helpers.dart';
import 'package:path/path.dart' as path;
import 'package:voice_recorder/views/banner_ad.dart';

import '../../services/fs3/fs3_upload_htt.dart';
import '../../widget/select_button.dart';

const List<String> list = <String>[
  'Upload to filecoin cloud storage',
  'Local device'
];

class ImagePreviewScreen extends StatefulWidget {
  final String? path;
  final PersistentTabController controller;
  final String? fileType;
  // final Map<String, dynamic>? item;
  String? voiceName;

  ImagePreviewScreen({
    super.key,
    required this.path,
    this.fileType,
    required this.controller,
    // this.item,
    this.voiceName,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  String dropdownValue = list.first;
  final TextEditingController textController = TextEditingController();
  bool _isloading = false;
  final _formKey = GlobalKey<FormState>();
  late VideoPlayerController videoController;
  bool isVideoInitialized = false;

  TextEditingController firstNameController = TextEditingController();

  TextEditingController lastNameController = TextEditingController();

  TextEditingController controllerMail = TextEditingController();

  TextEditingController controllerDescription = TextEditingController();
  bool? isSubscribed;

  void getFirstAndLastNames() async {
    final authState = AuthState.instance;
    final response = await authState!.loadUserData();

    firstNameController.text = response!['first_name'];
    lastNameController.text = response['last_name'];
    controllerMail.text = response['email'];
    isSubscribed = response['subscribed'];
  }

  @override
  void initState() {
    super.initState();
    getFirstAndLastNames();
    if (widget.fileType == 'video') {
      videoController = VideoPlayerController.file(File(widget.path ?? ''))
        ..initialize().then((_) {
          setState(() {
            isVideoInitialized = true;
          });
          videoController.play();
        });
    }
  }

  Widget _buildPreviewContent() {
    switch (widget.fileType) {
      case 'video':
        return isVideoInitialized
            ? AspectRatio(
                aspectRatio: videoController!.value.aspectRatio,
                child: VideoPlayer(videoController!),
              )
            : const Center(child: CircularProgressIndicator());
      case 'image':
        return Image.file(
          File(widget.path ?? ''),
          fit: BoxFit.contain,
        );
      case 'document':
        return _buildDocumentPreview();
      default:
        return Image.asset(
          'assets/image/recorder_icon.png',
          height: 120,
          fit: BoxFit.contain,
        );
    }
  }

  Widget _buildDocumentPreview() {
    String fileName = path.basename(widget.path ?? '');
    String extension = path.extension(fileName).toLowerCase();

    IconData iconData;
    Color iconColor;

    switch (extension) {
      case '.pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case '.doc':
      case '.docx':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case '.txt':
        iconData = Icons.text_snippet;
        iconColor = Colors.grey;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.orange;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(iconData, size: 100, color: iconColor),
        const SizedBox(height: 20),
        Text(
          fileName,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Uint8List bytes;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Preview',
                  textAlign: TextAlign.start,
                  style: GoogleFonts.lexend(
                    color: Color(0xff323743),
                    fontWeight: FontWeight.w400,
                    fontSize: 32.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  constraints:
                      widget.fileType == 'image' || widget.fileType == 'video'
                          ? BoxConstraints(maxHeight: (size.height - 230) / 1.3)
                          : null,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    child: _buildPreviewContent(),
                  ),
                ),
                const SizedBox(height: 21.0),
                Text(
                  'Name your capture',
                  style: GoogleFonts.poppins(
                    color: const Color(0xff171A1F),
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                TextFormField(
                  controller: textController,
                  style: GoogleFonts.poppins(
                    color: const Color(0xff171A1F),
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0,
                  ),
                  maxLength: 30,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kindly enter the name of the capture';
                    }
                    return null;
                  },
                  onSaved: (value) {},
                  decoration: InputDecoration(
                    hintText: 'Enter name of capture',
                    hintStyle: GoogleFonts.poppins(
                      color: const Color(0xff171A1F),
                      fontWeight: FontWeight.w400,
                      fontSize: 16.0,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.record_voice_over_rounded),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 2.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xff9095A1),
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(
                        color: Color(0xff9095A1),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(
                        color: Color(0xff9095A1FF),
                        width: 1.0,
                      ),
                    ),
                    counterText:
                        '', // This hides the built-in character counter
                  ),
                ),
                const SizedBox(height: 12.0),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                      color: const Color(0xff9095A1),
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    padding: const EdgeInsets.only(left: 16.0),
                    underline: Offstage(),
                    hint: const Text('Upload to fs3 or local device'),
                    style: GoogleFonts.poppins(
                      color: const Color(0xff171A1F),
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                    ),
                    items: list.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        dropdownValue = value!;
                      });

                      log('value: $dropdownValue');
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Describe your event",
                  style: GoogleFonts.poppins(
                    color: const Color(0xff171A1F),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Creating Text Field for Description
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextField(
                    controller: controllerDescription,
                    cursorColor: const Color(0xff000000),
                    keyboardType: TextInputType.multiline,
                    maxLines: 7,
                    maxLength: 700,
                    style: GoogleFonts.poppins(
                      color: const Color(0xff171A1F),
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                    ),
                    decoration: InputDecoration(
                      hintStyle: GoogleFonts.poppins(
                        color: const Color(0xff171A1F),
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                      ),
                      hintText: "Description (up to 700 characters)",
                      fillColor: Colors.blue,
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xff9095A1), width: 1.0),
                      ),
                      counterText: '',
                    ),
                    onChanged: (text) {
                      if (text.length > 700) {
                        controllerDescription.text = text.substring(0, 700);
                        controllerDescription.selection =
                            TextSelection.fromPosition(
                          const TextPosition(offset: 700),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80.0),
                  child: _isloading
                      ? const SizedBox(
                          width: 85,
                          child: LinearProgressIndicator(),
                        )
                      : SelectButton(
                          bTitle: 'Confirm',
                          onPressed: () async {
                            if (_formKey.currentState!.validate() &&
                                widget.path != null) {
                              setState(() {
                                _isloading = true;
                              });

                              try {
                                if (dropdownValue ==
                                    'Upload to filecoin cloud storage') {
                                  await _handleFilecoinUpload();
                                } else {
                                  await _handleLocalStorage();
                                }

                                _handleSuccessfulUpload();
                              } catch (e) {
                                _handleError(e.toString());
                              } finally {
                                setState(() {
                                  _isloading = false;
                                });
                              }
                            }
                          },
                        ),
                ),
                const SizedBox(height: 50.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleFilecoinUpload() async {
    String? extension = _getFileExtension();
    Fs3UploadHttpService fs3Service = Fs3UploadHttpService();

    final fs3Request = await fs3Service.fs3Upload(widget.path ?? '');
    if (fs3Request.isEmpty) {
      throw Exception('Failed to upload to Filecoin storage');
    }

    String? deviceId = await getDeviceId();
    EventUploadHttpService eventUploadService = EventUploadHttpService();
    final request = await eventUploadService.eventUpload(
        await downloadAndSaveImage(
            'https://gateway.lighthouse.storage/ipfs/${fs3Request['Hash']}'),
        deviceId);

    if (request == null) {
      throw Exception('Failed to upload event');
    }

    await _updateLocalDatabase(request);

    UpdateCIDHttpService updateCIDHttpService = UpdateCIDHttpService();
    final authState = AuthState.instance;
    final response = await authState!.loadUserData();
    final username = response!['username'];

    final cidUpdate = await updateCIDHttpService.updateCID(
      username: username,
      cid: fs3Request['Hash'],
      name:
          '${textController.text.trim().replaceAll('-', '').replaceAll(':', '')}$extension',
      date: DateFormat("dd.MM.yyyy HH:mm:ss").format(DateTime.now()),
      txId: request['tx_id'],
      bcProof: request['bc_proof'],
      mediaHash: request['media_hash'],
      deviceId: deviceId,
      description: controllerDescription.text.trim(),
    );

    if (cidUpdate['status'] != 'success') {
      throw Exception(cidUpdate['message'] ?? 'Failed to update CID');
    }
  }

  Future<void> _handleLocalStorage() async {
    final dir = await getTemporaryDirectory();
    if (!(await dir.exists())) {
      await dir.create();
    }

    String extension = _getFileExtension();
    String sanitizedFileName =
        textController.text.trim().replaceAll(RegExp(r'[^\w\s\-]'), '');
    String fileName =
        '${sanitizedFileName}_${DateTime.now().millisecondsSinceEpoch}$extension';
    File file = File('${dir.path}/$fileName');
    await file.create(recursive: true);

    Uint8List audioFileBytes = await File(widget.path!).readAsBytes();
    Uint8List bytes = hashKey(audioFileBytes);
    await file.writeAsBytes(audioFileBytes);

    await DbHelper().insertVoice(
      VoiceSaveModel(
        hasCreatedProof: false,
        name: file.path.split("/").last,
        playPath: file.path,
        hashBytes: bytes,
        path: base64.encode(bytes).replaceAll("/", "").trim(),
        date: DateTime.now(),
        duration: ' ',
      ),
    );

    if (await InAppReview.instance.isAvailable()) {
      InAppReview.instance.requestReview();
    }
  }

  void _handleSuccessfulUpload() {
    //this will remove the Ads
    // widget.controller.jumpToTab(0);
    // int count = 0;
    // if (context.mounted) {
    //   Navigator.of(context).popUntil((_) => count++ >= 2);
    // }

    //Uncomment this if/else to show Ads
    if (isSubscribed!) {
      widget.controller.jumpToTab(0);
      int count = 0;
      if (context.mounted) {
        Navigator.of(context).popUntil((_) => count++ >= 2);
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyBannerAdWidget(
            shouldNavigate: false,
            callback: () {
              widget.controller.jumpToTab(0);
              int count = 0;
              if (context.mounted) {
                Navigator.of(context).popUntil((_) => count++ >= 2);
              }
            },
          ),
        ),
      );
    }
  }

  void _handleError(String errorMessage) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error: $errorMessage'),
        ),
      );
    }
  }

  String _getFileExtension() {
    if (widget.path != null) {
      return path.extension(widget.path!).toLowerCase();
    } else {
      switch (widget.fileType) {
        case 'video':
          return '.mp4';
        case 'image':
          return '.png';
        case 'document':
          return '.pdf'; // Default document extension, adjust as needed
        default:
          return '.aac';
      }
    }
  }

  Future<void> _updateLocalDatabase(Map<String, dynamic> request) async {
    await DbHelper().updateProofCreatedStatus(widget.voiceName ?? '', true);
    await DbHelper().updateVoiceProofDetails(
      widget.voiceName ?? '',
      request,
      eventDescription: controllerDescription.text,
    );
    await DbHelper().fetchProducts();
  }

  Uint8List hashKey(Uint8List bytes) {
    var result = SHA256().update(bytes).digest();
    log('$result');
    return result;
  }
}

  // Future<void> processSuccessfulPurchase(Map<String, dynamic> proofDetails,
  //     String deviceId, String cid, String assetName) async {
  //   print("processSuccessfulPurchase()");

  //   final String bcProof = proofDetails['bc_proof'];

  //   UpdateCIDHttpService updateCIDHttpService = UpdateCIDHttpService();
  //   final authState = AuthState.instance;
  //   final response = await authState!.loadUserData();
  //   final username = response!['username'];
  //   final cidUpdate = await updateCIDHttpService.updateCID(
  //     username: username,
  //     cid: cid,
  //     name: assetName,
  //     date: DateFormat("dd.MM.yyyy HH:mm:ss").format(DateTime.now()),
  //     txId: proofDetails['tx_id'],
  //     bcProof: bcProof,
  //     mediaHash: proofDetails['media_hash'],
  //     deviceId: deviceId,
  //   );

  //   if (cidUpdate['status'] == 'success') {
  //     DbHelper.internal()
  //         .insertPDFDetails(
  //       PDFSaveModel(
  //         userName: firstNameController.text,
  //         description: controllerDescription.text,
  //         fileName: widget.voiceName,
  //         bcExplorer:
  //             'https://explorer.hydraledger.tech/transaction/${proofDetails['tx_id']}',
  //         email: controllerMail.text,
  //         hash: proofDetails['media_hash'],
  //         registeredContent: proofDetails['media_hash'],
  //         timeStamp: DateFormat("dd.MM.yyyy HH:mm:ss").format(DateTime.now()),
  //         transactionID: proofDetails['tx_id'],
  //         bcProof: proofDetails['bc_proof'],
  //       ),
  //     )
  //         .then((value) {
  //       snackbarShow(
  //           context: context,
  //           text:
  //               'A PDF proof has been generated. It can be downloaded by tapping on the "Show Proof"! on the homepage\nPlease save the file in external storage to prevent data loss.');
  //     });
  //   }
  // }


// SelectButton(
//                           bTitle: 'Confirm',
//                           onPressed: () async {
//                             if (_formKey.currentState!.validate() &&
//                                 widget.path != null) {
//                               setState(() {
//                                 _isloading = true;
//                               });

//                               if (dropdownValue ==
//                                   'Upload to filecoin cloud storage') {
//                                 String? extention;

//                                 if (widget.fileType == 'video') {
//                                   extention = '.mp4';
//                                 } else if (widget.fileType == 'image') {
//                                   extention = '.png';
//                                 } else {
//                                   extention = '.aac';
//                                 }

//                                 Fs3UploadHttpService fs3Service =
//                                     Fs3UploadHttpService();

//                                 final fs3Request = await fs3Service
//                                     .fs3Upload(widget.path ?? '');

//                                 if (fs3Request.isNotEmpty) {
//                                   String? deviceId = await getDeviceId();
//                                   EventUploadHttpService eventUploadService =
//                                       EventUploadHttpService();
//                                   final request =
//                                       await eventUploadService.eventUpload(
//                                           await downloadAndSaveImage(
//                                               'https://gateway.lighthouse.storage/ipfs/${fs3Request['Hash']}'),
//                                           deviceId);
//                                   if (request != null) {
//                                     await DbHelper().updateProofCreatedStatus(
//                                         widget.voiceName ?? '', true);

//                                     await DbHelper().updateVoiceProofDetails(
//                                       widget.voiceName ?? '',
//                                       request,
//                                       eventDescription:
//                                           controllerDescription.text,
//                                     );

//                                     log('response from event upload: $request');

//                                     await DbHelper().fetchProducts();
//                                     setState(() {});

//                                     UpdateCIDHttpService updateCIDHttpService =
//                                         UpdateCIDHttpService();
//                                     final authState = AuthState.instance;
//                                     final response =
//                                         await authState!.loadUserData();
//                                     final username = response!['username'];
//                                     final cidUpdate =
//                                         await updateCIDHttpService.updateCID(
//                                       username: username,
//                                       cid: fs3Request['Hash'],
//                                       name:
//                                           '${textController.text.trim().replaceAll('-', '').replaceAll(':', '')}$extention',
//                                       date: DateFormat("dd.MM.yyyy HH:mm:ss")
//                                           .format(DateTime.now()),
//                                       txId: request['tx_id'],
//                                       bcProof: request['bc_proof'],
//                                       mediaHash: request['media_hash'],
//                                       deviceId: deviceId,
//                                     );

//                                     log('request from fs3: $fs3Request');
//                                     if (cidUpdate['status'] == 'success' &&
//                                         context.mounted) {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(
//                                         const SnackBar(
//                                           backgroundColor: Colors.green,
//                                           content: Text(
//                                               'Upload to decentralized cloud storage was successful'),
//                                         ),
//                                       );
//                                     } else {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(
//                                         SnackBar(
//                                           backgroundColor: Colors.green,
//                                           content:
//                                               Text('${cidUpdate['message']}'),
//                                         ),
//                                       );
//                                     }
//                                   }
//                                 }
//                               } else {
//                                 final dir = await getTemporaryDirectory();

//                                 if ((await dir.exists())) {
//                                   String? extention;

//                                   if (widget.fileType == 'video') {
//                                     extention = '.mp4';
//                                   } else if (widget.fileType == 'image') {
//                                     extention = '.png';
//                                   } else {
//                                     extention = '.aac';
//                                   }

//                                   File('${dir.path}/${textController.text.trim().replaceAll('-', '').replaceAll(':', '')}$extention')
//                                       .create(recursive: true)
//                                       .then((File file) async {
//                                     Uint8List audioFilebytes =
//                                         await File(widget.path!).readAsBytes();
//                                     bytes = hashKey(audioFilebytes);
//                                     file.writeAsBytes(audioFilebytes);

//                                     String hashBytes =
//                                         bytes.toString().replaceAll('[', '');
//                                     DbHelper().insertVoice(
//                                       VoiceSaveModel(
//                                           hasCreatedProof: false,
//                                           name: file.path.split("/").last,
//                                           playPath: file.path,
//                                           hashBytes: bytes,
//                                           path: base64
//                                               .encode(bytes)
//                                               .replaceAll("/", "")
//                                               .trim(),
//                                           date: DateTime.parse(
//                                               DateTime.now().toString()),
//                                           duration: ' '),
//                                     );
//                                   });
//                                   if (await InAppReview.instance
//                                       .isAvailable()) {
//                                     InAppReview.instance.requestReview();
//                                   }
//                                 } else {
//                                   dir.create();
//                                   setState(() {
//                                     _isloading = false;
//                                   });
//                                 }
//                               }
//                               if (isSubscribed!) {
//                                 widget.controller.jumpToTab(0);
//                                 int count = 0;
//                                 if (context.mounted) {
//                                   Navigator.of(context)
//                                       .popUntil((_) => count++ >= 2);
//                                 }
//                               } else {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => MyBannerAdWidget(
//                                       shouldNavigate: false,
//                                       callback: () {
//                                         widget.controller.jumpToTab(0);
//                                         int count = 0;
//                                         if (context.mounted) {
//                                           Navigator.of(context)
//                                               .popUntil((_) => count++ >= 2);
//                                         }
//                                       },
//                                     ),
//                                   ),
//                                 );
//                               }

//                               setState(() {
//                                 _isloading = false;
//                               });
//                             }
//                           },
//                         ),