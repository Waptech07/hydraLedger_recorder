import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:hydraledger_recorder/models/pdf_save_model.dart';
import 'package:hydraledger_recorder/models/vocie_save_model.dart';
import 'package:hydraledger_recorder/services/sqflite_service.dart';
import 'package:hydraledger_recorder/services/user/user_http.dart';
import 'package:hydraledger_recorder/state/auth_state.dart';
import 'package:hydraledger_recorder/utils/helpers.dart';
import 'package:hydraledger_recorder/utils/pdf/pdf_file.dart';
import 'package:hydraledger_recorder/utils/pdf/save_pdf.dart';
import 'package:hydraledger_recorder/views/event_listing/image_with_blockchain_proof.dart';
import 'package:hydraledger_recorder/views/proof_view/create_proof.dart';
import 'package:hydraledger_recorder/views/witness/add_witness_screen.dart';
import 'package:hydraledger_recorder/views/witness/scan_qr.dart';
import 'package:http/http.dart' as http;

import '../../constants/color_constants.dart';
import '../preview_uplodaded_image_screen.dart';

class EventListScreen extends StatefulWidget {
  final PersistentTabController? controller;

  const EventListScreen({super.key, required this.controller});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  Map<int, bool> isLoadingMap = {};
  int? proofLoadingIndex;
  String? email;
  String? userName;
  UserHttpService userService = UserHttpService();

  DateTime selectedDate = DateTime.now();
  late TextEditingController textEditingController;

  String searchQuery = '';
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    getUserEmail();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void getUserEmail() async {
    final response = await context.read<AuthState>().loadUserData();
    email = response!['email'];
    userName = response['username'];
    log('email: $email');
  }

  List<DateTime> getUniqueDatesWithFiles(List<Map<String, dynamic>> data) {
    Set<DateTime> uniqueDates = data
        .map((item) => DateTime((item['date'] as DateTime).year,
            (item['date'] as DateTime).month, (item['date'] as DateTime).day))
        .toSet();

    List<DateTime> sortedDates = uniqueDates.toList()
      ..sort((a, b) => a.compareTo(b));

    return sortedDates;
  }

