import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hydraledger_recorder/globals.dart' as globals;
import 'package:hydraledger_recorder/views/subscription/trial_popup.dart';

class SubscriptionManager {
  Future<void> enableSubscription(SubscriptionType type, bool trial,
      EntitlementInfo entitlementInfo) async {
    print(
        "Enabling subscription: ${type.name} will refill on ${entitlementInfo.expirationDate}");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("is_trial") != null) {
      trial = false;
    }
    await prefs.setString(
        'will_refill', entitlementInfo.expirationDate.toString());
    await prefs.setInt(
        'proofs_left',
        type == SubscriptionType.monthly
            ? 5
            : trial
                ? 2
                : 100);
    await prefs.setString("subscription_type", type.name);
    await prefs.setBool("is_trial", trial);
    print("Proofs left: " + (await getLeftProofs()).toString());
    return;
  }

  Future<int> getLeftProofs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int proofsLeft = prefs.getInt('proofs_left') ?? 0;
    return proofsLeft;
  }

  Future<bool> checkIfRefillDue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('will_refill') == null) return false;
    String willRefill = prefs.getString('will_refill')!;
    DateTime willRefillDate = DateTime.parse(willRefill);
    return willRefillDate.isBefore(DateTime.now());
  }

  Future<SubscriptionType?> getSubscriptionType() async {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    if (customerInfo.entitlements.active.isEmpty) return null;
    return customerInfo.entitlements.active.values.first.identifier
            .contains(globals.monthlyEntitlement)
        ? SubscriptionType.monthly
        : SubscriptionType.yearly;
  }

  Future<SubscriptionDetails?> getSubscriptionDetails() async {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    int proofsLeft = await getLeftProofs();
    DateTime subscriptionDue = DateTime.parse(
        customerInfo.latestExpirationDate ?? DateTime.now().toString());
    SubscriptionType? type = await getSubscriptionType();
    if (subscriptionDue.isBefore(DateTime.now()) || type == null) {
      return null;
    }
    return SubscriptionDetails(proofsLeft, subscriptionDue, type);
  }

  Future<EntitlementInfo?> buyProduct(Package pkg) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(pkg);
      return customerInfo.activeSubscriptions.isNotEmpty
          ? customerInfo.entitlements.all.values.first
          : null;
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        print("Error: " + errorCode.toString());
      }
    }
  }

  Future<bool> useSubscriptionProof() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int proofsLeft = prefs.getInt('proofs_left') ?? 0;
    print("Proofs left: " + proofsLeft.toString());
    if (proofsLeft > 0) {
      await prefs.setInt('proofs_left', proofsLeft - 1);
      return true;
    }
    return false;
  }

  Future<Package?> getStorePackage(String id) async {
    Package? package;
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        for (Package pkg in offerings.current!.availablePackages) {
          print("Found one package: " + pkg.storeProduct.identifier);
          if (pkg.storeProduct.identifier == id) package = pkg;
        }
      } else {
        print("No current offerings or packages");
      }
    } catch (e) {
      // optional error handling
      print("Error: " + e.toString());
    }
    return package;
  }

  Future<void> reloadActiveSubscriptions() async {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();

    if ((customerInfo.entitlements.all[globals.monthlyEntitlement]?.isActive ??
            false) ||
        (customerInfo.entitlements.all[globals.yearlyEntitlement]?.isActive ??
            false)) {
      print("=>Found active subscription: " +
          customerInfo.entitlements.active.values.first.identifier +
          " will expire on " +
          customerInfo.entitlements.active.values.first.expirationDate
              .toString());
      if (customerInfo.entitlements.all[globals.yearlyEntitlement]?.isActive ??
          false) {
        if (await checkIfRefillDue()) {
          print("Refill due, enabling subscription");
          await enableSubscription(SubscriptionType.yearly, false,
              customerInfo.entitlements.all[globals.yearlyEntitlement]!);
        }
      } else if (customerInfo
              .entitlements.all[globals.monthlyEntitlement]?.isActive ??
          false) {
        if (await checkIfRefillDue()) {
          print("Refill due, enabling subscription");
          await enableSubscription(SubscriptionType.monthly, false,
              customerInfo.entitlements.all[globals.monthlyEntitlement]!);
        }
      }
    }
  }

  void maybeShowPopup(BuildContext context, {bool forceShow = false}) async {
    await reloadActiveSubscriptions();
    SubscriptionDetails? details = await getSubscriptionDetails();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (details == null && (prefs.getBool("is_trial") == null)) {
      if (Random().nextInt(3) == 1 || forceShow) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SubscriptionView()));
      }
    }
  }
}

class SubscriptionDetails {
  final int proofsLeft;
  final DateTime subscriptionDue;
  final SubscriptionType type;

  SubscriptionDetails(this.proofsLeft, this.subscriptionDue, this.type);
}

enum SubscriptionType { monthly, yearly, yearlyWithTrial }
