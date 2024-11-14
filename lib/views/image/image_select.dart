import 'dart:io';

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:voice_recorder/views/image/image_preview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voice_recorder/widget/select_button.dart';

class ImageSelect extends StatefulWidget {
  final PersistentTabController controller;

  ImageSelect({required this.controller, super.key});

  @override
  State<ImageSelect> createState() => _ImageSelectState();
}

class _ImageSelectState extends State<ImageSelect> {
  final picker = ImagePicker();

  late Future<XFile?> pickedFile = Future.value(null);

  String? path;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double statusBarheight = MediaQuery.of(context).padding.top;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: path != null,
                child: Container(
                  constraints:
                      BoxConstraints(maxHeight: (size.height - 230) / 1.3),
                  margin: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    child: Image.file(
                      File(path ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: SelectButton(
                  bTitle: 'Take Photo',
                  onPressed: () async {
                    var res = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (res != null) {
                      if (context.mounted) {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: ImagePreviewScreen(
                            path: res.path,
                            fileType: 'image',
                            controller: widget.controller,
                          ),
                        );
                      }
                    }
                    // path = res!.path;
                    // setState(() {});
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
