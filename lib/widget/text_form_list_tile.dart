import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextFormListTile extends StatelessWidget {
  final String? text;
  final TextEditingController textController;
  final Widget? trailing;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool? readOnly;
  final Function()? onTap;
  final bool showTitle;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;
  final String? hintText;
  final Widget? prefixIcon;

  const TextFormListTile({
    Key? key,
    this.text,
    required this.textController,
    this.trailing,
    this.validator,
    required this.keyboardType,
    this.obscureText = false,
    this.readOnly,
    this.onTap,
    this.showTitle = true,
    this.titleFontSize,
    this.titleFontWeight,
    this.hintText,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (showTitle && text != null)
          Text(
            text ?? '',
            style: GoogleFonts.poppins(
              fontSize: titleFontSize ?? 16.0,
              fontWeight: titleFontWeight ?? FontWeight.w700,
              color: Color(0xff171A1F),
            ),
          ),
        const Padding(padding: EdgeInsets.only(bottom: 4.0)),
        TextFormField(
          readOnly: readOnly ?? false,
          onTap: onTap,
          controller: textController,
          validator: validator ?? (_) => null,
          keyboardType: keyboardType,
          obscureText: obscureText,
          obscuringCharacter: '*',
          textInputAction: TextInputAction.next,
          onSaved: (value) {
            if (value != null) {
              textController.text = value;
            }
          },
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              color: Color(0xff171A1F).withOpacity(0.6),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: trailing,
            prefixIcon: prefixIcon,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: const BorderSide(
                color: Color(0xff9095A1),
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: const BorderSide(
                color: Color(0xff9095A1),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: const BorderSide(
                color: Color(0xff9095A1FF),
                width: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
