import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hydraledger_recorder/api/subscriptionmanager.dart';
import 'package:hydraledger_recorder/constants/color_constants.dart';
import 'package:hydraledger_recorder/models/pdf_save_model.dart';
import 'package:hydraledger_recorder/models/vocie_save_model.dart';
import 'package:hydraledger_recorder/services/event_upload/update_cid_http.dart';
import 'package:hydraledger_recorder/services/inApp_purchase.dart';
import 'package:hydraledger_recorder/services/network_checker.dart';
import 'package:hydraledger_recorder/services/sqflite_service.dart';
import 'package:hydraledger_recorder/services/user/user_http.dart';
import 'package:hydraledger_recorder/state/auth_state.dart';
import 'package:hydraledger_recorder/globals.dart' as globals;
import 'package:hydraledger_recorder/views/banner_ad.dart';
import 'package:hydraledger_recorder/widget/my_snackbar.dart';
import '../witness/add_witness_screen.dart';

final bool _kAutoConsume = Platform.isIOS || true;

class CreateProofView extends StatefulWidget {
  CreateProofView({
    this.voiceName,
    this.hash,
    required this.assetPath,
    required this.controller,
    this.item,
    Key? key,
  }) : super(key: key);

  String? voiceName;
  String? hash;
  final String? assetPath;
  final Map<String, dynamic>? item;

  final PersistentTabController? controller;

  @override
  State<CreateProofView> createState() => _CreateProofViewState();
}

class _CreateProofViewState extends State<CreateProofView> {
  TextEditingController firstNameController = TextEditingController();

  TextEditingController lastNameController = TextEditingController();

  TextEditingController controllerMail = TextEditingController();

  TextEditingController controllerDescription = TextEditingController();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  late StreamSubscription<List<PurchaseDetails>> _subscription;

  List<String> _notFoundIds = <String>[];

  List<ProductDetails> _products = [];

  List<PurchaseDetails> _purchases = <PurchaseDetails>[];

  List<String> _consumables = [];

  bool isClicked = false;

  bool isSubClicked = false;

  bool _isAvailable = false;

  bool _purchasePending = false;

  bool _loading = true;

  bool _subLoading = true;

  bool paid = false;

  String? _queryProductError;

  bool isPurchased = false;

  VoiceSaveModel? voiceSaveModelSelected;

  late SharedPreferences preferences;

  bool hasInternet = false;

  String consumablePrice = "";
  String yearlyPrice = "";
  String monthlyPrice = "";

  String username = '';
  bool? isSubscribed;

  @override
  void initState() {
    super.initState();
    var startTime = DateTime.now();
    getFirstAndLastNames();

    var endTime = DateTime.now();
    var difference = endTime.difference(startTime);

    log('Time taken: ${difference.inMilliseconds} ms');
    // loadPrices();
    // SubscriptionManager().reloadActiveSubscriptions();
    NetworkChecker().shouldProceed(context).then((value) {
      setState(() {
        hasInternet = value;
      });
    });
    log('item: ${widget.item}');
  }

  void getFirstAndLastNames() async {
    final authState = AuthState.instance;
    final response = await authState!.loadUserData();

    firstNameController.text = response!['first_name'];
    lastNameController.text = response['last_name'];
    controllerMail.text = response['email'];
    username = response['username'];
    isSubscribed = response['subscribed'];
  }

