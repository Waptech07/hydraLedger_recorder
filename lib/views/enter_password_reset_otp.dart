import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:hydraledger_recorder/services/auth/auth_http.dart';
import 'package:hydraledger_recorder/state/auth_state.dart';
import 'package:hydraledger_recorder/views/enter_new_password_screen.dart';
import 'package:hydraledger_recorder/widget/select_button.dart';

class EnterPasswordResetOtp extends StatefulWidget {
  final String email;

  const EnterPasswordResetOtp({Key? key, required this.email})
      : super(key: key);

  @override
  State<EnterPasswordResetOtp> createState() => _EnterPasswordResetOtpState();
}

class _EnterPasswordResetOtpState extends State<EnterPasswordResetOtp> {
  bool _isLoading = false;
  bool _canResend = false;
  int _remainingTime = 120; // 2 minutes
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _sendOtp();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer.cancel();
      }
    });
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
    });

    AuthHttpService authService = AuthHttpService();
    final otpRequest = await authService.sendPasswordResetOtp(widget.email);

    setState(() {
      _isLoading = false;
    });

    if (otpRequest['status'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('OTP sent successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to send OTP: ${otpRequest['message']}'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

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
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Kindly Enter the OTP sent to email address ',
                  ),
                  TextSpan(
                    text: widget.email,
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
            PinCodeTextField(
              controller: authState.otpController,
              appContext: context,
              length: 4,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.length == 4) {
                  setState(() {
                    authState.isOtpValid = true;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            Text(
              _canResend
                  ? 'You can now resend the OTP'
                  : 'Resend OTP in ${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
              style: GoogleFonts.poppins(
                fontSize: 14.0,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            TextButton(
              onPressed: _canResend ? _sendOtp : null,
              child: Text('Resend OTP'),
            ),
            SizedBox(height: 20),
            // SelectButton(
            //   onPressed: () async {
            //     FocusScope.of(context).requestFocus(FocusNode());

            //     if (authState.isOtpValid) {
            //       setState(() {
            //         _isLoading = true;
            //       });

            //       final request = await authState.verifyPasswordChangeOtp();
            //       if (request['status'] == true) {
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           SnackBar(
            //             backgroundColor: Colors.green,
            //             content: Text('${request['message']}'),
            //           ),
            //         );

            //         setState(() {
            //           _isLoading = false;
            //         });

            //         if (context.mounted) {
            //           Navigator.pushReplacement(
            //             context,
            //             MaterialPageRoute(
            //               builder: (context) => EnterNewPasswordScreen(),
            //             ),
            //           );
            //         }
            //       } else {
            //         setState(() {
            //           _isLoading = false;
            //         });
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           SnackBar(
            //             backgroundColor: Colors.red,
            //             content: Text('${request['message']}'),
            //           ),
            //         );
            //       }
            //     }
            //   },
            //   padding: 18.0,
            //   horMargin: 0.0,
            //   bTitle: _isLoading ? 'Verifying OTP...' : 'Verify OTP',
            // ),
            SelectButton(
              onPressed: () async {
                FocusScope.of(context).requestFocus(FocusNode());

                if (authState.isOtpValid) {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    final request = await authState.verifyPasswordChangeOtp();

                    if (request['status'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('${request['message']}'),
                        ),
                      );

                      final token = request['data'];

                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EnterNewPassword(
                              email: widget.email,
                              token: token,
                            ),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('${request['message']}'),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('An error occurred: $e'),
                      ),
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              padding: 18.0,
              horMargin: 0.0,
              bTitle: _isLoading ? 'Verifying OTP...' : 'Verify OTP',
            ),
          ],
        ),
      ),
    );
  }
}
