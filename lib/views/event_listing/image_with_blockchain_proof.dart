import 'dart:developer';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:hydraledger_recorder/constants/color_constants.dart';
import 'package:hydraledger_recorder/models/pdf_save_model.dart';
import 'package:hydraledger_recorder/services/sqflite_service.dart';
import 'package:hydraledger_recorder/utils/helpers.dart';
import 'package:hydraledger_recorder/utils/pdf/pdf_file.dart';
import 'package:hydraledger_recorder/utils/pdf/save_pdf.dart';

class ImageWithBlockchainProof extends StatefulWidget {
  final Map<String, dynamic>? item;
  final String? email;
  final String? userName;

  const ImageWithBlockchainProof({
    this.item,
    this.email,
    this.userName,
    Key? key,
  }) : super(key: key);

  @override
  State<ImageWithBlockchainProof> createState() =>
      _ImageWithBlockchainProofState();
}

class _ImageWithBlockchainProofState extends State<ImageWithBlockchainProof> {
  late int width;
  late int height;
  late double megapixels;
  late Future<void> _initializationFuture;
  VideoPlayerController? _videoController;
  String? _contentType;
  bool isProofLoading = false;
  String? _pdfPath;
  String? _docxContent;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initialize();
    log('item: ${widget.item}');
  }

  Future<void> _initialize() async {
    if (widget.item!['type'] == 'cid') {
      final url =
          'https://gateway.lighthouse.storage/ipfs/${widget.item!['cid']}';
      _contentType = await _getContentType(url);

      if (_contentType?.startsWith('video/') == true) {
        _videoController = VideoPlayerController.network(url);
        await _videoController!.initialize();
      } else if (_contentType?.startsWith('application/pdf') == true) {
        _pdfPath = await _downloadAndSavePdf(url);
      } else if (_contentType ==
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
        _docxContent = await _downloadAndReadDocx(url);
      }
    } else if (widget.item!['playPath'].endsWith('.pdf')) {
      _pdfPath = widget.item!['playPath'];
      _contentType = 'application/pdf';
    } else if (widget.item!['playPath'].endsWith('.docx')) {
      _docxContent = await _readLocalDocx(widget.item!['playPath']);
      _contentType =
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    await _getImageInfo();
  }

  Future<String> _downloadAndSavePdf(String url) async {
    final response = await http.get(Uri.parse(url));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File('${documentDirectory.path}/document.pdf');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  Future<String> _getContentType(String url) async {
    final response = await http.head(Uri.parse(url));
    return response.headers['content-type'] ?? '';
  }

  Future<void> _getImageInfo() async {
    if (widget.item!['type'] != 'cid') {
      File imageFile = File(widget.item!['playPath']);

      if (widget.item!['playPath'].endsWith('.mp4')) {
        _contentType = 'video/mp4';
        _videoController = VideoPlayerController.file(imageFile);
        await _videoController!.initialize();
        width = _videoController!.value.size.width.toInt();
        height = _videoController!.value.size.height.toInt();
      } else if (widget.item!['playPath'].endsWith('.pdf')) {
        width = 500;
        height = 500;
      } else {
        img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

        if (image != null && !widget.item!['playPath'].endsWith('.aac')) {
          width = image.width;
          height = image.height;
        } else {
          width = 500;
          height = 500;
        }
      }
    } else {
      width = 500;
      height = 500;
    }
    megapixels = (width * height) / 1000000;
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: FutureBuilder(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40),
              child: FutureBuilder<Map<String, dynamic>?>(
                  future: widget.item!['type'] == 'cid'
                      ? DbHelper().getFs3MediaDetails(widget.item!['cid'])
                      : Future.value(null),
                  builder: (context, snapshot) {
                    String eventDescription = '';

                    eventDescription =
                        widget.item!['eventDescription'] as String? ?? '';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              size: 40,
                              color: kColorGold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          widget.item!['name'],
                          textAlign: TextAlign.start,
                          style: GoogleFonts.poppins(
                            color: const Color(0xff171A1F),
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 26),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            height: size.height * 0.35,
                            child: _buildMediaContent(),
                          ),
                        ),
                        const SizedBox(height: 32),
                        FutureBuilder<bool>(
                            future: Future.value(
                                widget.item!['hasCreatedProof'] ?? false),
                            builder: (context, snapshot) {
                              bool hasProof = snapshot.data ?? false;
                              return InkWell(
                                onTap: (() async {
                                  if (hasProof) {
                                    if (widget.item!['name'] ==
                                        "Sample-File.aac") {
                                      setState(() {
                                        isProofLoading = true;
                                      });

                                      scaffoldMessengerKey.currentState!
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Exporting PDF...\nPlease make sure you have a PDF viewer installed (e.g. Google Drive)!'),
                                        duration: Duration(seconds: 2),
                                      ));
                                      final getPdf = await DbHelper()
                                          .getPDFsForFilename(
                                              widget.item!['name']);
                                      await Future.delayed(
                                          const Duration(seconds: 1));
                                      File pdfFile =
                                          await PdfAttendanceApi().generate(
                                        pdfSaveModel: getPdf[0],
                                        voiceSaveModel: null,
                                        imageData: widget.item!['playPath'],
                                        item: widget.item,
                                      );
                                      await SavePdf.openFile(pdfFile);
                                      log('fifth');
                                      setState(() {
                                        isProofLoading = false;
                                      });
                                    } else {
                                      Map<String, dynamic> proof =
                                          widget.item!['proof'];

                                      setState(() {
                                        isProofLoading = true;
                                      });

                                      scaffoldMessengerKey.currentState!
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Exporting PDF...\nPlease make sure you have a PDF viewer installed (e.g. Google Drive)!'),
                                        duration: Duration(seconds: 2),
                                      ));
                                      await Future.delayed(
                                          const Duration(seconds: 1));
                                      File pdfFile =
                                          await PdfAttendanceApi().generate(
                                        pdfSaveModel: PDFSaveModel(
                                          userName: widget.userName,
                                          description: 'description',
                                          fileName: widget.item!['name'],
                                          bcExplorer:
                                              'https://explorer.hydraledger.tech/transaction/${proof['tx_id']}}',
                                          email: widget.email,
                                          hash: proof['media_hash'],
                                          registeredContent:
                                              proof['media_hash'],
                                          timeStamp:
                                              DateFormat("dd.MM.yyyy HH:mm:ss")
                                                  .format(widget.item!['date']),
                                          transactionID: proof['tx_id'],
                                          bcProof: proof['bc_proof'],
                                        ),
                                        voiceSaveModel: null,
                                        imageData: widget.item!['type'] == 'cid'
                                            ? widget.item!['cid']
                                            : widget.item!['playPath'],
                                        item: widget.item,
                                      );
                                      await SavePdf.openFile(pdfFile);
                                      setState(() {
                                        isProofLoading = false;
                                      });
                                    }
                                  } else {
                                    scaffoldMessengerKey.currentState!
                                        .showSnackBar(const SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                          'A proof doesnt exist for this media yet,\nKindly create one before generating'),
                                      duration: Duration(seconds: 2),
                                    ));
                                  }
                                }),
                                child: Text(
                                  isProofLoading
                                      ? 'Generating proof.....'
                                      : 'View Blockchain proof',
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.poppins(
                                    decoration: TextDecoration.underline,
                                    decorationColor: kColorGold,
                                    color: kColorGold,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              );
                            }),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: size.height * 0.25,
                          child: eventDescription.isEmpty
                              ? const Center(
                                  child: Text('No Description Available'),
                                )
                              : Text(
                                  eventDescription,
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Swipe up for more information',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            decoration: TextDecoration.underline,
                            decorationColor: kColorGold,
                            color: kColorGold,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        GestureDetector(
                          onVerticalDragStart: ((details) async {
                            final deviceInfoPlugin = DeviceInfoPlugin();
                            final deviceInfo =
                                await deviceInfoPlugin.deviceInfo;
                            List? witnesses = widget.item!['witnesses'];
                            log('devicee: ${deviceInfo.data}');
                            showModalBottomSheet(
                              backgroundColor: Colors.black.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              context: context,
                              builder: (context) {
                                return Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(36, 50, 36, 4),
                                  height: size.height * 0.7,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                  ),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(
                                          Icons.image,
                                          size: 26,
                                          color: Colors.white,
                                        ),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.item!['name'],
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            if (_getMediaType(
                                                    widget.item!['name'] ??
                                                        '') ==
                                                'image')
                                              Text(
                                                '${megapixels.toStringAsFixed(1)}megapixels  $width x $height',
                                                // '1.2mp 720 x 1600',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(
                                          Icons.currency_bitcoin,
                                          size: 26,
                                          color: Colors.white,
                                        ),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Stored At',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              widget.item!['type'] == 'cid'
                                                  ? widget.item!['cid']
                                                  : 'Local device storage',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(
                                          Icons.location_city,
                                          size: 26,
                                          color: Colors.white,
                                        ),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Captured on',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              '${deviceInfo.data['model']} ${deviceInfo.data['device']}',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(
                                          Icons.people,
                                          size: 26,
                                          color: Colors.white,
                                        ),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Witnesses',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              witnesses != null &&
                                                      witnesses!.isNotEmpty
                                                  ? witnesses!
                                                      .map((witness) =>
                                                          witness['username'])
                                                      .join(
                                                          ', ') // Show only usernames, separated by commas
                                                  : 'No witnesses yet',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Icon(
                                          Icons.arrow_downward,
                                          size: 35,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
                          child: const Icon(
                            Icons.swipe_up,
                          ),
                        ),
                      ],
                    );
                  }),
            );
          }
        },
      ),
    );
  }

  String _getMediaType(String path) {
    final extension = path.toLowerCase().split('.').last;
    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      return 'image';
    } else if (extension == 'pdf') {
      return 'pdf';
    } else if (extension == 'docx') {
      return 'docx';
    } else if (extension == 'aac') {
      return 'audio';
    } else if (extension == 'mp4') {
      return 'video';
    }
    return 'unknown';
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_videoController!),
          IconButton(
            icon: Icon(
              _videoController!.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              size: 50.0,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: () {
              setState(() {
                _videoController!.value.isPlaying
                    ? _videoController!.pause()
                    : _videoController!.play();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer() {
    if (_pdfPath == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return PDFView(
      filePath: _pdfPath,
      enableSwipe: true,
      swipeHorizontal: true,
      autoSpacing: false,
      pageFling: false,
      onError: (error) {
        print(error.toString());
      },
      onPageError: (page, error) {
        print('$page: ${error.toString()}');
      },
    );
  }

  Widget _buildMediaContent() {
    if (_contentType?.startsWith('video/') == true) {
      return _buildVideoPlayer();
    } else if (_contentType?.startsWith('application/pdf') == true) {
      return _buildPdfViewer();
    } else if (_contentType ==
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
      return _buildDocxViewer();
    } else if (widget.item!['type'] == 'cid') {
      return Image.network(
        'https://gateway.lighthouse.storage/ipfs/${widget.item!['cid']}',
        fit: BoxFit.cover,
      );
    } else if (widget.item!['playPath'].endsWith('.aac')) {
      return Image.asset(
        'assets/image/recorder_icon.png',
        fit: BoxFit.fitHeight,
      );
    } else {
      return Image.file(
        File(widget.item!['playPath']),
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildDocxViewer() {
    if (_docxContent == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _docxContent!,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Future<String> _downloadAndReadDocx(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    return _extractTextFromDocx(bytes);
  }

  Future<String> _readLocalDocx(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    return _extractTextFromDocx(bytes);
  }

  String _extractTextFromDocx(List<int> bytes) {
    // This is a very basic text extraction.
    // For better results, you might want to use a package like 'dart_docx'
    // or implement a more sophisticated parsing logic.
    String content = String.fromCharCodes(bytes);
    // Remove XML tags (this is a very crude method and won't work perfectly)
    content = content.replaceAll(RegExp(r'<[^>]*>'), '');
    return content;
  }
}
