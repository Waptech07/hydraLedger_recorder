import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_recorder/constants/color_constants.dart';
import 'package:voice_recorder/models/request/edit_profile_request.dart';
import 'package:voice_recorder/services/fs3/fs3_upload_htt.dart';
import 'package:voice_recorder/services/user/user_http.dart';

import 'package:voice_recorder/state/auth_state.dart';
import 'package:voice_recorder/utils/helpers.dart';
import 'package:voice_recorder/views/enter_email_login_scree.dart';
import 'package:voice_recorder/widget/my_snackbar.dart';
import 'package:badges/badges.dart' as badges;
import 'package:voice_recorder/widget/select_button.dart';

class PrrofileScreen extends StatefulWidget {
  const PrrofileScreen({super.key});

  @override
  State<PrrofileScreen> createState() => _PrrofileScreenState();
}

class _PrrofileScreenState extends State<PrrofileScreen> {
  TextEditingController firstNameController = TextEditingController();

  TextEditingController lastNameController = TextEditingController();

  TextEditingController controllerMail = TextEditingController();

  TextEditingController fullNameCnt = TextEditingController();

  TextEditingController zipCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController homeAddressController = TextEditingController();

  TextEditingController userNameCnt = TextEditingController();
  TextEditingController phoneCnt = TextEditingController();
  TextEditingController dobCnt = TextEditingController();

  String imagePath = '';

  bool copying = false;
  bool _isNewObscure = true;
  bool _isLoading = false;
  // String? imageCid;

