import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/color_constants.dart';

class SelectButton extends StatelessWidget {
  String? bTitle;
  double? padding;
  double? horMargin;
  Function()? onPressed;
  final Widget? child;

  SelectButton({
    Key? key,
    this.bTitle,
    this.onPressed,
    this.padding,
    this.horMargin,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: kColorGold,
            border: Border.all(color: Color(0xff323743), width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: child ??
            Center(
              child: Text(
                bTitle!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xff323743),
                  fontWeight: FontWeight.w400,
                  fontSize: 18.0,
                ),
              ),
            ),
      ),
    );
  }
}
