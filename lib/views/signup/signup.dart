import 'dart:convert';
import 'dart:developer';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_recorder/models/request/create_user_request.dart';
import 'package:voice_recorder/services/auth/auth_http.dart';
import 'package:voice_recorder/services/user/user_http.dart';
import 'package:voice_recorder/state/auth_state.dart';
import 'package:voice_recorder/views/enter_otp_page.dart';
import 'package:voice_recorder/views/signup/login.dart';
import 'package:voice_recorder/widget/select_button.dart';

import '../../widget/text_form_list_tile.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  late bool _isPasswordVisible = true;
  bool _isloading = false;
  String _selectedCountryCode = '+234';
  String countryValue = "";

  String getFullPhoneNumber(AuthState authState) {
    final cleanNumber =
        authState.phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    return '$_selectedCountryCode$cleanNumber';
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Padding(padding: EdgeInsets.only(bottom: 12.0)),
                Text(
                  'Personal Info',
                  textAlign: TextAlign.start,
                  style: GoogleFonts.lexend(
                    fontSize: 28.0,
                    color: const Color(0xff171A1F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'To generate your unique DID',
                  textAlign: TextAlign.start,
                  style: GoogleFonts.lexend(
                    fontSize: 18.0,
                    color: const Color(0xff9095A1),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 16.0)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormListTile(
                        text: 'Name *',
                        hintText: 'First',
                        prefixIcon: const Icon(
                          Icons.person_outlined,
                          color: Color(0xff171A1F),
                        ),
                        titleFontSize: 18.0,
                        titleFontWeight: FontWeight.w400,
                        textController: authState.firstNameController,
                        keyboardType: TextInputType.name,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Kindly enter your first name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    Expanded(
                      child: TextFormListTile(
                        hintText: 'Last',
                        textController: authState.lastNameController,
                        keyboardType: TextInputType.name,
                        showTitle: false,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Kindly enter your last name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 12.0)),
                TextFormListTile(
                  text: 'Username *',
                  hintText: 'Username',
                  prefixIcon: const Icon(
                    Icons.person_outlined,
                    color: Color(0xff171A1F),
                  ),
                  titleFontSize: 18.0,
                  titleFontWeight: FontWeight.w400,
                  textController: authState.userNameController,
                  keyboardType: TextInputType.name,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Kindly enter your username name';
                    }
                    return null;
                  },
                ),
                const Padding(padding: EdgeInsets.only(top: 12.0)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone Number *',
                      style: GoogleFonts.poppins(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff171A1F),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 48,
                            margin: EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: const Color(0xff9095A1),
                                width: 1.0,
                              ),
                            ),
                            child: CountryCodePicker(
                              onChanged: (CountryCode countryCode) {
                                setState(() {
                                  _selectedCountryCode =
                                      countryCode.dialCode ?? '+1';
                                });
                              },
                              initialSelection: 'US',
                              textOverflow: TextOverflow.visible,
                              favorite: const ['US', 'NG', '+91', 'GB'],
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                              showDropDownButton: false,
                              flagWidth: 24,
                              padding: EdgeInsets.zero,
                              textStyle: GoogleFonts.poppins(
                                fontSize: 16,
                                color: const Color(0xff171A1F),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 4,
                          child: TextFormListTile(
                            showTitle: false,
                            hintText: '0000000000',
                            prefixIcon:
                                null, // Removed since we have country code
                            titleFontSize: 20.0,
                            titleFontWeight: FontWeight.w400,
                            textController: authState.phoneController,
                            keyboardType: TextInputType.phone,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Kindly enter your phone number';
                              }
                              final cleanNumber =
                                  text.replaceAll(RegExp(r'[^\d]'), '');

                              if (cleanNumber.length < 7) {
                                return 'Phone number is too short';
                              }
                              if (cleanNumber.length > 15) {
                                return 'Phone number is too long';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 12.0)),
                TextFormListTile(
                  readOnly: true,
                  text: 'Date of birth *',
                  titleFontSize: 18.0,
                  titleFontWeight: FontWeight.w400,
                  textController: authState.dobController,
                  keyboardType: TextInputType.name,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Kindly enter your date of birth';
                    }
                    return null;
                  },
                  onTap: () async {
                    final DateTime now = DateTime.now();
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime(now.year - 18, now.month,
                          now.day), // Set initial date to 18 years ago
                      firstDate: DateTime(1900),
                      lastDate: now, // Set last date to current date
                      locale: const Locale('en', 'GB'),
                    );
                    if (date != null) {
                      DateFormat formatter = DateFormat("d/MM/yyyy");
                      authState.dobController.text = formatter.format(date);
                      log('date: ${authState.dobController.text}');
                    }
                  },
                ),
                const SizedBox(width: 113),
                const Padding(padding: EdgeInsets.only(top: 18.0)),
                TextFormListTile(
                  text: 'Address *',
                  hintText: 'Line 1 *',
                  prefixIcon: const Icon(
                    Icons.home_outlined,
                    color: Color(0xff171A1F),
                  ),
                  titleFontSize: 18.0,
                  titleFontWeight: FontWeight.w400,
                  textController: authState.addressController,
                  keyboardType: TextInputType.name,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Kindly enter your address';
                    }
                    return null;
                  },
                ),
                const Padding(padding: EdgeInsets.only(top: 26.0)),
                Row(
                  children: [
                    Expanded(
                      child: TextFormListTile(
                        showTitle: false,
                        hintText: 'City *',
                        prefixIcon: const Icon(
                          Icons.apartment_outlined,
                          color: Color(0xff171A1F),
                        ),
                        textController: authState.cityController,
                        keyboardType: TextInputType.name,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Kindly enter your city';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: TextFormListTile(
                        showTitle: false,
                        hintText: 'Zip Code *',
                        textController: authState.zipcodeController,
                        keyboardType: TextInputType.number,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Kindly enter your zip code';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 26.0)),
                CSCPicker(
                  showStates: false,
                  showCities: false,
                  flagState: CountryFlag.DISABLE,
                  onCountryChanged: (country) {
                    setState(() {
                      authState.countryController.text = country;
                    });
                  },
                  countryDropdownLabel: "Select Country",
                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: Colors.white,
                    border: Border.all(color: Color(0xff9095A1), width: 1.0),
                  ),
                  dropdownHeadingStyle:
                      TextStyle(color: Colors.black, fontSize: 16),
                  selectedItemStyle: TextStyle(color: Color(0xff171A1F)),
                ),
                TextFormListTile(
                  hintText: 'Country *',
                  prefixIcon: const Icon(
                    Icons.public_outlined,
                    color: Color(0xff171A1F),
                  ),
                  showTitle: false,
                  textController: authState.countryController,
                  keyboardType: TextInputType.name,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Kindly enter your country';
                    }
                    return null;
                  },
                ),
                const Padding(padding: EdgeInsets.only(top: 50.0)),
                SelectButton(
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(FocusNode());

                    if (_formKey.currentState!.validate()) {
                      try {
                        setState(() {
                          _isloading = true;
                        });

                        final fullPhoneNumber = getFullPhoneNumber(authState);
                        AuthHttpService authService = AuthHttpService();

                        final request = await authService.createUser(
                          CreateUserRequest(
                            firstName: authState.firstNameController.text,
                            lastName: authState.lastNameController.text,
                            email: authState.emailController.text,
                            username: authState.userNameController.text,
                            password: authState.passwordController.text,
                            passwordHint: authState.passwordController.text,
                            dob: authState.dobController.text,
                            address: authState.addressController.text,
                            city: authState.cityController.text,
                            zip: authState.zipcodeController.text,
                            country: authState.countryController.text,
                            phoneNumber: fullPhoneNumber,
                          ),
                        );

                        if (request != null) {
                          if (request['message'] != null &&
                              request['message'] == 'Email already Exists ') {
                            UserHttpService userService = UserHttpService();
                            final userRequest = await userService
                                .getUser(authState.emailController.text);
                            if (userRequest['verified'] == false) {
                              final otpRequest =
                                  await authService.sendEmailVerifyOtp(
                                      authState.emailController.text);
                              if (otpRequest['status'] == true) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text('${otpRequest['message']}'),
                                    ),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EnterOtpPage(),
                                    ),
                                  );
                                }
                              }
                            } else {
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Login(),
                                  ),
                                );
                              }
                            }
                          } else {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            Map saved = request;
                            String encodedResponse = json.encode(saved);
                            log('created response: $encodedResponse');
                            await prefs.setString(
                                'createUserResponse', encodedResponse);
                            await prefs.setString('firstName',
                                authState.firstNameController.text);
                            await prefs.setString(
                                'lastName', authState.lastNameController.text);
                            await prefs.setString(
                                'email', authState.emailController.text);

                            final otpRequest =
                                await authService.sendEmailVerifyOtp(
                                    authState.emailController.text);
                            if (otpRequest['status'] == true) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text('${otpRequest['message']}'),
                                  ),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EnterOtpPage(),
                                  ),
                                );
                              }
                            }
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                    'Something went wrong. Please try again.'),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        // Handle any errors from the API call
                        if (e is Map &&
                            e['data'] != null &&
                            e['data']['message'] != null) {
                          // Handle structured error response
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(e['data']['message'].toString()),
                              ),
                            );
                          }
                        } else {
                          // Handle general errors
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(e.toString()),
                              ),
                            );
                          }
                        }
                      } finally {
                        // Always reset loading state
                        if (mounted) {
                          setState(() {
                            _isloading = false;
                          });
                        }
                      }
                    }
                  },
                  padding: 18.0,
                  horMargin: 0.0,
                  bTitle: _isloading
                      ? 'Setting up your account...'
                      : 'Register your DID',
                ),
                const Padding(padding: EdgeInsets.only(bottom: 30.0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
