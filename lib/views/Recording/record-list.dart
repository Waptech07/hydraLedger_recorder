// // ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages
// import 'dart:developer';
// import 'dart:io';

// import 'package:cr_file_saver/file_saver.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:intl/intl.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:share/share.dart';
// import 'package:hydraledger_recorder/constants/color_constants.dart';
// import 'package:hydraledger_recorder/models/vocie_save_model.dart';
// import 'package:hydraledger_recorder/services/event_upload/event_upload_http.dart';
// import 'package:hydraledger_recorder/services/sqflite_service.dart';
// import 'package:hydraledger_recorder/utils/helpers.dart';
// import 'package:hydraledger_recorder/views/Recording/stop_record_view.dart';
// import 'package:hydraledger_recorder/widget/app_bar.dart';
// import 'package:hydraledger_recorder/widget/my_snackbar.dart';

// import '../share_app_view.dart';

// class RecordFileList extends StatefulWidget {
//   const RecordFileList({Key? key}) : super(key: key);

//   @override
//   State<RecordFileList> createState() => _RecordFileListState();
// }

// class _RecordFileListState extends State<RecordFileList> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   bool isLoading = false;
//   Map<int, bool> isLoadingMap = {};

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final height = MediaQuery.of(context).size.height;
//     // final PurchaseDetails? previousPurchase = purchases['prooff'];
//     return SafeArea(
//       child: Scaffold(
//         body: Column(
//           children: [
//             CustomAppBar(
//               title: 'Record File List',
//               actions: [
//                 IconButton(
//                     icon: Icon(Icons.info_outline),
//                     onPressed: (() {
//                       Navigator.of(context).push(MaterialPageRoute(
//                           builder: (context) => ShareAppView()));
//                     }))
//               ],
//             ),
//             // ListTile(
//             //   leading: Padding(
//             //     padding: const EdgeInsets.only(top: 5),
//             //     child: SvgPicture.asset("assets/icons/back_arrow.svg",
//             //         color: const Color(0xff7F0D51)),
//             //   ),
//             //   title: Padding(
//             //     padding: EdgeInsets.only(
//             //       left: MediaQuery.of(context).size.width * 0.1,
//             //     ),
//             //     child: const Text(
//             //       'Record File List',
//             //       style: TextStyle(
//             //           color: Color(0xff484848),
//             //           fontSize: 24,
//             //           fontWeight: FontWeight.w500),
//             //     ),
//             //   ),
//             // ),
//             const SizedBox(
//               height: 15,
//             ),
//             // _buildConnectionCheckTile(),
//             // _buildProductList(),
//             //_buildConsumableBox(),
//             //_myConsumable(),
//             // _buildRestoreButton(),
//             Expanded(
//               child: FutureBuilder<List<VoiceSaveModel>>(
//                 future: DbHelper().fetchProducts(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   return ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: snapshot.data!.length,
//                     itemBuilder: (context, index) {
//                       // log('${snapshot.data![index].name}\n${snapshot.data![index].playPath}\n\n');

