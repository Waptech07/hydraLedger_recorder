import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ProofView extends StatelessWidget {
  final String deviceId;
  final String mediaHash;
  final String txHash;
  final String bcProof;

  const ProofView({
    Key? key,
    required this.deviceId,
    required this.mediaHash,
    required this.txHash,
    required this.bcProof,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Builder(builder: (context) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: height * 0.025, left: 5),
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: SvgPicture.asset("assets/icons/back_arrow.svg",
                          color: const Color(0xff7F0D51)),
                    ),
                    title: Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.21,
                      ),
                      child: const Text(
                        "Proof",
                        style: TextStyle(
                            color: Color(0xff484848),
                            fontSize: 24,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ListTile(
                  leading: Text(
                    'Device Id:',
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff565D6D),
                    ),
                  ),
                  title: Text(
                    deviceId,
                    style: GoogleFonts.poppins(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff95625D),
                    ),
                  ),
                ),
                ListTile(
                  leading: Text(
                    'Media hash:',
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff565D6D),
                    ),
                  ),
                  title: Text(
                    mediaHash,
                    style: GoogleFonts.poppins(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ),
                ListTile(
                  leading: Text(
                    'Tx Id:',
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff565D6D),
                    ),
                  ),
                  title: Text(
                    txHash,
                    style: GoogleFonts.poppins(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ),
                ListTile(
                  leading: Text(
                    'Bc proof:',
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff565D6D),
                    ),
                  ),
                  title: Text(
                    bcProof,
                    style: GoogleFonts.poppins(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
