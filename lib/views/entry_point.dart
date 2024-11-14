import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:voice_recorder/views/enter_otp_page.dart';
import 'package:voice_recorder/views/signup/create_account.dart';
import 'package:voice_recorder/views/signup/signup.dart';
import 'package:voice_recorder/widget/select_button.dart';

import '../state/auth_state.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({Key? key}) : super(key: key);

  @override
  _EntryPointState createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 50.0),
              SizedBox(
                width: size.width * 0.7,
                child: Image.asset(
                  "assets/image/hydra_logo.png",
                ),
              ),
              const SizedBox(height: 21.0),
              Text(
                'Welcome to\nHydraledger\'s event\nrecorder!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff171A1F),
                ),
              ),
              const SizedBox(height: 21.0),
              Text(
                'Your mobile blockchain witness and\ndeepfake prevention tool',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff565D6D),
                ),
              ),
              const SizedBox(height: 200.0),
              SelectButton(
                onPressed: () async {
                  // final hasLoggedIn = await authState.getIsUserLoggedIn();
                  // if (hasLoggedIn) {
                  //   if (context.mounted) {
                  //     Navigator.of(context).pushReplacement(
                  //       MaterialPageRoute(
                  //         builder: (BuildContext context) =>
                  //             const AppBottomNavBar(),
                  //       ),
                  //     );
                  //   }
                  // } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'You have to create an account before trying to login'),
                      ),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EnterOtpPage(),
                      ),
                    );
                  }
                  // }
                },
                padding: 20,
                horMargin: 0,
                bTitle: 'Start Recording',
              ),
              // Row(
              //   children: [
              //     Expanded(
              //       child: SelectButton(
              //         onPressed: () {
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) => const Signup(),
              //             ),
              //           );
              //         },
              //         padding: 20,
              //         horMargin: 0,
              //         bTitle: 'SignUp',
              //       ),
              //     ),
              //     const SizedBox(width: 12.0),
              //     Expanded(
              //       child: SelectButton(
              //         onPressed: () async {
              // await authState.getId();
              // if (authState.idController.text != '') {
              //   if (context.mounted) {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => const Login(),
              //       ),
              //     );
              //   }
              // } else {
              //   if (context.mounted) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       const SnackBar(
              //         content: Text(
              //             'You have to create an account before trying to login'),
              //       ),
              //     );
              //   }
              // }
              //         },
              //         padding: 20,
              //         horMargin: 0,
              //         bTitle: 'Login',
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