  void loadPrices() async {
    if (await SubscriptionManager()
            .getStorePackage(globals.kYearlySubscriptionId()) !=
        null) {
      yearlyPrice = (await SubscriptionManager()
              .getStorePackage(globals.kYearlySubscriptionId()))!
          .storeProduct
          .priceString;
      setState(() {});
    } else {
      print("Couldn't fetch store package!");
    }
    if (await SubscriptionManager()
            .getStorePackage(globals.kMontlySubscriptionId()) !=
        null) {
      monthlyPrice = (await SubscriptionManager()
              .getStorePackage(globals.kMontlySubscriptionId()))!
          .storeProduct
          .priceString;
      setState(() {});
    } else {
      print("Couldn't fetch store package!");
    }
    if ((await Purchases.getProducts([globals.kConsumableId],
            productCategory: ProductCategory.nonSubscription))
        .isNotEmpty) {
      consumablePrice = (await Purchases.getProducts([globals.kConsumableId],
              productCategory: ProductCategory.nonSubscription))
          .first
          .priceString; // JIMMY was here!!!
      setState(() {});
    } else {
      print("Couldn't fetch store package!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: const Color(0xffFFFFFF),
        appBar: AppBar(
          backgroundColor: const Color(0xffFFFFFF),
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.chevron_left,
              size: 40,
              color: Color(0xff9095A1),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 32, right: 32, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Proof details",
                  style: GoogleFonts.poppins(
                    color: Color(0xff163252),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Name *',
                  textAlign: TextAlign.start,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xffBDC1CA),
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: firstNameController,
                        readOnly: true,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xffBDC1CA),
                        ),
                        decoration: InputDecoration(
                          hintText: 'First',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xffBDC1CA),
                          ),
                          prefixIcon: const Icon(
                            Icons.person,
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
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: TextFormField(
                        controller: lastNameController,
                        readOnly: true,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xffBDC1CA),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Last',
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
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Email *',
                  textAlign: TextAlign.start,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xffBDC1CA),
                  ),
                ),
                SizedBox(height: 6),
                TextFormField(
                  controller: controllerMail,
                  readOnly: true,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xffBDC1CA),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter email',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xffBDC1CA),
                    ),
                    prefixIcon: Icon(
                      Icons.email,
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
                SizedBox(height: 20),
                // Text(
                //   "Describe your event",
                //   style: GoogleFonts.poppins(
                //     color: Color(0xff163252),
                //     fontSize: 16,
                //     fontWeight: FontWeight.w700,
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(top: 8),
                //   child: TextField(
                //     controller: controllerDescription,
                //     cursorColor: const Color(0xff000000),
                //     keyboardType: TextInputType.multiline,
                //     maxLines: 7,
                //     maxLength: 700,
                //     style: GoogleFonts.poppins(
                //       color: Color(0xffBDC1CA),
                //       fontSize: 16,
                //     ),
                //     decoration: InputDecoration(
                //       hintStyle: GoogleFonts.poppins(
                //         color: Color(0xffBDC1CA),
                //         fontSize: 16,
                //       ),
                //       hintText: "Description (up to 700 characters)",
                //       fillColor: Colors.blue,
                //       border: OutlineInputBorder(),
                //       enabledBorder: OutlineInputBorder(
                //         borderSide:
                //             BorderSide(color: Color(0xff9095A1), width: 1.0),
                //       ),
                //       counterText: '',
                //     ),
                //     onChanged: (text) {
                //       if (text.length > 700) {
                //         controllerDescription.text = text.substring(0, 700);
                //         controllerDescription.selection =
                //             TextSelection.fromPosition(
                //           TextPosition(offset: 700),
                //         );
                //       }
                //     },
                //   ),
                // ),
                const SizedBox(height: 11),
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xff0E2035),
                      size: 24.0,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Once you confirm, above mentioned details\ncannot be modified",
                      style:
                          GoogleFonts.poppins(color: kColorGold, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: purchaseButton(context),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> showCreateProofPopup() async {
    var currentDetails = await SubscriptionManager().getSubscriptionDetails();
    if (context.mounted) {
      return await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Create proof'),
                content: const Text('Please select a purchase option.'),
                actions: [
                  ListTile(
                    title: Text("Pay per use:"),
                    subtitle: Text("1 proof included"),
                    trailing: Text(
                      consumablePrice,
                      style: TextStyle(color: kColorDarkBlue),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop(true);
                      if (!(await NetworkChecker().shouldProceed(context))) {
                        setState(() {
                          isClicked = false;
                        });
                        return;
                      }
                      debugPrint("Purchasing...");
                      if (firstNameController.text.trim().isEmpty ||
                          controllerDescription.text.trim().isEmpty ||
                          controllerMail.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill out all the fields'),
                          ),
                        );
                        setState(() {
                          isClicked = false;
                        });
                        return;
                      }

                      List<StoreProduct> products = await Purchases.getProducts(
                          [globals.kConsumableId],
                          productCategory: ProductCategory.nonSubscription);

                      if (products.isEmpty) {
                        setState(() {
                          isClicked = false;
                        });
                        snackbarShow(
                            context: context,
                            text:
                                'An error occured while fetching the product. Please try again later.');

                        return;
                      }

                      bool success = true;
                      print("Purchasing oneTime");
                      try {
                        await Purchases.purchaseStoreProduct(products.first);
                      } catch (e) {
                        print("Error: $e");
                        setState(() {
                          isClicked = false;
                        });
                        snackbarShow(
                            context: context,
                            text:
                                'An error occured while purchasing the product. Please try again later.');

                        success = false;
                      }
                      if (!success) return;
                      // processSuccessfulPurchase();
                      setState(() {
                        isClicked = false;
                      });
                    },
                  ),
                  AbsorbPointer(
                    absorbing: currentDetails?.proofsLeft == 0,
                    child: Opacity(
                      opacity: currentDetails?.proofsLeft == 0 ? 0.5 : 1,
                      child: Column(
                        children: [
                          ListTile(
                            trailing: Text(
                              monthlyPrice,
                              style: TextStyle(color: kColorDarkBlue),
                            ),
                            title: Text("Pay per month:"),
                            subtitle: Text("5 proofs included"),
                            onTap: () {
                              Navigator.of(context).pop(true);
                              startSubscriptionPurchase(
                                  SubscriptionType.monthly);
                            },
                          ),
                          ListTile(
                            trailing: Text(
                              yearlyPrice,
                              style: TextStyle(color: kColorDarkBlue),
                            ),
                            title: Text("Pay per year:"),
                            subtitle: Text("100 proofs included"),
                            onTap: () async {
                              Navigator.of(context).pop(true);
                              startSubscriptionPurchase(
                                  SubscriptionType.yearly);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
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
                ],
              );
            },
          ) ??
          false;
    }

    return false;
  }

  MaterialButton purchaseButton(BuildContext context) {
    return MaterialButton(
      height: 52,
      minWidth: 210,
      onPressed: () async {
        setState(() {
          isClicked = true;
        });
        // String? deviceId = await getDeviceId();
        // EventUploadHttpService eventUploadService = EventUploadHttpService();
        // final request = await eventUploadService.eventUpload(
        //     widget.item!['type'] == 'cid'
        //         ? await downloadAndSaveImage(
        //             'https://gateway.lighthouse.storage/ipfs/${widget.item!['cid']}')
        //         : widget.assetPath ?? '',
        //     deviceId);
        // if (request != null) {
        //   setState(() {
        //     isClicked = false;
        //   });
        //   if (widget.item!['type'] == 'cid') {
        //     await DbHelper().updateFs3ProofStatus(widget.item!['cid'], true);
        //   }
        //   await DbHelper()
        //       .updateProofCreatedStatus(widget.voiceName ?? '', true);

        //   if (widget.item!['type'] == 'cid') {
        //     await DbHelper().updateFs3MediaDetails(
        //       widget.item!['cid'],
        //       controllerDescription.text,
        //     );
        //   }
        //   await DbHelper().updateVoiceProofDetails(
        //     widget.voiceName ?? '',
        //     request,
        //     eventDescription: controllerDescription.text,
        //   );

        //   log('response from event upload: $request');

        //   await processSuccessfulPurchase(request, deviceId ?? '');
        //   await DbHelper().fetchProducts();
        //   setState(() {});

        // if (context.mounted) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       backgroundColor: Colors.green,
        //       content: Text('Proof was created successfully'),
        //     ),
        //   );
        //   Future.delayed(const Duration(seconds: 2), () {
        //     return Navigator.pushReplacement(context, MaterialPageRoute(
        //       builder: (context) {
        //         return AddWitnessScreen(
        //           controller: widget.controller!,
        //           imageData: widget.item!['type'] == 'cid'
        //               ? widget.item!['cid']
        //               : widget.assetPath,
        //           item: widget.item,
        //         );
        //       },
        //     ));
        //   });
        //   setState(() {});
        // }
        // }

        UserHttpService userHttpService = UserHttpService();
        final udateTapRequest = await userHttpService.updateUserTap(
          username,
          widget.item!['cid'],
        );

        if (udateTapRequest['status'] == 'success') {
          setState(() {
            isClicked = false;
          });
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text('Proof was created successfully'),
              ),
            );
            //this will remove the Ads
            // Future.delayed(const Duration(seconds: 2), () {
            //   return Navigator.pushReplacement(context, MaterialPageRoute(
            //     builder: (context) {
            //       return AddWitnessScreen(
            //         controller: widget.controller!,
            //         imageData: widget.item!['type'] == 'cid'
            //             ? widget.item!['cid']
            //             : widget.assetPath,
            //         item: widget.item,
            //       );
            //     },
            //   ));
            // });

            //Uncomment this if/else to add the Ads back
            if (isSubscribed!) {
              Future.delayed(const Duration(seconds: 2), () {
                return Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) {
                    return AddWitnessScreen(
                      controller: widget.controller!,
                      imageData: widget.item!['type'] == 'cid'
                          ? widget.item!['cid']
                          : widget.assetPath,
                      item: widget.item,
                    );
                  },
                ));
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyBannerAdWidget(
                    shouldNavigate: false,
                    callback: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) {
                          return AddWitnessScreen(
                            controller: widget.controller!,
                            imageData: widget.item!['type'] == 'cid'
                                ? widget.item!['cid']
                                : widget.assetPath,
                            item: widget.item,
                          );
                        },
                      ));
                    },
                  ),
                ),
              );
            }

            setState(() {});
          }
        } else {
          setState(() {
            isClicked = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('An error occured'),
            ),
          );
        }

        setState(() {
          isClicked = false;
        });

        // if (isClicked) return;
        // if (await NetworkChecker().shouldProceed(context) == false) return;
        // FocusScopeNode currentFocus = FocusScope.of(context);

        // if (!currentFocus.hasPrimaryFocus) {
        //   currentFocus.unfocus();
        // }
        // if (firstNameController.text.trim().isEmpty ||
        //     controllerDescription.text.trim().isEmpty ||
        //     controllerMail.text.trim().isEmpty) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text('Please fill out all the fields'),
        //     ),
        //   );
        //   return;
        // }
        // var subData = await SubscriptionManager().getSubscriptionDetails();
        // if (subData == null) {
        //   setState(() {
        //     isClicked = true;
        //   });

        //   if (await showCreateProofPopup()) return;
        //   setState(() {
        //     isClicked = false;
        //   });
        // } else {
        //   if (subData.subscriptionDue.isBefore(DateTime.now()) ||
        //       subData.proofsLeft == 0) {
        //     setState(() {
        //       isClicked = true;
        //     });

        //     if (await showCreateProofPopup()) return;
        //     setState(() {
        //       isClicked = false;
        //     });
        //   } else {
        //     setState(() {
        //       isClicked = true;
        //     });
        //     if (await SubscriptionManager().useSubscriptionProof()) {
        //       print("Using subscription proof 500");
        //       processSuccessfulPurchase();
        //     }
        //   }
        // }
      },
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(
            color: Color(0xff323743),
            width: 1,
          )),
      color: (isClicked || !hasInternet) ? Colors.grey : kColorGold,
      child: isClicked
          ? const Center(
              child: Text(
              "Pending...",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ))
          : const Text(
              "Create Proof",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
    );
  }

  void startSubscriptionPurchase(SubscriptionType type) async {
    print("startSubscriptionPurchase(SubscriptionType type)");
    setState(() {
      isSubClicked = true;
    });
    if (!(await NetworkChecker().shouldProceed(context))) {
      setState(() {
        isSubClicked = false;
      });
      return;
    }

    if (firstNameController.text.trim().isEmpty ||
        controllerDescription.text.trim().isEmpty ||
        controllerMail.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all the fields'),
        ),
      );
      setState(() {
        isSubClicked = false;
      });
      return;
    }

    if (await SubscriptionManager().useSubscriptionProof()) {
      print("Using subscription proof 579");
      print("Will use subscription proof...");
      // processSuccessfulPurchase();
      return;
    } else {
      print("No subscription found or no proof left.");
      if (await SubscriptionManager().getSubscriptionDetails() != null) {
        snackbarShow(
            context: context,
            text:
                'You have no proofs left. Please use single purchase instead.');
        setState(() {
          isSubClicked = false;
        });
        return;
      }
    }

    print("Purchasing...");
    Package? pkg = await SubscriptionManager().getStorePackage(
        type == SubscriptionType.monthly
            ? globals.kMontlySubscriptionId()
            : globals.kYearlySubscriptionId());
    if (pkg == null) {
      setState(() {
        isSubClicked = false;
      });
      snackbarShow(
          context: context,
          text:
              'An error occured while fetching the product. Please try again later.');

      return;
    }
    EntitlementInfo? entitlementInfo =
        (await SubscriptionManager().buyProduct(pkg));
    if (entitlementInfo != null) {
      await SubscriptionManager()
          .enableSubscription(type, false, entitlementInfo);
      await SubscriptionManager().useSubscriptionProof();
      // processSuccessfulPurchase();
    } else {
      setState(() {
        isSubClicked = false;
        isClicked = false;
      });
      snackbarShow(
          context: context,
          text:
              'An error occured while purchasing the product. Please try again later.');

      return;
    }
  }

  Future<void> processSuccessfulPurchase(
      Map<String, dynamic> proofDetails, String deviceId) async {
    print("processSuccessfulPurchase()");
    // var txid = await HashHelper().tryAddHashToBC(widget.hash.toString());
    // if (txid == null) {
    //   snackbarShow(
    //       context: context,
    //       text:
    //           'An fatal error occured while registering your hash. Retrying...\nIf this error persists, please contact us.');
    //   processSuccessfulPurchase(proofDetails);
    //   return;
    // }

    final String bcProof = proofDetails['bc_proof'];

    UpdateCIDHttpService updateCIDHttpService = UpdateCIDHttpService();
    final authState = AuthState.instance;
    final response = await authState!.loadUserData();
    final username = response!['username'];
    final cidUpdate = await updateCIDHttpService.updateCID(
      username: username,
      cid: widget.item!['cid'],
      name: widget.voiceName,
      date: DateFormat("dd.MM.yyyy HH:mm:ss").format(DateTime.now()),
      txId: proofDetails['tx_id'],
      bcProof: bcProof,
      mediaHash: proofDetails['media_hash'],
      deviceId: deviceId,
    );

    if (cidUpdate['status'] == 'success') {
      DbHelper.internal()
          .insertPDFDetails(
        PDFSaveModel(
          userName: firstNameController.text,

          /// A function that is called when the user clicks the button.
          description: controllerDescription.text,
          fileName: widget.voiceName,
          bcExplorer:
              'https://explorer.hydraledger.tech/transaction/${proofDetails['tx_id']}',
          // bcExplorer: globals.netMode == NetMode.dev
          // ? 'https://dev.explorer.hydraledger.tech/transaction/$bcProof'
          // : 'https://explo'${textController.text.trim().replaceAll('-', '').replaceAll(':', '')}$extention'rer.hydraledger.tech/transaction/$bcProof',
          email: controllerMail.text,
          hash: proofDetails['media_hash'],
          registeredContent: proofDetails['media_hash'],
          timeStamp: DateFormat("dd.MM.yyyy HH:mm:ss").format(DateTime.now()),
          transactionID: proofDetails['tx_id'],
          bcProof: proofDetails['bc_proof'],
        ),
      )
          .then((value) {
        snackbarShow(
            context: context,
            text:
                'A PDF proof has been generated. It can be downloaded by tapping on the "Show Proof"! on the homepage\nPlease save the file in external storage to prevent data loss.');
        tryRate();
      });
    }
  }

  Future<void> consume(String id) async {
    print('Consuming $id');
    await ConsumableStore.consume(id);

    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _consumables = consumables;
    });
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  void tryRate() async {
    final InAppReview inAppReview = InAppReview.instance;
    if ((await inAppReview.isAvailable())) {
      inAppReview.requestReview();
    }
  }
}
