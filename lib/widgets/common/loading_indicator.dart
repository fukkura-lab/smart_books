import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  
  const LoadingIndicator({
    Key? key,
    this.size = 24.0,
    required this.color,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _DotsPainter(
              progress: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int dotsCount = 3;
  
  _DotsPainter({
    required this.progress,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;
    
    final double dotRadius = size.width * 0.15;
    final double centerY = size.height / 2;
    final double totalWidth = size.width * 0.7;
    final double spacing = totalWidth / (dotsCount - 1);
    final double startX = (size.width - totalWidth) / 2;
    
    // アニメーションオフセットを計算
    for (int i = 0; i < dotsCount; i++) {
      final double x = startX + (i * spacing);
      
      // 各ドットのアニメーション位置を計算
      final double offset = math.sin((progress * 2 * math.pi) + (i * math.pi / dotsCount)) * 0.3;
      final double y = centerY + (offset * size.height);
      
      // 各ドットの透明度を計算
      final double opacity = 0.5 + (0.5 * math.sin((progress * 2 * math.pi) + (i * math.pi / dotsCount)));
      
      // ドットを描画
      paint.color = color.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }
  }
  
  @override
  bool shouldRepaint(_DotsPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
