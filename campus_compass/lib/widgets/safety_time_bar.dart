import 'package:flutter/material.dart';

class SafetyTimeBar extends StatelessWidget {
  final String text;

  const SafetyTimeBar({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF369DF4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}