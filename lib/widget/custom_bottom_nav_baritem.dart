import 'package:flutter/material.dart';

class CustomBottomNavBarItem extends StatelessWidget {
  const CustomBottomNavBarItem({
    Key? key,
    required this.icon,
    required this.name,
    required this.selectedIndex,
    required this.index,
  }) : super(key: key);
  final Widget icon;
  final String name;
  final int selectedIndex;
  final int index;

//  bool isVisible = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        icon,
        // SizedBox(
        //   height: 4,
        // ),
        Text(
          name,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        // SizedBox(
        //   height: 4,
        // ),
        Visibility(
          visible: selectedIndex == index,
          child: Container(
            width: 14,
            height: 7,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
      ],
    );
  }
}
