import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:hydraledger_recorder/botton_nav_bar.dart';
import 'package:hydraledger_recorder/constants/color_constants.dart';
import 'package:hydraledger_recorder/models/request/morpheus_sign_statement_request.dart';
import 'package:hydraledger_recorder/models/vocie_save_model.dart';
import 'package:hydraledger_recorder/services/sign_statement/morpheus_sign_statement_http.dart';
import 'package:hydraledger_recorder/state/auth_state.dart';
import 'package:hydraledger_recorder/widget/select_button.dart';

class SignWitnessScreen extends StatefulWidget {
  String? imagePath;
  final VoiceSaveModel? voiceSaveModel;
  final bool showWitness;
  final Map<String, dynamic>? item;
  final String? eventDescription;

  SignWitnessScreen({
    this.imagePath,
    this.voiceSaveModel,
    required this.showWitness,
    this.item,
    this.eventDescription,
    super.key,
  });

  @override
  State<SignWitnessScreen> createState() => _SignWitnessScreenState();
}

class _SignWitnessScreenState extends State<SignWitnessScreen> {
  final TextEditingController nameController = TextEditingController();
  TextEditingController controllerDescription = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isloading = false;
  bool _obscureText = true;

  final _formKey = GlobalKey<FormState>();

  bool _isChecked1 = false;
  bool _isChecked2 = false;
  bool _isChecked3 = false;

