import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:voice_recorder/constants/color_constants.dart';
import 'package:voice_recorder/services/auth/auth_http.dart';
import 'package:voice_recorder/services/user/user_http.dart';
import 'package:voice_recorder/views/enter_otp_page.dart';
import 'package:voice_recorder/views/signup/create_account.dart';

import '../state/auth_state.dart';
import '../widget/select_button.dart';
import '../widget/text_form_list_tile.dart';
import 'enter_password_login_screen.dart';

class EnterEmailLoginScreen extends StatefulWidget {
  EnterEmailLoginScreen({super.key});

  @override
  State<EnterEmailLoginScreen> createState() => _EnterEmailLoginScreenState();
}

class _EnterEmailLoginScreenState extends State<EnterEmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isloading = false;

  @override
  void dispose() {
    super.dispose();
    AuthState auth = AuthState.instance!;
    auth.emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 100.0),
                Text(
                  'Enter your email to login',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 28.0,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff9095A1),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 32.0)),
                TextFormListTile(
                  text: 'Email',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xff171A1F),
                  ),
                  hintText: 'Enter email',
                  textController: auth.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Kindly enter your email address';
                    } else if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                        .hasMatch(text)) {
                      return 'Kindly Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 70.0), //verified
                SelectButton(
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isloading = true;
                      });
                      UserHttpService userService = UserHttpService();
                      final request =
                          await userService.getUser(auth.emailController.text);
                      if (request != null) {
                        setState(() {
                          _isloading = false;
                        });
                        try {
                          log('eee: $request');
                          await auth.saveUserData(request);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text('E-Mail verification successful'),
                              ),
                            );

                            // Check if user is verified
                            if (request['verified'] == false) {
                              AuthHttpService authService = AuthHttpService();

                              final otpRequest =
                                  await authService.sendEmailVerifyOtp(
                                      auth.emailController.text);
                              // Navigate to OTP screen
                              if (otpRequest['status'] == true) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EnterOtpPage(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text(
                                        'could not send otp for verification'),
                                  ),
                                );
                              }
                            } else {
                              // User is verified, proceed to password screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EnterPasswordLoginScreen(
                                    email: auth.emailController.text,
                                  ),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content:
                                    Text('Please use a valid email to login'),
                              ),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Error occured while verifying'),
                          ),
                        );
                        setState(() {
                          _isloading = false;
                        });
                      }
                    }
                  },
                  bTitle: _isloading ? 'Validating...' : 'Validate Email',
                ),
                const SizedBox(height: 30.0),
                Text.rich(
                  TextSpan(children: [
                    const TextSpan(text: 'Don\'t have account? '),
                    TextSpan(
                      text: 'Register here',
                      style: GoogleFonts.lexend(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: kColorGold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CreateAccountScreen()),
                          );
                        },
                    ),
                  ]),
                  textAlign: TextAlign.end,
                  style: GoogleFonts.lexend(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
