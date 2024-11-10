import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hydraledger_recorder/models/pdf_save_model.dart';
import 'package:hydraledger_recorder/services/inApp_purchase.dart';
import 'package:hydraledger_recorder/services/sqflite_service.dart';
import 'package:hydraledger_recorder/utils/pdf/pdf_file.dart';
import 'package:hydraledger_recorder/utils/pdf/save_pdf.dart';
import 'package:hydraledger_recorder/widget/app_bar.dart';
import '../../constants/app_constants.dart';
import '../../constants/color_constants.dart';
import '../share_app_view.dart';

class PDFListScreen extends StatefulWidget {
  PDFListScreen({this.cunsumableID, super.key});
  String? cunsumableID;

  @override
  State<PDFListScreen> createState() => _PDFListScreenState();
}

class _PDFListScreenState extends State<PDFListScreen> {
  int? proofLoadingIndex;
  List<String> consumables = [];
  @override
  void initState() {
    super.initState();
    widget.cunsumableID != null ? removeCunsumable() : null;
  }

  Future removeCunsumable() async {
    await ConsumableStore.consume(widget.cunsumableID!);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double statusbarHeight = MediaQuery.of(context).padding.top;
    return KeyboardDismisser(
      child: Scaffold(
          body: Column(
        children: [
          CustomAppBar(title: 'Proofs', actions: [
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: (() {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ShareAppView()));
              }),
            ),
          ]),
          SingleChildScrollView(
            child: SizedBox(
                child: FutureBuilder<List<PDFSaveModel>>(
                    future: DbHelper().fetchPDFDetails(),
                    builder: (context, snapshot) {
                      if (snapshot.data?.isEmpty == true) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Nothing here yet!',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600)),
                              Text('No PDFs Found.',
                                  style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            // log('${snapshot.data![index].name}\n${snapshot.data![index].playPath}\n\n');
                            // return  ListTile(title: Text('${snapshot.data![index].fileName}',),
                            // subtitle: Text('${snapshot.data![index].timeStamp}'));
                            return Slidable(
                              endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) async {
                                        setState(() {
                                          proofLoadingIndex = index;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text('Exporting PDF...'),
                                          duration: Duration(seconds: 2),
                                        ));
                                        await Future.delayed(
                                            Duration(seconds: 1));
                                        PdfAttendanceApi()
                                            .generate(
                                                pdfSaveModel:
                                                    snapshot.data![index])
                                            .then((value) async {
                                          setState(() {
                                            proofLoadingIndex = null;
                                          });
                                          try {
                                            final fileBytes =
                                                await value.readAsBytes();
                                            final fileName = await value.path
                                                .split("/")
                                                .last;

// Get the temporary directory to save the file temporarily
                                            final tempDir =
                                                await getTemporaryDirectory();
                                            final tempFile = File(
                                                '${tempDir.path}/$fileName');

// Write the bytes to the file
                                            await tempFile
                                                .writeAsBytes(fileBytes);

                                            final path = await FileSaver
                                                .instance
                                                .saveFile(
                                              name: fileName,
                                              file:
                                                  tempFile, // Pass the temporary File object here
                                              ext: "pdf",
                                              mimeType: MimeType.pdf,
                                            );

                                            print('Saved to $path');
                                          } catch (error) {
                                            print('Error: $error');
                                          }
                                        });
                                      },
                                      backgroundColor: kColorGold,
                                      foregroundColor: Colors.white,
                                      icon: Icons.save,
                                      label: 'Save',
                                    ),
                                    SlidableAction(
                                      onPressed: (context) async {
                                        setState(() {
                                          proofLoadingIndex = index;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text('Exporting PDF...'),
                                          duration: Duration(seconds: 2),
                                        ));
                                        await Future.delayed(
                                            Duration(seconds: 1));
                                        File pdfFile = await PdfAttendanceApi()
                                            .generate(
                                                pdfSaveModel:
                                                    snapshot.data![index]);
                                        await Share.shareXFiles(
                                            [XFile('pdfFile.path')],
                                            text: 'Proof PDF');
                                        setState(() {
                                          proofLoadingIndex = null;
                                        });
                                      },
                                      backgroundColor: kColorGold,
                                      foregroundColor: Colors.white,
                                      icon: Icons.share,
                                      label: 'Share',
                                    )
                                  ]),
                              startActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) async {
                                        if (await askIfReallyDelete()) {
                                          await DbHelper().removePDFDetails(
                                              snapshot.data![index]);
                                          setState(() {});
                                        }
                                      },
                                      backgroundColor: Color(0xFFFE4A49),
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    ),
                                  ]),
                              child: InkWell(
                                onTap: () async {
                                  setState(() {
                                    proofLoadingIndex = index;
                                  });
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        'Exporting PDF...\nPlease make sure you have a PDF viewer installed (e.g. Google Drive)!'),
                                    duration: Duration(seconds: 2),
                                  ));
                                  await Future.delayed(Duration(seconds: 1));
                                  File pdfFile = await PdfAttendanceApi()
                                      .generate(
                                          pdfSaveModel: snapshot.data![index]);
                                  await SavePdf.openFile(pdfFile);
                                  setState(() {
                                    proofLoadingIndex = null;
                                  });
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (_) => PDFopen(
                                  //               pdfSaveModel: snapshot.data![index],
                                  //             )));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Image.asset('assets/image/pdf.png'),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              child: Text(
                                                '${snapshot.data![index].fileName}',
                                                style: const TextStyle(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              child: Text(
                                                snapshot.data![index].timeStamp
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: proofLoadingIndex == index,
                                        child: Container(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: kColorGold,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                        onTap: () async {
                                          if (!(await askIfReallyDelete()))
                                            return;
                                          await DbHelper().removePDFDetails(
                                              snapshot.data![index]);
                                          setState(() {});
                                        },
                                        child: SvgPicture.asset(
                                            'assets/icons/delete_icon.svg'),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    })),
          ),
        ],
      )),
    );
  }

  Future<bool> askIfReallyDelete() async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete'),
            content: const Text(
                'Are you sure you want to delete this proof? It cannot be undone.'),
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)))),
                        backgroundColor: MaterialStateProperty.all(kColorGold)),
                    child: const Text(
                      "Yes",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}