  DateTime? eventDate;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        // If end time is not set or is earlier than start time, adjust it
        if (_endTime == null ||
            _timeOfDayToDouble(picked) >= _timeOfDayToDouble(_endTime!)) {
          _endTime = TimeOfDay(
            hour: (picked.hour + 1) % 24,
            minute: picked.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null && _startTime != null) {
      if (_timeOfDayToDouble(picked) > _timeOfDayToDouble(_startTime!)) {
        setState(() {
          _endTime = picked;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  double _timeOfDayToDouble(TimeOfDay time) {
    return time.hour + time.minute / 60.0;
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'Select time';
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  void initState() {
    super.initState();
    nameController.text =
        widget.item!['name'] ?? widget.voiceSaveModel!.name ?? '';
    controllerDescription.text = widget.item!['eventDescription'] ?? '';

    if (widget.item != null && widget.item!['date'] != null) {
      try {
        eventDate = DateTime.parse(widget.item!['date']);
        _startTime = TimeOfDay.fromDateTime(eventDate!);
        _endTime =
            TimeOfDay.fromDateTime(eventDate!.add(const Duration(hours: 1)));
      } catch (e) {
        print('Error parsing date: $e');
        eventDate = DateTime.now();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Image.asset(
              'assets/image/half_logo.png',
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    readOnly: true,
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kindly enter the name of the capture';
                      }
                      return null;
                    },
                    onSaved: (value) {},
                    style: GoogleFonts.poppins(
                      color: const Color(0xffA6A8AE),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter name of capture',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.record_voice_over_rounded),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 2.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: const BorderSide(
                          color: Color(0xff9095A1),
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(
                          color: Color(0xff9095A1),
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(
                          color: Color(0xff9095A1FF),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  if (widget.showWitness) ...[
                    Container(
                      height: size.height * 0.25,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        child: widget.imagePath == null
                            ? _buildLocalMediaPreview()
                            : _buildNetworkMediaPreview(),
                      ),
                    ),
                    // Container(
                    //   height: size.height * 0.25,
                    //   width: double.infinity,
                    //   decoration: const BoxDecoration(
                    //       borderRadius: BorderRadius.all(Radius.circular(15))),
                    //   child: ClipRRect(
                    //       borderRadius:
                    //           const BorderRadius.all(Radius.circular(15)),
                    //       child: widget.imagePath == null
                    //           ? Image.file(
                    //               File(widget.voiceSaveModel != null
                    //                   ? widget.voiceSaveModel!.playPath!
                    //                   : widget.imagePath ?? ''),
                    //               fit: BoxFit.cover,
                    //             )
                    //           : Image.network(
                    //               'https://gateway.lighthouse.storage/ipfs/${widget.imagePath}',
                    //               fit: BoxFit.cover,
                    //             )),
                    // ),
                    const SizedBox(height: 14.0),
                    Text(
                      "Event Description",
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                        color: const Color(0xffA6A8AE),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    TextFormField(
                      controller: controllerDescription,
                      readOnly: true,
                      cursorColor: const Color(0xff000000),
                      keyboardType: TextInputType.multiline,
                      minLines: 1, // This will set minimum height
                      maxLines:
                          null, // This allows the field to expand based on content
                      style: GoogleFonts.poppins(
                        color: const Color(0xffBDC1CA),
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xffBDC1CA),
                          fontSize: 16,
                        ),
                        hintText: "Description (upto 700 characters)",
                        fillColor: Colors.blue,
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xff9095A1), width: 1.0),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                  ],
                  if (!widget.showWitness) ...[
                    Container(
                      height: size.height * 0.7,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                      ),
                      child: Center(
                        child: Text(
                          'The owner of this media hasn\'t allowed this media to be shared',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Color(0xff323743),
                            fontWeight: FontWeight.w400,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                  ],
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kindly enter your password';
                        }
                        return null;
                      },
                      onSaved: (value) {},
                      style: GoogleFonts.poppins(
                        color: const Color(0xffA6A8AE),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: InkWell(
                          onTap: (() {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          }),
                          child: Icon(_obscureText
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 2.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: const BorderSide(
                            color: Color(0xff9095A1),
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: const BorderSide(
                            color: Color(0xff9095A1),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: const BorderSide(
                            color: Color(0xff9095A1FF),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  FutureBuilder<Map<String, dynamic>?>(
                    future: AuthState.instance!.loadUserData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final userData = snapshot.data!;
                        final userName =
                            '${userData['first_name']} ${userData['last_name']}';
                        final zip = userData['zip'];
                        final city = userData['city'];
                        final country = userData['country'];
                        final date =
                            DateFormat('MMMM d, yyyy').format(DateTime.now());
                        final medium = widget.item != null
                            ? widget.item!['name']
                            : widget.voiceSaveModel?.name ?? '';

                        return Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    value: _isChecked1,
                                    activeColor: kColorGold,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _isChecked1 = value ?? false;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      'I, $userName, $zip $city $country, hereby declare that I was physically and mentally present as an eye and ear witness to the critical event in question, that took place at said location on ${eventDate != null ? DateFormat('MMMM d, yyyy').format(eventDate!) : 'unknown date'} between ${_formatTimeOfDay(_startTime)} and ${_formatTimeOfDay(_endTime)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xff323743),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    value: _isChecked2,
                                    activeColor: kColorGold,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _isChecked2 = value ?? false;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      'I have reviewed the above description and can confirm that it is a correct verbal representation of the critical event in question',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xff323743),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    value: _isChecked3,
                                    activeColor: kColorGold,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _isChecked3 = value ?? false;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      'I have reviewed the above file $medium and can confirm that it is a correct digital representation of the critical event in question',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xff323743),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                  const SizedBox(height: 40.0),
                ],
              ),
            ),
          ),
          Container(
            // height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _isloading
                ? const SizedBox(
                    width: 85,
                    child: LinearProgressIndicator(),
                  )
                : SelectButton(
                    onPressed: () async {
                      if (!_isChecked1 || !_isChecked2 || !_isChecked3) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please confirm all declarations by checking all boxes'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (_formKey.currentState!.validate()) {
                        try {
                          setState(() {
                            _isloading = true;
                          });

                          final authState = AuthState.instance;
                          final response = await authState!.loadUserData();
                          final vault = response!['morpheus_vault'];

                          // First API call - Sign Witness Statement
                          MorpheusSignStatementHttpService
                              signStatementHttpService =
                              MorpheusSignStatementHttpService();
                          MorpheusSignStatementRequest data =
                              MorpheusSignStatementRequest(
                            vault: vault,
                            password: passwordController.text,
                            statement: Statement(
                              claim: Claim(
                                subject: response['did'],
                                content: Content(
                                  userId: response['_id'],
                                  fullName: BirthDate(
                                      nonce: NonceGenerator.generateNonce(),
                                      value:
                                          '${response['first_name']} ${response['last_name']}'),
                                  address: Address(
                                    nonce: NonceGenerator.generateNonce(),
                                    value: Value(
                                      country: BirthDate(
                                        nonce: NonceGenerator.generateNonce(),
                                        value: '',
                                      ),
                                      city: BirthDate(
                                        nonce: NonceGenerator.generateNonce(),
                                        value: '',
                                      ),
                                      street: BirthDate(
                                        nonce: NonceGenerator.generateNonce(),
                                        value: '',
                                      ),
                                      zipcode: BirthDate(
                                        nonce: NonceGenerator.generateNonce(),
                                        value: response['zip'],
                                      ),
                                    ),
                                  ),
                                  birthDate: BirthDate(
                                    nonce: NonceGenerator.generateNonce(),
                                    value: response['dob'],
                                  ),
                                ),
                              ),
                              processId: '',
                              constraints: Constraints(
                                authority: response['did'],
                                witness: '',
                                content: controllerDescription.text,
                              ),
                              nonce: NonceGenerator.generateNonce(),
                            ),
                          );

                          final signRequest = await signStatementHttpService
                              .morpheusSignStatement(data);

                          if (signRequest != null && context.mounted) {
                            // Second API call - Update Witness
                            final updateResponse =
                                await signStatementHttpService.updateWitness(
                              widget.item!['username'] ?? '',
                              widget.item!['cid'] ?? '',
                              response['username'],
                              response['did'],
                            );

                            if (updateResponse['status'] == 'success') {
                              // Both API calls successful
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      title: const Row(
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Colors.green),
                                          SizedBox(width: 10),
                                          Text('Success'),
                                        ],
                                      ),
                                      content: Text(
                                          'Sign Witness statement was successful'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AppBottomNavBar(),
                                              ),
                                              (route) => false,
                                            );
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            } else {
                              // Update witness failed
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(updateResponse['message'] ??
                                      'Failed to update witness'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('An error occurred: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isloading = false;
                            });
                          }
                        }
                      }
                    },
                    bTitle: 'Sign Witness',
                  ),
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  String _getMediaType(String path) {
    final extension = path.toLowerCase().split('.').last;
    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      return 'image';
    } else if (extension == 'pdf') {
      return 'pdf';
    } else if (extension == 'docx') {
      return 'docx';
    } else if (extension == 'aac') {
      return 'audio';
    } else if (extension == 'mp4') {
      return 'video';
    }
    return 'unknown';
  }

  Widget _buildLocalMediaPreview() {
    final path = widget.voiceSaveModel?.playPath ?? '';
    final mediaType = _getMediaType(path);

    switch (mediaType) {
      case 'image':
        return Image.file(
          File(path),
          fit: BoxFit.cover,
        );
      case 'video':
        // Assuming you have video preview logic similar to PreviewUploadedContent
        return Image.file(
          File(path),
          fit: BoxFit.cover,
        );
      case 'pdf':
      case 'docx':
        return Center(
          child: Image.asset(
            'assets/image/pdf.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
        );
      case 'audio':
        return Center(
          child: Image.asset(
            'assets/image/recorder_icon.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
        );
      default:
        return Center(
          child: Icon(
            Icons.file_present,
            size: 60,
            color: Colors.grey,
          ),
        );
    }
  }

  Widget _buildNetworkMediaPreview() {
    final url = 'https://gateway.lighthouse.storage/ipfs/${widget.imagePath}';
    final mediaType = _getMediaType(widget.item?['name'] ?? '');

    switch (mediaType) {
      case 'image':
        return Image.network(
          url,
          fit: BoxFit.cover,
        );
      case 'video':
        // Assuming you have video preview logic
        return Image.network(
          url,
          fit: BoxFit.cover,
        );
      case 'pdf':
      case 'docx':
        return Center(
          child: Image.asset(
            'assets/image/pdf.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
        );
      case 'audio':
        return Center(
          child: Image.asset(
            'assets/image/recorder_icon.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
        );
      default:
        return Center(
          child: Icon(
            Icons.file_present,
            size: 60,
            color: Colors.grey,
          ),
        );
    }
  }
}

class NonceGenerator {
  static String generateNonce({int length = 32}) {
    final Random random = Random.secure();
    final List<int> values =
        List<int>.generate(length, (i) => random.nextInt(256));

    return base64Url.encode(values);
  }
}
