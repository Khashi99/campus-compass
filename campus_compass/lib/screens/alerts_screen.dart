import 'package:campus_compass/models/incident.dart';
import 'package:campus_compass/screens/incident_detail_screen.dart';
import 'package:campus_compass/support/report_review_actions.dart';
import 'package:campus_compass/theme/app_colors.dart';
import 'package:campus_compass/theme/app_theme_controller.dart';
import 'package:campus_compass/utils/campus_time.dart';
import 'package:campus_compass/utils/incident_haptics.dart';
import 'package:campus_compass/utils/incident_sounds.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_compass/widgets/report_review_details.dart';
import 'package:campus_compass/models/alert_feed_item.dart';
import 'package:campus_compass/widgets/alert_widgets.dart';
import 'package:campus_compass/utils/alert_helpers.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key, this.campusId = 'sgw', this.onBack});

  final String campusId;
  final VoidCallback? onBack;

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  static const _readAlertsKey = 'alerts_read_items';

  String _role = '';
  bool _isLoadingRole = true;
  bool _isLoadingReadState = true;
  bool _isMarkingAllRead = false;
  int _visibleUnreadCount = 0;
  Set<String> _readAlertIds = <String>{};

  bool get _canReview => _role == 'staff' || _role == 'admin';

  @override
  void initState() {
    super.initState();
    _loadRole();
    _loadReadState();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return AnimatedBuilder(
      animation: AppThemeController.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'Alerts',
              style: TextStyle(
                color: AppColors.darkText,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: _handleBack,
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.darkText,
                size: 16,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.cardBorder),
            ),
          ),
          body: user == null
              ? Center(
                  child: Text(
                    'Sign in required to view alerts.',
                    style: TextStyle(color: AppColors.mutedText),
                  ),
                )
              : _buildAlertFeed(),
          // bottomNavigationBar removed: handled by HomeScreen
        );
      },
    );
  }

  Widget _buildAlertFeed() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('incidents')
          .orderBy('updatedAt', descending: true)
          .limit(40)
          .snapshots(),
      builder: (context, incidentSnapshot) {
        if (incidentSnapshot.hasError) {
          return _buildErrorState('Unable to load alert activity right now.');
        }

        final incidentItems = _buildIncidentItems(
          incidentSnapshot.data?.docs ?? const [],
        );

        if (_canReview) {
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('incidentReports')
                .orderBy('reportedTime', descending: true)
                .limit(20)
                .snapshots(),
            builder: (context, reviewSnapshot) {
              if (reviewSnapshot.hasError) {
                return _buildErrorState(
                  'Unable to load alert activity right now.',
                );
              }

              final reviewItems = _buildReviewItems(
                reviewSnapshot.data?.docs ?? const [],
              );
              final feedItems = [...reviewItems, ...incidentItems]
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
              return _buildAlertFeedContent(
                items: feedItems,
                isLoading:
                    _isLoadingRole ||
                    _isLoadingReadState ||
                    incidentSnapshot.connectionState ==
                        ConnectionState.waiting ||
                    reviewSnapshot.connectionState == ConnectionState.waiting,
              );
            },
          );
        }

        return _buildAlertFeedContent(
          items: incidentItems,
          isLoading:
              _isLoadingRole ||
              _isLoadingReadState ||
              incidentSnapshot.connectionState == ConnectionState.waiting,
        );
      },
    );
  }

  void _handleBack() {
    final onBack = widget.onBack;
    if (onBack != null) {
      onBack();
      return;
    }
    if (Navigator.canPop(context)) {
      context.pop();
    } else {
      context.go('/home/map');
    }
  }

  Widget _buildAlertFeedContent({
    required List<AlertFeedItem> items,
    required bool isLoading,
  }) {
    final groupedItems = _groupItemsByDate(items);
    final unreadCount = items
        .where((item) => !_readAlertIds.contains(item.id))
        .length;
    _syncUnreadBadge(unreadCount);

    if (isLoading && items.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (isLoading)
          const LinearProgressIndicator(
            minHeight: 2,
            backgroundColor: Colors.transparent,
          ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Text(
                        'RECENT ACTIVITY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: AppColors.mutedText,
                        ),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: unreadCount == 0 || _isMarkingAllRead
                            ? null
                            : () => _markAllAsRead(items),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: _isMarkingAllRead
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Mark all as read',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              if (groupedItems.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyAlertState(),
                )
              else
                ..._buildGroupedActivitySlivers(groupedItems),
              if (groupedItems.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 28, 0, 36),
                    child: FeedFooter(showMuted: unreadCount == 0),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildGroupedActivitySlivers(
    List<MapEntry<String, List<AlertFeedItem>>> groupedItems,
  ) {
    final slivers = <Widget>[];

    for (final entry in groupedItems) {
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.only(top: 18),
          sliver: SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            sliver: SliverToBoxAdapter(
              child: Text(
                entry.key,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.mutedText,
                ),
              ),
            ),
          ),
        ),
      );

      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.only(top: 10),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final childIndex = index ~/ 2;
                if (index.isOdd) {
                  return Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.cardBorder,
                  );
                }

                final item = entry.value[childIndex];
                final isUnread = !_readAlertIds.contains(item.id);
                return AlertActivityRow(
                  item: item,
                  isUnread: isUnread,
                  onTap: () => _handleAlertTap(item),
                );
              },
              childCount: entry.value.isEmpty
                  ? 0
                  : (entry.value.length * 2) - 1,
            ),
          ),
        ),
      );
    }

    return slivers;
  }

  List<AlertFeedItem> _buildIncidentItems(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .where((doc) => _matchesCampusId(doc.data()['campusId'] as String?))
        .map((doc) {
          final incident = Incident.fromFirestore(doc);
          final data = doc.data();
          final updatedAt =
              asDateTime(data['updatedAt']) ?? incident.reportedTime;

          return AlertFeedItem(
            id: 'incident_${doc.id}',
            title: incidentActionLabel(incident),
            location: incident.location,
            timestamp: updatedAt,
            detailLine: detailLineForTimestamp(updatedAt),
            kind: kindForIncident(incident),
            incident: incident,
            incidentDoc: doc,
          );
        })
        .toList();
  }

  List<AlertFeedItem> _buildReviewItems(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .where((doc) => (doc.data()['status'] as String?) == 'reported')
        .where((doc) => doc.data()['linkedIncidentId'] == null)
        .where((doc) => _matchesCampusId(doc.data()['campusId'] as String?))
        .map((doc) {
          final data = doc.data();
          final timestamp =
              asDateTime(data['reportedTime']) ?? DateTime.now().toUtc();

          return AlertFeedItem(
            id: 'review_${doc.id}',
            title: 'Incident reported',
            location: (data['location'] as String?) ?? 'Unknown location',
            timestamp: timestamp,
            detailLine: detailLineForTimestamp(timestamp),
            kind: AlertFeedKind.warning,
            reportDoc: doc,
            description:
                (data['description'] as String?) ?? 'No description provided.',
          );
        })
        .toList();
  }

  bool _matchesCampusId(String? rawCampusId) {
    final target = _normalizeCampusId(widget.campusId);
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

  List<MapEntry<String, List<AlertFeedItem>>> _groupItemsByDate(
    List<AlertFeedItem> items,
  ) {
    final grouped = <String, List<AlertFeedItem>>{};
    for (final item in items) {
      final label = groupLabel(item.timestamp);
      grouped.putIfAbsent(label, () => <AlertFeedItem>[]).add(item);
    }
    return grouped.entries.toList();
  }

  // Uses helpers in alert_helpers.dart: groupLabel, detailLineForTimestamp

  Future<void> _handleAlertTap(AlertFeedItem item) async {
    await _markAsRead(item.id);

    if (item.reportDoc != null) {
      await _showReviewSheet(item.reportDoc!, item);
      return;
    }

    final incident = item.incident;
    if (incident == null) {
      return;
    }

    if (_canReview && item.incidentDoc != null) {
      await _showIncidentManagementSheet(item.incidentDoc!, incident);
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncidentDetailScreen(
          incident: incident,
          onViewLiveMap: () => context.go('/home/map'),
          onRequestUpdate: () => _requestAlertUpdate(incident),
        ),
      ),
    );
  }

  Future<void> _showIncidentManagementSheet(
    QueryDocumentSnapshot<Map<String, dynamic>> incidentDoc,
    Incident incident,
  ) async {
    if (!mounted) {
      return;
    }

    final data = incidentDoc.data();
    final status = (data['status'] as String?) ?? 'reported';
    final title = (data['title'] as String?) ?? incident.title;
    final location = (data['location'] as String?) ?? incident.location;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '$location • ${prettyStatus(status)}',
                  style: TextStyle(fontSize: 14, color: AppColors.mutedText),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (!mounted) {
                        return;
                      }
                      Navigator.push(
                        this.context,
                        MaterialPageRoute(
                          builder: (context) => IncidentDetailScreen(
                            incident: incident,
                            onViewLiveMap: () => context.go('/home/map'),
                            onRequestUpdate: () =>
                                _requestAlertUpdate(incident),
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: BorderSide(
                        color: AppColors.primaryBlue,
                        width: 1.0,
                      ),
                      minimumSize: Size.fromHeight(50),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text('View details'),
                  ),
                ),
                SizedBox(height: 10),
                if (status == 'reported')
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _setIncidentStatus(
                              incidentDoc: incidentDoc,
                              nextStatus: 'investigating',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            minimumSize: Size.fromHeight(50),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text('Move to Investigating'),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _deleteIncident(
                              incidentDoc: incidentDoc,
                              reasonLabel: 'declined',
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.statusHighRisk,
                            side: BorderSide(
                              color: AppColors.statusHighRisk,
                              width: 1.0,
                            ),
                            minimumSize: Size.fromHeight(50),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text('Decline and Delete Incident'),
                        ),
                      ),
                    ],
                  ),
                if (status == 'investigating')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _setIncidentStatus(
                          incidentDoc: incidentDoc,
                          nextStatus: 'verified',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        minimumSize: Size.fromHeight(50),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text('Mark as Verified'),
                    ),
                  ),
                if (status == 'verified')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _setIncidentStatus(
                          incidentDoc: incidentDoc,
                          nextStatus: 'resolved',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusNormal,
                        foregroundColor: Colors.white,
                        minimumSize: Size.fromHeight(50),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text('Mark as Resolved'),
                    ),
                  ),
                if (status == 'resolved')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _setIncidentStatus(
                          incidentDoc: incidentDoc,
                          nextStatus: 'investigating',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        minimumSize: Size.fromHeight(50),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text('Reopen (Move to Investigating)'),
                    ),
                  ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _deleteIncident(
                        incidentDoc: incidentDoc,
                        reasonLabel: 'deleted',
                      );
                    },
                    icon: Icon(Icons.delete_outline),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.statusHighRisk,
                      side: BorderSide(color: AppColors.statusHighRisk),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    label: Text('Delete Incident'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showReviewSheet(
    QueryDocumentSnapshot<Map<String, dynamic>> reportDoc,
    AlertFeedItem item,
  ) async {
    if (!mounted) {
      return;
    }

    final data = reportDoc.data();
    final title = (data['title'] as String?) ?? item.title;
    final location = (data['location'] as String?) ?? item.location;
    final description =
        (data['description'] as String?) ?? item.description ?? '';

    final reportedTime = data['reportedTime'];
    final incidentTimeLabel = reportedTime is Timestamp
        ? (reportedTime.toDate()).toLocal().toString()
        : '';
    final evidence = (data['evidence'] as List?)
        ?.map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.cardBorder,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      SizedBox(height: 18),

                      /// 👇 THIS FIXES OVERFLOW
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReportReviewDetails(
                                title: title,
                                typeLabel: data['type'] as String?,
                                location: location,
                                description: description,
                                incidentTimeLabel: incidentTimeLabel,
                                evidence:
                                    evidence as List<Map<String, dynamic>>?,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await _dismissReport(reportDoc);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.mutedText,
                                side: BorderSide(
                                  color: AppColors.cardBorder,
                                  width: 1.0,
                                ),
                                minimumSize: Size.fromHeight(50),
                              ),
                              child: Text('Dismiss'),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await _approveReport(reportDoc);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                minimumSize: Size.fromHeight(50),
                              ),
                              child: Text('Approve'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _markAsRead(String id) async {
    if (_readAlertIds.contains(id)) {
      return;
    }

    final updatedIds = {..._readAlertIds, id};
    setState(() {
      _readAlertIds = updatedIds;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_readAlertsKey, updatedIds.toList());
  }

  Future<void> _markAllAsRead(List<AlertFeedItem> items) async {
    setState(() {
      _isMarkingAllRead = true;
    });

    try {
      final updatedIds = {..._readAlertIds, ...items.map((item) => item.id)};
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_readAlertsKey, updatedIds.toList());

      if (!mounted) {
        return;
      }
      setState(() {
        _readAlertIds = updatedIds;
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isMarkingAllRead = false;
      });
    }
  }

  Future<void> _loadReadState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    setState(() {
      _readAlertIds = {
        ...prefs.getStringList(_readAlertsKey) ?? const <String>[],
      };
      _isLoadingReadState = false;
    });
  }

  Future<void> _loadRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _role = '';
        _isLoadingRole = false;
      });
      return;
    }

    try {
      final roleDoc = await FirebaseFirestore.instance
          .collection('roles')
          .doc(user.uid)
          .get();
      final role = (roleDoc.data()?['role'] as String?) ?? '';

      if (role == 'staff' || role == 'admin') {
        await ReportReviewActions.migrateSubmittedReportsToReported();
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _role = role;
        _isLoadingRole = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _role = '';
        _isLoadingRole = false;
      });
    }
  }

  Future<void> _approveReport(
    QueryDocumentSnapshot<Map<String, dynamic>> reportDoc,
  ) async {
    try {
      await ReportReviewActions.approveReport(reportDoc);
      await IncidentHaptics.playForEvent(IncidentHapticEvent.reportApproved);
      await IncidentSounds.playForEvent(IncidentSoundEvent.reportApproved);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report approved and published.')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Approval failed: $e')));
    }
  }

  Future<void> _dismissReport(
    QueryDocumentSnapshot<Map<String, dynamic>> reportDoc,
  ) async {
    try {
      await ReportReviewActions.dismissReport(reportDoc);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report dismissed.')));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Dismiss failed: $e')));
    }
  }

  Future<void> _requestAlertUpdate(Incident incident) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

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
  }

  Future<void> _setIncidentStatus({
    required QueryDocumentSnapshot<Map<String, dynamic>> incidentDoc,
    required String nextStatus,
  }) async {
    try {
      if (nextStatus == 'investigating') {
        await incidentDoc.reference.update({
          'status': 'investigating',
          'isActive': true,
          'resolvedAt': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await _updateLinkedReports(
          incidentId: incidentDoc.id,
          status: 'investigating',
        );
        await IncidentHaptics.playForEvent(
          IncidentHapticEvent.reportedToInvestigating,
        );
        await IncidentSounds.playForEvent(
          IncidentSoundEvent.reportedToInvestigating,
        );

        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incident moved to investigating.')),
        );
        return;
      }

      if (nextStatus == 'resolved') {
        await incidentDoc.reference.update({
          'status': 'resolved',
          'isActive': false,
          'resolvedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await _updateLinkedReports(
          incidentId: incidentDoc.id,
          status: 'resolved',
        );
        await IncidentHaptics.playForEvent(
          IncidentHapticEvent.escalatedToVerifiedOrResolved,
        );
        await IncidentSounds.playForEvent(
          IncidentSoundEvent.escalatedToVerifiedOrResolved,
        );

        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incident marked as resolved.')),
        );
        return;
      }

      if (nextStatus == 'verified') {
        await incidentDoc.reference.update({
          'status': 'verified',
          'isActive': true,
          'resolvedAt': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await _updateLinkedReports(
          incidentId: incidentDoc.id,
          status: 'verified',
        );
        await IncidentHaptics.playForEvent(
          IncidentHapticEvent.escalatedToVerifiedOrResolved,
        );
        await IncidentSounds.playForEvent(
          IncidentSoundEvent.escalatedToVerifiedOrResolved,
        );

        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incident marked as verified.')),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status update failed: $e')));
    }
  }

  Future<void> _deleteIncident({
    required QueryDocumentSnapshot<Map<String, dynamic>> incidentDoc,
    required String reasonLabel,
  }) async {
    if (!mounted) {
      return;
    }

    final data = incidentDoc.data();
    final title = (data['title'] as String?) ?? 'this incident';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Delete incident?'),
          content: Text('This will permanently remove "$title" from alerts.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _updateLinkedReports(
        incidentId: incidentDoc.id,
        status: 'dismissed',
      );
      await incidentDoc.reference.delete();

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incident $reasonLabel and removed.')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Future<void> _updateLinkedReports({
    required String incidentId,
    required String status,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final linkedReports = await firestore
        .collection('incidentReports')
        .where('linkedIncidentId', isEqualTo: incidentId)
        .get();

    if (linkedReports.docs.isEmpty) {
      return;
    }

    final batch = firestore.batch();
    for (final report in linkedReports.docs) {
      batch.update(report.reference, {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.mutedText, height: 1.4),
        ),
      ),
    );
  }

  void _syncUnreadBadge(int unreadCount) {
    if (_visibleUnreadCount == unreadCount) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _visibleUnreadCount == unreadCount) {
        return;
      }
      setState(() {
        _visibleUnreadCount = unreadCount;
      });
    });
  }
}
