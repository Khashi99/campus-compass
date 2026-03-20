import 'package:flutter/material.dart';
import 'package:campus_compass/theme/app_colors.dart';
import 'package:campus_compass/widgets/status_banner.dart';
import 'package:campus_compass/widgets/bottom_nav_bar.dart';
import 'package:campus_compass/widgets/map_placeholder.dart';
import 'package:campus_compass/widgets/incident_card.dart';
import 'package:campus_compass/models/incident.dart';
import 'package:campus_compass/screens/incident_detail_screen.dart';

/// Main map screen that dynamically updates based on campus status
/// This is the primary screen users see after onboarding
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Current navigation tab
  int _currentNavIndex = 0;
  
  // Campus status - in real app, this comes from backend/API
  CampusStatus _campusStatus = CampusStatus.normal;
  
  // Active incidents - in real app, this comes from backend/API
  List<Incident> _activeIncidents = [];
  
  // Is high risk overlay showing?
  bool _showHighRiskOverlay = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Dynamic status banner
              StatusBanner(
                status: _campusStatus,
                onMoreInfo: _campusStatus != CampusStatus.normal 
                    ? () => _showStatusInfo(context) 
                    : null,
              ),
              
              // Map area
              Expanded(
                child: Stack(
                  children: [
                    // Map with dynamic tension zones
                    MapPlaceholder(
                      showTensionZone: _activeIncidents.isNotEmpty,
                      tensionZoneLabel: _activeIncidents.isNotEmpty 
                          ? _getTensionZoneLabel() 
                          : null,
                      tensionZonePosition: const Offset(100, 180),
                    ),
                    
                    // Map legend (only show when there are incidents)
                    if (_activeIncidents.isNotEmpty)
                      const Positioned(
                        left: 16,
                        bottom: 200,
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
                ),
              ),
            ],
          ),
          
          // High risk overlay (appears when user enters danger zone)
          if (_showHighRiskOverlay && _activeIncidents.isNotEmpty)
            _buildHighRiskOverlay(),
          
          // Demo controls (REMOVE IN PRODUCTION)
          _buildDemoControls(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
        alertBadgeCount: _activeIncidents.length,
      ),
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
        );
      
      case CampusStatus.highRisk:
        return HighRiskAlertCard(
          incident: _activeIncidents.first,
          onViewDetails: () => _navigateToIncidentDetail(_activeIncidents.first),
          onNavigateToSafety: _navigateToSafety,
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
            
            const Spacer(),
            
            // High risk alert card
            HighRiskAlertCard(
              incident: _activeIncidents.first,
              onViewDetails: () => _navigateToIncidentDetail(_activeIncidents.first),
              onNavigateToSafety: _navigateToSafety,
              onReportTrust: () => _reportTrust(_activeIncidents.first),
            ),
            
            const SizedBox(height: 16),
            
            // Dismiss button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showHighRiskOverlay = false;
                  });
                },
                child: const Text(
                  'Dismiss Alert',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Demo controls - REMOVE IN PRODUCTION
  Widget _buildDemoControls() {
    return Positioned(
      top: 100,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DEMO MODE',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildDemoButton('Normal', CampusStatus.normal, Colors.green),
            _buildDemoButton('Caution', CampusStatus.caution, Colors.amber),
            _buildDemoButton('High Risk', CampusStatus.highRisk, Colors.red),
            const Divider(color: Colors.white24),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showHighRiskOverlay = !_showHighRiskOverlay;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _showHighRiskOverlay ? Colors.red : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Toggle Overlay',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoButton(String label, CampusStatus status, Color color) {
    final isSelected = _campusStatus == status;
    return GestureDetector(
      onTap: () => _simulateStatusChange(status),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============ ACTIONS ============

  /// Simulates status change (in real app, this comes from backend)
  void _simulateStatusChange(CampusStatus newStatus) {
    setState(() {
      _campusStatus = newStatus;
      
      // Update incidents based on status
      switch (newStatus) {
        case CampusStatus.normal:
          _activeIncidents = [];
          _showHighRiskOverlay = false;
          break;
        case CampusStatus.caution:
          _activeIncidents = [SampleData.gatheringIncident];
          _showHighRiskOverlay = false;
          break;
        case CampusStatus.highRisk:
          _activeIncidents = [SampleData.protestIncident];
          break;
      }
    });
  }

  void _handleNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
    
    // Handle navigation to other screens
    switch (index) {
      case 0: // Map - already here
        break;
      case 1: // Report
        _showSnackBar('Report incident feature coming soon!');
        break;
      case 2: // Alerts
        _showSnackBar('Alerts history coming soon!');
        break;
      case 3: // Profile
        _showSnackBar('Profile screen coming soon!');
        break;
    }
  }

  void _navigateToIncidentDetail(Incident incident) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncidentDetailScreen(
          incident: incident,
          onViewLiveMap: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _navigateToSafety() {
    _showSnackBar('Calculating safe route...', isSuccess: true);
    // In real app: Open navigation with safe route
  }

  void _reportTrust(Incident incident) {
    _showSnackBar('Thank you for your feedback!', isSuccess: true);
    // In real app: Send trust report to backend
  }

  void _showStatusInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
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
                    _campusStatus == CampusStatus.caution 
                        ? Icons.warning_amber_rounded 
                        : Icons.error,
                    color: _campusStatus.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_campusStatus.displayText} Status',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _activeIncidents.isNotEmpty 
                  ? _activeIncidents.first.description
                  : 'Status information unavailable.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.mutedText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recommendations:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            _buildRecommendation('Consider alternative routes if possible'),
            _buildRecommendation('Stay aware of your surroundings'),
            _buildRecommendation('Check for updates before heading out'),
            const SizedBox(height: 20),
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
                child: const Text(
                  'Got it',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendation(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.statusNormal,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
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
        title: const Text('Incident Detail'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.construction,
                size: 64,
                color: AppColors.mutedText,
              ),
              const SizedBox(height: 16),
              Text(
                incident.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
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