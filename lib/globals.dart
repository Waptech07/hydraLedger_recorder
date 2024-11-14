import 'dart:io';

import 'package:voice_recorder/api/modechecker.dart';

NetMode netMode = NetMode.dev;
const String kConsumableId = 'proof';
String kMontlySubscriptionId() {
  if (Platform.isIOS) {
    return 'premium_subscription_monthly';
  } else {
    return 'premium_subscription_monthly:premium-monthly';
  }
}

String kYearlySubscriptionId() {
  if (Platform.isIOS) {
    return 'premium_subscription_yearly';
  } else {
    return 'premium_subscription_yearly:premium-yearly';
  }
}

const String kTrialSubscriptionIdAndroid = 'free-trial';
const String kTrialSubscriptionIdiOS = 'free_trial';

const String rciOSKey = "appl_ZIppiXOsRGyhnkkbyalIDTmdVCv";
const String rcAndroidKey = "goog_ZKfwjNVCWWmnhiVxjVrrIqnRQEt";

const String monthlyEntitlement = "premium_subscription_monthly";
const String yearlyEntitlement = "premium_subscription_yearly";
