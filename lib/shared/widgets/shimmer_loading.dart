import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:farmconnect/shared/design_constants.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DesignColors.shimmerBase,
      highlightColor: DesignColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DesignColors.shimmerBase,
      highlightColor: DesignColors.shimmerHighlight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.l),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerLoading(width: double.infinity, height: 120, borderRadius: DesignRadius.l),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLoading(width: 100, height: 14),
                  const SizedBox(height: 8),
                  const ShimmerLoading(width: 80, height: 12),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      ShimmerLoading(width: 50, height: 18),
                      ShimmerLoading(width: 32, height: 32, borderRadius: DesignRadius.full),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturedProductShimmer extends StatelessWidget {
  const FeaturedProductShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DesignColors.shimmerBase,
      highlightColor: DesignColors.shimmerHighlight,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.xxl),
        ),
      ),
    );
  }
}

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DesignColors.shimmerBase,
      highlightColor: DesignColors.shimmerHighlight,
      child: Row(
        children: List.generate(
          4,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DesignRadius.full),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SearchFieldShimmer extends StatelessWidget {
  const SearchFieldShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DesignColors.shimmerBase,
      highlightColor: DesignColors.shimmerHighlight,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.xxl),
        ),
      ),
    );
  }
}

class ListItemShimmer extends StatelessWidget {
  final int itemCount;
  
  const ListItemShimmer({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DesignColors.shimmerBase,
      highlightColor: DesignColors.shimmerHighlight,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DesignRadius.l),
            ),
          ),
        ),
      ),
    );
  }
}

class OrderShimmer extends StatelessWidget {
  const OrderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DesignColors.shimmerBase,
      highlightColor: DesignColors.shimmerHighlight,
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignSpacing.m),
        padding: const EdgeInsets.all(DesignSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.l),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 100, height: 16, color: Colors.white),
                Container(width: 60, height: 14, color: Colors.white),
              ],
            ),
            const SizedBox(height: 12),
            Container(width: 150, height: 12, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 80, height: 12, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
