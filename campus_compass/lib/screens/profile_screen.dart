import 'package:campus_compass/theme/app_colors.dart';
import 'package:campus_compass/theme/app_theme_controller.dart';
import 'package:campus_compass/utils/incident_sounds.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _stairsFreeKey = 'profile_stairs_free_routing';
  // Removed unused _reduceMotionKey and _hideLowRiskKey
  // Removed unused _alertStyleKey
  // Removed unused _hapticPulseCountKey

  // Onboarding alert preferences keys
  static const _onboardingHapticKey = 'profile_onboarding_haptic';
  static const _onboardingSoundKey = 'profile_onboarding_sound';

  bool _isLoadingPreferences = true;
  bool _isLoggingOut = false;

  bool _stairsFreeRouting = false;
  // Removed unused _reduceMotion and _hideLowRiskZones
  bool _darkMode = false;
  // Removed unused _selectedAlertStyle
  // Removed unused _hapticPulseCount

  // Onboarding alert preferences
  bool _onboardingHaptic = false;
  bool _onboardingSound = false;


  Future<void> _initThemeAndPreferences() async {
    await AppThemeController.instance.load();
    await _loadPreferences();
  }

  @override
  void initState() {
    super.initState();
    _initThemeAndPreferences();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Profile and Settings',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.darkText),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.cardBorder),
        ),
      ),
      body: user == null
          ? Center(
              child: Text(
                'Sign in required to view your profile.',
                style: TextStyle(color: AppColors.mutedText),
              ),
            )
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final userData =
                    snapshot.data?.data() ?? const <String, dynamic>{};
                final displayName = _displayNameForUser(userData, user);
                final email = user.email ?? 'Not provided';

                final alertPreference = userData['alertPreference'] as Map<String, dynamic>?;
                // Removed unused selectedAlertStyle


                // Defensive: ensure bools for onboarding toggles (Firestore may store null)
                _onboardingHaptic = (alertPreference?['haptic'] is bool)
                  ? alertPreference!['haptic'] as bool
                  : _onboardingHaptic;
                _onboardingSound = (alertPreference?['sound'] is bool)
                  ? alertPreference!['sound'] as bool
                  : _onboardingSound;

                // Removed unused hapticPulseCount logic

                return Column(
                  children: [
                    if (_isLoadingPreferences)
                      const LinearProgressIndicator(
                        minHeight: 2,
                        backgroundColor: Colors.transparent,
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileHeaderCard(
                              displayName: displayName,
                              email: email,
                              user: user,
                            ),
                            SizedBox(height: 22),
                            Text(
                              'Personalize for Your Comfort',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Customize how you navigate and receive safety information to reduce sensory overload and cognitive stress.',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                color: AppColors.mutedText,
                              ),
                            ),
                            SizedBox(height: 18),
                            _SectionLabel('Campus Navigation'),
                            SizedBox(height: 10),
                            _PreferenceCard(
                              children: [
                                _PreferenceSwitchTile(
                                  icon: Icons.navigation_outlined,
                                  title: 'Stairs-free routing',
                                  subtitle:
                                      'Prioritize routes with ramps and elevators.\nBest for mobility assistance.',
                                  value: _stairsFreeRouting,
                                  onChanged: (value) {
                                    _updateStairsFreeRouting(value);
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 18),
                            // Visual & Calm Controls section removed
                            _SectionLabel('Alert Preferences'),
                            SizedBox(height: 10),
                            _PreferenceCard(
                              children: [
                                _PreferenceSwitchTile(
                                  icon: Icons.vibration_rounded,
                                  title: 'Haptic feedback',
                                  subtitle: 'Vibrations you can feel',
                                  value: _onboardingHaptic,
                                  onChanged: (value) async {
                                    setState(() {
                                      _onboardingHaptic = value;
                                    });
                                    final user = FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                                        'alertPreference': {
                                          'haptic': value,
                                          'sound': _onboardingSound,
                                          'visual': true,
                                        },
                                      }, SetOptions(merge: true));
                                    }
                                  },
                                ),
                                SizedBox(height: 16),
                                Divider(height: 1, color: AppColors.cardBorder),
                                SizedBox(height: 16),
                                _PreferenceSwitchTile(
                                  icon: Icons.volume_up_rounded,
                                  title: 'Sound alerts',
                                  subtitle: 'Audio notifications',
                                  value: _onboardingSound,
                                  onChanged: (value) async {
                                    setState(() {
                                      _onboardingSound = value;
                                    });
                                    final user = FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                                        'alertPreference': {
                                          'haptic': _onboardingHaptic,
                                          'sound': value,
                                          'visual': true,
                                        },
                                      }, SetOptions(merge: true));
                                    }

                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.setBool(_onboardingSoundKey, value);

                                    if (value) {
                                      await IncidentSounds.playTestTone(
                                        ignorePreferences: true,
                                      );
                                    }
                                  },
                                ),
                                SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await IncidentSounds.playTestTone(
                                        ignorePreferences: true,
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primaryBlue,
                                      side: BorderSide(color: AppColors.primaryBlue),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: Icon(Icons.volume_up_rounded, size: 18),
                                    label: Text(
                                      'Test sound',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 18),
                            _SectionLabel('Display Preferences'),
                            SizedBox(height: 10),
                            _PreferenceCard(
                              children: [
                                _PreferenceSwitchTile(
                                  icon: Icons.dark_mode_outlined,
                                  title: 'Dark mode',
                                  subtitle: 'Increases color contrast for map markers and text elements to improve legibility.',
                                  value: _darkMode,
                                  onChanged: (value) {
                                    setState(() {
                                      _darkMode = value;
                                    });
                                    AppThemeController.instance.setDarkMode(value);
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 18),
                            // Communication Style section removed
                            // Save Changes button removed
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      // bottomNavigationBar removed: handled by HomeScreen
    );
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    // Set defaults to true if not present (except dark mode)
    bool stairsFree = prefs.getBool(_stairsFreeKey) ?? true;
    bool onboardingHaptic = prefs.getBool(_onboardingHapticKey) ?? true;
    bool onboardingSound = prefs.getBool(_onboardingSoundKey) ?? true;
    // Save defaults if not present
    if (!prefs.containsKey(_stairsFreeKey)) await prefs.setBool(_stairsFreeKey, true);
    if (!prefs.containsKey(_onboardingHapticKey)) await prefs.setBool(_onboardingHapticKey, true);
    if (!prefs.containsKey(_onboardingSoundKey)) await prefs.setBool(_onboardingSoundKey, true);

    setState(() {
      _stairsFreeRouting = stairsFree;
      _darkMode = AppThemeController.instance.isDarkMode; // dark mode remains off by default
      _onboardingHaptic = onboardingHaptic;
      _onboardingSound = onboardingSound;
      _isLoadingPreferences = false;
    });
  }

  Future<void> _updateStairsFreeRouting(bool value) async {
    setState(() {
      _stairsFreeRouting = value;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_stairsFreeKey, value);
    } catch (_) {
      // Keep UI responsive even if local persistence fails.
    }
  }

  // _saveChanges method removed

  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) {
        return;
      }
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoggingOut = false;
      });
    }
  }

  // Removed unused _handleBottomNavTap

  Widget _buildProfileHeaderCard({
    required String displayName,
    required String email,
    required User user,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AvatarBadge(displayName: displayName, photoUrl: user.photoURL),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoggingOut ? null : _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF242730),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoggingOut
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayNameForUser(Map<String, dynamic> userData, User user) {
    final profileName = (userData['displayName'] as String?)?.trim();
    if (profileName != null && profileName.isNotEmpty) {
      return profileName;
    }

    final authName = user.displayName?.trim();
    if (authName != null && authName.isNotEmpty) {
      return authName;
    }

    final email = user.email?.trim();
    if (email != null && email.contains('@')) {
      final localPart = email.split('@').first.replaceAll('.', ' ').trim();
      if (localPart.isNotEmpty) {
        return localPart
            .split(RegExp(r'\s+'))
            .map(
              (word) => word.isEmpty
                  ? word
                  : '${word[0].toUpperCase()}${word.substring(1)}',
            )
            .join(' ');
      }
    }

    return user.isAnonymous ? 'Guest User' : 'Campus User';
  }

  // Removed unused _alertStyleFromBackend

  // Removed unused _backendAlertMode

  // Removed unused _sanitizeAlertStyle

  // Removed unused _sanitizeHapticPulseCount
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.mutedText,
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _PreferenceSwitchTile extends StatelessWidget {
  const _PreferenceSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F7FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 20),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppColors.primaryBlue,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFC9CEDA),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.displayName, required this.photoUrl});

  final String displayName;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      return CircleAvatar(radius: 24, backgroundImage: NetworkImage(photoUrl!));
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7DD3FC), Color(0xFF3B82F6)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(displayName),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  static String _initials(String displayName) {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .take(2)
        .toList();

    if (parts.isEmpty) {
      return 'CU';
    }

    return parts.map((part) => part[0].toUpperCase()).join();
  }
}
