import 'package:campus_compass/models/incident.dart';
import 'package:campus_compass/screens/incident_detail_screen.dart';
import 'package:campus_compass/support/report_review_actions.dart';
import 'package:campus_compass/theme/app_colors.dart';
import 'package:campus_compass/theme/app_theme_controller.dart';
import 'package:campus_compass/utils/campus_time.dart';
import 'package:campus_compass/utils/incident_sounds.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: _handleBack,
              icon: Icon(Icons.arrow_back_ios_new, color: AppColors.darkText),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: AppColors.cardBorder,
              ),
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

        final incidentItems = _buildIncidentItems(incidentSnapshot.data?.docs ?? const []);

        if (_canReview) {
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('incidentReports')
                .orderBy('reportedTime', descending: true)
                .limit(20)
                .snapshots(),
            builder: (context, reviewSnapshot) {
              if (reviewSnapshot.hasError) {
                return _buildErrorState('Unable to load alert activity right now.');
              }

              final reviewItems = _buildReviewItems(reviewSnapshot.data?.docs ?? const []);
              final feedItems = [...reviewItems, ...incidentItems]
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
              return _buildAlertFeedContent(
                items: feedItems,
                isLoading: _isLoadingRole ||
                    _isLoadingReadState ||
                    incidentSnapshot.connectionState == ConnectionState.waiting ||
                    reviewSnapshot.connectionState == ConnectionState.waiting,
              );
            },
          );
        }

        return _buildAlertFeedContent(
          items: incidentItems,
          isLoading: _isLoadingRole ||
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
    Navigator.maybePop(context);
  }

  Widget _buildAlertFeedContent({
    required List<_AlertFeedItem> items,
    required bool isLoading,
  }) {
    final groupedItems = _groupItemsByDate(items);
    final unreadCount = items.where((item) => !_readAlertIds.contains(item.id)).length;
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
                                child: CircularProgressIndicator(strokeWidth: 2),
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
                  child: _EmptyAlertState(),
                )
              else
                ..._buildGroupedActivitySlivers(groupedItems),
              if (groupedItems.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 28, 0, 36),
                    child: _FeedFooter(showMuted: unreadCount == 0),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildGroupedActivitySlivers(
    List<MapEntry<String, List<_AlertFeedItem>>> groupedItems,
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
                return _AlertActivityRow(
                  item: item,
                  isUnread: isUnread,
                  onTap: () => _handleAlertTap(item),
                );
              },
              childCount: entry.value.isEmpty ? 0 : (entry.value.length * 2) - 1,
            ),
          ),
        ),
      );
    }

    return slivers;
  }

  List<_AlertFeedItem> _buildIncidentItems(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .where(
          (doc) => _matchesCampusId(doc.data()['campusId'] as String?),
        )
        .map((doc) {
          final incident = Incident.fromFirestore(doc);
          final data = doc.data();
          final updatedAt = _asDateTime(data['updatedAt']) ?? incident.reportedTime;

          return _AlertFeedItem(
            id: 'incident_${doc.id}',
            title: _incidentActionLabel(incident),
            location: incident.location,
            timestamp: updatedAt,
            detailLine: _detailLineForTimestamp(updatedAt),
            kind: _kindForIncident(incident),
            incident: incident,
            incidentDoc: doc,
          );
        })
        .toList();
  }

  List<_AlertFeedItem> _buildReviewItems(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .where((doc) => (doc.data()['status'] as String?) == 'reported')
        .where((doc) => doc.data()['linkedIncidentId'] == null)
        .where(
          (doc) => _matchesCampusId(doc.data()['campusId'] as String?),
        )
        .map((doc) {
          final data = doc.data();
          final timestamp = _asDateTime(data['reportedTime']) ?? DateTime.now().toUtc();

          return _AlertFeedItem(
            id: 'review_${doc.id}',
            title: 'Incident reported',
            location: (data['location'] as String?) ?? 'Unknown location',
            timestamp: timestamp,
            detailLine: _detailLineForTimestamp(timestamp),
            kind: _AlertFeedKind.warning,
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

  List<MapEntry<String, List<_AlertFeedItem>>> _groupItemsByDate(
    List<_AlertFeedItem> items,
  ) {
    final grouped = <String, List<_AlertFeedItem>>{};
    for (final item in items) {
      final label = _groupLabel(item.timestamp);
      grouped.putIfAbsent(label, () => <_AlertFeedItem>[]).add(item);
    }
    return grouped.entries.toList();
  }

  String _groupLabel(DateTime timestamp) {
    final easternTimestamp = CampusTime.toEastern(timestamp);
    final nowEastern = CampusTime.toEastern(DateTime.now());
    final today = DateTime(nowEastern.year, nowEastern.month, nowEastern.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(
      easternTimestamp.year,
      easternTimestamp.month,
      easternTimestamp.day,
    );

    if (itemDate == today) {
      return 'TODAY';
    }
    if (itemDate == yesterday) {
      return 'YESTERDAY';
    }

    return '${easternTimestamp.day} ${_monthName(easternTimestamp.month).toUpperCase()} ${easternTimestamp.year}';
  }

  String _detailLineForTimestamp(DateTime timestamp) {
    final easternTimestamp = CampusTime.toEastern(timestamp);
    final nowEastern = CampusTime.toEastern(DateTime.now());
    final today = DateTime(nowEastern.year, nowEastern.month, nowEastern.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(
      easternTimestamp.year,
      easternTimestamp.month,
      easternTimestamp.day,
    );

    final formattedTime = _formatClock(easternTimestamp);
    if (itemDate == today) {
      return formattedTime;
    }
    if (itemDate == yesterday) {
      return 'Yesterday, $formattedTime';
    }
    return '${_monthNameShort(easternTimestamp.month)} ${easternTimestamp.day}, $formattedTime';
  }

  Future<void> _handleAlertTap(_AlertFeedItem item) async {
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

    if (!mounted) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncidentDetailScreen(
          incident: incident,
          onViewLiveMap: () {
            Navigator.pop(context);
            widget.onBack?.call();
          },
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
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '$location • ${_prettyStatus(status)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedText,
                  ),
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
                            onViewLiveMap: () {
                              Navigator.pop(context);
                              widget.onBack?.call();
                            },
                            onRequestUpdate: () => _requestAlertUpdate(incident),
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: BorderSide(color: AppColors.primaryBlue),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                            side: BorderSide(color: AppColors.statusHighRisk),
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
    _AlertFeedItem item,
  ) async {
    if (!mounted) {
      return;
    }

    final data = reportDoc.data();
    final title = (data['title'] as String?) ?? item.title;
    final location = (data['location'] as String?) ?? item.location;
    final description = (data['description'] as String?) ?? item.description ?? '';

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
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedText,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.darkText,
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
                          side: BorderSide(color: AppColors.cardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Approve'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

  Future<void> _markAllAsRead(List<_AlertFeedItem> items) async {
    setState(() {
      _isMarkingAllRead = true;
    });

    try {
      final updatedIds = {
        ..._readAlertIds,
        ...items.map((item) => item.id),
      };
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
      _readAlertIds = {...prefs.getStringList(_readAlertsKey) ?? const <String>[]};
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Approval failed: $e')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report dismissed.')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dismiss failed: $e')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status update failed: $e')),
      );
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
          content: Text(
            'This will permanently remove "$title" from alerts.',
          ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
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
          style: TextStyle(
            color: AppColors.mutedText,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  static _AlertFeedKind _kindForIncident(Incident incident) {
    if (incident.status == IncidentStatus.resolved) {
      return _AlertFeedKind.success;
    }
    if (incident.type == IncidentType.maintenance && incident.severity <= 1) {
      return _AlertFeedKind.neutral;
    }
    return _AlertFeedKind.warning;
  }

  static String _incidentActionLabel(Incident incident) {
    if (incident.status == IncidentStatus.resolved) {
      switch (incident.type) {
        case IncidentType.maintenance:
        case IncidentType.construction:
          return 'Maintenance completed';
        case IncidentType.blockage:
          return 'Route reopened';
        case IncidentType.gathering:
        case IncidentType.protest:
          return 'Crowd dispersed';
        case IncidentType.emergency:
          return 'Hazard cleared';
      }
    }

    if (incident.status == IncidentStatus.verified) {
      return 'Incident verified by staff';
    }

    switch (incident.type) {
      case IncidentType.protest:
      case IncidentType.gathering:
        return 'Suspicious activity';
      case IncidentType.blockage:
        return 'Access issue reported';
      case IncidentType.maintenance:
        return 'Routine patrol scheduled';
      case IncidentType.construction:
        return 'Incident reported';
      case IncidentType.emergency:
        return 'Incident reported';
    }
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }

  static String _formatClock(DateTime timestamp) {
    final hour = timestamp.hour == 0
        ? 12
        : timestamp.hour > 12
            ? timestamp.hour - 12
            : timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final suffix = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  static String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  static String _monthNameShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  static String _prettyStatus(String status) {
    if (status == 'investigating') {
      return 'Investigating';
    }
    if (status == 'verified') {
      return 'Verified';
    }
    if (status == 'resolved') {
      return 'Resolved';
    }
    return 'Reported';
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

class _AlertActivityRow extends StatelessWidget {
  const _AlertActivityRow({
    required this.item,
    required this.isUnread,
    required this.onTap,
  });

  final _AlertFeedItem item;
  final bool isUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _AlertIndicator(kind: item.kind),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.35,
                          color: AppColors.darkText,
                        ),
                        children: [
                          TextSpan(
                            text: item.title,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (item.location.trim().isNotEmpty)
                            TextSpan(
                              text: ' near ${item.location}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.mutedText.withValues(alpha: 0.72),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          item.detailLine,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mutedText,
                          ),
                        ),
                        if (isUnread) ...[
                          SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFB923C),
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'UNREAD',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Color(0xFFFB923C),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertIndicator extends StatelessWidget {
  const _AlertIndicator({required this.kind});

  final _AlertFeedKind kind;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (kind) {
      _AlertFeedKind.warning => (const Color(0xFFF97316), Icons.priority_high_rounded),
      _AlertFeedKind.success => (const Color(0xFF22C55E), Icons.check_rounded),
      _AlertFeedKind.neutral => (const Color(0xFF6B7280), Icons.circle_outlined),
    };

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.6),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: kind == _AlertFeedKind.neutral ? 13 : 12,
        color: color,
      ),
    );
  }
}

class _FeedFooter extends StatelessWidget {
  const _FeedFooter({required this.showMuted});

  final bool showMuted;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 52,
            color: AppColors.mutedText.withValues(alpha: 0.42),
          ),
          SizedBox(height: 8),
          Text(
            showMuted ? 'All caught up!' : 'Recent activity synced.',
            style: TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: AppColors.mutedText.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAlertState extends StatelessWidget {
  const _EmptyAlertState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 32, 18, 0),
      child: _FeedFooter(showMuted: true),
    );
  }
}

enum _AlertFeedKind {
  warning,
  success,
  neutral,
}

class _AlertFeedItem {
  const _AlertFeedItem({
    required this.id,
    required this.title,
    required this.location,
    required this.timestamp,
    required this.detailLine,
    required this.kind,
    this.incident,
    this.incidentDoc,
    this.reportDoc,
    this.description,
  });

  final String id;
  final String title;
  final String location;
  final DateTime timestamp;
  final String detailLine;
  final _AlertFeedKind kind;
  final Incident? incident;
  final QueryDocumentSnapshot<Map<String, dynamic>>? incidentDoc;
  final QueryDocumentSnapshot<Map<String, dynamic>>? reportDoc;
  final String? description;
}