  bool isUserNameChanged = false;
  bool nameChanged = false;
  bool phoneChanged = false;
  bool dobChanged = false;
  bool zipChanged = false;
  bool cityChanged = false;
  bool countryChanged = false;
  bool homeAddressChanged = false;

  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    getImagePath();
    getId();
    _userDataFuture = _loadUserData();
  }

  Future<Map<String, dynamic>> _loadUserData() async {
    final authState = AuthState.instance;
    final response = await authState!.loadUserData();
    return response!;
  }

  Future<void> getId() async {
    final authState = AuthState.instance;
    final response = await authState!.loadUserData();
    authState.idController.text = response!['did'];
    if (response['image'] != null) {
      imagePath = response['image'];
    }
    firstNameController.text = response['first_name'];
    lastNameController.text = response['last_name'];
    controllerMail.text = response['email'];
    userNameCnt.text = response['username'];
    phoneCnt.text = response['phone_number'];
    zipCodeController.text = response['zip'];
    cityController.text = response['city'];
    countryController.text = response['country'];
    homeAddressController.text = response['country'];
    dobCnt.text = response['dob'];
    fullNameCnt.text = '${firstNameController.text} ${lastNameController.text}';
    // setState(() {});
  }

  Future<void> getImagePath() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();

    // setState(() {
    //   imagePath = prefs.getString('userImagePath') ?? '';
    // });
    final authState = AuthState.instance;
    final response = await authState!.loadUserData();
    authState.idController.text = response!['did'];
    if (response['image'] != null) {
      setState(() {
        imagePath = response['image'];
      });
    }
  }

  Future<void> updateProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Fs3UploadHttpService fs3Service = Fs3UploadHttpService();

      final fs3Request = await fs3Service.fs3Upload(image.path);

      if (fs3Request.isNotEmpty) {
        UserHttpService userHttpService = UserHttpService();
        final editProfileRequest = EditProfileRequest(
          image: fs3Request['Hash'],
        );

        final result = await userHttpService.updateUser(
          controllerMail.text,
          editProfileRequest,
        );

        if (result == 'true') {
          snackbarShow(
            context: context,
            text: 'Profile picture updated successfully',
            backgroundColor: Colors.green,
          );
          setState(() {
            imagePath = fs3Request['Hash'];
          });
        }
      }

      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('userImagePath', image.path);
      // setState(() {
      //   imagePath = image.path;
      // });
      // snackbarShow(
      //   context: context,
      //   text: 'Profile picture updated successfully',
      //   backgroundColor: Colors.green,
      // );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate;
    DateTime now = DateTime.now();

    try {
      initialDate = dobCnt.text.isNotEmpty
          ? DateFormat("dd/MM/yyyy").parse(dobCnt.text)
          : DateTime(
              now.year - 18, now.month, now.day); // Default to 18 years ago
    } catch (e) {
      initialDate = DateTime(
          now.year - 18, now.month, now.day); // Default to 18 years ago
    }

    // Ensure initialDate is not in the future
    if (initialDate.isAfter(now)) {
      initialDate = now;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now, // Set last date to today
    );

    if (picked != null && picked != DateTime.parse(dobCnt.text)) {
      setState(() {
        dobCnt.text = DateFormat("dd/MM/yyyy").format(picked);
        dobChanged = true;
      });
    }
  }

  Widget _buildListTile(String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xffBDC1CA),
        ),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Profile',
          style: GoogleFonts.lexend(
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
            color: const Color(0xff323743),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setBool('isLoggedIn', false);
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return EnterEmailLoginScreen();
                          },
                        ),
                        (_) => false,
                      );
                    }
                  },
                  child: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff9095A1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _userDataFuture = _loadUserData();
          });
        },
        child: FutureBuilder<Map<String, dynamic>>(
            future: _userDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No data available'));
              }

              final userData = snapshot.data!;
              // if (userData['image'] != null) {
              //   imagePath = userData['image'];
              // }
              // firstNameController.text = userData['first_name'];
              // lastNameController.text = userData['last_name'];
              // controllerMail.text = userData['email'];
              // userNameCnt.text = userData['username'];
              // phoneCnt.text = userData['phone_number'];
              // if (userData['address'] != null && userData['address'] is Map) {
              //   zipCodeController.text = userData['address']['zip'];
              //   cityController.text = userData['address']['city'];
              //   countryController.text = userData['address']['country'];
              //   homeAddressController.text = userData['address']['country'];
              // } else {
              //   zipCodeController.text = userData['zip'];
              //   cityController.text = userData['city'];
              //   countryController.text = userData['country'];
              //   homeAddressController.text = userData['country'];
              // }
              // dobCnt.text = userData['dob'];
              // fullNameCnt.text =
              //     '${firstNameController.text} ${lastNameController.text}';

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8.0),
                    CircleAvatar(
                      radius: 80,
                      backgroundColor: const Color(0xffF1E4D0),
                      child: badges.Badge(
                        badgeContent: InkWell(
                          onTap: updateProfileImage,
                          child: const Icon(Icons.edit),
                        ),
                        badgeStyle: badges.BadgeStyle(
                          badgeColor: kColorGold,
                          padding: const EdgeInsets.all(5),
                          borderRadius: BorderRadius.circular(4),
                          badgeGradient: const badges.BadgeGradient.linear(
                            colors: [Colors.blue, Colors.yellow],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          elevation: 0,
                        ),
                        position:
                            badges.BadgePosition.bottomEnd(bottom: 0, end: 0),
                        child: ClipOval(
                          child: imagePath.isNotEmpty
                              ? Image.network(
                                  'https://gateway.lighthouse.storage/ipfs/$imagePath',
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/image/hrecorder_avatar.jpg',
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'My unique Hydraledger DID:',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff323743),
                      ),
                    ),
                    Text(
                      authState.idController.text,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff323743),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Copy DID',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xffBDC1CA),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            setState(() {
                              copying = true;
                            });
                            Clipboard.setData(
                              ClipboardData(text: authState.idController.text),
                            );
                            Future.delayed(const Duration(seconds: 2), () {
                              setState(() {
                                copying = false;
                              });
                            });
                          },
                          child: Icon(
                            copying ? Icons.check : Icons.copy,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    // _buildListTile('Name',
                    //     '${userData['first_name']} ${userData['last_name']}'),
                    // _buildListTile('Username', '${userData['username']}'),
                    // _buildListTile('Phone', '${userData['phone_number']}'),
                    // _buildListTile('Email', '${userData['email']}'),
                    // _buildListTile('Date of Birth', '${userData['dob']}'),
                    // const Divider(color: Colors.black54),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                    //   child: Text(
                    //     'Address',
                    //     style: GoogleFonts.poppins(
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.w600,
                    //       color: Colors.black87,
                    //     ),
                    //   ),
                    // ),
                    // _buildListTile('ZIP Code', '${userData['zip']}'),
                    // _buildListTile('Home Address', '${userData['address']}'),
                    // _buildListTile('City', '${userData['city']}'),
                    // _buildListTile('Country', '${userData['country']}'),
                    Text(
                      'Name *',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xffBDC1CA),
                      ),
                    ),
                    TextFormField(
                      controller: fullNameCnt,
                      // readOnly: true,
                      onChanged: (value) {
                        if (value != fullNameCnt.text) {
                          setState(() {
                            nameChanged = true;
                            fullNameCnt.text = value;
                          });
                        }
                      },
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff262728),
                      ),
                      decoration: InputDecoration(
                        constraints: const BoxConstraints(maxHeight: 45),
                        hintText: 'James Harid',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xffBDC1CA),
                        ),
                        fillColor: const Color(0xffF3F4F6),
                        filled: true,
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      'Username',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xffBDC1CA),
                      ),
                    ),
                    TextFormField(
                      controller: userNameCnt,
                      // readOnly: true,
                      onChanged: (value) {
                        if (value != userNameCnt.text) {
                          setState(() {
                            isUserNameChanged = true;
                          });
                        }
                      },
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff262728),
                      ),
                      decoration: InputDecoration(
                        constraints: const BoxConstraints(maxHeight: 45),
                        hintText: 'jimmy',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xffBDC1CA),
                        ),
                        fillColor: const Color(0xffF3F4F6),
                        filled: true,
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      'Phone *',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xffBDC1CA),
                      ),
                    ),
                    TextFormField(
                      controller: phoneCnt,
                      // readOnly: true,
                      onChanged: (value) {
                        if (value != phoneCnt.text) {
                          setState(() {
                            phoneChanged = true;
                          });
                        }
                      },
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff262728),
                      ),
                      decoration: InputDecoration(
                        constraints: const BoxConstraints(maxHeight: 45),
                        hintText: '123-456-7890',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xffBDC1CA),
                        ),
                        fillColor: const Color(0xffF3F4F6),
                        filled: true,
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      'Email *',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffBDC1CA),
                      ),
                    ),
                    TextFormField(
                      controller: controllerMail,
                      readOnly: true,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff262728),
                      ),
                      decoration: InputDecoration(
                        constraints: BoxConstraints(maxHeight: 45),
                        hintText: 'example@email.com',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffBDC1CA),
                        ),
                        fillColor: Color(0xffF3F4F6),
                        filled: true,
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      'Date Of Birth *',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffBDC1CA),
                      ),
                    ),
                    TextFormField(
                      controller: dobCnt,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      onChanged: (value) {
                        if (value != dobCnt.text) {
                          setState(() {
                            dobChanged = true;
                          });
                        }
                      },
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          try {
                            DateTime enteredDate =
                                DateFormat("dd/MM/yyyy").parse(value);
                            if (enteredDate.isAfter(DateTime.now())) {
                              return 'Date of birth cannot be in the future';
                            }
                          } catch (e) {
                            return 'Invalid date format';
                          }
                        }
                        return null;
                      },
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff262728),
                      ),
                      decoration: InputDecoration(
                        constraints: BoxConstraints(maxHeight: 45),
                        hintText: '12/12/2012',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffBDC1CA),
                        ),
                        fillColor: Color(0xffF3F4F6),
                        filled: true,
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Divider(
                      color: Colors.black,
                      thickness: 0.5,
                    ),
                    Text(
                      'Address',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xffBDC1CA),
                      ),
                    ),

                    const SizedBox(height: 8.0),
                    Text(
                      'Street Name and House Number  ',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffBDC1CA),
                      ),
                    ),
                    TextFormField(
                      controller: homeAddressController,
                      // readOnly: true,
                      onChanged: (value) {
                        setState(() {
                          homeAddressChanged = true;
                        });
                      },
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff262728),
                      ),
                      decoration: InputDecoration(
                        constraints: BoxConstraints(maxHeight: 45),
                        hintText: 'no 1 bovas road',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffBDC1CA),
                        ),
                        fillColor: Color(0xffF3F4F6),
                        filled: true,
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8.0),
                    Text(
                      'City',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffBDC1CA),
                      ),
                    ),
                    TextFormField(
                      controller: cityController,
                      // readOnly: true,
                      onChanged: (value) {
                        setState(() {
                          cityChanged = true;
                        });
                      },
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff262728),
                      ),
                      decoration: InputDecoration(
                        constraints: const BoxConstraints(maxHeight: 45),
                        hintText: 'San franscisco',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xffBDC1CA),
                        ),
                        fillColor: const Color(0xffF3F4F6),
                        filled: true,
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Zip',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xffBDC1CA),
                      ),
                    ),
                    TextFormField(
                      controller: zipCodeController,
                      // readOnly: true,
                      onChanged: (value) {
                        setState(() {
                          zipChanged = true;
                        });
                      },
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff262728),
                      ),
                      decoration: InputDecoration(
                        constraints: BoxConstraints(maxHeight: 45),
                        hintText: '23223',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffBDC1CA),
                        ),
                        fillColor: Color(0xffF3F4F6),
                        filled: true,
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Country',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffBDC1CA),
                      ),
                    ),
                    TextFormField(
                      controller: countryController,
                      // readOnly: true,
                      onChanged: (value) {
                        setState(() {
                          countryChanged = true;
                        });
                      },
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff262728),
                      ),
                      decoration: InputDecoration(
                        constraints: BoxConstraints(maxHeight: 45),
                        hintText: 'United states',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffBDC1CA),
                        ),
                        fillColor: Color(0xffF3F4F6),
                        filled: true,
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    _isLoading
                        ? const SizedBox(
                            width: 85,
                            child: LinearProgressIndicator(),
                          )
                        : SelectButton(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                final fullName = fullNameCnt.text;
                                log('fullName: $fullName');
                                final nameParts = splitFullName(fullName);

                                final data = EditProfileRequest(
                                  firstName: nameParts[0],
                                  lastName: nameParts[1],
                                  zip: zipCodeController.text,
                                  city: cityController.text,
                                  address: homeAddressController.text,
                                  country: countryController.text,
                                  dob: dobChanged ? dobCnt.text : null,
                                  username: isUserNameChanged
                                      ? userNameCnt.text
                                      : null,
                                  phoneNumber:
                                      phoneChanged ? phoneCnt.text : null,
                                  zipChanged: zipChanged,
                                  cityChanged: cityChanged,
                                  countryChanged: countryChanged,
                                  homeAddressChanged: homeAddressChanged,
                                );

                                UserHttpService userHttpService =
                                    UserHttpService();
                                final updateUser = await userHttpService
                                    .updateUser(controllerMail.text, data);

                                if (updateUser == 'true') {
                                  UserHttpService userService =
                                      UserHttpService();
                                  final request = await userService
                                      .getUser(controllerMail.text);
                                  if (request != null) {
                                    await authState.saveUserData(request);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text(
                                              'Profile updated successfully'),
                                        ),
                                      );
                                    }
                                  }
                                }

                                print('Update result: $updateUser');
                              } catch (error) {
                                print('Error updating profile result: $error');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Error updating profile: $error'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                            bTitle: 'Update profile',
                          ),
                    const SizedBox(height: 90),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
