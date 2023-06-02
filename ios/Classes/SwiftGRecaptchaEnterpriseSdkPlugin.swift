import Flutter
import UIKit
import RecaptchaEnterprise


public class SwiftGRecaptchaEnterpriseSdkPlugin: NSObject, FlutterPlugin {
  private var recaptchaClient: RecaptchaClient?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "g_recaptcha_enterprise_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftGRecaptchaEnterpriseSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  //handle the methods
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initializeRecaptchaClient":
      initializeRecaptchaClient(call, result: result)
      break
    case "executeRecaptchaClient":
      executeRecaptchaClient(call, result: result)
      break
    default:
      result(FlutterMethodNotImplemented)
    }
  }


  private func initializeRecaptchaClient(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

     guard let args = call.arguments as? [String: Any],
      let siteKey = args["siteKey"] as? String
    else {
      result(
        FlutterError.init(code: "FL_INIT_FAILED", message: "Missing reCAPTCHA site key", details: nil))
      return
    }

    var getClientClosure: (RecaptchaClient?, Error?) -> Void = { recaptchaClient, error in
      if let recaptchaClient = recaptchaClient {
        self.recaptchaClient = recaptchaClient
        result(true)
      } else if let error = error {
        guard let error = error as? RecaptchaError else {
          FlutterError.init(code: "FL_CAST_ERROR", message: "Not a reCAPTCHA error", details: nil)
          return
        }
        result(
          FlutterError.init(code: String(error.code), message: error.errorMessage, details: nil)
        )
      }
    }
     Recaptcha.getClient(withSiteKey: siteKey, completion: getClientClosure)
  }


  private func executeRecaptchaClient(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    guard let recaptchaClient = recaptchaClient else {
      result(
        FlutterError.init(
          code: "FL_EXECUTE_FAILED", message: "Initialize client first", details: nil))
      return
    }

      recaptchaClient.execute(.login) { (token, error) -> Void in
        if let token = token {
          result(token.recaptchaToken)
        } else if let error = error {
          result(
            FlutterError.init(code: String(error.code), message: error.errorMessage, details: nil)
          )
        }
      }
  }

}
