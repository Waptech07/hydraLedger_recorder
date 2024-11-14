import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_recorder/botton_nav_bar.dart';
import 'package:voice_recorder/state/auth_state.dart';
import 'package:voice_recorder/views/entry_point.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool isUserAuthenticated = false;
  @override
  void initState() {
    super.initState();
    // checkIfUserIsAuthenticated();
    navigate();
  }

  // void checkIfUserIsAuthenticated() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String savedResponse = prefs.getString('createUserResponse') ?? '';
  //   Map decodedMap = json.decode(savedResponse);
  //   String id = decodedMap['data']['id'];
  //   if (id.isNotEmpty) {
  //     setState(() {
  //       isUserAuthenticated = true;
  //     });
  //   }
  // }

  navigate() async {
    final authState = Provider.of<AuthState>(context, listen: false);

    final hasLoggedIn = await authState.getIsUserLoggedIn();
    if (hasLoggedIn) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => const AppBottomNavBar(),
          ),
        );
      }
    } else {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const EntryPoint(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container();
  }
}
