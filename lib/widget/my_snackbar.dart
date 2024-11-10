// Flutter imports:
import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackbarShow({
  required BuildContext context,
  required String text,
  int? duration,
  String? label,
  Color? backgroundColor,
}) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(text),
    backgroundColor: backgroundColor,
    duration: Duration(seconds: duration ?? 5),
    action: SnackBarAction(
      onPressed: () {},
      label: label ?? 'Ok',
    ),
  ));
}
