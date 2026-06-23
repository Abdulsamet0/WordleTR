import 'package:flutter/material.dart';

class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final ValueChanged<bool>? onHoverStateChanged;
  final BoxDecoration? decoration;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final bool hasTexture;

  const BouncingButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.onHoverStateChanged,
    this.decoration,
    this.width = double.infinity,
    this.height = 60.0,
    this.padding = EdgeInsets.zero,
    this.hasTexture = true,
  });

  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() {});
      });

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    widget.onHoverStateChanged?.call(true);
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onHoverStateChanged?.call(false);
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
    widget.onHoverStateChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          clipBehavior: Clip.antiAlias,
          decoration: widget.decoration ??
              BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
          alignment: Alignment.center,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              if (widget.hasTexture)
                CustomPaint(
                  painter: TexturePainter(),
                ),
              Center(child: widget.child),
            ],
          ),
        ),
      ),
    );
  }
}

class TexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(15) // Çok şeffaf beyaz çizgiler
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    const double spacing = 12.0;
    // Çizgileri çapraz (diagonal) olarak çizmek için genişletilmiş bir döngü
    for (double i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
