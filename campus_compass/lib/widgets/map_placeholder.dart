import 'package:flutter/material.dart';
import 'package:campus_compass/theme/app_colors.dart';

class MapPlaceholder extends StatefulWidget {
  final bool showTensionZone;
  final String? tensionZoneLabel;
  //final Offset? tensionZonePosition;
  final bool showZoomControls;

  const MapPlaceholder({
    super.key,
    this.showTensionZone = false,
    this.tensionZoneLabel,
    //this.tensionZonePosition,
    this.showZoomControls = true,
  });

  @override
  State<MapPlaceholder> createState() => _MapPlaceholderState();
}

class _MapPlaceholderState extends State<MapPlaceholder> {
  static const double _minZoom = 1.0;
  static const double _maxZoom = 2.2;
  static const double _zoomStep = 0.2;

  double _zoomLevel = 1.0;
  Offset _panOffset = Offset.zero;

  Offset _clampPanOffset({
    required Offset candidate,
    required Size size,
    required double zoom,
  }) {
    if (zoom <= 1.0) {
      return Offset.zero;
    }

    final maxDx = (size.width * (zoom - 1)) / 2;
    final maxDy = (size.height * (zoom - 1)) / 2;

    return Offset(
      candidate.dx.clamp(-maxDx, maxDx),
      candidate.dy.clamp(-maxDy, maxDy),
    );
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + _zoomStep).clamp(_minZoom, _maxZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - _zoomStep).clamp(_minZoom, _maxZoom);
      if (_zoomLevel <= _minZoom) {
        _panOffset = Offset.zero;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.mapBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = Size(constraints.maxWidth, constraints.maxHeight);

          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onPanUpdate: (details) {
                    if (_zoomLevel <= _minZoom) {
                      return;
                    }

                    setState(() {
                      final candidate = _panOffset + details.delta;
                      _panOffset = _clampPanOffset(
                        candidate: candidate,
                        size: viewport,
                        zoom: _zoomLevel,
                      );
                    });
                  },
                  child: ClipRect(
                    child: Transform(
                      transform: Matrix4.identity()
                        ..translate(_panOffset.dx, _panOffset.dy)
                        ..scale(_zoomLevel),
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          // Actual campus map image
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/floor_plan.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Tension zone overlay
                          // Tension zone overlay - CENTERED and RESPONSIVE (Fixes #4 and #5)
                          if (widget.showTensionZone)
                            Positioned.fill(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.tensionZone.withOpacity(0.25),
                                        border: Border.all(
                                          color: AppColors.tensionZone.withOpacity(0.7),
                                          width: 3,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.warning_rounded,
                                          color: AppColors.tensionZone.withOpacity(0.8),
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                    if (widget.tensionZoneLabel != null) ...[
                                      SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.statusHighRisk,
                                          borderRadius: BorderRadius.circular(6),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          widget.tensionZoneLabel!,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Zoom controls
              if (widget.showZoomControls)
                Positioned(
                  right: 8,
                  top: 100,
                  child: Column(
                    children: [
                      _buildZoomButton(
                        icon: Icons.add,
                        onTap: _zoomIn,
                      ),
                      SizedBox(height: 8),
                      _buildZoomButton(
                        icon: Icons.remove,
                        onTap: _zoomOut,
                      ),
                    ],
                  ),
                ),
              // Compass
              // Positioned(
              //   right: 16,
              //   top: 100,
              //   child: Container(
              //     width: 40,
              //     height: 40,
              //     decoration: BoxDecoration(
              //       color: AppColors.white,
              //       shape: BoxShape.circle,
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withOpacity(0.1),
              //           blurRadius: 8,
              //         ),
              //       ],
              //     ),
              //     child: Icon(
              //       Icons.navigation,
              //       color: AppColors.statusHighRisk,
              //       size: 20,
              //     ),
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppColors.darkText,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class MiniMapButton extends StatelessWidget {
  final VoidCallback? onTap;

  const MiniMapButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              'View Live Map',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
