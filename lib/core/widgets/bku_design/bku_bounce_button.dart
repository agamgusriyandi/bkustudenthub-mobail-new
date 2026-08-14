import 'package:flutter/material.dart';

class BkuBounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final Duration duration;
  final HitTestBehavior behavior;

  const BkuBounceButton({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.93,
    this.duration = const Duration(milliseconds: 150),
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<BkuBounceButton> createState() => _BkuBounceButtonState();
}

class _BkuBounceButtonState extends State<BkuBounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: Duration(milliseconds: (widget.duration.inMilliseconds * 1.4).round()),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.32, 0.72, 0.0, 1.0),
      reverseCurve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        if (widget.onTap != null) {
          _controller.forward().then((_) {
            _controller.reverse();
          });
          widget.onTap!();
        }
      },
      behavior: widget.behavior,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
