// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:hash/hash.dart';
// import 'package:in_app_review/in_app_review.dart';

// import 'package:voice_recorder/constants/color_constants.dart';
// import 'package:voice_recorder/models/vocie_save_model.dart';
// import 'package:voice_recorder/services/sqflite_service.dart';
// import 'package:voice_recorder/views/homepage/home_screen.dart';

// class NameRecord {
//   Future<bool> nameRecord(
//       {required context,
//       String? filePath,
//       File? audioFile,
//       XFile? imageFile,
//       String? fileType,
//       String? recordDate,
//       String? recordDuration}) async {
//     TextEditingController controller = TextEditingController();
//     Uint8List bytes;
//     controller.text =
//         'Record ' + DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
//     return await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Center(
//               child: Text(
//             'Save as',
//             style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 24,
//                 color: Color(0xff232323)),
//           )),
//           content: Padding(
//             padding: const EdgeInsets.only(top: 10),
//             child: TextField(
//               cursorColor: const Color(0xff000000),
//               controller: controller,
//               decoration: const InputDecoration(
//                 isDense: true,
//                 focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: kColorGold)),
//                 hintStyle: TextStyle(color: Color(0xff919191)),
//                 hintText: 'Enter Voice Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//           actions: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(right: 15),
//                   child: SizedBox(
//                     width: 80,
//                     height: 40,
//                     child: TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop(false);
//                       },
//                       style: ButtonStyle(
//                         side: MaterialStateProperty.all(
//                             const BorderSide(width: 1, color: kColorGold)),
//                         shape: MaterialStateProperty.all(
//                             const RoundedRectangleBorder(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(100)))),
//                       ),
//                       child: const Text(
//                         'Cancel',
//                         style: TextStyle(color: kColorGold, fontSize: 16),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(right: 15),
//                   child: SizedBox(
//                     width: 51,
//                     height: 38,
//                     child: TextButton(
//                       onPressed: () async {
//                         //Future<String> createFolder(String cow) async {
//                         final dir = await getTemporaryDirectory();

//                         if ((await dir.exists())) {
//                           String? extention;
//                           if (fileType == 'video') {
//                             extention = '.mp4';
//                           } else if (fileType == 'image') {
//                             extention = '.png';
//                           } else {
//                             extention = '.aac';
//                           }

//                           File('${dir.path}/${controller.text.trim().replaceAll('-', '').replaceAll(':', '')}$extention')
//                               .create(recursive: true)
//                               .then((File file) async {
//                             //write to file\
//                             Uint8List audioFilebytes = audioFile != null
//                                 ? await audioFile.readAsBytes()
//                                 : await imageFile!.readAsBytes();
//                             //hashKey(audioFilebytes);
//                             bytes = hashKey(audioFilebytes);
//                             // bytes = await file.readAsBytes();
//                             file.writeAsBytes(audioFilebytes);
//                             // log('-- $bytes');
//                             // print("bytes: $bytes");
//                             String hashBytes =
//                                 bytes.toString().replaceAll('[', '');
//                             DbHelper().insertVoice(VoiceSaveModel(
//                                 name: file.path.split("/").last,
//                                 playPath: file.path,
//                                 hashBytes: bytes,
//                                 path: base64
//                                     .encode(bytes)
//                                     .replaceAll("/", "")
//                                     .trim(),
//                                 date: DateTime.parse(recordDate!),
//                                 duration: recordDuration ?? ' '));
//                             Navigator.of(context).pop(true);
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     HomeScreen(selectedIndex: 1),
//                               ),
//                             );
//                           });
//                           if (await InAppReview.instance.isAvailable())
//                             InAppReview.instance.requestReview();
//                         } else {
//                           dir.create();
//                         }
//                       },
//                       style: ButtonStyle(
//                           shape: MaterialStateProperty.all(
//                               const RoundedRectangleBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(100)))),
//                           backgroundColor:
//                               MaterialStateProperty.all(kColorGold)),
//                       child: const Text(
//                         "Ok",
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         );
//       },
//     );
//   }

//   Uint8List hashKey(Uint8List bytes) {
//     // var result = SHA224().update(byte).digest();

//     var result = SHA256().update(bytes).digest();
//     log('$result');
//     return result;
//   }
// }
