import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotibook2/Stripe/snackbars.dart';
import 'package:spotibook2/Stripe/stripe_service.dart';

class StripeComponent extends StatefulWidget {
  const StripeComponent({super.key});

  @override
  State<StripeComponent> createState() => _StripeComponentState();
}

class _StripeComponentState extends State<StripeComponent> {
  bool isYearly = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _username;
  bool _isPremium = false;
  DateTime? _premiumExpiryDate;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _username = userData['username'] as String?;
            _isPremium = (userData['isPremium'] ?? false) == true;
            _premiumExpiryDate =
                (userData['premiumUntil'] as Timestamp?)?.toDate();
          });
        }
      }
    } catch (e) {
      showErrorSnackBar(context, e.toString());
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Elige tu plan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: const Color(0xff1A2323),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff181D1D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...[0, 1].map((index) {
                        final bool selected = (index == 1) == isYearly;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              isYearly = index == 1;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xff2E4D4D)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.white70,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                letterSpacing: 1.2,
                                fontSize: 15,
                              ),
                              child: Text(
                                index == 0 ? 'MENSUAL' : 'ANUAL  (AHORRA  20%)',
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (_username != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        'Hola, ${_username!} ${_isPremium ? ' (Pro User - ${_premiumExpiryDate?.toLocal().toString().split(' ')[0]})' : ''}',
                        style: const TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(height: 8),
                ],
                _buildPlanCard(
                  title: 'Hobby',
                  price: 'Free',
                  description: [
                    'Prueba Pro de 2 semanas',
                    'Subidas limitadas de libros',
                    'Descargas limitadas para lectura offline',
                    'Soporte básico',
                  ],
                  buttonText: 'Continuar',
                  buttonColor: const Color(0xff2E4D4D),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                _buildPlanCard(
                    title: 'Pro',
                    price: isYearly ? '240 MXN / año' : '20 MXN / mes',
                    description: [
                      'Incluye todo en Hobby',
                      'Subidas ilimitadas de libros',
                      'Descargas ilimitadas para lectura offline',
                      'Lectura sin anuncios',
                      'Acceso avanzado a búsqueda',
                      'Soporte prioritario',
                    ],
                    buttonText:
                        isYearly ? 'Comprar Pro Anual' : 'Comprar Pro Mensual',
                    buttonColor: const Color(0xffFF0080),
                    onPressed: () {
                      StripeService.instance
                          .makePayment(
                              context, isYearly ? 240 : 20, isYearly, _auth)
                          .then((_) {
                        _loadUser();
                      });
                    },
                    showGradient: true,
                    pro: _isPremium),
                const SizedBox(height: 30),
                const Text(
                  'Elige el plan que mejor se adapte a tus necesidades.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> description,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onPressed,
    bool showGradient = false,
    bool pro = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            if (showGradient)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withAlpha(151),
                        const Color(0xFF1f2222).withAlpha(204),
                        const Color(0xFFff8c00).withAlpha(71),
                        const Color(0xFFFF0080).withAlpha(82),
                      ],
                      stops: const [0.0, 0.5, 0.85, 1.0],
                    ),
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Builder(
                        builder: (_) {
                          final whitespaceMatch =
                              RegExp(r'\s').firstMatch(price);
                          final mainPrice = whitespaceMatch != null
                              ? price.substring(0, whitespaceMatch.start)
                              : price;
                          final trailing = whitespaceMatch != null
                              ? price.substring(whitespaceMatch.start)
                              : '';

                          return RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: mainPrice,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (trailing.isNotEmpty)
                                  TextSpan(
                                    text: trailing,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 10),
                  const Text(
                    'Everything in Hobby, plus',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: description.map((line) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2.0),
                              child: Icon(Icons.check,
                                  size: 16, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                line.replaceAll('✓', '').trim(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: !pro
                            ? onPressed
                            : () => showCustomSnackBar(
                                context, 'Ya eres Pro User de SpotyBook'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(buttonText,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
