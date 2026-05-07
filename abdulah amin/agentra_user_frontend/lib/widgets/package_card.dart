import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/package.dart';
import '../services/saved_packages_service.dart';

class PackageCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String duration;
  final String price;
  final String description;
  final double rating;
  final bool showSaleBadge;
  final VoidCallback? onTap;
  final VoidCallback? onReviewTap;
  final Package? package; // needed for saving
  final double discountPercentage;

  const PackageCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.duration,
    required this.price,
    required this.description,
    this.rating = 0,
    this.showSaleBadge = false,
    this.onTap,
    this.package,
    this.onReviewTap,
    this.discountPercentage = 0,
  });

  @override
  State<PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<PackageCard> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkSavedStatus();
  }

  Future<void> _checkSavedStatus() async {
    if (widget.package == null) return;
    final saved =
        await SavedPackagesService.isPackageSaved(widget.package!.id);
    if (mounted) setState(() => _isSaved = saved);
  }

  Future<void> _toggleSave() async {
    if (widget.package == null) return;
    if (_isSaved) {
      await SavedPackagesService.unsavePackage(widget.package!.id);
    } else {
      await SavedPackagesService.savePackage(widget.package!);
    }
    if (mounted) setState(() => _isSaved = !_isSaved);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image with badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Image.network(
                    widget.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: AppColors.backgroundGray,
                        child: const Icon(Icons.broken_image_outlined,
                            color: AppColors.textTertiary),
                      );
                    },
                  ),
                ),
                if (widget.showSaleBadge)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_offer,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            '${widget.discountPercentage.toInt()}%\nOFF',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style:
                          AppTextStyles.headingSmall.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.duration} | ${widget.price}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // Icons and rating
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                     GestureDetector(
  onTap: widget.onReviewTap,
  child: const Icon(
    Icons.chat_bubble_outline,
    size: 18,
    color: AppColors.textTertiary,
  ),
),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _toggleSave,
                        child: Icon(
                          _isSaved ? Icons.bookmark : Icons.bookmark_border,
                          size: 18,
                          // Colored when saved, grey when not saved
                          color: _isSaved
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (widget.rating > 0)
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: AppColors.star, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          widget.rating.toString(),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
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