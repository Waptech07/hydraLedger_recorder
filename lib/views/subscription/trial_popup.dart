import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_recorder/constants/color_constants.dart';
import 'package:voice_recorder/globals.dart' as globals;
import '../../api/subscriptionmanager.dart';

import '../../services/network_checker.dart';

class SubscriptionView extends StatefulWidget {
  SubscriptionView({Key? key}) : super(key: key);

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  String yearlyPrice = "";

  late SharedPreferences preferences;

  @override
  void initState() {
    loadPricing();

    SubscriptionManager().reloadActiveSubscriptions();
    super.initState();
  }

  void loadPricing() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon:
                        Icon(Icons.close, color: Colors.black.withOpacity(.8)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 250,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ]),
                          child: ClipRRect(
                            child: Image.asset(
                              'assets/image/sub_ad.jpg',
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          height: 135,
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ]),
                          child: ClipRRect(
                            child: Image.asset(
                              'assets/image/Accident_rental_car.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                BoldText(
                  boldText: 'ĦRecorder Pro',
                ),
                Text(
                  "3-Day Free Trial",
                  style: TextStyle(fontSize: 17),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Try HRecorder Pro for 3 days incl. 2 Blockchain Certificates for free, then $yearlyPrice/year (100 proofs included). Cancel anytime.',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  height: 60.0,
                  child: MaterialButton(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    onPressed: () async {
                      startPurchase(SubscriptionType.yearly);
                    },
                    child: Ink(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                kColorGold,
                                kColorGold.withOpacity(0.8),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(6.0)),
                        child: Container(
                            constraints: BoxConstraints(
                                maxWidth: 300.0, minHeight: 60.0),
                            alignment: Alignment.center,
                            child: Text(
                              'Start Free Trial',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white),
                            ))),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void startPurchase(SubscriptionType type) async {
    if (!(await NetworkChecker().shouldProceed(context))) {
      return;
    }

    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    log('customer info $customerInfo');
    bool alreadyHasActiveSubscription = false;
    for (EntitlementInfo entitlement
        in customerInfo.entitlements.active.values) {
      if (entitlement.identifier == globals.kYearlySubscriptionId() ||
          entitlement.identifier == globals.kMontlySubscriptionId()) {
        alreadyHasActiveSubscription = true;
        break;
      }
    }

    if (alreadyHasActiveSubscription) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'You already have an active subscription. Please cancel it first.'),
      ));
      return;
    }
    Package? pkg = await SubscriptionManager()
        .getStorePackage(globals.kYearlySubscriptionId());
    if (pkg == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something went wrong. Please try again later.'),
      ));
      return;
    }

    EntitlementInfo? entitlementInfo =
        await SubscriptionManager().buyProduct(pkg);
    if (entitlementInfo == null) return;

    await SubscriptionManager()
        .enableSubscription(SubscriptionType.yearly, true, entitlementInfo);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          'Thanks for subscribing to our yearly plan! Your free trial will end on ' +
              DateFormat("dd.MM.yyyy").format(
                  DateTime.parse(entitlementInfo.expirationDate.toString())) +
              ')'),
    ));
    await Future.delayed(Duration(seconds: 1));
    Navigator.of(context).pop();
  }
}

class CustomListTile extends StatelessWidget {
  final String titleText;
  final String subtitleText;

  const CustomListTile({required this.titleText, required this.subtitleText});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.check_circle,
        color: kColorGold,
      ),
      title: Text(
        titleText,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitleText,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
      ),
    );
  }
}

class BoldText extends StatelessWidget {
  final String boldText;

  const BoldText({required this.boldText}) : assert(boldText != null);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        boldText,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
    );
  }
}