  DateTime parseCustomDateTime(String dateString) {
    String reformattedString =
        '${dateString.split(' ')[0].split('.').reversed.join('-')} ${dateString.split(' ')[1]}';
    return DateTime.parse(reformattedString);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Get the current date
    DateTime now = DateTime.now();

    // Generate a list of the next 5 days
    List<DateTime> days =
        List.generate(5, (index) => now.add(Duration(days: index)));

    Future<String?> getUserEmail() async {
      final response = await context.read<AuthState>().loadUserData();
      email = response!['email'];
      log('email: $email');
      return email;
    }

    Future<bool> askIfReallyDelete() async {
      return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete'),
            content: const Text('Are you sure you want to delete this file?'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: SizedBox(
                  width: 80,
                  height: 40,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    style: ButtonStyle(
                      side: MaterialStateProperty.all(
                          const BorderSide(width: 1, color: kColorGold)),
                      shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)))),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: kColorGold, fontSize: 16),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: SizedBox(
                  width: 51,
                  height: 38,
                  child: TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop(true);
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(100),
                          ),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(kColorGold),
                    ),
                    child: const Text(
                      "Yes",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffF3F4F6),
        leadingWidth: 75,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Image.asset('assets/image/half_logo.png'),
        ),
        actions: [
          InkWell(
            onTap: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: ScanQrScreen(),
              );
            },
            child: const Icon(
              Icons.camera,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.notifications_outlined,
            color: Colors.black,
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name of files',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                            isSearching = false;
                          });
                          // Clear the text in the TextField
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            textEditingController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              controller: textEditingController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                  isSearching = value.isNotEmpty;
                });
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: FutureBuilder(
                future: getUserEmail(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Text('No email found');
                  } else {
                    return FutureBuilder(
                      future: Future.wait([
                        userService.getUser(snapshot.data!),
                        DbHelper().fetchProducts(),
                      ]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        Map<String, dynamic> userData =
                            (snapshot.data)?.elementAt(0);

                        List<VoiceSaveModel> voiceSaveModel =
                            (snapshot.data)?.elementAt(1);

                        List<Map<String, dynamic>> combinedData = [];

                        // Add CID data
                        if (userData['cid'] != null) {
                          for (var cidItem in userData['cid']) {
                            combinedData.add({
                              'type': 'cid',
                              'name': cidItem['name'],
                              'cid': cidItem['cid'],
                              'date': parseCustomDateTime(cidItem['date']),
                              'hasCreatedProof':
                                  cidItem['hasTapCreatedProofButton'],
                              'proof': cidItem['proof'],
                              'eventDescription': cidItem['descripton'],
                              'witnesses': cidItem['witnesses'],
                              'username': userData['username'],
                            });
                          }
                        }

                        // Add local storage data
                        for (var localItem in voiceSaveModel) {
                          if (!combinedData
                              .any((item) => item['name'] == localItem.name)) {
                            combinedData.add({
                              'type': 'local',
                              'name': localItem.name,
                              'date': localItem.date,
                              'playPath': localItem.playPath,
                              'hasCreatedProof': localItem.hasCreatedProof,
                              'eventDescription': localItem.eventDescription,
                            });
                          }
                        }

                        List<Map<String, dynamic>> getFilteredData() {
                          return combinedData.where((item) {
                            if (isSearching) {
                              return item['name']
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase());
                            } else {
                              return item['date'].year == selectedDate.year &&
                                  item['date'].month == selectedDate.month &&
                                  item['date'].day == selectedDate.day;
                            }
                          }).toList();
                        }

                        List<DateTime> datesWithFiles =
                            getUniqueDatesWithFiles(combinedData);

                        if (!datesWithFiles.contains(selectedDate)) {
                          selectedDate = datesWithFiles.isNotEmpty
                              ? datesWithFiles.first
                              : DateTime.now();
                        }

                        List<Map<String, dynamic>> filteredData =
                            getFilteredData();

                        Future<void> selectDate(BuildContext context) async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate:
                                getUniqueDatesWithFiles(combinedData).first,
                            lastDate:
                                getUniqueDatesWithFiles(combinedData).last,
                            selectableDayPredicate: (DateTime date) {
                              return getUniqueDatesWithFiles(combinedData)
                                  .contains(DateTime(
                                      date.year, date.month, date.day));
                            },
                          );
                          if (picked != null && picked != selectedDate) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        }

                        void onDateSelected(DateTime date) {
                          setState(() {
                            selectedDate = date;
                            isSearching = false;
                            searchQuery = '';
                          });
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 24.0),
                              child: Text(
                                getGreeting(),
                                style: GoogleFonts.poppins(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xff171A1F),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 55.0,
                              child: Row(
                                children: [
                                  const SizedBox(width: 22.0),
                                  Visibility(
                                    visible: !isSearching,
                                    child: Expanded(
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: datesWithFiles.length,
                                        itemBuilder: (context, index) {
                                          // List<DateTime> sortedDates =
                                          //     getUniqueDatesWithFiles(
                                          //         combinedData)
                                          //       ..sort(
                                          //           (a, b) => b.compareTo(a));

                                          // DateTime day = sortedDates[index];
                                          DateTime day = datesWithFiles[index];
                                          String dayNumber =
                                              DateFormat('d').format(day);
                                          String dayName =
                                              DateFormat('EEE').format(day);

                                          bool isSelected = day.year ==
                                                  selectedDate.year &&
                                              day.month == selectedDate.month &&
                                              day.day == selectedDate.day;

                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedDate = day;
                                                isSearching = false;
                                                searchQuery = '';
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 12.0),
                                              child: Container(
                                                height: 47.0,
                                                width: 56.0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2.0),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? kColorGold
                                                      : const Color(0xffF8F9FA),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      dayNumber,
                                                      style: GoogleFonts.lexend(
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color:
                                                            Color(0xff323743),
                                                      ),
                                                    ),
                                                    Text(
                                                      dayName,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color:
                                                            Color(0xff565D6D),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      List<DateTime> uniqueDates =
                                          getUniqueDatesWithFiles(combinedData);

                                      uniqueDates.sort();

                                      DateTime lastDate = uniqueDates.last;

                                      DateTime adjustedSelectedDate =
                                          selectedDate.isAfter(lastDate)
                                              ? lastDate
                                              : selectedDate;

                                      final DateTime? picked =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: adjustedSelectedDate,
                                        firstDate: uniqueDates.first,
                                        lastDate: lastDate,
                                        selectableDayPredicate:
                                            (DateTime date) {
                                          return uniqueDates.contains(DateTime(
                                              date.year, date.month, date.day));
                                        },
                                      );

                                      if (picked != null &&
                                          picked != selectedDate) {
                                        onDateSelected(picked);
                                      }
                                    },
                                    child: const Icon(Icons.calendar_month),
                                  ),
                                  const SizedBox(width: 9.0),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18.0),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14.0),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 14.0),
                              decoration: const BoxDecoration(
                                color: Color(0xffFAFAFB),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 24.0),
                                    child: Text(
                                      'NAME',
                                      style: GoogleFonts.lexend(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xff565D6D),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24.0),
                                  Divider(
                                    color: Colors.black.withOpacity(0.4),
                                    height: 2,
                                  ),
                                  const SizedBox(height: 24.0),
                                  RefreshIndicator(
                                    onRefresh: () async {
                                      await userService.getUser(email ?? '');
                                      await DbHelper().fetchProducts();
                                      setState(() {});
                                    },
                                    child: SizedBox(
                                      height: size.height * 0.58,
                                      child: FutureBuilder(
                                        future: getUserEmail(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else if (!snapshot.hasData ||
                                              snapshot.data == null) {
                                            return const Text('No email found');
                                          } else {
                                            return FutureBuilder(
                                              future: Future.wait([
                                                userService
                                                    .getUser(snapshot.data!),
                                                DbHelper().fetchProducts(),
                                              ]),
                                              builder:
                                                  (context, localSnapshot) {
                                                final localItems =
                                                    localSnapshot.data?[1];
                                                log('local data: ${localItems}');
                                                if (!snapshot.hasData) {
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator());
                                                }

                                                return filteredData.isEmpty
                                                    ? const SizedBox()
                                                    : ListView.builder(
                                                        itemCount:
                                                            filteredData.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final item =
                                                              filteredData[
                                                                  index];

                                                          return Padding(
                                                            padding: EdgeInsets.only(
                                                                bottom: index ==
                                                                        filteredData.length -
                                                                            1
                                                                    ? 50
                                                                    : 12),
                                                            child: Slidable(
                                                              endActionPane:
                                                                  ActionPane(
                                                                motion:
                                                                    const ScrollMotion(),
                                                                children: [
                                                                  SlidableAction(
                                                                    onPressed:
                                                                        (context) {
                                                                      log('voice length: ${voiceSaveModel.length}');
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                        builder:
                                                                            (context) {
                                                                          return AddWitnessScreen(
                                                                            controller:
                                                                                widget.controller,
                                                                            voiceSaveModel: item['type'] != 'cid'
                                                                                ? voiceSaveModel[1]
                                                                                : null,
                                                                            imageData: item['type'] == 'cid'
                                                                                ? item['cid']
                                                                                : item['playPath'],
                                                                            item:
                                                                                item,
                                                                          );
                                                                        },
                                                                      ));
                                                                    },
                                                                    icon: Icons
                                                                        .qr_code,
                                                                    backgroundColor:
                                                                        kColorGold,
                                                                    foregroundColor:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                                  SlidableAction(
                                                                    onPressed:
                                                                        (context) async {
                                                                      item['type'] ==
                                                                              'cid'
                                                                          ? null
                                                                          : await Share
                                                                              .shareXFiles([
                                                                              item['playPath'] ?? 'assets/image/recorder_icon.png'
                                                                            ]);
                                                                    },
                                                                    backgroundColor:
                                                                        kColorGold,
                                                                    foregroundColor:
                                                                        Colors
                                                                            .white,
                                                                    icon: Icons
                                                                        .share,
                                                                  )
                                                                ],
                                                              ),
                                                              startActionPane:
                                                                  item['type'] !=
                                                                          'cid'
                                                                      ? ActionPane(
                                                                          motion:
                                                                              const ScrollMotion(),
                                                                          children: [
                                                                            SlidableAction(
                                                                              onPressed: (context) async {
                                                                                if (await askIfReallyDelete()) {
                                                                                  if (item['type'] != 'cid') {
                                                                                    VoiceSaveModel voiceModel = VoiceSaveModel(
                                                                                      name: item['name'],
                                                                                      date: item['date'],
                                                                                      playPath: item['playPath'],
                                                                                      hasCreatedProof: item['hasCreatedProof'] ?? false,
                                                                                      eventDescription: item['eventDescription'] ?? '',
                                                                                    );

                                                                                    bool deleted = await DbHelper().removeVoice(voiceModel);
                                                                                    if (deleted) {
                                                                                      setState(() {
                                                                                        filteredData.removeWhere((data) => data['name'] == item['name']);
                                                                                      });
                                                                                    } else {
                                                                                      // Show an error message if deletion failed
                                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                                        const SnackBar(content: Text('Failed to delete the item')),
                                                                                      );
                                                                                    }
                                                                                  }
                                                                                }
                                                                              },
                                                                              backgroundColor: Color(0xFFFE4A49),
                                                                              foregroundColor: Colors.white,
                                                                              icon: Icons.delete,
                                                                              label: 'Delete',
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : null,
                                                              child: ListTile(
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            12.0,
                                                                        right:
                                                                            8.0),
                                                                minLeadingWidth:
                                                                    0,
                                                                minVerticalPadding:
                                                                    0,
                                                                leading:
                                                                    InkWell(
                                                                  onTap: () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) {
                                                                          return PreviewUploadedContent(
                                                                            item:
                                                                                item,
                                                                          );
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        40.0,
                                                                    width: 40.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: const Color(
                                                                          0xffFFEAC5),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              4.0),
                                                                    ),
                                                                    child: item['type'] ==
                                                                            'cid'
                                                                        ? DynamicMediaThumbnail(
                                                                            url:
                                                                                'https://gateway.lighthouse.storage/ipfs/${item['cid']}',
                                                                            height:
                                                                                40.0,
                                                                            width:
                                                                                40.0,
                                                                          )
                                                                        : getImageWidget(
                                                                            path:
                                                                                item['playPath'],
                                                                          ),
                                                                  ),
                                                                ),
                                                                title: Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          12.0,
                                                                      right:
                                                                          32.0),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        flex: 8,
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () {
                                                                            PersistentNavBarNavigator.pushNewScreen(
                                                                              context,
                                                                              screen: ImageWithBlockchainProof(
                                                                                item: item,
                                                                                email: email,
                                                                                userName: userName,
                                                                              ),
                                                                              withNavBar: false,
                                                                            );
                                                                          },
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                item['name'],
                                                                                maxLines: 2,
                                                                                style: GoogleFonts.poppins(
                                                                                  fontSize: 14.0,
                                                                                  fontWeight: FontWeight.w700,
                                                                                  color: const Color(0xff171A1F),
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                DateFormat("dd.MM.yyyy").format(item['date']),
                                                                                style: GoogleFonts.poppins(
                                                                                  fontSize: 12.0,
                                                                                  fontWeight: FontWeight.w700,
                                                                                  color: const Color(0xff565D6D),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              24),
                                                                      Visibility(
                                                                        visible:
                                                                            proofLoadingIndex !=
                                                                                index,
                                                                        child: Expanded(
                                                                            flex: 6,
                                                                            child: FutureBuilder<bool>(
                                                                              future: Future.value(item['hasCreatedProof'] ?? false),
                                                                              builder: (context, snapshot) {
                                                                                bool hasProof = snapshot.data ?? false;

                                                                                log('this content hasProof: $hasProof');

                                                                                return FutureBuilder(
                                                                                  future: DbHelper().getPDFsForFilename(item['name']),
                                                                                  builder: (context, btnsnapshot) {
                                                                                    return TextButton(
                                                                                      onPressed: () async {
                                                                                        if (hasProof) {
                                                                                          if (item['name'] == "Sample-File.aac") {
                                                                                            log('first');
                                                                                            setState(() {
                                                                                              proofLoadingIndex = index;
                                                                                            });
                                                                                            log('second');

                                                                                            scaffoldMessengerKey.currentState!.showSnackBar(const SnackBar(
                                                                                              content: Text('Exporting PDF...\nPlease make sure you have a PDF viewer installed (e.g. Google Drive)!'),
                                                                                              duration: Duration(seconds: 2),
                                                                                            ));
                                                                                            log('third');
                                                                                            await Future.delayed(const Duration(seconds: 1));
                                                                                            File pdfFile = await PdfAttendanceApi().generate(
                                                                                              pdfSaveModel: btnsnapshot.data![0],
                                                                                              voiceSaveModel: null,
                                                                                              imageData: item['playPath'],
                                                                                              item: item,
                                                                                            );
                                                                                            log('fourth');
                                                                                            await SavePdf.openFile(pdfFile);
                                                                                            log('fifth');
                                                                                            setState(() {
                                                                                              proofLoadingIndex = null;
                                                                                            });
                                                                                          } else {
                                                                                            Map<String, dynamic> proof = item['proof'];

                                                                                            setState(() {
                                                                                              proofLoadingIndex = index;
                                                                                            });

                                                                                            scaffoldMessengerKey.currentState!.showSnackBar(const SnackBar(
                                                                                              content: Text('Exporting PDF...\nPlease make sure you have a PDF viewer installed (e.g. Google Drive)!'),
                                                                                              duration: Duration(seconds: 2),
                                                                                            ));
                                                                                            await Future.delayed(const Duration(seconds: 1));
                                                                                            File pdfFile = await PdfAttendanceApi().generate(
                                                                                              pdfSaveModel: PDFSaveModel(
                                                                                                userName: userName,
                                                                                                description: item['eventDescription'],
                                                                                                fileName: item['name'],
                                                                                                bcExplorer: 'https://explorer.hydraledger.tech/transaction/${proof['tx_id']}',
                                                                                                email: email,
                                                                                                hash: proof['media_hash'],
                                                                                                registeredContent: proof['media_hash'],
                                                                                                timeStamp: DateFormat("dd.MM.yyyy HH:mm:ss").format(item['date']),
                                                                                                transactionID: proof['tx_id'],
                                                                                                bcProof: proof['bc_proof'],
                                                                                              ),
                                                                                              voiceSaveModel: item['type'] != 'cid' ? voiceSaveModel[1] : null,
                                                                                              imageData: item['type'] == 'cid' ? item['cid'] : item['playPath'],
                                                                                              item: item,
                                                                                            );
                                                                                            await SavePdf.openFile(pdfFile);
                                                                                            setState(() {
                                                                                              proofLoadingIndex = null;
                                                                                            });
                                                                                          }
                                                                                        } else {
                                                                                          Navigator.push(
                                                                                            context,
                                                                                            MaterialPageRoute(
                                                                                              builder: (context) {
                                                                                                return CreateProofView(
                                                                                                  assetPath: item['playPath'],
                                                                                                  voiceName: item['name'],
                                                                                                  controller: widget.controller,
                                                                                                  item: item,
                                                                                                );
                                                                                              },
                                                                                            ),
                                                                                          );
                                                                                        }
                                                                                      },
                                                                                      style: ButtonStyle(
                                                                                        shape: MaterialStateProperty.all(
                                                                                          const RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.all(
                                                                                              Radius.circular(100),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        backgroundColor: MaterialStateProperty.all(
                                                                                            // btnsnapshot.data?.isEmpty ?? true
                                                                                            !hasProof ? kColorDarkBlue : kColorGold),
                                                                                      ),
                                                                                      child: Center(
                                                                                        child: Text(
                                                                                          hasProof ? 'Show proof' : 'Create proof',
                                                                                          textAlign: TextAlign.center,
                                                                                          style: GoogleFonts.poppins(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.w400,
                                                                                            color: Colors.white,
                                                                                            // decoration: TextDecoration.underline,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                );
                                                                              },
                                                                            )),
                                                                      ),
                                                                      Visibility(
                                                                        visible:
                                                                            proofLoadingIndex ==
                                                                                index,
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              20,
                                                                          width:
                                                                              20,
                                                                          child:
                                                                              const CircularProgressIndicator(
                                                                            strokeWidth:
                                                                                2,
                                                                            color:
                                                                                kColorGold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                              },
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String getGreeting() {
  DateTime now = DateTime.now();
  int hour = now.hour;

  if (hour >= 5 && hour < 12) {
    return 'Good morning!';
  } else if (hour >= 12 && hour < 17) {
    return 'Good afternoon!';
  } else {
    return 'Good evening!';
  }
}

Widget getImageWidget({
  required String path,
}) {
  if (path.endsWith('.png') ||
      path.endsWith('.jpg') ||
      path.endsWith('.jpeg')) {
    return Image.file(
      File(path),
      fit: BoxFit.cover,
    );
  } else if (path.endsWith('.mp3') ||
      path.endsWith('.wav') ||
      path.endsWith('.m4a')) {
    return Image.asset(
      'assets/image/recorder_icon.png',
      fit: BoxFit.cover,
    );
  } else {
    return Icon(Icons.help_outline); // Fallback for unknown file types
  }
}

class DynamicMediaThumbnail extends StatefulWidget {
  final String url;
  final double height;
  final double width;

  const DynamicMediaThumbnail({
    Key? key,
    required this.url,
    this.height = 40.0,
    this.width = 40.0,
  }) : super(key: key);

  @override
  _DynamicMediaThumbnailState createState() => _DynamicMediaThumbnailState();
}

class _DynamicMediaThumbnailState extends State<DynamicMediaThumbnail> {
  late Future<String> _contentTypeFuture;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _contentTypeFuture = _getContentType();
  }

  Future<String> _getContentType() async {
    final response = await http.head(Uri.parse(widget.url));
    log('content type: ${response.headers['content-type']}');
    return response.headers['content-type'] ?? '';
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _contentTypeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: widget.height,
            width: widget.width,
            child: SizedBox(
                height: 8, width: 8, child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return SizedBox(
            height: widget.height,
            width: widget.width,
            child: Center(child: Icon(Icons.error)),
          );
        } else {
          final contentType = snapshot.data ?? '';
          if (contentType.startsWith('image/')) {
            return Image.network(
              widget.url,
              height: widget.height,
              width: widget.width,
              fit: BoxFit.cover,
            );
          } else if (contentType.startsWith('video/')) {
            _videoController ??=
                VideoPlayerController.networkUrl(Uri.parse(widget.url))
                  ..initialize().then((_) {
                    setState(() {});
                  });
            return _videoController!.value.isInitialized
                ? SizedBox(
                    height: widget.height,
                    width: widget.width,
                    child: VideoPlayer(_videoController!),
                  )
                : SizedBox(
                    height: widget.height,
                    width: widget.width,
                    child: SizedBox(
                        height: 8,
                        width: 8,
                        child: CircularProgressIndicator()),
                  );
          } else if (contentType.startsWith('audio/')) {
            return Image.asset(
              'assets/image/recorder_icon.png',
              height: widget.height,
              width: widget.width,
              fit: BoxFit.cover,
            );
          } else {
            return SizedBox(
              height: widget.height,
              width: widget.width,
              child: Center(child: Icon(Icons.help_outline)),
            );
          }
        }
      },
    );
  }
}
