import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:voice_recorder/constants/color_constants.dart';

class ShareAppView extends StatelessWidget {
  const ShareAppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: true,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: true,
        title: const Text(
          'Information',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Color(0xff484848),
              fontSize: 24,
              fontWeight: FontWeight.w500),
        ),
        //const SizedBox()
        // actions: actions ?? [],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    height: 1.4,
                    color: Color(0xFF121212),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: "Welcome to ",
                    ),
                    TextSpan(
                      text: "Ħ",
                      style: TextStyle(
                        color: Color(0xFF143454),
                      ),
                    ),
                    TextSpan(
                      text: "Recorder",
                      style: TextStyle(
                        color: kColorGold,
                      ),
                    ),
                    TextSpan(
                      text:
                          " - Ħydraledger's blockchain witness for your significant and potentially controversial communication and life events.",
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Text(
                "Create recording files with court-proof evidence of authorship, authenticity and time of creation on Hydraledger, the public blockchain for self sovereign identities.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                  onTap: () => launchUrlString("https://hrecorder.com",
                      mode: LaunchMode.externalApplication),
                  child: Text(
                    "ĦRecorder Website",
                    style: TextStyle(decoration: TextDecoration.underline),
                  )),
              SizedBox(height: 7),
              GestureDetector(
                  onTap: () => launchUrlString("https://hydraledger.tech",
                      mode: LaunchMode.externalApplication),
                  child: Text(
                    "Ħydraledger Website",
                    style: TextStyle(decoration: TextDecoration.underline),
                  )),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50,
                child: MaterialButton(
                  color: kColorDarkBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textColor: Colors.white,
                  child: Text(
                    "Share",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                  onPressed: () {
                    Share.share(
                        "https://play.google.com/com.hydraledger.voice_recorder");
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                  width: double.infinity,
                  child: Text(
                    "Join our Telegram:",
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                  )),
              GestureDetector(
                onTap: () {
                  launchUrlString("https://t.me/H_Recorder_news",
                      mode: LaunchMode.externalApplication);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: RichText(
                      text: TextSpan(
                          style: TextStyle(color: kColorDarkBlue),
                          children: [
                        TextSpan(text: "• "),
                        TextSpan(
                            text: "Official Announcements",
                            style:
                                TextStyle(decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrlString("https://t.me/H_Recorder_news",
                                    mode: LaunchMode.externalApplication);
                              }),
                      ])),
                ),
              ),
              GestureDetector(
                onTap: () {
                  launchUrlString("https://t.me/H_Recorder",
                      mode: LaunchMode.externalApplication);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: RichText(
                      text: TextSpan(
                          style: TextStyle(color: kColorDarkBlue),
                          children: [
                        TextSpan(text: "• "),
                        TextSpan(
                            text: "Official support chat",
                            style:
                                TextStyle(decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrlString("https://t.me/H_Recorder",
                                    mode: LaunchMode.externalApplication);
                              }),
                      ])),
                ),
              ),
              GestureDetector(
                onTap: () {
                  launchUrlString("https://t.me/hydraledger",
                      mode: LaunchMode.externalApplication);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: RichText(
                      text: TextSpan(
                          style: TextStyle(color: kColorDarkBlue),
                          children: [
                        TextSpan(text: "• "),
                        TextSpan(
                            text: "Hydraledger community",
                            style:
                                TextStyle(decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrlString("https://t.me/hydraledger",
                                    mode: LaunchMode.externalApplication);
                              }),
                      ])),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                      style: TextStyle(
                        height: 1.2,
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                      ),
                      children: [
                        TextSpan(text: "By using this app I agree to it's "),
                        TextSpan(
                            text: "Terms & Conditions ",
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: kColorDarkBlue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrlString(
                                    "https://hrecorder.com/terms-and-conditions",
                                    mode: LaunchMode.externalApplication);
                              }),
                        TextSpan(text: "and "),
                        TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: kColorDarkBlue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrlString(
                                    "https://hrecorder.com/privacy-policy",
                                    mode: LaunchMode.externalApplication);
                              }),
                      ])),
            ],
          ),
        ),
      ),
    );
  }
}
