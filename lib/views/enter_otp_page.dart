import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:voice_recorder/constants/color_constants.dart';
import 'package:voice_recorder/state/auth_state.dart';
import 'package:voice_recorder/views/signup/login.dart';
import 'package:voice_recorder/widget/select_button.dart';

class EnterOtpPage extends StatefulWidget {
  EnterOtpPage({super.key});

  @override
  State<EnterOtpPage> createState() => _EnterOtpPageState();
}

class _EnterOtpPageState extends State<EnterOtpPage> {
  bool _isloading = false;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Enter OTP',
          style: GoogleFonts.poppins(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.only(top: 40.0)),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Kindly Enter the otp sent to email address ',
                  ),
                  TextSpan(
                    text: authState.emailController.text,
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.blue.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              style: GoogleFonts.poppins(
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 20.0,
              ),
              child: PinCodeTextField(
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.underline,
                  borderWidth: 0,
                  fieldHeight: 40,
                  fieldWidth: 40,
                  activeFillColor: kColorGold,
                  activeColor: kColorGold,
                  selectedColor: kColorGold,
                  inactiveColor: kColorGold,
                ),
                controller: authState.otpController,
                appContext: context,
                length: 4,
                cursorColor: kColorBlack,
                keyboardType: TextInputType.number,
                onChanged: (value) async {
                  if (value.length == 4) {
                    setState(() {
                      authState.isOtpValid = true;
                    });
                  }
                },
              ),
            ),
            // 9135366375
            SizedBox(height: 200),
            SelectButton(
              onPressed: () async {
                FocusScope.of(context).requestFocus(FocusNode());

                if (authState.isOtpValid) {
                  setState(() {
                    _isloading = true;
                  });

                  final request = await authState.verifyOtp();
                  if (request['status'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('${request['message']}'),
                      ),
                    );

                    setState(() {
                      _isloading = false;
                    });

                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ),
                      );
                    }
                  } else {
                    setState(() {
                      _isloading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('${request['message']}'),
                      ),
                    );
                  }
                }
              },
              padding: 18.0,
              horMargin: 0.0,
              bTitle: _isloading ? 'Verifying Otp...' : 'Verify Otp',
            ),
          ],
        ),
      ),
    );
  }
}
