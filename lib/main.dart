import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hash/hash.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_recorder/constants/color_constants.dart';
import 'package:voice_recorder/globals.dart' as globals;
import 'package:voice_recorder/models/vocie_save_model.dart';
import 'package:voice_recorder/services/sqflite_service.dart';
import 'package:voice_recorder/state/auth_state.dart';
import 'package:voice_recorder/utils/helpers.dart';
import 'package:voice_recorder/views/splash_view.dart';

import 'firebase_options.dart';
import 'models/pdf_save_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'hrecorder',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  unawaited(MobileAds.instance.initialize());

  // MobileAds.instance.updateRequestConfiguration(
  //   RequestConfiguration(
  //     testDeviceIds: ['ED97AC6A8FFAFB7CC8098F5580A0FC44'],
  //   ),
  // );

  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  await FirebaseAnalytics.instance.logAppOpen();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  await analytics.logEvent(
    name: 'Test Event',
    parameters: {
      'string': 'Hello, world!',
      'int': 42,
    },
  );
  setup();
  await initRCPlatformState();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  //FlutterBranchSdk.validateSDKIntegration();
  // globals.netMode = await ModeChecker().getMode();
  await Permission.microphone.request();
  await Permission.camera.request();
  await Permission.photos.request();
  runApp(const MyApp());
}

void setup() async {
  if (await isFirstLaunch()) {
    //copies file from assets to local storage
    ByteData data = await rootBundle.load('assets/voices/example.aac');
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    String dir = (await getApplicationDocumentsDirectory()).path;
    var file = await File('$dir/Sample-File.aac').writeAsBytes(bytes);

    DbHelper().insertVoice(VoiceSaveModel(
      name: "Sample-File.aac",
      path: base64
          .encode(hashKey(file.readAsBytesSync()))
          .replaceAll("/", "")
          .trim(),
      playPath: file.path,
      duration: "00:01:18",
      date: DateTime.now(),
      hashBytes: hashKey(file.readAsBytesSync()),
      hasCreatedProof: true,
    ));

    DbHelper.internal().insertPDFDetails(PDFSaveModel(
      userName: "Max Mustermann",
      description: "Richard Nixon's closure of the USD's gold peg in 1971",
      fileName: "Sample-File.aac",
      bcExplorer:
          'https://explorer.hydraledger.tech/transaction/464b04bf51b2c26f6ae4e3cef001b54e68b594b0bdb06958efe8457177118f38',
      email: "Max@mustermann.de",
      hash: base64
          .encode(hashKey(file.readAsBytesSync()))
          .replaceAll("/", "")
          .trim(),
      registeredContent: base64
          .encode(hashKey(file.readAsBytesSync()))
          .replaceAll("/", "")
          .trim(),
      timeStamp: '05.02.2023 15:28:00',
      transactionID:
          "464b04bf51b2c26f6ae4e3cef001b54e68b594b0bdb06958efe8457177118f38",
      bcProof:
          '464b04bf51b2c26f6ae4e3cef001b54e68b594b0bdb06958efe8457177118f38',
    ));

    print("Preset files created");
  }
}

Future<void> initRCPlatformState() async {
  await Purchases.setLogLevel(LogLevel.debug);

  PurchasesConfiguration configuration = PurchasesConfiguration("");
  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration(globals.rcAndroidKey);
  } else if (Platform.isIOS) {
    configuration = PurchasesConfiguration(globals.rciOSKey);
  }
  await Purchases.configure(configuration);
}

Uint8List hashKey(Uint8List bytes) {
  // var result = SHA224().update(byte).digest();

  var result = SHA256().update(bytes).digest();
  return result;
}

Future<bool> isFirstLaunch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isFirstLaunch = prefs.getBool('isFirstLaunch');
  if (isFirstLaunch == null) {
    prefs.setBool('isFirstLaunch', false);
    return true;
  }
  return false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthState.instance,
          lazy: true,
        ),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        home: const SplashView(),
        theme: ThemeData().copyWith(
            colorScheme:
                ColorScheme.fromSwatch().copyWith(primary: kColorGold)),
      ),
    );
  }
}
