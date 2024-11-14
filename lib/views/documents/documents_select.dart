import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:voice_recorder/views/image/image_preview.dart';
import 'package:voice_recorder/widget/select_button.dart';

class DocumentSelect extends StatefulWidget {
  final PersistentTabController controller;

  const DocumentSelect({required this.controller, Key? key}) : super(key: key);

  @override
  State<DocumentSelect> createState() => _DocumentSelectState();
}

class _DocumentSelectState extends State<DocumentSelect> {
  String? _fileName;
  String? _filePath;

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _filePath = result.files.single.path;
      });

      if (context.mounted) {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ImagePreviewScreen(
            path: _filePath,
            fileType: 'document',
            controller: widget.controller,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: size.height * 0.1),
          if (_fileName != null)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Selected file: $_fileName',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: SelectButton(
              onPressed: _pickDocument,
              bTitle: 'Select Document',
            ),
          ),
        ],
      ),
    );
  }
}
