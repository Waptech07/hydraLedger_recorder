import 'package:flutter/material.dart';

class BlockchainProofScreen extends StatelessWidget {
  const BlockchainProofScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 128,
            ),
            SizedBox(height: 270.0),
            Icon(
              Icons.u_turn_right,
              size: 45,
            ),
            SizedBox(height: 80.0),
          ],
        ),
      ),
    );
  }
}
