import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:hydraledger_recorder/constants/color_constants.dart';
import 'package:hydraledger_recorder/views/event_listing/event_listing.dart';
import 'package:hydraledger_recorder/views/profile/profile.dart';
import 'package:hydraledger_recorder/views/select_recording_view.dart';

class AppBottomNavBar extends StatefulWidget {
  final int? initialIndex;
  const AppBottomNavBar({
    super.key,
    this.initialIndex,
  });

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  late PersistentTabController _controller;
  bool? _hideNavBar;

  @override
  void initState() {
    super.initState();

    _controller =
        PersistentTabController(initialIndex: widget.initialIndex ?? 0);
    _hideNavBar = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex != null) {
        _controller.index = widget.initialIndex!;
      }
    });
  }

  List<Widget> _buildScreens() {
    return [
      EventListScreen(
        controller: _controller,
      ),
      SelectRecordingType(controller: _controller),
      PrrofileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(
          Icons.house,
          size: 30,
        ),
        activeColorSecondary: kColorGold,
        inactiveColorPrimary: kTextPrimaryColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(
          Icons.attach_file,
          size: 30,
        ),
        activeColorSecondary: kColorGold,
        inactiveColorPrimary: kTextPrimaryColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(
          Icons.person,
          size: 30,
        ),
        activeColorSecondary: kColorGold,
        inactiveColorPrimary: kTextPrimaryColor,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardShows: true,
        popActionScreens: PopActionScreensType.once,
        bottomScreenMargin: 0.0,
        selectedTabScreenContext: (context) {},
        decoration: NavBarDecoration(
          border: Border.all(
            color: Colors.black.withOpacity(0.1),
            width: 2,
          ),
          colorBehindNavBar: Colors.black,
          adjustScreenBottomPaddingOnCurve: true,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        itemAnimationProperties: const ItemAnimationProperties(
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: const ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle:
            NavBarStyle.style6, // Choose the nav bar style with this property
      ),
    );
  }
}
