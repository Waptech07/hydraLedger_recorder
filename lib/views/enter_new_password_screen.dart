import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hydraledger_recorder/services/auth/auth_http.dart';
import 'package:hydraledger_recorder/state/auth_state.dart';
import 'package:hydraledger_recorder/views/enter_email_login_scree.dart';
import 'package:hydraledger_recorder/widget/select_button.dart';
import 'package:hydraledger_recorder/widget/text_form_list_tile.dart';

class EnterNewPassword extends StatefulWidget {
  final String email;
  final String token;

  const EnterNewPassword({Key? key, required this.email, required this.token})
      : super(key: key);

  @override
  State<EnterNewPassword> createState() => _EnterNewPasswordState();
}

class _EnterNewPasswordState extends State<EnterNewPassword> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _passwordHintController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  bool _obscureHintText = true;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Enter New Password',
          style: GoogleFonts.poppins(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormListTile(
                obscureText: _obscureText,
                prefixIcon: const Icon(
                  Icons.lock_outlined,
                  color: Color(0xff171A1F),
                ),
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
                showTitle: false,
                textController: _passwordController,
                hintText: 'New Password',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
              ),
              const Padding(padding: EdgeInsets.only(top: 12.0)),
              TextFormListTile(
                obscureText: _obscureHintText,
                prefixIcon: const Icon(
                  Icons.lock_outlined,
                  color: Color(0xff171A1F),
                ),
                trailing: InkWell(
                  onTap: () {
                    setState(() {
                      _obscureHintText = !_obscureHintText;
                    });
                  },
                  child: Icon(
                    _obscureHintText ? Icons.visibility : Icons.visibility_off,
                    color: Color(0xff171A1F),
                  ),
                ),
                showTitle: false,
                textController: _passwordHintController,
                hintText: 'Password Hint',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password hint';
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 32),
              SelectButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      AuthHttpService authService = AuthHttpService();

                      final response = await authService.changePassword(
                        email: widget.email,
                        token: widget.token,
                        password: _passwordController.text,
                        passwordHint: _passwordHintController.text,
                      );

                      if (response['status'] == true) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.green,
                              content: Text('Password changed successfully'),
                            ),
                          );
                        }
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => EnterEmailLoginScreen()),
                          (route) => false,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('${response['message']}'),
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
                bTitle: _isLoading ? 'Changing Password...' : 'Change Password',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
