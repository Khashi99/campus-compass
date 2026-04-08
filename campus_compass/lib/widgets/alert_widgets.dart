import 'package:flutter/material.dart';
import 'package:campus_compass/theme/app_colors.dart';
import 'package:campus_compass/models/alert_feed_item.dart';

class AlertActivityRow extends StatelessWidget {
  const AlertActivityRow({
    required this.item,
    required this.isUnread,
    required this.onTap,
    super.key,
  });

  final AlertFeedItem item;
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
                child: AlertIndicator(kind: item.kind),
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
                            fontSize: 14,
                            color: AppColors.mutedText,
                          ),
                        ),
                        if (isUnread) ...[
                          SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 14,
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

class AlertIndicator extends StatelessWidget {
  const AlertIndicator({required this.kind, super.key});

  final AlertFeedKind kind;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (kind) {
      AlertFeedKind.warning => (const Color(0xFFF97316), Icons.priority_high_rounded),
      AlertFeedKind.success => (const Color(0xFF22C55E), Icons.check_rounded),
      AlertFeedKind.neutral => (const Color(0xFF6B7280), Icons.circle_outlined),
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
        size: kind == AlertFeedKind.neutral ? 13 : 12,
        color: color,
      ),
    );
  }
}

class FeedFooter extends StatelessWidget {
  const FeedFooter({required this.showMuted, super.key});

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
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: AppColors.mutedText.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyAlertState extends StatelessWidget {
  const EmptyAlertState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 32, 18, 0),
      child: FeedFooter(showMuted: true),
    );
  }

}
