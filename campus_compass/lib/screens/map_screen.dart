
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_compass/screens/alerts_screen.dart';
import 'package:campus_compass/screens/profile_screen.dart';
import 'package:campus_compass/theme/app_colors.dart';
import 'package:campus_compass/widgets/status_banner.dart';
import 'package:campus_compass/widgets/bottom_nav_bar.dart';
import 'package:campus_compass/widgets/map_placeholder.dart';
import 'package:campus_compass/widgets/incident_card.dart';
import 'package:campus_compass/models/incident.dart';
import 'package:campus_compass/screens/incident_detail_screen.dart';
import 'package:campus_compass/screens/report_incident_screen.dart';
import 'package:campus_compass/screens/safety_route_screen.dart';
import 'package:campus_compass/support/report_review_actions.dart';
import 'package:campus_compass/utils/map_highlight_position.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class _NetworkStatusBanner extends StatelessWidget {
  final bool isOffline;
  const _NetworkStatusBanner({required this.isOffline});

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: Colors.redAccent,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text(
            'You are offline. The map will update when you are back online.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Main map screen that dynamically updates based on campus status
/// This is the primary screen users see after onboarding
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
    bool _isOffline = false;
    late final Connectivity _connectivity;
    late final Stream<ConnectivityResult> _connectivityStream;
    late final StreamSubscription<ConnectivityResult> _connectivitySubscription;
  static const String _defaultCampusId = 'sgw';
  static const String _alertStylePreferenceKey = 'profile_alert_style';
  static const List<_MoreInfoResource> _moreInfoResources = [
    _MoreInfoResource(
      title: 'Services',
      description:
          'Safewalk, access requests, safety checks, and security support.',
      phone: '514-848-3717',
      link: 'https://www.concordia.ca/campus-life/security/services.html',
      offline: true,
    ),
    _MoreInfoResource(
      title: 'Emergency',
      description: 'Emergency procedures and immediate assistance.',
      phone: '514-848-3717',
      link: 'https://www.concordia.ca/campus-life/security/emergency.html',
      offline: true,
      priority: 'high',
    ),
    _MoreInfoResource(
      title: 'Prevention',
      description: 'Crime, hazard, and fire prevention tips and procedures.',
      link: 'https://www.concordia.ca/campus-life/security/prevention.html',
      offline: true,
    ),
    _MoreInfoResource(
      title: 'Training',
      description: 'Safety, prevention, and emergency training programs.',
      link: 'https://www.concordia.ca/campus-life/security/training.html',
      offline: false,
    ),
  ];

  // Current navigation tab
  int _currentNavIndex = 0;
  
  // Campus status - in real app, this comes from backend/API
  CampusStatus _campusStatus = CampusStatus.normal;
  
  // Active incidents - in real app, this comes from backend/API
  List<Incident> _activeIncidents = [];
  
  // Is high risk overlay showing?
  bool _showHighRiskOverlay = false;
  bool _isLoadingIncidents = true;
  String? _incidentLoadError;
  int _pendingReviewCount = 0;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _incidentStream;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _pendingReviewSubscription;
  final Set<String> _knownIncidentIds = <String>{};
  bool _hasPrimedIncidentAlerts = false;
  String? _cachedAlertStyle;

  @override
  void initState() {
        _connectivity = Connectivity();
        _connectivityStream = _connectivity.onConnectivityChanged;
        _connectivitySubscription = _connectivityStream.listen((result) {
          final offline = result == ConnectivityResult.none;
          if (offline != _isOffline) {
            setState(() {
              _isOffline = offline;
            });
            if (offline) {
              _showSnackBar('You are offline. The map will update when you are back online.');
            } else {
              _showSnackBar('You are back online.', isSuccess: true);
            }
          }
        });
        _connectivity.checkConnectivity().then((result) {
          final offline = result == ConnectivityResult.none;
          if (offline != _isOffline) {
            setState(() {
              _isOffline = offline;
            });
          }
        });
    super.initState();
    _incidentStream = FirebaseFirestore.instance
        .collection('incidents')
        .where('isActive', isEqualTo: true)
        .snapshots();
    _loadPendingReviewCount();
  }

  @override
  void dispose() {
      _connectivitySubscription.cancel();
    _pendingReviewSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NetworkStatusBanner(isOffline: _isOffline),
        Expanded(
          child: Scaffold(
            backgroundColor: AppColors.pageBackground,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  'assets/images/icon_prod_circ.png',
                  height: 32,
                  width: 32,
                ),
              ),
              title: Text(
                'Campus Safety Map',
                style: TextStyle(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              actions: [],
            ),
            body: Stack(
              children: [
                // Main content
                Column(
                  children: [
                    // Dynamic status banner
                    StatusBanner(
                      status: _campusStatus,
                      onMoreInfo: () => _showStatusInfo(context),
                    ),
                    
                    // Map area
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _incidentStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            _isLoadingIncidents = true;
                          } else if (snapshot.hasError) {
                            _incidentLoadError = snapshot.error.toString();
                            _isLoadingIncidents = false;
                          } else {
                            _incidentLoadError = null;
                            _isLoadingIncidents = false;
                            _activeIncidents = (snapshot.data?.docs ?? const [])
                                .where(
                                  (doc) => _matchesCampusId(
                                    doc.data()['campusId'] as String?,
                                  ),
                                )
                                .map((doc) => Incident.fromFirestore(doc))
                                .toList()
                              ..sort(
                                (a, b) => b.reportedTime.compareTo(a.reportedTime),
                              );
                            _handleIncomingIncidentAlerts(_activeIncidents);
                            _deriveCampusStatusFromIncidents();
                          }

                          return Stack(
                            children: [
                              // Map with dynamic tension zones
                              MapPlaceholder(
                                showTensionZone: _activeIncidents.isNotEmpty,
                                tensionZoneLabel: _activeIncidents.isNotEmpty
                                    ? _getTensionZoneLabel()
                                    : null,
                              ),

                              if (_isLoadingIncidents)
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),

                              if (_incidentLoadError != null)
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  right: 16,
                                  child: _buildErrorBanner(
                                    'Unable to load incidents from backend.',
                                  ),
                                ),

                              // Map legend (only show when there are incidents)
                              if (_activeIncidents.isNotEmpty)
                                const Positioned(
                                  right: 4,
                                  top: 8,
                                  child: MapLegend(),
                                ),

                              // Dynamic bottom card based on status
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: _buildBottomCard(),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                
                // High risk overlay (appears when user enters danger zone)
                if (_showHighRiskOverlay && _activeIncidents.isNotEmpty)
                  _buildHighRiskOverlay(),
              ],
            ),
            bottomNavigationBar: BottomNavBar(
              currentIndex: _currentNavIndex,
              onTap: _handleNavTap,
              alertBadgeCount: _activeIncidents.length + _pendingReviewCount,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the appropriate bottom card based on current status
  Widget _buildBottomCard() {
    switch (_campusStatus) {
      case CampusStatus.normal:
        return CalmStatusCard(
          onTap: () {
            // In real app: navigate to safety tips or history
            _showSnackBar('No active incidents. Campus is safe!');
          },
        );
      
      case CampusStatus.caution:
        return IncidentPreviewCard(
          incident: _activeIncidents.first,
          onViewDetails: () => _navigateToIncidentDetail(_activeIncidents.first),
          onNavigateToSafety: () => _navigateToSafety(_activeIncidents.first),
        );
      
      case CampusStatus.highRisk:
        return HighRiskAlertCard(
          incident: _activeIncidents.first,
          onViewDetails: () => _navigateToIncidentDetail(_activeIncidents.first),
          onNavigateToSafety: () => _navigateToSafety(_activeIncidents.first),
          onReportTrust: () => _reportTrust(_activeIncidents.first),
        );
    }
  }

  /// Gets the label for tension zone based on incident type
  String _getTensionZoneLabel() {
    if (_activeIncidents.isEmpty) return '';
    
    final incident = _activeIncidents.first;
    switch (incident.type) {
      case IncidentType.protest:
        return 'PROTEST AREA';
      case IncidentType.gathering:
        return 'GATHERING AREA';
      case IncidentType.construction:
        return 'CONSTRUCTION ZONE';
      case IncidentType.blockage:
        return 'BLOCKED ENTRANCE';
      case IncidentType.emergency:
        return 'EMERGENCY ZONE';
      case IncidentType.maintenance:
        return 'MAINTENANCE AREA';
    }
  }

  /// Builds the high risk overlay that appears when user enters danger zone
  Widget _buildHighRiskOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: SafeArea(
        child: Column(
          children: [
            // Red status banner
            const StatusBanner(status: CampusStatus.highRisk),
            
            Spacer(),
            
            // High risk alert card
            HighRiskAlertCard(
              incident: _activeIncidents.first,
              onViewDetails: () => _navigateToIncidentDetail(_activeIncidents.first),
              onNavigateToSafety: () => _navigateToSafety(_activeIncidents.first),
              onReportTrust: () => _reportTrust(_activeIncidents.first),
            ),
            
            SizedBox(height: 16),
            
            // Dismiss button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showHighRiskOverlay = false;
                  });
                },
                child: Text(
                  'Dismiss Alert',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ============ ACTIONS ============

  void _deriveCampusStatusFromIncidents() {
    if (_activeIncidents.isEmpty) {
      _campusStatus = CampusStatus.normal;
      _showHighRiskOverlay = false;
      return;
    }

    final hasHighRisk = _activeIncidents.any(
      (incident) =>
          incident.severity >= 2 || incident.status == IncidentStatus.verified,
    );
    _campusStatus = hasHighRisk ? CampusStatus.highRisk : CampusStatus.caution;
    if (!hasHighRisk) {
      _showHighRiskOverlay = false;
    }
  }

  void _handleNavTap(int index) {
    switch (index) {
      case 0: // Map - already here
        setState(() {
          _currentNavIndex = 0;
        });
        break;
      case 1: // Report
        _openScreen(const ReportIncidentScreen());
        break;
      case 2: // Alerts
        _openScreen(const AlertsScreen());
        break;
      case 3: // Profile
        _openScreen(const ProfileScreen());
        break;
    }
  }

  Future<void> _openScreen(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _currentNavIndex = 0;
    });
  }

  void _navigateToIncidentDetail(Incident incident) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncidentDetailScreen(
          incident: incident,
          onViewLiveMap: () => Navigator.pop(context),
          onRequestUpdate: () => _requestAlertUpdate(incident),
        ),
      ),
    );
  }

  void _navigateToSafety(Incident incident) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SafetyRouteScreen(incident: incident),
      ),
    );
  }

  Future<void> _reportTrust(Incident incident) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Sign in required to submit trust feedback.');
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final incidentRef = firestore.collection('incidents').doc(incident.id);
      final voteRef = incidentRef.collection('trustVotes').doc(user.uid);

      await firestore.runTransaction((transaction) async {
        final incidentSnap = await transaction.get(incidentRef);
        if (!incidentSnap.exists) {
          throw Exception('Incident not found.');
        }

        final voteSnap = await transaction.get(voteRef);
        final data = incidentSnap.data() ?? <String, dynamic>{};
        final currentReports = (data['userReports'] as int?) ?? 0;
        final levelRaw = (data['verificationLevel'] as String?) ?? 'unverified';
        final alreadyVoted = voteSnap.exists;
        final nextReports = alreadyVoted ? currentReports : currentReports + 1;

        final nextLevel = levelRaw == 'verified' ? 'verified' : 'userReported';
        final nextProgress = nextLevel == 'verified'
            ? 100
            : (45 + (nextReports * 6)).clamp(0, 95);

        transaction.set(voteRef, {
          'uid': user.uid,
          'vote': 'confirm',
          'submittedAt': voteSnap.exists
              ? (voteSnap.data()?['submittedAt'] ?? FieldValue.serverTimestamp())
              : FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (!alreadyVoted) {
          transaction.update(incidentRef, {
            'userReports': nextReports,
            'verificationLevel': nextLevel,
            'verificationProgress': nextProgress,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      _showSnackBar('Thank you for your feedback!', isSuccess: true);
    } catch (e) {
      _showSnackBar('Failed to submit trust vote: $e');
    }
  }

  Future<void> _requestAlertUpdate(Incident incident) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Sign in required to request an update.');
      return;
    }

    try {
      final now = FieldValue.serverTimestamp();
      await FirebaseFirestore.instance
          .collection('incidents')
          .doc(incident.id)
          .collection('updateRequests')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'message': 'Requesting a status update for this alert.',
        'requestedAt': now,
        'updatedAt': now,
      }, SetOptions(merge: true));

      _showSnackBar('Update request submitted.', isSuccess: true);
    } catch (e) {
      _showSnackBar('Failed to request update: $e');
    }
  }

  Future<void> _loadPendingReviewCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      final roleDoc = await FirebaseFirestore.instance
          .collection('roles')
          .doc(user.uid)
          .get();
      final role = (roleDoc.data()?['role'] as String?) ?? '';

      if (role != 'staff' && role != 'admin') {
        return;
      }

      await ReportReviewActions.migrateSubmittedReportsToReported();

      _pendingReviewSubscription = FirebaseFirestore.instance
          .collection('incidentReports')
          .orderBy('reportedTime', descending: true)
          .snapshots()
          .listen((snapshot) {
        final pendingCount = snapshot.docs
          .where((doc) => (doc.data()['status'] as String?) == 'reported')
          .where((doc) => doc.data()['linkedIncidentId'] == null)
            .length;

        if (!mounted) {
          return;
        }
        setState(() {
          _pendingReviewCount = pendingCount;
        });
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _pendingReviewCount = 0;
      });
    }
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.statusCaution.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.statusCaution.withValues(alpha: 0.35)),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: AppColors.darkText,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showStatusInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _campusStatus.color.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _campusStatus == CampusStatus.normal
                              ? Icons.check_circle
                              : (_campusStatus == CampusStatus.caution
                                  ? Icons.warning_amber_rounded
                                  : Icons.error),
                          color: _campusStatus.color,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '${_campusStatus.displayText} Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    _activeIncidents.isNotEmpty
                        ? _activeIncidents.first.description
                        : 'Campus is operating normally. Continue to stay aware and use the resources below if you need support.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mutedText,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Recommendations:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildRecommendation('Consider alternative routes if possible'),
                  _buildRecommendation('Stay aware of your surroundings'),
                  _buildRecommendation('Check for updates before heading out'),
                  SizedBox(height: 16),
                  Text(
                    'Security Resources',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 10),
                  ..._moreInfoResources
                      .map((resource) => _buildMoreInfoResourceCard(resource)),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Got it',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreInfoResourceCard(_MoreInfoResource resource) {
    final isHighPriority = resource.priority == 'high';
    final cardBorderColor = isHighPriority
        ? AppColors.statusHighRisk.withOpacity(0.4)
        : AppColors.cardBorder;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  resource.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              if (resource.offline)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusNormal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.statusNormal.withOpacity(0.35),
                    ),
                  ),
                  child: Text(
                    'Offline',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.statusNormal,
                    ),
                  ),
                ),
              if (isHighPriority) ...[
                SizedBox(width: 6),
                Icon(
                  Icons.priority_high_rounded,
                  size: 18,
                  color: AppColors.statusHighRisk,
                ),
              ],
            ],
          ),
          SizedBox(height: 6),
          Text(
            resource.description,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mutedText,
              height: 1.4,
            ),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (resource.phone != null)
                OutlinedButton.icon(
                  onPressed: () => _openPhone(resource.phone!),
                  icon: Icon(Icons.call, size: 16),
                  label: Text(resource.phone!),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: BorderSide(color: AppColors.primaryBlue),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              TextButton.icon(
                onPressed: () => _openExternalLink(resource.link),
                icon: Icon(Icons.open_in_new_rounded, size: 16),
                label: Text('Open link'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openExternalLink(String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _showSnackBar('Unable to open link right now.');
    }
  }

  Future<void> _openPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    final opened = await launchUrl(uri);
    if (!opened && mounted) {
      _showSnackBar('Unable to open phone dialer right now.');
    }
  }

  Widget _buildRecommendation(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.statusNormal,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.statusNormal : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleIncomingIncidentAlerts(List<Incident> incidents) {
    final currentIds = incidents.map((incident) => incident.id).toSet();

    if (!_hasPrimedIncidentAlerts) {
      _knownIncidentIds
        ..clear()
        ..addAll(currentIds);
      _hasPrimedIncidentAlerts = true;
      return;
    }

    final newIncidents = incidents
        .where((incident) => !_knownIncidentIds.contains(incident.id))
        .toList();

    _knownIncidentIds
      ..clear()
      ..addAll(currentIds);

    if (newIncidents.isEmpty) {
      return;
    }

    unawaited(_deliverAlertFeedback(newIncidents.first));
  }

  Future<void> _deliverAlertFeedback(Incident incident) async {
    if (!mounted) {
      return;
    }

    final alertStyle = await _resolveAlertStyle();
    final isSilent = alertStyle == 'silent';
    final allowVisual = alertStyle == 'visual' || alertStyle == 'haptic_visual';
    final allowHaptic = alertStyle == 'haptic' || alertStyle == 'haptic_visual';

    if (isSilent) {
      return;
    }

    if (allowHaptic) {
      if (incident.severity >= 2) {
        await HapticFeedback.heavyImpact();
      } else {
        await HapticFeedback.mediumImpact();
      }
    }

    if (allowVisual && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(
                child: Text(
                  'New incident: ${incident.title} near ${incident.location}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  messenger.hideCurrentSnackBar();
                  _navigateToIncidentDetail(incident);
                },
                child: Text(
                  'View',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                onPressed: messenger.hideCurrentSnackBar,
                icon: Icon(Icons.close, color: Colors.white, size: 20),
                tooltip: 'Close alert',
              ),
            ],
          ),
          backgroundColor: incident.severity >= 2
              ? AppColors.statusHighRisk
              : AppColors.primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<String> _resolveAlertStyle() async {
    if (_cachedAlertStyle != null) {
      return _cachedAlertStyle!;
    }

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_alertStylePreferenceKey);
    if (stored == 'haptic_visual' ||
        stored == 'visual' ||
        stored == 'haptic' ||
        stored == 'silent') {
      final savedStyle = stored!;
      _cachedAlertStyle = savedStyle;
      return savedStyle;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _cachedAlertStyle = 'haptic_visual';
      return _cachedAlertStyle!;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final mode = (snapshot.data()?['alertPreference'] as Map<String, dynamic>?)?['mode']
          as String?;
      switch (mode) {
        case 'haptic_visual':
          _cachedAlertStyle = 'haptic_visual';
          break;
        case 'visual':
          _cachedAlertStyle = 'visual';
          break;
        case 'silent':
          _cachedAlertStyle = 'silent';
          break;
        case 'haptic':
          _cachedAlertStyle = 'haptic';
          break;
        default:
          _cachedAlertStyle = 'haptic_visual';
          break;
      }
    } catch (_) {
      _cachedAlertStyle = 'haptic_visual';
    }

    return _cachedAlertStyle!;
  }

  bool _matchesCampusId(String? rawCampusId) {
    final target = _normalizeCampusId(_defaultCampusId);
    final source = _normalizeCampusId(rawCampusId);
    return source == target;
  }

  String _normalizeCampusId(String? campusId) {
    final value = (campusId ?? '').trim().toLowerCase();
    if (value == 'loy' || value.contains('loyola')) {
      return 'loyola';
    }
    if (value.isEmpty ||
        value == 'sgw' ||
        value == 'main' ||
        value == 'main campus' ||
        value == 'main-campus' ||
        value.contains('downtown')) {
      return 'sgw';
    }
    return value;
  }
}

class _MoreInfoResource {
  const _MoreInfoResource({
    required this.title,
    required this.description,
    required this.link,
    required this.offline,
    this.phone,
    this.priority,
  });

  final String title;
  final String description;
  final String? phone;
  final String link;
  final bool offline;
  final String? priority;
}

/// Temporary placeholder for incident detail screen
/// We'll create the full version next
class _IncidentDetailPlaceholder extends StatelessWidget {
  final Incident incident;
  
  const _IncidentDetailPlaceholder({required this.incident});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incident Detail'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 64,
                color: AppColors.mutedText,
              ),
              SizedBox(height: 16),
              Text(
                incident.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Full incident detail screen coming next!',
                style: TextStyle(color: AppColors.mutedText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
