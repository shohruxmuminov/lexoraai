import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isScanning = false;
  String? _scannedText;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        title: Text('Camera Scanner', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark)),
      ),
      body: _scannedText != null ? _buildResult(isDark) : _buildScanner(isDark),
    );
  }

  Widget _buildScanner(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Camera preview placeholder
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 2),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_rounded, color: Colors.white54, size: 60),
                        SizedBox(height: 12),
                        Text('Camera preview',
                          style: TextStyle(color: Colors.white54, fontSize: 14)),
                        SizedBox(height: 4),
                        Text('Point at text to scan',
                          style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                  // Scanning overlay corners
                  Positioned(top: 20, left: 20, child: _corner(true, true)),
                  Positioned(top: 20, right: 20, child: _corner(true, false)),
                  Positioned(bottom: 20, left: 20, child: _corner(false, true)),
                  Positioned(bottom: 20, right: 20, child: _corner(false, false)),
                  if (_isScanning)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Action options
          Row(
            children: [
              Expanded(child: _actionCard('📷', 'Take Photo', 'Scan text from camera', _simulateScan)),
              const SizedBox(width: 12),
              Expanded(child: _actionCard('🖼️', 'Gallery', 'Import from photos', _simulateScan)),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _actionCard('📄', 'PDF', 'Extract from PDF', _simulateScan)),
              const SizedBox(width: 12),
              Expanded(child: _actionCard('✍️', 'Handwriting', 'Scan handwritten text', _simulateScan)),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isScanning ? null : _simulateScan,
              icon: _isScanning
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.qr_code_scanner_rounded),
              label: Text(_isScanning ? 'Scanning...' : 'Scan Now',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Text('Text extracted successfully!',
                style: TextStyle(fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark)),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _scannedText = null),
                child: const Text('Scan Again', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _scannedText!,
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
          ).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 20),

          Text('Quick Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textDark)),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _quickAction('📖 Analyze Vocabulary', AppColors.primary),
              _quickAction('🌐 Translate', AppColors.secondary),
              _quickAction('📝 Create Exercises', AppColors.accent),
              _quickAction('🃏 Make Flashcards', AppColors.levelPurple),
            ],
          ).animate(delay: 200.ms).fadeIn(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _corner(bool isTop, bool isLeft) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(painter: _CornerPainter(isTop: isTop, isLeft: isLeft)),
    );
  }

  Widget _actionCard(String emoji, String title, String subtitle, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
              color: isDark ? Colors.white : AppColors.textDark)),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }

  Future<void> _simulateScan() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isScanning = false;
      _scannedText = 'The resilience of human civilization has been demonstrated through countless adversities. Despite ephemeral setbacks, societies have shown an extraordinary capacity to adapt and thrive in the face of unprecedented challenges.';
    });
  }
}

class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;

  _CornerPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
