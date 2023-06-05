package com.nsk.g_recaptcha_enterprise_sdk

import android.app.Application
import androidx.annotation.NonNull
import com.google.android.recaptcha.Recaptcha
import com.google.android.recaptcha.RecaptchaAction
import com.google.android.recaptcha.RecaptchaClient
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

/** GRecaptchaEnterpriseSdkPlugin */
class GRecaptchaEnterpriseSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private lateinit var recaptchaClient: RecaptchaClient
  private lateinit var application: Application

  override fun onAttachedToEngine(
    @NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
  ) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "g_recaptcha_enterprise_sdk")
    channel.setMethodCallHandler(this)
  }

  private fun initializeRecaptchaClient(@NonNull call: MethodCall, @NonNull result: Result) {
    if (application == null) {
      result.error("FL_INIT_FAILED", "No application registered", null)
      return
    }
    val siteKey = call.argument<String>("siteKey")

    if (siteKey != null) {
      GlobalScope.launch {
        let {
             Recaptcha.getClient(application, siteKey)
          }
          .onSuccess { client ->
            recaptchaClient = client
            result.success(true)
          }
          .onFailure { exception -> result.error("FL_INIT_FAILED", exception.toString(), null) }
      }
    }
  }

  private fun executeRecaptchaClient(@NonNull call: MethodCall, @NonNull result: Result) {
    if (!this::recaptchaClient.isInitialized || recaptchaClient == null) {
      result.error("FL_EXECUTE_FAILED", "Initialize reCAPTCHA client first", null)
      return
    }

    GlobalScope.launch {
      recaptchaClient
        .let { it.execute(RecaptchaAction.LOGIN) }
        .onSuccess { token -> result.success(token) }
        .onFailure { exception -> result.error("FL_EXECUTE_FAILED", exception.toString(), null) }
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "initializeRecaptchaClient" -> initializeRecaptchaClient(call, result)
      "executeRecaptchaClient" -> executeRecaptchaClient(call, result)
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    val activity = binding.activity
    application = activity.application
  }

  override fun onDetachedFromActivity() {}

  override fun onDetachedFromActivityForConfigChanges() {}

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
}
