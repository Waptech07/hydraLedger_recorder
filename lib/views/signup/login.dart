import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:voice_recorder/state/auth_state.dart';
import 'package:voice_recorder/views/enter_email_login_scree.dart';

import '../../widget/select_button.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late bool _isPasswordVisible = true;
  final TextEditingController _passwordController = TextEditingController();
  bool _isloading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const Padding(padding: EdgeInsets.only(bottom: 16.0)),
                SizedBox(
                  width: 62,
                  height: 57,
                  child: Image.asset('assets/image/half_logo.png'),
                ),
                SizedBox(height: 60),
                Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/image/hrecorder_avatar.jpg'),
                    ),
                    color: Color(0xffF1E4D0),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  '${authState.firstNameController.text}\n${authState.lastNameController.text}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Color(0xff171A1F),
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 80),
                // TextFormListTile(
                //   readOnly: true,
                //   text: 'ID',
                //   textController: authState.idController,
                //   keyboardType: TextInputType.name,
                //   validator: (text) {
                //     if (text == null || text.isEmpty) {
                //       return 'Kindly enter your first name';
                //     }
                //     return null;
                //   },
                // ),
                // const Padding(padding: EdgeInsets.only(top: 12.0)),
                // TextFormListTile(
                //   text: 'Password',
                //   textController: _passwordController,
                //   keyboardType: TextInputType.text,
                //   obscureText: _isPasswordVisible,
                //   validator: (text) {
                //     if (text!.isEmpty || text.length < 6) {
                //       return 'Password must be more than 6 characters';
                //     }
                //     return null;
                //   },
                //   trailing: IconButton(
                //     onPressed: () {
                //       setState(() {
                //         _isPasswordVisible = !_isPasswordVisible;
                //       });
                //     },
                //     icon: Icon(
                //       !_isPasswordVisible
                //           ? Icons.visibility_off
                //           : Icons.visibility,
                //       color: const Color(0xFF1A2731).withOpacity(0.6),
                //     ),
                //   ),
                // ),
                SelectButton(
                  onPressed: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EnterEmailLoginScreen(),
                      ),
                    );
                    // setState(() {
                    //   _isloading = true;
                    // });
                    // AuthHttpService authService = AuthHttpService();
                    // await authState.getId();
                    // final request = await authService.login(
                    //   authState.idController.text,
                    //   authState.passwordController.text,
                    // );
                    // log('request: $request');
                    // if (request == 'true') {
                    //   SharedPreferences prefs =
                    //       await SharedPreferences.getInstance();
                    //   await prefs.setBool('isLoggedIn', true);
                    //   setState(() {
                    //     _isloading = false;
                    //   });
                    //   if (context.mounted) {
                    //     Navigator.of(context).pushReplacement(
                    //       MaterialPageRoute(
                    //         builder: (BuildContext context) =>
                    //             const AppBottomNavBar(),
                    //       ),
                    //     );
                    //   }
                    // } else {
                    //   setState(() {
                    //     _isloading = false;
                    //   });
                    // }
                  },
                  padding: 18.0,
                  horMargin: 0.0,
                  bTitle: _isloading ? 'Authenticating user....' : 'Login',
                ),
                SizedBox(height: 49),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Not a member yet? ',
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff171A1F),
                        ),
                      ),
                      TextSpan(
                        text: 'Create new\naccount',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pop(context);
                          },
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xffD1A967),
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
