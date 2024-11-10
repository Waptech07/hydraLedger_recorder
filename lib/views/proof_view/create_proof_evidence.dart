import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateProofEvidenceScreenn extends StatefulWidget {
  const CreateProofEvidenceScreenn({super.key});

  @override
  State<CreateProofEvidenceScreenn> createState() =>
      _CreateProofEvidenceScreennState();
}

class _CreateProofEvidenceScreennState
    extends State<CreateProofEvidenceScreenn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your court-proof evidence of\nauthorship and authenticity is just a\nclick away',
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff163252),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Name *',
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xffBDC1CA),
                ),
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(),
                  ),
                  SizedBox(width: 40),
                  Expanded(
                    child: TextFormField(),
                  ),
                ],
              ),
              SizedBox(height: 36),
              Text(
                'Email *',
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xffBDC1CA),
                ),
              ),
              SizedBox(height: 6),
              TextFormField(),
              SizedBox(height: 36),
              Text(
                'Describe your event *',
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff163252),
                ),
              ),
              TextFormField(
                maxLines: 10,
              ),
              SizedBox(height: 11),
              Row(
                children: [
                  Icon(Icons.warning),
                  Text(
                    'Once you confirm, above mentioned details\ncannot be modified',
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
