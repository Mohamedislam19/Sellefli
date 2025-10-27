// lib/src/core/widgets/shimmer/shimmer_placeholder.dart
import 'package:flutter/material.dart';

class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration period;
  final Gradient? gradient;

  const Shimmer({
    Key? key,
    required this.child,
    this.period = const Duration(milliseconds: 1500),
    this.gradient,
  }) : super(key: key);

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Gradient _defaultGradient;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
    _defaultGradient = LinearGradient(
      colors: [
        Colors.grey.shade300,
        Colors.grey.shade200,
        Colors.grey.shade300,
      ],
      stops: const [0.1, 0.5, 0.9],
      begin: Alignment(-1.0, -0.3),
      end: Alignment(1.0, 0.3),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ?? _defaultGradient;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final width = bounds.width;
            final dx = _controller.value * (width + width * 0.3) - width * 0.2;
            return LinearGradient(
              colors: (gradient as LinearGradient).colors,
              stops: (gradient as LinearGradient).stops,
              begin: Alignment(-1 + _controller.value * 2, 0),
              end: Alignment(-0.2 + _controller.value * 2.2, 0),
            ).createShader(Rect.fromLTWH(-dx, 0, width * 1.6, bounds.height));
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Simple rectangular shimmer skeleton
class ShimmerBox extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius borderRadius;

  const ShimmerBox({
    Key? key,
    required this.height,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: borderRadius,
      ),
    );

    return Shimmer(child: container);
  }
}
