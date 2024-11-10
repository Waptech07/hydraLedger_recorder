import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hydraledger_recorder/constants/color_constants.dart';
import 'package:hydraledger_recorder/models/request/edit_profile_request.dart';
import 'package:hydraledger_recorder/services/user/user_http.dart';
import 'package:hydraledger_recorder/state/auth_state.dart';
import 'package:hydraledger_recorder/utils/helpers.dart';

class EditProfilePage extends StatefulWidget {
  final String email;
  const EditProfilePage({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController? _firstNameController;
  late TextEditingController? _lastNameController;
  late TextEditingController? _zipController;
  late TextEditingController? _cityController;
  late TextEditingController? _addressController;
  late TextEditingController? _countryController;
  late TextEditingController? _dobController;
  late TextEditingController? _usernameController;
  late TextEditingController? _phoneNumberController;
  late TextEditingController? _fullNameController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _zipController = TextEditingController();
    _cityController = TextEditingController();
    _addressController = TextEditingController();
    _countryController = TextEditingController();
    _dobController = TextEditingController(text: '');
    _usernameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _fullNameController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController?.dispose();
    _lastNameController?.dispose();
    _zipController?.dispose();
    _cityController?.dispose();
    _addressController?.dispose();
    _countryController?.dispose();
    _dobController?.dispose();
    _usernameController?.dispose();
    _phoneNumberController?.dispose();
    _fullNameController?.dispose();
    super.dispose();
  }

  void clearControllers() {
    _firstNameController?.clear();
    _lastNameController?.clear();
    _zipController?.clear();
    _cityController?.clear();
    _addressController?.clear();
    _countryController?.clear();
    _dobController?.clear();
    _usernameController?.clear();
    _phoneNumberController?.clear();
    _fullNameController?.clear();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      initialDate = _dobController!.text.isNotEmpty
          ? DateFormat("dd/MM/yyyy").parse(_dobController!.text)
          : DateTime.now();
    } catch (e) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController?.text = DateFormat("dd/MM/yyyy").format(picked);
      });
    }
  }

  void _saveProfile() async {
    // if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    UserHttpService userHttpService = UserHttpService();

    try {
      final fullName = _fullNameController?.text;
      log('fullName: $fullName');
      final nameParts = splitFullName(fullName ?? '');

      final editProfileRequest = EditProfileRequest(
        firstName: nameParts[0],
        lastName: nameParts[1],
        zip: _zipController?.text,
        city: _cityController?.text,
        address: _addressController?.text,
        country: _countryController?.text,
        dob: _dobController?.text,
        username: _usernameController?.text,
        phoneNumber: _phoneNumberController?.text,
      );

      final result = await userHttpService.updateUser(
        widget.email,
        editProfileRequest,
      );

      if (result == 'true') {
        UserHttpService userService = UserHttpService();
        final request = await userService.getUser(widget.email);
        if (request != null) {
          final authState = AuthState.instance;
          await authState?.saveUserData(request);
          setState(() {
            _isLoading = false;
          });

          clearControllers();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }

      // You can handle the result here if needed
      print('Update result: $result');
    } catch (error) {
      print('Error updating profile result: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
                bottom: 65.0, left: 16, right: 16, top: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _fullNameController!,
                    label: 'Full Name',
                    hintText: 'Jane Doe',
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  // CustomTextField(
                  //   controller: _lastNameController,
                  //   label: 'Last Name',
                  //   prefixIcon: Icons.person,
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter your last name';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  CustomTextField(
                    controller: _phoneNumberController!,
                    label: 'Phone Number',
                    prefixIcon: Icons.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    controller: _zipController!,
                    label: 'ZIP Code',
                    prefixIcon: Icons.location_on,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your ZIP code';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    controller: _cityController!,
                    label: 'City',
                    prefixIcon: Icons.location_city,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your city';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    controller: _addressController!,
                    label: 'Street Address',
                    prefixIcon: Icons.home,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your street address';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    controller: _countryController!,
                    label: 'Country',
                    prefixIcon: Icons.flag,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your country';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    controller: _dobController!,
                    label: 'Date of Birth',
                    prefixIcon: Icons.cake,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      return null;
                    },
                  ),
                  CustomTextField(
                    controller: _usernameController!,
                    label: 'Username',
                    prefixIcon: Icons.account_circle,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                    color: kColorGold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final IconData? prefixIcon;
  final String? hintText;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.prefixIcon,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).primaryColor.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
  }
}
