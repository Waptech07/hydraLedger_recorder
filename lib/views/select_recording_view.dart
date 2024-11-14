import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:voice_recorder/api/subscriptionmanager.dart';
import 'package:voice_recorder/views/homepage/home_screen.dart';
import 'package:voice_recorder/widget/select_button.dart';

class SelectRecordingType extends StatelessWidget {
  final PersistentTabController controller;

  const SelectRecordingType({
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10.0),
            InkWell(
              onTap: () {
                controller.jumpToTab(0);
              },
              child: const Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 31.0),
                  child: Icon(
                    Icons.house,
                    size: 32,
                    color: Color(0xff323743),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45.0),
              child: Image.asset(
                'assets/image/logo_transparent.png',
                height: 80,
                width: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding:
                  EdgeInsets.only(left: 30, right: 30, bottom: height * 0.02),
              child: Text(
                "Create recording files with court-proof\nevidence of authorship, authenticity\n"
                "and time of creation on Hydraledger,\nthe public blockchain for\nself-sovereign identities.",
                style: GoogleFonts.poppins(
                  color: const Color(0xff565D6D),
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0),
              child: SelectButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.picture_in_picture_alt_outlined,
                      color: Color(0xff323743),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Picture',
                      style: GoogleFonts.poppins(
                        color: const Color(0xff323743),
                        fontWeight: FontWeight.w400,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  SubscriptionManager()
                      .maybeShowPopup(context, forceShow: true);
                  //snackbarShow(context: context, text: 'Coming Soon!');
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: HomeScreen(
                      typePresetIndex: 2,
                      controller: controller,
                    ),
                  );
                  // Navigator.push(context, MaterialPageRoute(
                  //   builder: (context) {
                  //     return HomeScreen(typePresetIndex: 2);
                  //   },
                  // ));
                },
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0),
              child: SelectButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.video_call,
                      color: Color(0xff323743),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Video',
                      style: GoogleFonts.poppins(
                        color: Color(0xff323743),
                        fontWeight: FontWeight.w400,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  SubscriptionManager()
                      .maybeShowPopup(context, forceShow: true);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return HomeScreen(
                        typePresetIndex: 1,
                        controller: controller,
                      );
                    },
                  ));
                },
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0),
              child: SelectButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.mic,
                      color: Color(0xff323743),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Audio',
                      style: GoogleFonts.poppins(
                        color: Color(0xff323743),
                        fontWeight: FontWeight.w400,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  SubscriptionManager()
                      .maybeShowPopup(context, forceShow: true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                        typePresetIndex: 0,
                        controller: controller,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0),
              child: SelectButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.print_outlined,
                      color: Color(0xff323743),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Documents',
                      style: GoogleFonts.poppins(
                        color: Color(0xff323743),
                        fontWeight: FontWeight.w400,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  SubscriptionManager()
                      .maybeShowPopup(context, forceShow: true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                        typePresetIndex: 3,
                        controller: controller,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
