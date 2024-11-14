import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_recorder/botton_nav_bar.dart';
import 'package:voice_recorder/constants/color_constants.dart';
import 'package:voice_recorder/views/enter_password_reset_otp.dart';
import 'package:voice_recorder/widget/text_form_list_tile.dart';

import '../services/auth/auth_http.dart';
import '../state/auth_state.dart';
import '../widget/select_button.dart';

class EnterPasswordLoginScreen extends StatefulWidget {
  final String email;
  const EnterPasswordLoginScreen({super.key, required this.email});

  @override
  State<EnterPasswordLoginScreen> createState() =>
      _EnterPasswordLoginScreenState();
}

class _EnterPasswordLoginScreenState extends State<EnterPasswordLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? id;
  bool _isloading = false;
  bool _obscureText = true;

  @override
  void initState() {
    // TODO: implement initState
    getUserData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    AuthState auth = AuthState.instance!;
    auth.passwordController.clear();
  }

  void getUserData() async {
    final auth = AuthState.instance!;
    final response = await auth.loadUserData();
    log('local user data: $response');
    id = response!['_id'];
    log('local user id: $id');
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
                  'Enter your password to complete login process',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 28.0,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff9095A1),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 32.0)),
                TextFormListTile(
                  text: 'Password',
                  obscureText: _obscureText,
                  prefixIcon: const Icon(
                    Icons.lock_outlined,
                    color: Color(0xff171A1F),
                  ),
                  hintText: 'Enter password',
                  trailing: InkWell(
                    onTap: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Color(0xff171A1F),
                    ),
                  ),
                  textController: auth.passwordController,
                  keyboardType: TextInputType.name,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Kindly enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15.0),
                Text.rich(
                  TextSpan(children: [
                    const TextSpan(text: 'Forgot password? '),
                    TextSpan(
                      text: 'Reset here',
                      style: GoogleFonts.lexend(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: kColorGold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => EnterPasswordResetOtp(
                                      email: widget.email,
                                    )),
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
                const SizedBox(height: 86.0),
                SelectButton(
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isloading = true;
                      });
                      AuthHttpService authService = AuthHttpService();

                      final request = await authService.login(
                        id ?? '',
                        auth.passwordController.text,
                      );
                      if (request == 'true') {
                        setState(() {
                          _isloading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Account login was successful'),
                          ),
                        );
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('isLoggedIn', true);
                        if (context.mounted) {
                          Navigator.of(context, rootNavigator: true)
                              .pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return AppBottomNavBar();
                              },
                            ),
                            (_) => false,
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                                'Error occured. Please recheck your login details'),
                          ),
                        );
                      }
                      setState(() {
                        _isloading = false;
                      });
                    }
                  },
                  bTitle: _isloading
                      ? 'Setting up your account...'
                      : 'Complete Login Process',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
