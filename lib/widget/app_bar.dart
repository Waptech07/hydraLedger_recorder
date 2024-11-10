import 'package:flutter/material.dart';
import 'package:hydraledger_recorder/constants/color_constants.dart';

class CustomAppBar extends StatelessWidget {
  CustomAppBar(
      {this.title,
      super.key,
      this.actions,
      this.automaticallyImplyLeading = false});
  // double height;
  bool automaticallyImplyLeading;
  String? title;
  List<Widget>? actions;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: 0,
      toolbarHeight: 80,
      centerTitle: true,
      title: Text(
        title ?? ' ',
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Color(0xff484848),
            fontSize: 24,
            fontWeight: FontWeight.w500),
      ),
      actions: actions ?? [],
    );
  }
}
