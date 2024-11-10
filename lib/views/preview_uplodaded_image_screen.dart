import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:hydraledger_recorder/constants/color_constants.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PreviewUploadedContent extends StatefulWidget {
  final Map<String, dynamic> item;

  const PreviewUploadedContent({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<PreviewUploadedContent> createState() => _PreviewUploadedContentState();
}

class _PreviewUploadedContentState extends State<PreviewUploadedContent> {
  late Future<void> _initializationFuture;
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  String? _contentType;
  String? _pdfPath;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initialize();
  }

  Future<void> _initialize() async {
    if (widget.item['type'] == 'cid') {
      final url =
          'https://gateway.lighthouse.storage/ipfs/${widget.item['cid']}';
      _contentType = await _getContentType(url);

      if (_contentType?.startsWith('video/') == true) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
        await _videoController!.initialize();
      } else if (_contentType?.startsWith('audio/') == true) {
        await _initializeAudioPlayer(url);
      } else if (_contentType?.startsWith('application/pdf') == true) {
        _pdfPath = await _downloadAndSavePdf(url);
      }
    } else if (widget.item['playPath'].endsWith('.aac')) {
      await _initializeAudioPlayer(widget.item['playPath']);
    }
  }

  Future<void> _initializeAudioPlayer(String source) async {
    _audioPlayer = AudioPlayer();
    if (widget.item['type'] == 'cid') {
      await _audioPlayer!.setUrl(source);
    } else {
      await _audioPlayer!.setFilePath(source);
    }
    _duration = _audioPlayer!.duration ?? Duration.zero;
    _audioPlayer!.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });
  }

  Future<String> _getContentType(String url) async {
    final response = await http.head(Uri.parse(url));
    return response.headers['content-type'] ?? '';
  }

  Future<String> _downloadAndSavePdf(String url) async {
    final response = await http.get(Uri.parse(url));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File('${documentDirectory.path}/document.pdf');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              size: 40,
              color: kColorGold,
            ),
          ),
        ),
        body: FutureBuilder<void>(
          future: _initializationFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              if (widget.item['type'] == 'cid') {
                return _buildRemoteContent();
              } else {
                return _buildLocalContent();
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildRemoteContent() {
    final url = 'https://gateway.lighthouse.storage/ipfs/${widget.item['cid']}';
    if (_contentType?.startsWith('image/') == true) {
      return _buildImageViewer(url);
    } else if (_contentType?.startsWith('video/') == true) {
      return _buildVideoPlayer();
    } else if (_contentType?.startsWith('audio/') == true) {
      return _buildAudioPlayer();
    } else if (_contentType?.startsWith('application/pdf') == true) {
      return _buildPdfViewer();
    } else {
      return _buildUnsupportedContent();
    }
  }

  Widget _buildImageViewer(String url) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            size: 50.0,
            color: Colors.white.withOpacity(0.7),
          ),
          onPressed: () {
            setState(() {
              _isPlaying = !_isPlaying;
              _isPlaying ? _videoController!.play() : _videoController!.pause();
            });
          },
        ),
      ],
    );
  }

  Widget _buildAudioPlayer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/image/recorder_icon.png',
            width: 100,
            height: 100,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 20),
          const Text(
            'Audio File',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  setState(() {
                    if (_isPlaying) {
                      _audioPlayer?.pause();
                    } else {
                      _audioPlayer?.play();
                    }
                    _isPlaying = !_isPlaying;
                  });
                },
              ),
              const SizedBox(width: 20),
              Text(_formatDuration(_position)),
              Slider(
                value: _position.inSeconds.toDouble(),
                max: _duration.inSeconds.toDouble(),
                onChanged: (value) {
                  final position = Duration(seconds: value.toInt());
                  _audioPlayer?.seek(position);
                },
              ),
              Text(_formatDuration(_duration)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
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

  Widget _buildUnsupportedContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.file_present, size: 50, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'Unsupported file type',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalContent() {
    if (widget.item['playPath'].endsWith('.aac')) {
      return _buildAudioPlayer();
    } else if (widget.item['playPath'].endsWith('.pdf')) {
      return PDFView(
        filePath: widget.item['playPath'],
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
    } else {
      return InteractiveViewer(
        constrained: false,
        child: Image.file(
          File(widget.item['playPath']),
          filterQuality: FilterQuality.high,
          fit: BoxFit.contain,
        ),
      );
    }
  }
}
