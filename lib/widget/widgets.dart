
import 'package:flutter/material.dart';

import '../constants/color_constants.dart';

class ButtonWidget extends StatelessWidget {
  final String bTitle;
  VoidCallback? onPressed;
  ButtonWidget( {Key? key, required this.bTitle, this.onPressed}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding:   EdgeInsets.only(left: 16, top: height*0.03, right: 16),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: height*0.05,
        child: TextButton(
            style: ButtonStyle(
                shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.all(Radius.circular(100)))),
                backgroundColor:
                MaterialStateProperty.all( kColorGold)),
            onPressed: onPressed,
            child: Text(
              bTitle,
              style: const TextStyle(
                  color: Color(
                    0xffFFFFFF,
                  ),
                  fontWeight: FontWeight.w500,
                  fontSize: 16),
              textAlign: TextAlign.center,
            )),
      ),
    );
  }
}
