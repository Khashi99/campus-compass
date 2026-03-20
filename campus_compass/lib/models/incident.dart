/// Incident model for campus safety reports

enum IncidentType {
  protest,
  construction,
  gathering,
  blockage,
  emergency,
  maintenance,
}

enum IncidentStatus {
  reported,
  investigating,
  resolved,
}

enum VerificationLevel {
  unverified,
  userReported,
  verified,
}

class Incident {
  final String id;
  final String title;
  final String description;
  final String location;
  final IncidentType type;
  final IncidentStatus status;
  final VerificationLevel verificationLevel;
  final int userReports;
  final int verificationProgress; // 0-100
  final DateTime reportedTime;
  final String? imageUrl;
  final List<CommunityInsight> communityInsights;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.type,
    required this.status,
    required this.verificationLevel,
    required this.userReports,
    required this.verificationProgress,
    required this.reportedTime,
    this.imageUrl,
    this.communityInsights = const [],
  });

  String get timeAgo {
    final difference = DateTime.now().difference(reportedTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case IncidentType.protest:
        return 'Protest / Gathering';
      case IncidentType.construction:
        return 'Construction';
      case IncidentType.gathering:
        return 'Gathering';
      case IncidentType.blockage:
        return 'Entrance Blockage';
      case IncidentType.emergency:
        return 'Emergency';
      case IncidentType.maintenance:
        return 'Maintenance';
    }
  }
}

class CommunityInsight {
  final String id;
  final String authorName;
  final String? authorRole;
  final String content;
  final DateTime postedTime;
  final String? avatarUrl;

  CommunityInsight({
    required this.id,
    required this.authorName,
    this.authorRole,
    required this.content,
    required this.postedTime,
    this.avatarUrl,
  });

  String get timeAgo {
    final difference = DateTime.now().difference(postedTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Sample data for testing
class SampleData {
  static Incident get constructionIncident => Incident(
    id: '1',
    title: 'Hall Building: Construction & Entrance Blockage',
    description: 'Emergency maintenance on the main staircase in the Hall Building lobby has resulted in the temporary closure of the primary entrance. Students are advised to use the Mackay Street entrance until further notice. No tension detected, purely structural safety.',
    location: 'Hall Building Entrance',
    type: IncidentType.construction,
    status: IncidentStatus.investigating,
    verificationLevel: VerificationLevel.verified,
    userReports: 8,
    verificationProgress: 66,
    reportedTime: DateTime.now().subtract(const Duration(minutes: 14)),
    communityInsights: [
      CommunityInsight(
        id: '1',
        authorName: 'Officer Sarah J.',
        authorRole: 'Staff',
        content: 'Security teams are on-site redirecting pedestrian traffic through the North Tunnel.',
        postedTime: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      CommunityInsight(
        id: '2',
        authorName: 'Marc L.',
        content: 'The main library entrance is still blocked by heavy equipment.',
        postedTime: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
    ],
  );

  static Incident get protestIncident => Incident(
    id: '2',
    title: 'Protest near Hive Cafe',
    description: 'People are protesting near Hive cafe. You may be in a high-tension zone. Review your surroundings and take appropriate action.',
    location: 'Hive Cafe Area',
    type: IncidentType.protest,
    status: IncidentStatus.investigating,
    verificationLevel: VerificationLevel.verified,
    userReports: 12,
    verificationProgress: 85,
    reportedTime: DateTime.now().subtract(const Duration(minutes: 8)),
    communityInsights: [],
  );

  static Incident get gatheringIncident => Incident(
    id: '3',
    title: 'Gathering Near Hall Entrance',
    description: 'Large crowd forming near escalators',
    location: 'Hall Building Entrance',
    type: IncidentType.gathering,
    status: IncidentStatus.reported,
    verificationLevel: VerificationLevel.verified,
    userReports: 5,
    verificationProgress: 30,
    reportedTime: DateTime.now().subtract(const Duration(minutes: 3)),
    communityInsights: [],
  );
}