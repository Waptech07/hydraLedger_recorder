import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

Future<String> getUniqueDeviceId() async {
  String uniqueDeviceId = '';

  var deviceInfo = DeviceInfoPlugin();

  if (Platform.isIOS) {
    var iosDeviceInfo = await deviceInfo.iosInfo;
    uniqueDeviceId =
        '${iosDeviceInfo.model}:${iosDeviceInfo.identifierForVendor}'; // unique ID on iOS
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    uniqueDeviceId =
        '${androidDeviceInfo.model}:${androidDeviceInfo.device}:${androidDeviceInfo.id}'; // unique ID on Android
  }

  return uniqueDeviceId;
}

Future<String> convertImageToBase64(String imagePath) async {
  File file = File('');
  final ByteData bytes =
      await rootBundle.load('assets/image/recorder_icon.png');
  final buffer = bytes.buffer;
  final base64String = base64.encode(Uint8List.view(buffer));
  return base64String;
}

Future<String> downloadAndSaveImage(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(url);
    final filePath = path.join(directory.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  } else {
    throw Exception('Failed to download image');
  }
}

List<String> splitFullName(String fullName) {
  List<String> nameParts = fullName.trim().split(' ');
  if (nameParts.length > 1) {
    String lastName = nameParts.last;
    String firstName = nameParts.sublist(0, nameParts.length - 1).join(' ');
    return [firstName, lastName];
  } else {
    return [fullName, '']; // If there's only one word, treat it as first name
  }
}
