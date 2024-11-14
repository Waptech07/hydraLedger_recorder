import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voice_recorder/state/auth_state.dart';
import 'package:voice_recorder/views/signup/signup.dart';
import 'package:voice_recorder/widget/select_button.dart';

import '../../widget/text_form_list_tile.dart';
import '../enter_email_login_scree.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isChecked = false;
  bool _isObscure = true;
  bool _isObscureHint = true;

  bool _obscureTextConfirm = true;
  final TextEditingController passwordConfirmController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 30.0),
                Text(
                  'Create an account',
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
                const SizedBox(height: 20.0),
                TextFormListTile(
                  text: 'Password',
                  obscureText: _isObscure,
                  prefixIcon: const Icon(
                    Icons.lock_outlined,
                    color: Color(0xff171A1F),
                  ),
                  hintText: 'Enter password',
                  trailing: InkWell(
                    onTap: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                    child: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Color(0xff171A1F),
                    ),
                  ),
                  textController: auth.passwordController,
                  keyboardType: TextInputType.text,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Kindly enter your password';
                    }
                    if (text.length < 8) {
                      return 'Password atleast 8 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15.0),
                TextFormListTile(
                  text: 'Confirm Password',
                  obscureText: _obscureTextConfirm,
                  prefixIcon: const Icon(
                    Icons.lock_outlined,
                    color: Color(0xff171A1F),
                  ),
                  hintText: 'Confirm password',
                  trailing: InkWell(
                    onTap: () {
                      setState(() {
                        _obscureTextConfirm = !_obscureTextConfirm;
                      });
                    },
                    child: Icon(
                      _obscureTextConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Color(0xff171A1F),
                    ),
                  ),
                  textController: passwordConfirmController,
                  keyboardType: TextInputType.text,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Kindly confirm your password';
                    }
                    if (text != auth.passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32.0),
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: ((value) {
                        setState(() {
                          isChecked = value!;
                        });
                      }),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'I agree with ',
                            style: GoogleFonts.poppins(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xff171A1F),
                            ),
                          ),
                          TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _openLink(
                                    'https://hrecorder.com/terms-and-conditions',
                                    context);
                              },
                            text: 'Terms and Conditions\n',
                            style: GoogleFonts.poppins(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xffD1A967),
                            ),
                          ),
                          TextSpan(
                            text: 'and ',
                            style: GoogleFonts.poppins(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xff171A1F),
                            ),
                          ),
                          TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _openLink(
                                    'https://hrecorder.com/privacy-policy',
                                    context);
                              },
                            text: 'Privacy Policy',
                            style: GoogleFonts.poppins(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xffD1A967),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60.0),
                SelectButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    if (_formKey.currentState!.validate() && isChecked) {
                      if (auth.passwordController.text !=
                          passwordConfirmController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Passwords do not match'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Signup(),
                        ),
                      );
                    }
                  },
                  bTitle: 'Generate DID',
                ),
                const SizedBox(height: 70.0),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Already have an account? ',
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff171A1F),
                        ),
                      ),
                      TextSpan(
                        text: 'Sign In',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EnterEmailLoginScreen(),
                              ),
                            );
                          },
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xffD1A967),
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    passwordConfirmController.dispose();
    super.dispose();
  }
}

void _openLink(url, BuildContext context) async {
  Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch URL'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
