import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tour_guide/services/api_client.dart';

import '../components/app_colors.dart';
import '../components/category_chips.dart';
import '../components/community_post_card.dart';
import '../components/destination_card.dart';
import '../components/feature_cards.dart';
import '../components/plan_header.dart';
import '../components/section_header.dart';
import '../components/top_bar.dart';
import '../../services/destination_service.dart';
import '../../services/community_service.dart';
import '../../models/destination.dart' as MD;
import '../../models/community_post.dart' as CP;
import '../../routes/app_routes.dart';

class TourBookHome extends StatefulWidget {
  const TourBookHome({super.key, this.onProfileTap});
  final VoidCallback? onProfileTap;

  @override
  State<TourBookHome> createState() => _TourBookHomeState();
}

class _TourBookHomeState extends State<TourBookHome> {
  bool _showAllPosts = false;
  bool _loadingFeatured = true;
  bool _loadingCommunity = true;
  List<MD.Destination> _featuredDestinations = [];
  List<CP.CommunityPost> _communityPosts = [];
  String? _featuredError;
  String? _communityError;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    _loadFeatured();
    _loadCommunity();
  }

  String? _formatImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '${ApiClient.baseUrl}$path';
  }

  Future<void> _loadFeatured() async {
    if (!mounted) return;
    setState(() {
      _loadingFeatured = true;
      _featuredError = null;
    });
    try {
      final list = await DestinationService.popular();
      if (mounted) setState(() => _featuredDestinations = list);
    } catch (e) {
      if (mounted)
        setState(() => _featuredError = "Failed to load destinations");
    } finally {
      if (mounted) setState(() => _loadingFeatured = false);
    }
  }

  Future<void> _loadCommunity() async {
    if (!mounted) return;
    setState(() {
      _loadingCommunity = true;
      _communityError = null;
    });
    try {
      final posts = await CommunityService.trending();
      if (mounted) setState(() => _communityPosts = posts);
    } catch (e) {
      if (mounted)
        setState(() => _communityError = "Failed to load community posts");
    } finally {
      if (mounted) setState(() => _loadingCommunity = false);
    }
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final featureCards = [
      FeatureCardData(
        'Explore',
        Icons.explore_outlined,
        onTap: () => context.push(AppRoutes.destinations),
      ),
      const FeatureCardData('Trip Planner', Icons.event_note_outlined),
      const FeatureCardData('Itineraries', Icons.route_outlined),
    ];

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHomeData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBar(onProfileTap: widget.onProfileTap),
                const SizedBox(height: 12),
                const CategoryChips(
                  chips: [
                    'Nearby',
                    'Popular',
                    'Budget',
                    'Nature',
                    'Adventure',
                    'Luxury',
                  ],
                ),
                const SizedBox(height: 16),
                const PlanHeader(),
                const SizedBox(height: 12),
                FeatureCardsRow(cards: featureCards),
                const SizedBox(height: 22),
                SectionHeader(
                  title: 'Featured destinations',
                  actionText: 'See all',
                  onActionTap: () => context.push(AppRoutes.destinations),
                ),
                const SizedBox(height: 12),
                _loadingFeatured
                    ? const SizedBox(
                        height: 220,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _featuredError != null
                    ? _buildErrorWidget(_featuredError!, _loadFeatured)
                    : FeaturedList(
                        destinations: _featuredDestinations.map((d) {
                          final imgUrl = _formatImageUrl(
                            d.images.isNotEmpty ? d.images.first : null,
                          );
                          return DestinationCardData(
                            title: d.name,
                            subtitle: d.shortDescription,
                            tag: (d.tags.isNotEmpty ? d.tags.first : 'Dest'),
                            tagColor: AppColors.primary,
                            imageUrl: imgUrl ?? "",
                            metaIcon: Icons.location_on,
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 22),
                SectionHeader(
                  title: 'Community posts',
                  actionText: _showAllPosts ? 'Show less' : 'Show more',
                  onActionTap: () =>
                      setState(() => _showAllPosts = !_showAllPosts),
                ),
                const SizedBox(height: 12),
                _loadingCommunity
                    ? const Center(child: CircularProgressIndicator())
                    : _communityError != null
                    ? _buildErrorWidget(_communityError!, _loadCommunity)
                    : Column(
                        children:
                            (_showAllPosts
                                    ? _communityPosts
                                    : _communityPosts.take(2))
                                .map((post) {
                                  // ✅ FIXED: Using .media instead of .images
                                  final String? firstMediaUrl =
                                      post.media.isNotEmpty
                                      ? post.media.first.mediaUrl
                                      : null;

                                  final imgUrl = _formatImageUrl(firstMediaUrl);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: CommunityPostCard(
                                      post: CommunityPostData(
                                        title: post.title,
                                        // ✅ FIXED: Using .user?.fullName
                                        author:
                                            post.user?.fullName ?? 'Traveler',
                                        // ✅ FIXED: Using .totalLikes
                                        likes: post.totalLikes,
                                        comments: 0,
                                        imageUrl: imgUrl ?? "",
                                        accent: AppColors.primary,
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
