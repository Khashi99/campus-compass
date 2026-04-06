import 'package:campus_compass/theme/app_colors.dart';
import 'package:campus_compass/theme/app_theme_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'onboarding_contents.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _hapticEnabled = false;
  bool _soundEnabled = false;
  bool _darkMode = false;
  @override
  void initState() {
    super.initState();
    _initTheme();
  }

  Future<void> _initTheme() async {
    await AppThemeController.instance.load();
    setState(() {
      _darkMode = AppThemeController.instance.isDarkMode;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_currentPage < contents.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      await _saveAlertPreference();
      if (!mounted) {
        return;
      }
      Navigator.pushNamed(context, '/login');
    }
  }

  Future<void> _saveAlertPreference() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'alertPreference': {
        'visual': true, // always on
        'haptic': _hapticEnabled,
        'sound': _soundEnabled,
        'quietHours': null,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void _skip() {
    _controller.animateToPage(
      contents.length - 1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: PageView.builder(
          controller: _controller,
          itemCount: contents.length,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (value) {
            setState(() => _currentPage = value);
          },
          itemBuilder: (context, index) {
            final item = contents[index];

            return Container(
              color: AppColors.pageBackground,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        if (index == 1)
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              _controller.previousPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.arrow_back_ios_new_rounded,
                                  size: 20),
                            ),
                          )
                        else
                          const SizedBox(width: 32),
                        Expanded(
                          child: Center(
                            child: Text(
                              index == 1 ? 'Personalize Alerts' : '',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                        ),
                        item.showSkip
                            ? TextButton(
                                onPressed: _skip,
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                    color: AppColors.mutedText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : SizedBox(width: 52),
                      ],
                    ),
                  ),

                  if (index == 1)
                    Divider(height: 1, thickness: 1, color: AppColors.cardBorder),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0) ...[
                            ClipRRect(borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/images/instructions_map_vector.png', 
                              width: double.infinity,
                              height: 275,
                              fit: BoxFit.contain),),
                            SizedBox(height: 26),
                          ] else ...[
                            Center(
                              child: Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryBlue.withValues(alpha: 0.20),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.notifications_active_rounded,
                                  size: 42,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],

                          Center(
                            child: Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkText,
                                height: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Center(
                            child: Text(
                              item.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.mutedText,
                                height: 1.6,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),

                          if (index == 0)
                            ...item.bullets.map((b) => _bulletTile(b)),

                          if (index == 1) ...[
                            // Visual alerts card removed
                            Card(
                              margin: const EdgeInsets.only(bottom: 22),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: AppColors.cardBorder),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
                                child: Column(
                                  children: [
                                    SwitchListTile(
                                      value: _hapticEnabled,
                                      onChanged: (val) => setState(() => _hapticEnabled = val),
                                      title: Text('Haptic feedback', style: TextStyle(fontWeight: FontWeight.w600)),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Vibrations you can feel'),
                                          SizedBox(height: 4),
                                          Text('Get a gentle vibration when an alert is triggered. Great for when your phone is in your pocket or you want a discreet cue.',
                                            style: TextStyle(fontSize: 13, color: AppColors.mutedText),
                                          ),
                                        ],
                                      ),
                                      secondary: Icon(Icons.vibration_rounded, color: AppColors.primaryBlue),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Divider(),
                                    ),
                                    SwitchListTile(
                                      value: _soundEnabled,
                                      onChanged: (val) => setState(() => _soundEnabled = val),
                                      title: Text('Sound alerts', style: TextStyle(fontWeight: FontWeight.w600)),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Audio notifications'),
                                          SizedBox(height: 4),
                                          Text('Play a sound when an alert is triggered. Useful if you want to be notified even when not looking at your device.',
                                            style: TextStyle(fontSize: 13, color: AppColors.mutedText),
                                          ),
                                        ],
                                      ),
                                      secondary: Icon(Icons.volume_up_rounded, color: AppColors.primaryBlue),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Card(
                              margin: const EdgeInsets.only(bottom: 22),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: AppColors.cardBorder),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
                                child: SwitchListTile(
                                  value: _darkMode,
                                  onChanged: (val) async {
                                    setState(() => _darkMode = val);
                                    await AppThemeController.instance.setDarkMode(val);
                                  },
                                  title: Text('Dark mode', style: TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Increases color contrast for map markers and text elements to improve legibility.'),
                                    ],
                                  ),
                                  secondary: Icon(Icons.dark_mode_outlined, color: AppColors.primaryBlue),
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            if (item.quote != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.quoteBackground,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: Text(
                                  item.quote!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.6,
                                    color: AppColors.mutedText,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        contents.length,
                        (dotIndex) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: dotIndex == _currentPage ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: dotIndex == _currentPage
                                ? AppColors.primaryBlue
                                : const Color(0xFFD1D5DB),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                    Text(
                      item.buttonText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                            ),
                            if (index == 0) ...[
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 16),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _bulletTile(OnboardingBullet bullet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              bullet.icon,
              color: bullet.iconColor,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              bullet.text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertOptionCard({
    required AlertOption option,
    required bool isSelected,
    required VoidCallback onTap,
    required Color cardBlue,
    required Color border,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.secondaryBlue.withValues(alpha: 0.18)
                : AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? cardBlue : border,
              width: isSelected ? 1.6 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isSelected
                      ? cardBlue.withValues(alpha: 0.14)
                      : AppColors.lightCircle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  option.icon,
                  color: isSelected ? cardBlue : AppColors.mutedText,
                  size: 24,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      option.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? cardBlue : border,
                    width: 1.5,
                  ),
                  color: isSelected
                      ? cardBlue.withValues(alpha: 0.08)
                      : AppColors.white,
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 16, color: AppColors.primaryBlue)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapCard({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.quoteBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
    );
  }
}

class DashedCurvePainter extends CustomPainter {
  final Color color;
  final bool flip;

  DashedCurvePainter({
    required this.color,
    this.flip = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (!flip) {
      path.moveTo(0, size.height * 0.35);
      path.quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.95,
        size.width,
        size.height * 0.15,
      );
    } else {
      path.moveTo(0, size.height * 0.8);
      path.quadraticBezierTo(
        size.width * 0.45,
        0,
        size.width,
        size.height * 0.55,
      );
    }

    final dashed = _createDashedPath(path, dashLength: 7, gapLength: 6);
    canvas.drawPath(dashed, paint);
  }

  Path _createDashedPath(
    Path source, {
    required double dashLength,
    required double gapLength,
  }) {
    final Path dashedPath = Path();

    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + dashLength;
        dashedPath.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance += dashLength + gapLength;
      }
    }

    return dashedPath;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
