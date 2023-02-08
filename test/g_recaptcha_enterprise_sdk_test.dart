import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_recaptcha_enterprise_sdk/g_recaptcha_enterprise_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('g_recaptcha_enterprise_sdk');
  GRecaptchaEnterpriseSdk gRecaptchaEnterpriseSdk = GRecaptchaEnterpriseSdk();

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('initializeRecaptchaClient', () async {
    expect(gRecaptchaEnterpriseSdk.initializeRecaptchaClient, '42');
  });

  test('executeRecaptchaClient', () async {
    expect(gRecaptchaEnterpriseSdk.executeRecaptchaClient, '42');
  });
}
