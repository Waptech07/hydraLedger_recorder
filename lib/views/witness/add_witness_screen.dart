import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:voice_recorder/constants/color_constants.dart';
import 'package:voice_recorder/models/vocie_save_model.dart';
import 'package:voice_recorder/services/fs3/fs3_upload_htt.dart';
import 'package:voice_recorder/services/sqflite_service.dart';

class AddWitnessScreen extends StatefulWidget {
  final PersistentTabController? controller;
  final String? imageData;
  final VoiceSaveModel? voiceSaveModel;
  final Map<String, dynamic>? item;

  const AddWitnessScreen({
    required this.controller,
    this.imageData,
    this.voiceSaveModel,
    this.item,
    super.key,
  });

  @override
  State<AddWitnessScreen> createState() => _AddWitnessScreenState();
}

class _AddWitnessScreenState extends State<AddWitnessScreen> {
  bool isSwitched = false;
  Fs3UploadHttpService fs3Service = Fs3UploadHttpService();

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> fs3Upload() async {
    try {
      final request = await fs3Service.fs3Upload(widget.voiceSaveModel != null
          ? widget.voiceSaveModel!.playPath!
          : widget.imageData ?? '');
      return request;
    } catch (e) {
      print('Error in fs3Upload: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.home,
            color: Color(0xff323743),
            size: 28,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
          future: widget.item!['type'] == 'cid'
              ? DbHelper().getFs3MediaDetails(widget.item!['cid'])
              : Future.value(null),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            String? data;

            if (widget.item!['type'] == 'cid') {
              if (snapshot.hasData && snapshot.data != null) {
                data = jsonEncode({
                  'voiceSaveModel': widget.voiceSaveModel?.toJson(),
                  'imageData': widget.imageData ?? '',
                  'allowMediaSharing': true,
                  'item': widget.item.toString(),
                  'eventDescription':
                      snapshot.data!['event_description'] as String? ?? '',
                });
              } else {
                // Handle the case where we don't have data for a CID type
                data = jsonEncode({
                  'voiceSaveModel': widget.voiceSaveModel?.toJson(),
                  'imageData': widget.imageData ?? '',
                  'allowMediaSharing': true,
                  'item': widget.item.toString(),
                  'eventDescription': '', // or some default value
                });
              }
            } else {
              data = jsonEncode({
                'voiceSaveModel': widget.voiceSaveModel?.toJson(),
                'imageData': widget.imageData ?? '',
                'allowMediaSharing': true,
                'item': widget.item.toString(),
                'eventDescription':
                    widget.item!['eventDescription'] as String? ?? '',
              });
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Add a witness',
                    style: GoogleFonts.poppins(
                      fontSize: 32.0,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff163252),
                    ),
                  ),
                  const SizedBox(height: 70),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xff15ABFF),
                        width: 1.0,
                      ),
                    ),
                    child: QrImageView(
                      data: data,
                      version: QrVersions.auto,
                    ),
                    // child: Image.asset('assets/image/witness_qr.png'),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 11,
                    decoration: BoxDecoration(
                      color: kColorGold,
                      border: Border.all(
                        color: Color(0xffBDC1CA),
                      ),
                    ),
                  ),
                  Container(
                    height: 11,
                    decoration: const BoxDecoration(
                      color: Color(0xff163252),
                    ),
                  ),
                  // const SizedBox(height: 95),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'Share the media with\nwitness',
                  //       style: GoogleFonts.poppins(
                  //         fontSize: 18.0,
                  //         fontWeight: FontWeight.w400,
                  //         color: const Color(0xff171A1F),
                  //       ),
                  //     ),
                  //     CupertinoSwitch(
                  //       value: isSwitched,
                  //       activeColor: kColorGold,
                  //       onChanged: ((value) {
                  //         setState(() {
                  //           isSwitched = value;
                  //         });
                  //       }),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            );
          }),
    );
  }
}
