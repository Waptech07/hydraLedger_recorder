import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:voice_recorder/constants/color_constants.dart';
import 'package:voice_recorder/utils/pdf/pdf_file.dart';
import 'package:voice_recorder/views/Recording/record_view.dart';
import 'package:voice_recorder/views/share_app_view.dart';

import '../../utils/pdf/save_pdf.dart';
import '../../widget/widgets.dart';

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xffF5D7FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                top: height * 0.09,
                right: 16,
              ),
              child: Container(
                height: height * 0.28,
                width: double.infinity,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image:
                            AssetImage("assets/image/logo_transparent.png"))),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 24, right: 25, top: height * 0.03),
              child: const AutoSizeText.rich(
                TextSpan(children: [
                  TextSpan(
                    text: "Welcome to ",
                    style: TextStyle(
                      height: 1.4,
                      color: Color(0xFF121212),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: "Hydraledger's Dictaphone ",
                    style: TextStyle(
                      height: 1.4,
                      color: Color(0xff8724AA),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: "the first ",
                    style: TextStyle(
                      height: 1.4,
                      color: Color(0xFF121212),
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: "Proof of events",
                    style: TextStyle(
                      height: 1.4,
                      color: kColorGold,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ]),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: 30,
                  right: 30,
                  top: height * 0.035,
                  bottom: height * 0.02),
              child: const AutoSizeText.rich(
                TextSpan(
                  text:
                      "Create recording files with court-proof evidence of authorship, authenticity and time of creation on Hydraledger, the public blockchain for self sovereign identities.",
                  style: TextStyle(
                      // fontFamily: Manrope,
                      height: 1.2,
                      color: Color(0xff484848),
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Text Button
            // ButtonWidget(
            //   bTitle: 'Try for free',
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => RecordView(),
            //       ),
            //     );
            //   },
            // ),
            ButtonWidget(
              bTitle: 'Use full version',
            ),
            ButtonWidget(
              bTitle: 'Recommend',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShareAppView(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
