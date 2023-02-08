import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:g_recaptcha_enterprise_sdk/g_recaptcha_enterprise_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GRecaptchaEnterpriseSdk gRecaptchaEnterpriseSdk;

  String? _token;
  String _recaptchaClient = 'Not Initialized';

  @override
  void initState() {
    gRecaptchaEnterpriseSdk = GRecaptchaEnterpriseSdk();

    initializeRecaptchaClient();
    executeRecaptchaClient();

    super.initState();
  }

  // Initializing the recaptcha client is asynchronous ation, so we initialize in an async method.
  Future<void> initializeRecaptchaClient() async {
    String recaptchaClient;
    try {
      recaptchaClient = await gRecaptchaEnterpriseSdk.initializeRecaptchaClient(
              siteKey: Platform.isIOS
                  ? "6LcJR1YkAAAAABdAHmtTCj_ldtr92Jf7DaNgDyBK"
                  : "6Ld5l2AkAAAAAGGYbyfHGRXSyaqyjpASGMV4xaR2") ??
          'executeRecaptchaClient error';
    } catch (e) {
      recaptchaClient = '$e';
      log(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _recaptchaClient = recaptchaClient;
    });
  }

  // Executing the recaptcha client is asynchronous ation, so we initialize in an async method.
  Future<void> executeRecaptchaClient() async {
    String? token;
    try {
      token = await gRecaptchaEnterpriseSdk.executeRecaptchaClient() ??
          'There was an error while trying to get the reCAPTCHA token.';
    } catch (e) {
      token = null;
    }
    if (!mounted) return;

    setState(() {
      _token = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Google reCAPTCHA Example App'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  Text(_recaptchaClient),
                  const SizedBox(height: 30),
                  Text(_token ?? ''),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _token != null
            ? FloatingActionButton(
                onPressed: () async =>
                    //Once you have the reCAPTCHA toke you can send it to the BE and get the score
                    await Clipboard.setData(ClipboardData(text: _token)),
                child: const Icon(Icons.copy),
              )
            : null,
      ),
    );
  }
}
