import 'package:flutter/material.dart';
import 'package:spotibook2/Stripe/stripe_service.dart';

class StripeComponent extends StatefulWidget {
  const StripeComponent({super.key});

  @override
  State<StripeComponent> createState() => _StripeComponentState();
}

class _StripeComponentState extends State<StripeComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Builder(builder: (context) {
              return OutlinedButton(
                  onPressed: () {
                    StripeService.instance.makePayment(context);
                  },
                  child: const Text('makePayment'));
            }),
            Builder(builder: (context) {
              return OutlinedButton(
                  onPressed: () {
                    StripeService.instance.makePaymentPremium(context);
                  },
                  child: const Text('makePaymentPremium'));
            }),
          ],
        ),
      ),
    );
  }
}
