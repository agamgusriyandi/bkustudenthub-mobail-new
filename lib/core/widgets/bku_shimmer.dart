import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BkuShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final EdgeInsetsGeometry? margin;

  const BkuShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.margin,
  });

  const BkuShimmer.circle({super.key, required double size, this.margin})
    : width = size,
      height = size,
      borderRadius = null,
      shape = BoxShape.circle;

  const BkuShimmer.text({
    super.key,
    required this.width,
    this.height = 14,
    this.margin,
  }) : borderRadius = const BorderRadius.all(Radius.circular(4)),
       shape = BoxShape.rectangle;

  @override
  Widget build(BuildContext context) {
    // Colors that look professional in light mode (very soft grays)
    final baseColor = Colors.grey[200]!;
    final highlightColor = Colors.white;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        period: const Duration(milliseconds: 1500),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                shape == BoxShape.circle
                    ? null
                    : (borderRadius ?? AppRadius.radiusMd),
            shape: shape,
          ),
        ),
      ),
    );
  }
}

class BkuShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  const BkuShimmerCard({super.key, required this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      constraints: BoxConstraints(minHeight: height),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BkuShimmer(
            width: 50,
            height: 50,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                BkuShimmer.text(width: MediaQuery.of(context).size.width * 0.4),
                const SizedBox(height: 8),
                BkuShimmer.text(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BkuShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const BkuShimmerList({super.key, this.itemCount = 5, this.itemHeight = 100});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => BkuShimmerCard(height: itemHeight),
    );
  }
}
