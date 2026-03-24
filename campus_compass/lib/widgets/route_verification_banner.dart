import 'package:flutter/material.dart';

class RouteVerificationBanner extends StatelessWidget {
  final String text;

  const RouteVerificationBanner({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF9EE),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFB8E7C3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 14,
            color: Color(0xFF22C55E),
          ),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'You are following a security-verified safety route',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF22C55E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}