//                       if (!isLoadingMap.containsKey(index)) {
//                         isLoadingMap[index] = false;
//                       }
//                       return Slidable(
                        // endActionPane: ActionPane(
                        //   motion: const ScrollMotion(),
                        //   children: [
                        //     SlidableAction(
                        //       onPressed: (context) async {
                        //         try {
                        //           var path =
                        //               await CRFileSaver.saveFileWithDialog(
                        //                   SaveFileDialogParams(
                        //             sourceFilePath:
                        //                 snapshot.data![index].playPath ??
                        //                     'assets/image/recorder_icon.png',
                        //             destinationFileName:
                        //                 snapshot.data![index].playPath ??
                        //                     'assets/image/recorder_icon.png'
                        //                         .split("/")
                        //                         .last,
                        //           ));
                        //           print('Saved to $path');
                        //         } catch (error) {
                        //           print('Error: $error');
                        //         }
                        //       },
                        //       backgroundColor: kColorGold,
                        //       foregroundColor: Colors.white,
                        //       icon: Icons.save,
                        //       label: 'Save',
                        //     ),
                        //     SlidableAction(
                        //       onPressed: (context) async {
                        //         await Share.shareFiles([
                        //           snapshot.data![index].playPath ??
                        //               'assets/image/recorder_icon.png'
                        //         ]);
                        //       },
                        //       backgroundColor: kColorGold,
                        //       foregroundColor: Colors.white,
                        //       icon: Icons.share,
                        //       label: 'Share',
                        //     )
                        //   ],
                        // ),
                        // startActionPane: ActionPane(
                        //   motion: const ScrollMotion(),
                        //   children: [
                        //     SlidableAction(
                        //       onPressed: (context) async {
                        //         if (await askIfReallyDelete()) {
                        //           await DbHelper()
                        //               .removeVoice(snapshot.data![index]);
                        //           setState(() {});
                        //         }
                        //       },
                        //       backgroundColor: Color(0xFFFE4A49),
                        //       foregroundColor: Colors.white,
                        //       icon: Icons.delete,
                        //       label: 'Delete',
                        //     ),
                        //   ],
                        // ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 8, horizontal: 10),
//                           child: InkWell(
//                             onTap: () {
//                               print(
//                                   "FileLength: ${File(snapshot.data![index].playPath ?? 'assets/image/recorder_icon.png').lengthSync()}");
//                               String fileExtension = snapshot.data![index].name!
//                                   .substring(
//                                       snapshot.data![index].name!.length - 4,
//                                       snapshot.data![index].name!.length);

