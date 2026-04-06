import 'package:campus_compass/widgets/bottom_nav_bar.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_compass/models/incident.dart';
import 'package:campus_compass/theme/app_colors.dart';
import 'package:campus_compass/utils/campus_time.dart';
import 'package:campus_compass/utils/incident_haptics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Screen for reporting a new incident on campus
class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class EvidenceFile {
  final XFile file;
  final bool isVideo;
  final Uint8List? thumbnail;

  EvidenceFile({required this.file, required this.isVideo, this.thumbnail});
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  // Form state
  IncidentType? _selectedType;
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedLocation;
  final List<EvidenceFile> _evidenceFiles = [];
  TimeOfDay? _incidentTime;

  // Step state
  int _currentStep = 1; // 1 or 2
  bool _isSubmitting = false;

  final ImagePicker _imagePicker = ImagePicker();

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
      // bottomNavigationBar removed: handled by HomeScreen
    );
  }

  // ============ APP BAR ============

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppColors.darkText),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
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
        SizedBox(height: 16),

        // Title
        Text(
          "What's happening?",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Your report helps other students navigate the campus safely. Choose a category to start.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.mutedText,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24),

        // Incident Type Field
        _buildIncidentTypeField(),
        SizedBox(height: 20),

        // Description Field
        _buildDescriptionField(),
        SizedBox(height: 20),

        // Location Field
        _buildLocationField(),
        SizedBox(height: 20),

        // Time Input Field
        _buildTimeField(),
        SizedBox(height: 20),

        // Evidence Section
        _buildEvidenceSection(),
        SizedBox(height: 24),

        // Emergency Info Box
        _buildEmergencyInfoBox(),
        SizedBox(height: 32),

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
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: step == 2
                        ? AppColors.primaryBlue
                        : AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        Text(
          'Step $step of 2',
          style: TextStyle(
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
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.primaryBlue,
              size: 20,
            ),
            SizedBox(width: 8),
            RichText(
              text: TextSpan(
                text: 'Incident Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
                children: [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.statusHighRisk),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
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
            hint: Text(
              'Select type...',
              style: TextStyle(color: AppColors.mutedText),
            ),
            underline: SizedBox(),
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
            Icon(Icons.info_outlined, color: AppColors.primaryBlue, size: 20),
            SizedBox(width: 8),
            RichText(
              text: TextSpan(
                text: 'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
                children: [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.statusHighRisk),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        TextField(
          controller: _descriptionController,
          style: TextStyle(fontSize: 14, color: AppColors.darkText),
          maxLines: 6,
          decoration: InputDecoration(
            hintText:
                "Briefly describe the situation (e.g., Main entrance blocked by protestors, please use the side gate.)",
            hintStyle: TextStyle(color: AppColors.mutedText),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.all(12),
            counterText: '', // hides default counter inside the field
          ),
          onChanged: (_) => setState(() {}),
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
            Icon(
              Icons.location_on_outlined,
              color: AppColors.primaryBlue,
              size: 20,
            ),
            SizedBox(width: 8),
            RichText(
              text: TextSpan(
                text: 'Location',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
                children: [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.statusHighRisk),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
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
            hint: Text(
              'Select location...',
              style: TextStyle(color: AppColors.mutedText),
            ),
            underline: SizedBox(),
            items:
                [
                  'Lounge',
                  'Hive Café',
                  'HoJo Concordia',
                  "Reggie's Pub",
                  'Student association offices',
                  'Escalators',
                  'Presentation booths',
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
            Icon(
              Icons.access_time_outlined,
              color: AppColors.primaryBlue,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Incident Time (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: _incidentTime ?? TimeOfDay.now(),
            );
            if (picked != null) {
              setState(() => _incidentTime = picked);
              if (_isCampusClosedHour(picked.hour)) {
                _showSnackBar('Campus is closed from 12:00 AM to 6:00 AM.');
              }
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
                Icon(
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
            Icon(Icons.image_outlined, color: AppColors.primaryBlue, size: 20),
            SizedBox(width: 8),
            Text(
              'Evidence (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        if (_evidenceFiles.isEmpty)
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _showMediaPickerOptions,
              child: DashedBorderPainter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 12,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_camera_outlined,
                        size: 32,
                        color: AppColors.primaryBlue,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap to add photo or video',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._evidenceFiles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final evidence = entry.value;
                    return _buildEvidenceCard(evidence, index);
                  }),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showMediaPickerOptions,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primaryBlue,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add,
                        color: AppColors.primaryBlue,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEvidenceCard(EvidenceFile evidence, int index) {
    return GestureDetector(
      onTap: () => _showEvidencePreview(evidence, index),
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
              color: AppColors.white,
            ),
            child: evidence.isVideo
                ? (evidence.thumbnail != null
                      ? Image.memory(evidence.thumbnail!, fit: BoxFit.cover)
                      : Center(
                          child: Icon(
                            Icons.videocam,
                            color: AppColors.primaryBlue,
                            size: 40,
                          ),
                        ))
                : Image.file(File(evidence.file.path), fit: BoxFit.cover),
          ),
          if (evidence.isVideo)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.play_arrow, color: Colors.white, size: 16),
              ),
            ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () {
                setState(() => _evidenceFiles.removeAt(index));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMediaPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Evidence',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 24),
              _buildMediaOption(
                icon: Icons.camera_alt_outlined,
                label: 'Take Photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              SizedBox(height: 12),
              _buildMediaOption(
                icon: Icons.videocam_outlined,
                label: 'Take Video',
                onTap: () {
                  Navigator.pop(context);
                  _pickVideoFromCamera();
                },
              ),
              SizedBox(height: 12),
              _buildMediaOption(
                icon: Icons.image_outlined,
                label: 'Pick Photo from Gallery',
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              SizedBox(height: 12),
              _buildMediaOption(
                icon: Icons.folder_outlined,
                label: 'Pick Video from Gallery',
                onTap: () {
                  Navigator.pop(context);
                  _pickVideoFromGallery();
                },
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 24),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      if (photo != null) {
        setState(
          () => _evidenceFiles.add(EvidenceFile(file: photo, isVideo: false)),
        );
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  Future<void> _pickVideoFromCamera() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
      );
      if (video != null) {
        final thumbnail = await VideoThumbnail.thumbnailData(
          video: video.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 128,
          quality: 70,
        );
        setState(
          () => _evidenceFiles.add(
            EvidenceFile(file: video, isVideo: true, thumbnail: thumbnail),
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Error picking video: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (photo != null) {
        setState(
          () => _evidenceFiles.add(EvidenceFile(file: photo, isVideo: false)),
        );
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      if (video != null) {
        final thumbnail = await VideoThumbnail.thumbnailData(
          video: video.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 128,
          quality: 70,
        );
        setState(
          () => _evidenceFiles.add(
            EvidenceFile(file: video, isVideo: true, thumbnail: thumbnail),
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Error picking video: $e');
    }
  }

  void _showEvidencePreview(EvidenceFile evidence, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (evidence.isVideo) {
          return _VideoPlaybackDialog(
            file: File(evidence.file.path),
            fileName: evidence.file.name,
            onDelete: () {
              setState(() => _evidenceFiles.removeAt(index));
              Navigator.pop(context);
            },
          );
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  color: Colors.black87,
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Image.file(
                      File(evidence.file.path),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Photo',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              evidence.file.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        setState(() => _evidenceFiles.removeAt(index));
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
          Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: RichText(
              text: TextSpan(
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
                    text: 'Please contact Campus Security directly at ',
                    style: TextStyle(color: AppColors.darkText, fontSize: 13),
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
                    style: TextStyle(color: AppColors.darkText, fontSize: 13),
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
    final currentLocalHour = DateTime.now().hour;
    final isReportingOpen = !_isCampusClosedHour(currentLocalHour);
    final isSelectedTimeAllowed =
        _incidentTime == null || !_isCampusClosedHour(_incidentTime!.hour);
    final isFormValid =
        _selectedType != null &&
        _descriptionController.text.trim().isNotEmpty &&
        _selectedLocation != null &&
        isReportingOpen &&
        isSelectedTimeAllowed;

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
          backgroundColor: isFormValid
              ? AppColors.primaryBlue
              : AppColors.cardBorder,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              !isReportingOpen
                  ? 'Reporting Unavailable'
                  : (!isSelectedTimeAllowed ? 'Invalid Incident Time' : 'Next'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isFormValid ? Colors.white : AppColors.mutedText,
              ),
            ),
            SizedBox(width: 8),
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
        SizedBox(height: 16),

        // Info box - Review Details
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.fact_check_outlined,
                color: AppColors.primaryBlue,
                size: 28,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Review Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Please ensure the information below is accurate before sharing it with the campus.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.darkText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),

        _buildReviewCard(
          icon: Icons.warning_amber_rounded,
          label: 'INCIDENT TYPE',
          value: _selectedType?.displayName ?? 'Not selected',
        ),
        SizedBox(height: 12),

        _buildReviewCard(
          icon: Icons.location_on_outlined,
          label: 'LOCATION',
          value: _selectedLocation ?? 'Not selected',
        ),
        SizedBox(height: 12),

        _buildReviewCard(
          icon: Icons.description_outlined,
          label: 'DESCRIPTION',
          value: _descriptionController.text,
        ),
        SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildSmallReviewCard(
                icon: Icons.photo_outlined,
                label: 'ATTACHMENTS',
                value: '${_evidenceFiles.length} Evidence',
              ),
            ),
            SizedBox(width: 12),
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
        SizedBox(height: 12),
        if (_evidenceFiles.isNotEmpty) _buildEvidenceReviewList(),

        SizedBox(height: 12),

        // Privacy info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.security_outlined,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your report will be anonymous to other students. Only campus security can view your account profile if required for safety verification.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkText,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 32),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSubmitting)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else ...[
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
              ],
            ),
          ),
        ),
        SizedBox(height: 12),

        // Cancel Button
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              setState(() => _currentStep = 1);
            },
            child: Text(
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
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
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
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
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

  Widget _buildEvidenceReviewList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidence Preview',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _evidenceFiles.length,
            itemBuilder: (context, index) {
              final evidence = _evidenceFiles[index];
              return GestureDetector(
                onTap: () => _showEvidencePreview(evidence, index),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                    color: AppColors.white,
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: evidence.isVideo
                            ? (evidence.thumbnail != null
                                  ? Image.memory(
                                      evidence.thumbnail!,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.videocam,
                                        color: AppColors.primaryBlue,
                                        size: 40,
                                      ),
                                    ))
                            : Image.file(
                                File(evidence.file.path),
                                fit: BoxFit.cover,
                              ),
                      ),
                      if (evidence.isVideo)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============ ACTIONS ============

  Future<void> _submitReport() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Sign in required before submitting a report.');
      return;
    }

    if (_selectedType == null ||
        _selectedLocation == null ||
        _descriptionController.text.trim().isEmpty) {
      _showSnackBar('Please complete all required fields.');
      return;
    }

    final currentLocalHour = DateTime.now().hour;
    if (_isCampusClosedHour(currentLocalHour)) {
      _showSnackBar(
        'Reporting is unavailable from 12:00 AM to 6:00 AM while campus is closed.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final nowUtc = DateTime.now().toUtc();
      final currentEasternDate = CampusTime.toEastern(nowUtc);
      final reportedAt = _incidentTime != null
          ? CampusTime.easternDateAndTimeToUtc(
              date: currentEasternDate,
              hour: _incidentTime!.hour,
              minute: _incidentTime!.minute,
            )
          : nowUtc;
      final locationCoordinates = _coordinatesForLocation(_selectedLocation!);
      final firestore = FirebaseFirestore.instance;

      await firestore.collection('incidentReports').add({
        'campusId': _campusIdForLocation(_selectedLocation!),
        'title': _titleForType(_selectedType!),
        'description': _descriptionController.text.trim(),
        'location': _selectedLocation,
        'coordinates': {
          'latitude': locationCoordinates.$1,
          'longitude': locationCoordinates.$2,
        },
        'buildingCode': _buildingCodeForLocation(_selectedLocation!),
        'type': _typeToBackendValue(_selectedType!),
        'status': 'reported',
        'verificationLevel': 'userReported',
        'createdBy': user.uid,
        'linkedIncidentId': null,
        'reportedTime': Timestamp.fromDate(reportedAt),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await IncidentHaptics.playForEvent(IncidentHapticEvent.reportSubmitted);

      _showSnackBar('Report submitted successfully!', isSuccess: true);

      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      _showSnackBar('Failed to submit report: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _titleForType(IncidentType type) {
    switch (type) {
      case IncidentType.protest:
        return 'Protest / Gathering reported';
      case IncidentType.construction:
        return 'Construction disruption reported';
      case IncidentType.gathering:
        return 'Large gathering reported';
      case IncidentType.blockage:
        return 'Entrance blockage reported';
      case IncidentType.emergency:
        return 'Emergency situation reported';
      case IncidentType.maintenance:
        return 'Maintenance issue reported';
    }
  }

  bool _isCampusClosedHour(int hour24) {
    return hour24 < 6;
  }

  String _typeToBackendValue(IncidentType type) {
    switch (type) {
      case IncidentType.protest:
        return 'protest';
      case IncidentType.construction:
        return 'construction';
      case IncidentType.gathering:
        return 'gathering';
      case IncidentType.blockage:
        return 'blockage';
      case IncidentType.emergency:
        return 'emergency';
      case IncidentType.maintenance:
        return 'maintenance';
    }
  }

  String _campusIdForLocation(String location) {
    if (location.toLowerCase().contains('loyola')) {
      return 'loyola';
    }
    return 'sgw';
  }

  String _buildingCodeForLocation(String location) {
    switch (location) {
      case 'Hall Building Entrance':
        return 'H';
      case 'Library':
        return 'LB';
      case 'Engineering Building':
        return 'EV';
      case 'Science Building':
        return 'SP';
      case 'Student Center':
        return 'SC';
      default:
        return 'GEN';
    }
  }

  (double, double) _coordinatesForLocation(String location) {
    switch (location) {
      case 'Hall Building Entrance':
        return (45.4971, -73.5789);
      case 'Library':
        return (45.4974, -73.5783);
      case 'Engineering Building':
        return (45.4969, -73.5778);
      case 'Science Building':
        return (45.4959, -73.5790);
      case 'Student Center':
        return (45.4976, -73.5793);
      case 'Loyola Campus':
        return (45.4580, -73.6405);
      case 'SGW Campus':
      case 'Main Campus':
      default:
        return (45.4973, -73.5790);
    }
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

class _VideoPlaybackDialog extends StatefulWidget {
  final File file;
  final String fileName;
  final VoidCallback onDelete;

  const _VideoPlaybackDialog({
    required this.file,
    required this.fileName,
    required this.onDelete,
  });

  @override
  State<_VideoPlaybackDialog> createState() => _VideoPlaybackDialogState();
}

class _VideoPlaybackDialogState extends State<_VideoPlaybackDialog> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
    });
    _controller.setLooping(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Container(
            color: Colors.black87,
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: FutureBuilder<void>(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                        VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            playedColor: AppColors.primaryBlue,
                            bufferedColor: AppColors.mutedText.withOpacity(0.4),
                            backgroundColor: AppColors.cardBorder,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_fill,
                                color: Colors.white,
                                size: 40,
                              ),
                              onPressed: () {
                                setState(() {
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                });
                              },
                            ),
                            SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                widget.fileName,
                                style: TextStyle(color: Colors.white70),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    );
                  }
                },
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 16,
            child: GestureDetector(
              onTap: widget.onDelete,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
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
