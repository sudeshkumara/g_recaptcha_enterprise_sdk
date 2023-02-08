package com.nsk.g_recaptcha_enterprise_sdk

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import com.google.android.recaptcha.Recaptcha
import com.google.android.recaptcha.RecaptchaAction
import com.google.android.recaptcha.RecaptchaClient

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** GRecaptchaEnterpriseSdkPlugin */
class GRecaptchaEnterpriseSdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

  private lateinit var channel : MethodChannel
  private lateinit var recaptchaClient: RecaptchaClient
    private lateinit var context: Context
    private lateinit var activity: Activity
  private var lifecycleScope = CoroutineScope(Dispatchers.Main)

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "g_recaptcha_enterprise_sdk")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initializeRecaptchaClient" -> {
                lifecycleScope.launch {
                    try {
                        withContext(Dispatchers.Default) {
                            initializeRecaptchaClient(call, result)
                        }
                    } catch (e: Exception) {
                        result.error("LoginException", e.message, null)
                    }
                }
            }
            "executeRecaptchaClient" -> {
                lifecycleScope.launch {
                    try {
                        withContext(Dispatchers.Default) {
                            executeRecaptchaClient(call, result)
                        }
                    } catch (e: Exception) {
                        result.error("LoginException", e.message, null)
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    private suspend fun initializeRecaptchaClient(call: MethodCall, result: Result) {
        val siteKey = call.argument<String>("siteKey")

            if (siteKey != null) {
                Recaptcha.getClient(activity.application, siteKey)
                        .onSuccess { client ->
                            recaptchaClient = client
                        }
                        .onFailure { exception ->
                            print("RecaptchaClient creation error: $exception")
                            result.success("RecaptchaClient creation error: $exception")

                        }

        }
    }

    private suspend fun executeRecaptchaClient(call: MethodCall, result: Result) {

            recaptchaClient
                    .execute(RecaptchaAction.LOGIN)
                    .onSuccess { token -> result.success($token) }
                    .onFailure { exception -> result.success("executeRecaptchaClient Failure : $exception") }

    }

    override fun onDetachedFromActivity() {
        TODO("Not yet implemented")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        TODO("Not yet implemented")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity;
    }

    override fun onDetachedFromActivityForConfigChanges() {
        TODO("Not yet implemented")
    }


}