//                               if (fileExtension == '.aac' ||
//                                   fileExtension == '.ogg') {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => Material(
//                                       child: StopRecordView(
//                                         fileName2: snapshot.data![index].name,
//                                         previousPath:
//                                             snapshot.data![index].playPath,
//                                         isFromRecordList: true,
//                                         path1: snapshot.data![index].playPath,
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               } else {
//                                 OpenFilex.open(snapshot.data![index].playPath);
//                               }
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     SizedBox(
//                                       width: width * 0.5,
//                                       child: Text(
//                                         snapshot.data![index].name ?? '',
//                                         maxLines: 1,
//                                         style: const TextStyle(
//                                             overflow: TextOverflow.ellipsis,
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.w500,
//                                             color: Color(0xff484848)),
//                                       ),
//                                     ),
//                                     Row(
//                                       children: [
//                                         Text(
//                                           DateFormat("dd.MM.yyyy").format(
//                                               snapshot.data![index].date ??
//                                                   DateTime.now()),
//                                           style: const TextStyle(
//                                               color: kColorGold,
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w600),
//                                         ),
//                                         Container(
//                                           width: 4,
//                                           height: 4,
//                                           margin: const EdgeInsets.symmetric(
//                                               horizontal: 4),
//                                           decoration: const BoxDecoration(
//                                               color: kColorGold,
//                                               borderRadius: BorderRadius.all(
//                                                   Radius.circular(10))),
//                                         ),
//                                         Text(
//                                           DateFormat("HH:mm").format(
//                                               snapshot.data![index].date ??
//                                                   DateTime.now()),
//                                           style: const TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w600),
//                                         )
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                                 const Spacer(),
//                                 SizedBox(
//                                   width: width * 0.35,
//                                   height: 40,
//                                   child: FutureBuilder(
//                                     future: DbHelper().getPDFsForFilename(
//                                         snapshot.data![index].name ?? ''),
//                                     builder: (context, btnsnapshot) {
//                                       return TextButton(
//                                         onPressed: () async {
//                                           setState(() {
//                                             isLoadingMap[index] = true;
//                                           });
//                                           String? deviceId =
//                                               await getUniqueDeviceId();
//                                           log('deviceId: $deviceId');
//                                           EventUploadHttpService eventService =
//                                               EventUploadHttpService();
//                                           final request =
//                                               await eventService.eventUpload(
//                                                   snapshot.data![index]
//                                                           .playPath ??
//                                                       'assets/image/recorder_icon.png',
//                                                   deviceId);
//                                           if (request != null) {
//                                             setState(() {
//                                               isLoadingMap[index] = false;
//                                             });
//                                             snackbarShow(
//                                                 context: context,
//                                                 text:
//                                                     'A proof of existence has been created for this media');
//                                           } else {
//                                             setState(() {
//                                               isLoadingMap[index] = false;
//                                             });
//                                             snackbarShow(
//                                                 context: context,
//                                                 text:
//                                                     'Proof of existence could not be created');
//                                           }
//                                           // if ((await DbHelper()
//                                           //         .getPDFsForFilename(snapshot
//                                           //             .data![index].name))
//                                           //     .isNotEmpty) {
//                                           //   File pdfFile =
//                                           //       await PdfAttendanceApi().generate(
//                                           //           pdfSaveModel:
//                                           //               (await DbHelper()
//                                           //                   .getPDFsForFilename(
//                                           //                       snapshot
//                                           //                           .data![
//                                           //                               index]
//                                           //                           .name))[0]);
//                                           //   SavePdf.openFile(pdfFile);
//                                           //   return;
//                                           // }
//                                           // if (!(await NetworkChecker()
//                                           //     .shouldProceed(context))) {
//                                           //   return;
//                                           // }
//                                           //
//                                           // bool res = await HashHelper()
//                                           //     .checkIfHashAlreadyExist(
//                                           //         snapshot.data![index].path);
//                                           // if (!res) {
//                                           //   isLoading = false;
//                                           //   Navigator.push(
//                                           //     context,
//                                           //     MaterialPageRoute(
//                                           //       builder: (context) =>
//                                           //           CreateProofView(
//                                           //         hash: snapshot
//                                           //             .data![index].path,
//                                           //         voiceName: snapshot
//                                           //             .data![index].name,
//                                           //       ),
//                                           //     ),
//                                           //   );
//                                           // } else {
//                                           //   isLoading = false;
//                                           //   snackbarShow(
//                                           //       context: context,
//                                           //       text:
//                                           //           'This hash is already registered on our blockchain.');
//                                           // }
//                                           // }
//                                           //}

//                                           //--------- Post HashKey
//                                         },
                                        // style: ButtonStyle(
                                        //   shape: MaterialStateProperty.all(
                                        //     const RoundedRectangleBorder(
                                        //       borderRadius: BorderRadius.all(
                                        //         Radius.circular(100),
                                        //       ),
                                        //     ),
                                        //   ),
                                        //   backgroundColor:
                                        //       MaterialStateProperty.all(
                                        //           btnsnapshot.data?.isEmpty ??
                                        //                   true
                                        //               ? kColorDarkBlue
                                        //               : kColorGold),
                                        // ),
//                                         child: Text(
//                                           btnsnapshot.data?.isEmpty ?? true
//                                               ? isLoadingMap[index] ?? false
//                                                   ? 'Creating proof....'
//                                                   : 'Create proof'
//                                               : 'Show proof',
//                                           style: const TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   width: 5,
//                                 ),
//                                 GestureDetector(
//                                     onTap: () async {
//                                       var confirmation =
//                                           await askIfReallyDelete();
//                                       if (!confirmation) return;
//                                       var res = await DbHelper()
//                                           .removeVoice(snapshot.data![index]);
//                                       if (res) {
//                                         setState(() {});
//                                       } else {
//                                         snackbarShow(
//                                             context: context,
//                                             text: 'Something went wrong!');
//                                       }
//                                     },
//                                     child: SvgPicture.asset(
//                                         "assets/icons/delete_icon.svg"))
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

  // Future<bool> askIfReallyDelete() async {
  //   return await showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: const Text('Delete'),
  //           content: const Text('Are you sure you want to delete this file?'),
  //           actions: [
  //             Padding(
  //               padding: const EdgeInsets.only(right: 15),
  //               child: SizedBox(
  //                 width: 80,
  //                 height: 40,
  //                 child: TextButton(
  //                   onPressed: () {
  //                     Navigator.of(context).pop(false);
  //                   },
  //                   style: ButtonStyle(
  //                     side: MaterialStateProperty.all(
  //                         const BorderSide(width: 1, color: kColorGold)),
  //                     shape: MaterialStateProperty.all(
  //                         const RoundedRectangleBorder(
  //                             borderRadius:
  //                                 BorderRadius.all(Radius.circular(100)))),
  //                   ),
  //                   child: const Text(
  //                     'Cancel',
  //                     style: TextStyle(color: kColorGold, fontSize: 16),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.only(right: 15),
  //               child: SizedBox(
  //                 width: 51,
  //                 height: 38,
  //                 child: TextButton(
  //                   onPressed: () async {
  //                     Navigator.of(context).pop(true);
  //                   },
  //                   style: ButtonStyle(
  //                       shape: MaterialStateProperty.all(
  //                           const RoundedRectangleBorder(
  //                               borderRadius:
  //                                   BorderRadius.all(Radius.circular(100)))),
  //                       backgroundColor: MaterialStateProperty.all(kColorGold)),
  //                   child: const Text(
  //                     "Yes",
  //                     style: TextStyle(color: Colors.white, fontSize: 16),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         );
  //       });
  // }

// // Future<void> _getProducts() async {
// //   Set<String> ids = {'prooff'};
// //   ProductDetailsResponse response =
// //       await _inAppPurchase.queryProductDetails(ids);

// //   setState(() {
// //     _products = response.productDetails;
// //   });
// // }

// // Future<bool> _buyProduct(ProductDetails prod) {
// //   final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
// //   // _iap.buyNonConsumable(purchaseParam: purchaseParam);
// //   return _inAppPurchase.buyConsumable(
// //       purchaseParam: purchaseParam, autoConsume: true);
// // }

// // PurchaseDetails _hasPurchased(String productID) {
// //   return _purchases.firstWhere((purchase) => purchase.productID == productID,
// //       orElse: () => null);
// // }

// // void _verifyPurchase(String productID) {
// //   PurchaseDetails purchase = _hasPurchased(productID);

// //   // TODO serverside verification & record consumable in the database

// //   if (purchase != null && purchase.status == PurchaseStatus.purchased) {
// //     //TODO _credits = 10;
// //   }
// // }

// // Card _buildConnectionCheckTile() {
// //   if (_loading) {
// //     return const Card(child: ListTile(title: Text('Trying to connect...')));
// //   }
// //   final Widget storeHeader = ListTile(
// //     leading: Icon(_isAvailable ? Icons.check : Icons.block,
// //         color: _isAvailable
// //             ? Colors.green
// //             : ThemeData.light().colorScheme.error),
// //     title:
// //         Text('The store is ${_isAvailable ? 'available' : 'unavailable'}.'),
// //   );
// //   final List<Widget> children = <Widget>[storeHeader];

// //   if (!_isAvailable) {
// //     children.addAll(<Widget>[
// //       const Divider(),
// //       ListTile(
// //         title: Text('Not connected',
// //             style: TextStyle(color: ThemeData.light().colorScheme.error)),
// //         subtitle: const Text(
// //             'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
// //       ),
// //     ]);
// //   }
// //   return Card(child: Column(children: children));
// // }

// // Card _buildProductList() {
// //   if (_loading) {
// //     return const Card(
// //         child: ListTile(
// //             leading: CircularProgressIndicator(),
// //             title: Text('Fetching products...')));
// //   }
// //   if (!_isAvailable) {
// //     return const Card();
// //   }
// //   const ListTile productHeader = ListTile(title: Text('Products for Sale'));
// //   final List<ListTile> productList = [];
// //   if (_notFoundIds.isNotEmpty) {
// //     productList.add(ListTile(
// //         title: Text('[${_notFoundIds.join(", ")}] not found',
// //             style: TextStyle(color: ThemeData.light().colorScheme.error)),
// //         subtitle: const Text(
// //             'This app needs special configuration to run. Please see example/README.md for instructions.')));
// //   }

// //   // This loading previous purchases code is just a demo. Please do not use this as it is.
// //   // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
// //   // We recommend that you use your own server to verify the purchase data.
// //   final Map<String, PurchaseDetails> purchases =
// //       Map<String, PurchaseDetails>.fromEntries(
// //           _purchases.map((PurchaseDetails purchase) {
// //     if (purchase.pendingCompletePurchase) {
// //       _inAppPurchase.completePurchase(purchase);
// //     }
// //     return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
// //   }));
// //   productList.addAll(_products.map(
// //     (ProductDetails productDetails) {
// //       final PurchaseDetails? previousPurchase = purchases[productDetails];
// //       return ListTile(
// //         title: Text(
// //           productDetails.title,
// //         ),
// //         subtitle: Text(
// //           productDetails.description,
// //         ),
// //         trailing: previousPurchase != null
// //             ? IconButton(
// //                 onPressed: () => confirmPriceChange(context),
// //                 icon: const Icon(Icons.upgrade))
// //             : TextButton(
// //                 style: TextButton.styleFrom(
// //                   backgroundColor: Colors.green[800],
// //                   // ignore: deprecated_member_use
// //                   primary: Colors.white,
// //                 ),
// //                 onPressed: () {
// //                   late PurchaseParam purchaseParam;
// //                   if (Platform.isAndroid) {
// //                     // NOTE: If you are making a subscription purchase/upgrade/downgrade, we recommend you to
// //                     // verify the latest status of you your subscription by using server side receipt validation
// //                     // and update the UI accordingly. The subscription purchase status shown
// //                     // inside the app may not be accurate.
// //                     final GooglePlayPurchaseDetails? oldSubscription =
// //                         _getOldSubscription(productDetails, purchases);

// //                     purchaseParam = GooglePlayPurchaseParam(
// //                         productDetails: productDetails,
// //                         changeSubscriptionParam: (oldSubscription != null)
// //                             ? ChangeSubscriptionParam(
// //                                 oldPurchaseDetails: oldSubscription,
// //                                 prorationMode:
// //                                     ProrationMode.immediateWithTimeProration,
// //                               )
// //                             : null);
// //                   } else {
// //                     purchaseParam = PurchaseParam(
// //                       productDetails: productDetails,
// //                     );
// //                   }

// //                   if (productDetails.id == _kConsumableId) {
// //                     _inAppPurchase.buyConsumable(
// //                         purchaseParam: purchaseParam,
// //                         autoConsume: _kAutoConsume);
// //                     _inAppPurchase.getPlatformAddition();
// //                   }
// //                 },
// //                 child: Text(productDetails.price),
// //               ),
// //       );
// //     },
// //   ));

// //   return Card(
// //       child: Column(
// //           children: <Widget>[productHeader, const Divider()] + productList));
// // }

// // Widget _myConsumable() {
// //   if (_loading) {
// //     return const Card(
// //         child: ListTile(
// //             leading: CircularProgressIndicator(),
// //             title: Text('Fetching consumables...')));
// //   }
// //   if (!_isAvailable || _notFoundIds.contains(_kConsumableId)) {
// //     return const SizedBox();
// //   }
// //   if (_isAvailable || !_notFoundIds.contains(_kConsumableId)) {
// //     const ListTile consumableHeader =
// //         ListTile(title: Text('Purchased consumables'));
// //     final List<Widget> tokens = _consumables.map((String id) {
// //       voiceSaveModelSelected != null
// //           ? DbHelper().updateProduct(
// //               voiceSaveModelSelected!.copyWith(consumableID: id))
// //           : null;
// //       return SizedBox();
// //       // return GridTile(
// //       //   child: IconButton(
// //       //     icon: const Icon(
// //       //       Icons.stars,
// //       //       size: 42.0,
// //       //       color: Colors.orange,
// //       //     ),
// //       //     splashColor: Colors.yellowAccent,
// //       //     onPressed: () => consume(id),
// //       //   ),
// //       // );
// //     }).toList();
// //     return SizedBox();
// //     // return Card(
// //     //     child: Column(children: <Widget>[
// //     //   consumableHeader,
// //     //   const Divider(),
// //     //   GridView.count(
// //     //     crossAxisCount: 5,
// //     //     shrinkWrap: true,
// //     //     padding: const EdgeInsets.all(16.0),
// //     //     children: tokens,
// //     //   )
// //     // ]));
// //   }
// //   return SizedBox();
// // }

// // Card _buildConsumableBox() {
// //   if (_loading) {
// //     return const Card(
// //         child: ListTile(
// //             leading: CircularProgressIndicator(),
// //             title: Text('Fetching consumables...')));
// //   }
// //   if (!_isAvailable || _notFoundIds.contains(_kConsumableId)) {
// //     return const Card();
// //   }
// //   if (_isAvailable || !_notFoundIds.contains(_kConsumableId)) {
// //     const ListTile consumableHeader =
// //         ListTile(title: Text('Purchased consumables'));
// //     final List<Widget> tokens = _consumables.map((String id) {
// //       voiceSaveModelSelected != null
// //           ? DbHelper().updateProduct(
// //               voiceSaveModelSelected!.copyWith(consumableID: id))
// //           : null;
// //       return GridTile(
// //         child: IconButton(
// //           icon: const Icon(
// //             Icons.stars,
// //             size: 42.0,
// //             color: Colors.orange,
// //           ),
// //           splashColor: Colors.yellowAccent,
// //           onPressed: () => consume(id),
// //         ),
// //       );
// //     }).toList();
// //     return Card(
// //         child: Column(children: <Widget>[
// //       consumableHeader,
// //       const Divider(),
// //       GridView.count(
// //         crossAxisCount: 5,
// //         shrinkWrap: true,
// //         padding: const EdgeInsets.all(16.0),
// //         children: tokens,
// //       )
// //     ]));
// //   }
// //   return Card();
// // }

// // Widget _buildRestoreButton() {
// //   if (_loading) {
// //     return Container();
// //   }

// //   return Padding(
// //     padding: const EdgeInsets.all(4.0),
// //     child: Row(
// //       mainAxisAlignment: MainAxisAlignment.end,
// //       children: <Widget>[
// //         TextButton(
// //           style: TextButton.styleFrom(
// //             backgroundColor: Theme.of(context).primaryColor,
// //             // TODO(darrenaustin): Migrate to new API once it lands in stable: https://github.com/flutter/flutter/issues/105724
// //             // ignore: deprecated_member_use
// //             primary: Colors.white,
// //           ),
// //           onPressed: () => _inAppPurchase.restorePurchases(),
// //           child: const Text('Restore purchases'),
// //         ),
// //       ],
// //     ),
// //   );
// // }

// // Future<void> consume(String id) async {
// //   await ConsumableStore.consume(id);
// //   final List<String> consumables = await ConsumableStore.load();
// //   setState(() {
// //     _consumables = consumables;
// //   });
// // }

// // void showPendingUI() {
// //   setState(() {
// //     _purchasePending = true;
// //   });
// // }

// // Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
// //   // IMPORTANT!! Always verify purchase details before delivering the product.
// //   if (purchaseDetails.productID == _kConsumableId) {
// //     await ConsumableStore.save(purchaseDetails.purchaseID!);
// //     final List<String> consumables = await ConsumableStore.load();
// //     setState(() {
// //       _purchasePending = false;
// //       _consumables = consumables;
// //     });
// //   } else {
// //     setState(() {
// //       _purchases.add(purchaseDetails);
// //       _purchasePending = false;
// //     });
// //   }
// // }

// // void handleError(IAPError error) {
// //   setState(() {
// //     _purchasePending = false;
// //   });
// // }

// // Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
// //   // IMPORTANT!! Always verify a purchase before delivering the product.
// //   // For the purpose of an example, we directly return true.
// //   return Future<bool>.value(true);
// // }

// // void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
// //   // handle invalid purchase here if  _verifyPurchase` failed.
// // }

// // Future<void> _listenToPurchaseUpdated(
// //     List<PurchaseDetails> purchaseDetailsList) async {
// //   for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
// //     if (purchaseDetails.status == PurchaseStatus.pending) {
// //       showPendingUI();
// //     } else {
// //       if (purchaseDetails.status == PurchaseStatus.error) {
// //         handleError(purchaseDetails.error!);
// //       } else if (purchaseDetails.status == PurchaseStatus.purchased ||
// //           purchaseDetails.status == PurchaseStatus.restored) {
// //         final bool valid = await _verifyPurchase(purchaseDetails);
// //         if (valid) {
// //           deliverProduct(purchaseDetails);
// //         } else {
// //           _handleInvalidPurchase(purchaseDetails);
// //           return;
// //         }
// //       }
// //       if (Platform.isAndroid) {
// //         if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
// //           final InAppPurchaseAndroidPlatformAddition androidAddition =
// //               _inAppPurchase.getPlatformAddition<
// //                   InAppPurchaseAndroidPlatformAddition>();
// //           await androidAddition.consumePurchase(purchaseDetails);
// //         }
// //       }
// //       if (purchaseDetails.pendingCompletePurchase) {
// //         await _inAppPurchase.completePurchase(purchaseDetails);
// //       }
// //     }
// //   }
// // }

// // Future<void> confirmPriceChange(BuildContext context) async {
// //   if (Platform.isAndroid) {
// //     final InAppPurchaseAndroidPlatformAddition androidAddition =
// //         _inAppPurchase
// //             .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
// //     final BillingResultWrapper priceChangeConfirmationResult =
// //         await androidAddition.launchPriceChangeConfirmationFlow(
// //       sku: 'purchaseId',
// //     );
// //     if (priceChangeConfirmationResult.responseCode == BillingResponse.ok) {
// //       // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
// //       //   content: Text('Price change accepted'),
// //       // ));
// //     } else {
// //       // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// //       //   content: Text(
// //       //     priceChangeConfirmationResult.debugMessage ??
// //       //         'Price change failed with code ${priceChangeConfirmationResult.responseCode}',
// //       //   ),
// //       // ));
// //     }
// //   }
// //   if (Platform.isIOS) {
// //     final InAppPurchaseStoreKitPlatformAddition iapStoreKitPlatformAddition =
// //         _inAppPurchase
// //             .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
// //     await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
// //   }
// // }

// //   GooglePlayPurchaseDetails? _getOldSubscription(
// //       ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
// //     // This is just to demonstrate a subscription upgrade or downgrade.
// //     // This method assumes that you have only 2 subscriptions under a group, 'subscription_silver' & 'subscription_gold'.
// //     // The 'subscription_silver' subscription can be upgraded to 'subscription_gold' and
// //     // the 'subscription_gold' subscription can be downgraded to 'subscription_silver'.
// //     // Please remember to replace the logic of finding the old subscription Id as per your app.
// //     // The old subscription is only required on Android since Apple handles this internally
// //     // by using the subscription group feature in iTunesConnect.
// //     GooglePlayPurchaseDetails? oldSubscription;
// //     if (productDetails.id == _kSilverSubscriptionId &&
// //         purchases[_kGoldSubscriptionId] != null) {
// //       oldSubscription =
// //           purchases[_kGoldSubscriptionId]! as GooglePlayPurchaseDetails;
// //     } else if (productDetails.id == _kGoldSubscriptionId &&
// //         purchases[_kSilverSubscriptionId] != null) {
// //       oldSubscription =
// //           purchases[_kSilverSubscriptionId]! as GooglePlayPurchaseDetails;
// //     }
// //     return oldSubscription;
// //   }
// // }
// }

// /// Example implementation of the
// /// [`SKPaymentQueueDelegate`](https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate?language=objc).
// ///
// /// The payment queue delegate can be implementated to provide information
// /// needed to complete transactions.
// // class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
// //   @override
// //   bool shouldContinueTransaction(
// //       SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
// //     return true;
// //   }

// //   @override
// //   bool shouldShowPriceConsent() {
// //     return false;
// //   }
// // }
