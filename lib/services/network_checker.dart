import 'dart:io';

import 'package:flutter/material.dart';

class NetworkChecker {
  Future<bool> shouldProceed(BuildContext context) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Could not connect to the internet.\nPlease check your connection.'),
        ),
      );
      return false;
    }
    return false;
  }
}
