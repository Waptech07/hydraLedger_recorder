import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:voice_recorder/models/vocie_save_model.dart';
import 'package:voice_recorder/state/auth_state.dart';
import 'package:voice_recorder/views/witness/sign_witness.dart';

class ScanQrScreen extends StatefulWidget {
  ScanQrScreen({
    super.key,
  });

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isNavigating = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(Barcode barcode) {
    if (_isNavigating) return; // Prevent further navigation

    if (barcode.rawValue == null) {
      return;
    } else {
      try {
        Map<String, dynamic> decodedData = jsonDecode(barcode.rawValue ?? '');
        log('decoded data: $decodedData');

        VoiceSaveModel? voiceSaveModel;
        if (decodedData['voiceSaveModel'] != null) {
          voiceSaveModel =
              VoiceSaveModel.fromJson(decodedData['voiceSaveModel']);
        }

        String? imageData = decodedData['imageData'];
        bool allowMediaSharing = decodedData['allowMediaSharing'] ?? false;
        String? decodedItem = decodedData['item'];
        String? eventDescription = decodedData['eventDescription'];
        log('decodedItem: $decodedItem');

        Map<String, dynamic> item = {};
        if (decodedItem != null && decodedItem.isNotEmpty) {
          try {
            // First, try to parse it as JSON
            item = jsonDecode(decodedItem);
          } catch (e) {
            // If that fails, try to parse it as a string representation of a map
            try {
              item = parseStringToMap(decodedItem);
            } catch (e) {
              log('Error parsing item: $e');
              // Handle the error, perhaps by showing a message to the user
              return;
            }
          }
        }
        log('item: $item');

        // Set the flag to true to indicate navigation is in progress
        setState(() {
          _isNavigating = true;
        });

        Future.delayed(
          const Duration(seconds: 1),
          () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: SignWitnessScreen(
                imagePath: imageData,
                voiceSaveModel: voiceSaveModel,
                showWitness: allowMediaSharing,
                item: item,
                eventDescription: eventDescription,
              ),
              withNavBar: false,
            ).then((_) {
              // Reset the flag after navigation is done
              setState(() {
                _isNavigating = false;
              });
            });
          },
        );
      } catch (e) {
        log('Error processing barcode data: $e');
        // Handle the error, perhaps by showing a message to the user
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  Map<String, dynamic> parseStringToMap(String str) {
    // Remove the curly braces at the start and end
    str = str.trim().substring(1, str.length - 1);

    // Split the string into key-value pairs
    List<String> pairs = str.split(', ');

    // Create a map to store the result
    Map<String, dynamic> result = {};

    // Parse each key-value pair
    for (String pair in pairs) {
      List<String> keyValue = pair.split(': ');
      if (keyValue.length == 2) {
        String key = keyValue[0].trim();
        String value = keyValue[1].trim();

        // Remove quotes if present
        if (value.startsWith('"') && value.endsWith('"')) {
          value = value.substring(1, value.length - 1);
        }

        // Try to parse as int or double, otherwise keep as string
        if (int.tryParse(value) != null) {
          result[key] = int.parse(value);
        } else if (double.tryParse(value) != null) {
          result[key] = double.parse(value);
        } else {
          result[key] = value;
        }
      }
    }

    return result;
  }

  // void _onBarcodeDetected(Barcode barcode) {
  //   if (_isNavigating) return; // Prevent further navigation

  //   if (barcode.rawValue == null) {
  //     return;
  //   } else {
  //     Map<String, dynamic> decodedData = jsonDecode(barcode.rawValue ?? '');
  //     log('decoded data: $decodedData');
  //     VoiceSaveModel? voiceSaveModel;
  //     if (decodedData['voiceSaveModel'] != null) {
  //       voiceSaveModel = VoiceSaveModel.fromJson(decodedData['voiceSaveModel']);
  //     }

  //     String? imageData = decodedData['imageData'];
  //     bool allowMediaSharing = decodedData['allowMediaSharing'];
  //     String? decodedItem = decodedData['item'];
  //     log('decodedItem: $decodedItem');
  //     Map<String, dynamic> item = jsonDecode(decodedItem ?? '');
  //     log('itaem: $item');

  //     // Set the flag to true to indicate navigation is in progress
  //     setState(() {
  //       _isNavigating = true;
  //     });

  //     Future.delayed(
  //       const Duration(seconds: 1),
  //       () {
  //         PersistentNavBarNavigator.pushNewScreen(
  //           context,
  //           screen: SignWitnessScreen(
  //             imagePath: imageData,
  //             voiceSaveModel: voiceSaveModel,
  //             showWitness: allowMediaSharing,
  //             item: item,
  //           ),
  //         ).then((_) {
  //           // Reset the flag after navigation is done
  //           setState(() {
  //             _isNavigating = false;
  //           });
  //         });
  //       },
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();

    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                List<Barcode> barcodes = capture.barcodes;

                for (final barcode in barcodes) {
                  _onBarcodeDetected(barcode);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
