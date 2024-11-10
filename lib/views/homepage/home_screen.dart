import 'package:flutter/material.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:hydraledger_recorder/constants/color_constants.dart';
import 'package:hydraledger_recorder/views/Recording/stop_record_view.dart';
import 'package:hydraledger_recorder/views/documents/documents_select.dart';
import 'package:hydraledger_recorder/views/image/image_select.dart';
import 'package:hydraledger_recorder/views/share_app_view.dart';
import 'package:hydraledger_recorder/views/video/record_video.dart';

import '../../widget/app_bar.dart';

class HomeScreen extends StatefulWidget {
  final PersistentTabController controller;

  HomeScreen(
      {this.isImageSelect,
      this.isVideoRecord,
      this.selectedIndex,
      this.consumableID,
      this.typePresetIndex = 0,
      required this.controller,
      super.key});

  int? selectedIndex;
  int typePresetIndex = 0;
  String? consumableID;
  bool? isImageSelect;
  bool? isVideoRecord;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int typeindex = 0;

  @override
  void initState() {
    super.initState();
    typeindex = widget.typePresetIndex;
  }

  @override
  Widget build(BuildContext context) {
    return homeTabs()[widget.selectedIndex ?? 0];
    // bottomNavigationBar: FloatingNavbar(
    //   padding: EdgeInsets.zero,
    //   borderRadius: 12,
    //   backgroundColor: kColorGold,
    //   selectedBackgroundColor: Colors.transparent,
    //   items: [
    //     FloatingNavbarItem(
    //       customWidget: CustomBottomNavBarItem(
    //           icon: const Icon(
    //             Icons.keyboard_voice_outlined,
    //             color: Colors.white,
    //           ),
    //           name: 'Recording',
    //           selectedIndex: widget.selectedIndex ?? 0,
    //           index: 0),
    //     ),
    //     FloatingNavbarItem(
    //       customWidget: CustomBottomNavBarItem(
    //           icon: const Icon(
    //             Icons.list_alt_rounded,
    //             color: Colors.white,
    //           ),
    //           name: 'Record File List',
    //           selectedIndex: widget.selectedIndex ?? 0,
    //           index: 1),
    //     ),
    //     FloatingNavbarItem(
    //       customWidget: CustomBottomNavBarItem(
    //           icon: const Icon(
    //             Icons.receipt,
    //             color: Colors.white,
    //           ),
    //           name: 'Proofs',
    //           selectedIndex: widget.selectedIndex ?? 0,
    //           index: 2),
    //     ),
    //   ],
    //   currentIndex: widget.selectedIndex ?? 0,
    //   // selectedItemColor: Colors.yellow,
    //   // unselectedItemColor: Colors.white,
    //   onTap: (val) {
    //     widget.selectedIndex = val;
    //     setState(() {});
    //   },
    // ),
  }

  List<Widget> homeTabs() {
    return [
      Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              CustomAppBar(
                title: 'Recording',
                actions: [
                  IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: (() {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ShareAppView()));
                    }),
                  )
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: MaterialSegmentedControl(
                  children: const {
                    0: Text('Audio'),
                    1: Text('Video'),
                    2: Text('Photo'),
                    3: Text('Documents'),
                  },
                  selectionIndex: typeindex,
                  borderColor: Colors.grey,
                  selectedColor: kColorGold,
                  unselectedColor: Colors.white,
                  borderRadius: 32.0,
                  horizontalPadding: const EdgeInsets.only(left: 4, right: 4),
                  onSegmentTapped: (index) {
                    setState(() {
                      typeindex = index;
                    });
                  },
                ),
              ),
              Expanded(
                  child: [
                StopRecordView(
                  controller: widget.controller,
                ),
                RecordVideo(
                  controller: widget.controller,
                ),
                ImageSelect(
                  controller: widget.controller,
                ),
                DocumentSelect(
                  controller: widget.controller,
                )
              ][typeindex])
            ],
          ),
        ),
      ),
    ];
  }
}
