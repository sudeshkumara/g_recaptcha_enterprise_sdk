import 'dart:async';

import 'package:flutter/services.dart';

class GRecaptchaEnterpriseSdk {
  static const MethodChannel _channel =
      MethodChannel('g_recaptcha_enterprise_sdk');

  GRecaptchaEnterpriseSdk();

  //initialize the google recaptcha enterprise client by passing you site key
  Future<bool?> initializeRecaptchaClient({required String siteKey}) async {
    final bool? response = await _channel
        .invokeMethod('initializeRecaptchaClient', {"siteKey": siteKey});
    return response;
  }

  //execute google recaptcha enterprise client and get the token
  Future<String?> executeRecaptchaClient() async {
    final String? response =
        await _channel.invokeMethod('executeRecaptchaClient');
    return response;
  }
}
