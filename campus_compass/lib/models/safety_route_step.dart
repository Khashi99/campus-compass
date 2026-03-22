import 'package:flutter/material.dart';

class SafetyRouteStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isFinalStep;

  const SafetyRouteStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isFinalStep = false,
  });
}