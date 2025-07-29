import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:spotibook2/Stripe/status_view.dart';
import 'package:spotibook2/env.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<void> makePayment(BuildContext context) async {
    try {
      String? paymentIntentClientSecret =
          await _createPaymentIntent(100, 'mxn');

      if (paymentIntentClientSecret == null) return;

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentClientSecret,
              merchantDisplayName: 'PetWalks Enterprise'));

      await _processPayment(context);
    } catch (e) {
      print(e.toString());
      _navigateToStatusScreen(context, 'Error', e.toString());
    }
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();

      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": currency,
        "description": 'description'
      };
      var response = await dio.post('https://api.stripe.com/v1/payment_intents',
          data: data,
          options:
              Options(contentType: Headers.formUrlEncodedContentType, headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": 'application/x-www-form-urlencoded'
          }));

      if (response.data != null) {
        return response.data['client_secret'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _processPayment(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      _navigateToStatusScreen(
        context,
        'Success',
        'Payment completed successfully!',
      );
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        // User cancelled the payment sheet - ignore silently
        return;
      }
      _navigateToStatusScreen(
          context, 'Error', e.error.localizedMessage ?? e.toString());
    } catch (e) {
      _navigateToStatusScreen(context, 'Error', e.toString());
    }
  }

  String _calculateAmount(int amount) {
    return (amount * 100).toString();
  }

  Future<void> makePaymentPremium(BuildContext context) async {
    try {
      String? paymentIntentClientSecret = await _createPaymentIntent(29, 'mxn');

      if (paymentIntentClientSecret == null) return;

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentClientSecret,
        merchantDisplayName: 'PetWalks Enterprise',
      ));

      await _processPayment(context);
    } catch (e) {
      print(e.toString());
      _navigateToStatusScreen(context, 'Error', e.toString());
    }
  }

  void _navigateToStatusScreen(
      BuildContext context, String status, String message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PaymentStatusScreen(status: status, message: message),
      ),
    );
  }
}
