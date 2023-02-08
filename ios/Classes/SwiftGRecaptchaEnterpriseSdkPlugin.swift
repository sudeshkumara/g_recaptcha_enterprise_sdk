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
    if let args = call.arguments as? [String: Any],
      let siteKey = args["siteKey"] as? String
    {
      DispatchQueue.main.async {
        Task{
              let (recaptchaClient, error) = await Recaptcha.getClient(
                siteKey: siteKey)
              if let recaptchaClient = recaptchaClient {
                self.recaptchaClient = recaptchaClient
                result("Recaptcha client has been initialized.")
              }
              if let error = error {
                result("Recaptcha client initialization error: \(error.errorMessage).")
              }
          
            }
      }   
    }
  }


  private func executeRecaptchaClient(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let recaptchaClient = recaptchaClient else {
      return
    }
    DispatchQueue.main.async {
      Task {
        let (token, error) = await recaptchaClient.execute(RecaptchaAction(action: .login))
        if let token = token {
          result(token.recaptchaToken)
        } else if let error = error {
          result("Recaptcha client excution error: \(error.errorMessage).")
        }
      }
    }
  }

}
