import 'package:campus_compass/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:campus_compass/utils/app_haptics.dart';
import 'onboarding_contents.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  int _selectedAlertIndex = 1; // Haptic selected by default
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_isSubmitting) {
      return;
    }

    if (_currentPage < contents.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() => _isSubmitting = true);
      try {
        await _saveAlertPreference();
      } catch (error) {
        debugPrint('Failed to save alert preference: $error');
      }

      if (!mounted) {
        return;
      }

      setState(() => _isSubmitting = false);
      Navigator.pushNamed(context, '/login');
    }
  }

  Future<void> _saveAlertPreference() async {
    if (Firebase.apps.isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final mode = switch (_selectedAlertIndex) {
      0 => 'visual',
      1 => 'haptic',
      _ => 'silent',
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
          'alertPreference': {
            'mode': mode,
            'quietHours': null,
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        .timeout(const Duration(seconds: 6));
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
                            //TODO: finalize either custom symbols Hero card or use iilustration
                            // _screenOneHero(AppColors.pageBackground, AppColors.primaryBlue),
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
                                  color: AppColors.lightCircle,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.notifications_none_rounded,
                                  size: 42,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            SizedBox(height: 28),
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
                          SizedBox(height: 14),
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
                          SizedBox(height: 26),

                          if (index == 0)
                            ...item.bullets.map((b) => _bulletTile(b)),

                          if (index == 1) ...[
                            for (int i = 0; i < item.alertOptions.length; i++)
                              _alertOptionCard(
                                option: item.alertOptions[i],
                                isSelected: i == _selectedAlertIndex,
                                onTap: () {
                                  AppHaptics.selection();
                                  setState(() => _selectedAlertIndex = i);
                                },
                                cardBlue: AppColors.primaryBlue,
                                border: AppColors.cardBorder,
                              ),
                            SizedBox(height: 18),
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
                        onPressed: _isSubmitting ? null : _nextPage,
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
                              _isSubmitting ? 'Saving...' : item.buttonText,
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

  //custom symbols Hero card
  Widget _screenOneHero(Color pageBg, Color blue) {
    return Container(
      width: double.infinity,
      height: 255,
      decoration: BoxDecoration(
        color: pageBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 38,
            top: 48,
            child: Transform.rotate(
              angle: 0.06,
              child: _mapCard(width: 92, height: 62),
            ),
          ),
          Positioned(
            right: 42,
            top: 95,
            child: Transform.rotate(
              angle: -0.03,
              child: _mapCard(width: 92, height: 96),
            ),
          ),
          Positioned(
            left: 78,
            top: 120,
            child: Transform.rotate(
              angle: 0.08,
              child: _mapCard(width: 92, height: 62),
            ),
          ),
          Positioned(
            left: 36,
            top: 142,
            child: Icon(Icons.location_on_outlined,
                size: 26, color: Color(0xFF111827)),
          ),
          Positioned(
            right: 64,
            top: 36,
            child: Icon(Icons.place_outlined,
                size: 24, color: Color(0xFF4ADE80)),
          ),

          Positioned(
            top: 24,
            left: 42,
            child: SizedBox(
              width: 220,
              height: 90,
              child: CustomPaint(
                painter: DashedCurvePainter(
                  color: const Color(0xFFBFDBFE),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 28,
            left: 36,
            child: SizedBox(
              width: 250,
              height: 60,
              child: CustomPaint(
                painter: DashedCurvePainter(
                  color: const Color(0xFFBBF7D0),
                  flip: true,
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: blue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: blue.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Secure Campus',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
