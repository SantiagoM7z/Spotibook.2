import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:spotibook2/Stripe/snackbars.dart';
import 'package:spotibook2/env.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<void> makePayment(BuildContext context, int amount, bool isYearly,
      FirebaseAuth _auth) async {
    try {
      String? paymentIntentClientSecret =
          await _createPaymentIntent(amount, 'mxn');

      if (paymentIntentClientSecret == null) return;

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentClientSecret,
              merchantDisplayName: 'PetWalks Enterprise'));

      await _processPayment(context, isYearly, _auth);
    } catch (e) {
      print(e.toString());

      showErrorSnackBar(context, e.toString());
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

  Future<void> _processPayment(
      BuildContext context, bool isYearly, FirebaseAuth auth) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      handlePro(context, isYearly, auth);
      showSuccessSnackBar(context);
      return;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        showErrorSnackBar(context, 'Payment was cancelled by the user.');
        return;
      }

      showErrorSnackBar(context, e.toString());
    } catch (e) {
      showErrorSnackBar(context, e.toString());
    }
  }

  String _calculateAmount(int amount) {
    return (amount * 100).toString();
  }
}

Future<void> handlePro(
    BuildContext context, bool isYearly, FirebaseAuth auth) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    final user = auth.currentUser;
    if (user != null) {
      final now = DateTime.now();
      final expiry = isYearly
          ? DateTime(now.year + 1, now.month, now.day)
          : DateTime(now.year, now.month + 1, now.day);

      await _firestore.collection('users').doc(user.uid).set({
        'isPremium': true,
        'premiumUntil': Timestamp.fromDate(expiry),
      }, SetOptions(merge: true));
    }
  } catch (e) {
    showErrorSnackBar(context, e.toString());
  }
}
