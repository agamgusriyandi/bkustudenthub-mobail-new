import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedSvgImage extends StatefulWidget {
  final String assetPath;
  final double width;
  final double height;
  final Duration duration;

  const AnimatedSvgImage({
    super.key,
    required this.assetPath,
    this.width = 200,
    this.height = 200,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedSvgImage> createState() => _AnimatedSvgImageState();
}

class _AnimatedSvgImageState extends State<AnimatedSvgImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _animation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: SvgPicture.asset(
        widget.assetPath,
        width: widget.width,
        height: widget.height,
      ),
    );
  }
}
