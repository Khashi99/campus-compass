import 'package:flutter/material.dart';
import 'package:campus_compass/models/incident.dart';
import 'package:campus_compass/theme/app_colors.dart';

/// Screen for reporting a new incident on campus
class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  // Form state
  IncidentType? _selectedType;
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedLocation;
  bool _hasEvidence = true;
  TimeOfDay? _incidentTime;

  // Step state
  int _currentStep = 1; // 1 or 2

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
        ),
      ),
    );
  }

  // ============ APP BAR ============

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.darkText),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Report an Incident',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
      centerTitle: true,
    );
  }

  // ============ STEP 1: INCIDENT DETAILS ============

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress indicator
        _buildProgressIndicator(1),
        const SizedBox(height: 16),

        // Title
        const Text(
          "What's happening?",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your report helps other students navigate the campus safely. Choose a category to start.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.mutedText,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        // Incident Type Field
        _buildIncidentTypeField(),
        const SizedBox(height: 20),

        // Description Field
        _buildDescriptionField(),
        const SizedBox(height: 20),

        // Location Field
        _buildLocationField(),
        const SizedBox(height: 20),

        // Time Input Field
        _buildTimeField(),
        const SizedBox(height: 20),

        // Evidence Section
        _buildEvidenceSection(),
        const SizedBox(height: 24),

        // Emergency Info Box
        _buildEmergencyInfoBox(),
        const SizedBox(height: 32),

        // Next Button
        _buildNextButton(),
      ],
    );
  }

  Widget _buildProgressIndicator(int step) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: step == 2 ? AppColors.primaryBlue : AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Step $step of 2',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildIncidentTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Incident Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.white,
          ),
          child: DropdownButton<IncidentType>(
            isExpanded: true,
            value: _selectedType,
            hint: const Text(
              'Select type...',
              style: TextStyle(color: AppColors.mutedText),
            ),
            underline: const SizedBox(),
            items: IncidentType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.displayName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedType = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(
            Icons.info_outlined,
            color: AppColors.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),

      Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.white,
        ),
        child: TextField(
          controller: _descriptionController,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.darkText,
          ),
          maxLines: 4,
          maxLength: 3000,
          decoration: const InputDecoration(
            hintText:
                "Briefly describe the situation (e.g., 'Main entrance blocked by protestors, please use the side gate.')",
            hintStyle: TextStyle(color: AppColors.mutedText),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(12),
            counterText: '', // hides default counter inside the field
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),

      const SizedBox(height: 4),

      // Character counter BELOW the box
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          '${_descriptionController.text.length} / 3000 characters',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.mutedText,
          ),
        ),
      ),
    ],
  );
}

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppColors.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.white,
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedLocation,
            hint: const Text(
              'Select location...',
              style: TextStyle(color: AppColors.mutedText),
            ),
            underline: const SizedBox(),
            items: [
              'Main Campus',
              'SGW Campus',
              'Loyola Campus',
              'Hall Building Entrance',
              'Library',
              'Engineering Building',
              'Science Building',
              'Student Center',
            ].map((location) {
              return DropdownMenuItem(
                value: location,
                child: Text(location),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedLocation = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.access_time_outlined,
              color: AppColors.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Incident Time',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: _incidentTime ?? TimeOfDay.now(),
            );
            if (picked != null) {
              setState(() => _incidentTime = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _incidentTime != null
                      ? _incidentTime!.format(context)
                      : 'Select time...',
                  style: TextStyle(
                    fontSize: 14,
                    color: _incidentTime != null
                        ? AppColors.darkText
                        : AppColors.mutedText,
                  ),
                ),
                const Icon(
                  Icons.access_time_outlined,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.image_outlined,
              color: AppColors.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Evidence (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: () {
              setState(() => _hasEvidence = !_hasEvidence);
              if (_hasEvidence) {
                _showSnackBar('Photo/video upload: Coming soon');
              }
            },
            child: DashedBorderPainter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
                child: Column(
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      size: 32,
                      color: _hasEvidence
                          ? AppColors.primaryBlue
                          : AppColors.mutedText,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _hasEvidence ? '1 Photo' : 'Tap to add photo or video',
                      style: TextStyle(
                        fontSize: 13,
                        color: _hasEvidence
                            ? AppColors.primaryBlue
                            : AppColors.mutedText,
                        fontWeight: _hasEvidence ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Emergency? ',
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  TextSpan(
                    text:
                        'Please contact Campus Security directly at ',
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontSize: 13,
                    ),
                  ),
                  TextSpan(
                    text: '+1 514-555-0199',
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  TextSpan(
                    text: ' before filing a report.',
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    final isFormValid = _selectedType != null &&
        _descriptionController.text.isNotEmpty &&
        _selectedLocation != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isFormValid
            ? () {
                setState(() {
                  _currentStep = 2;
                });
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid ? AppColors.primaryBlue : AppColors.cardBorder,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Next',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isFormValid ? Colors.white : AppColors.mutedText,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              color: isFormValid ? Colors.white : AppColors.mutedText,
            ),
          ],
        ),
      ),
    );
  }

  // ============ STEP 2: CONFIRMATION ============

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress indicator
        _buildProgressIndicator(2),
        const SizedBox(height: 16),

        // Info box - Review Details
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 214, 234, 254),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Review Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Please ensure the information below is accurate before sharing it with the campus.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildReviewCard(
          icon: Icons.warning_amber_rounded,
          label: 'INCIDENT TYPE',
          value: _selectedType?.displayName ?? 'Not selected',
        ),
        const SizedBox(height: 12),

        _buildReviewCard(
          icon: Icons.location_on_outlined,
          label: 'LOCATION',
          value: _selectedLocation ?? 'Not selected',
        ),
        const SizedBox(height: 12),

        _buildReviewCard(
          icon: Icons.description_outlined,
          label: 'DESCRIPTION',
          value: _descriptionController.text,
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildSmallReviewCard(
                icon: Icons.photo_outlined,
                label: 'ATTACHMENTS',
                value: '0 Evidence',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallReviewCard(
                icon: Icons.access_time_outlined,
                label: 'INCIDENT TIME',
                value: _incidentTime != null
                    ? _incidentTime!.format(context)
                    : 'Not set',
              ),
            ),
          ],
        ),
  
        const SizedBox(height: 12),

        // Privacy info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 232, 232, 232),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.security_outlined,
                  color: Colors.blueGrey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your report will be anonymous to other students. Only campus security can view your account profile if required for safety verification.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Submit Report',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Cancel Button
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              setState(() => _currentStep = 1);
            },
            child: const Text(
              'Back to Edit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallReviewCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============ ACTIONS ============

  void _submitReport() {
    // In a real app, send data to backend
    _showSnackBar('Report submitted successfully!', isSuccess: true);
    
    // Navigate back after brief delay
    Future.delayed(
      const Duration(milliseconds: 1500),
      () {
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.statusNormal : Colors.grey,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Custom widget to draw dashed borders
class DashedBorderPainter extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  const DashedBorderPainter({
    super.key,
    required this.child,
    this.color = AppColors.primaryBlue,
    this.strokeWidth = 2,
    this.dashWidth = 5,
    this.dashSpace = 5,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const radius = 8.0;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // Draw dashed border
    _drawDashedRRect(canvas, rRect, paint);
  }

  void _drawDashedRRect(Canvas canvas, RRect rRect, Paint paint) {
    final path = Path()..addRRect(rRect);
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      bool drawing = true;
      while (distance < pathMetric.length) {
        if (drawing) {
          final extractPath = pathMetric.extractPath(
            distance,
            distance + dashWidth,
          );
          canvas.drawPath(extractPath, paint);
          distance += dashWidth;
        } else {
          distance += dashSpace;
        }
        drawing = !drawing;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
