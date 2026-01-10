import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_colors.dart';
import '../../routes/app_routes.dart';

class CommunityFeed {
  const CommunityFeed({
    required this.author,
    required this.avatarUrl,
    required this.timeLocation,
    required this.title,
    required this.tag,
    required this.images,
    required this.itinerary,
    required this.likes,
  });

  final String author;
  final String avatarUrl;
  final String timeLocation;
  final String title;
  final String tag;
  final List<String> images;
  final List<String> itinerary;
  final int likes;
}

class CommunityPostFeedCard extends StatelessWidget {
  const CommunityPostFeedCard({super.key, required this.feed});

  final CommunityFeed feed;

  @override
  Widget build(BuildContext context) {
    final imageUrl = feed.images.firstWhere(
      (url) => url.isNotEmpty,
      orElse: () => '',
    );
    final stopsPlanned = feed.itinerary.length;

    return GestureDetector(
      onTap: () {
        // quick visual confirmation and debug log that a tap occurred
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Opening post...')));
        debugPrint('CommunityPostFeedCard tapped: ${feed.title}');
        context.push(
          AppRoutes.communityPost,
          extra: CommunityPostDetailArgs(feed: feed),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 190,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl.isNotEmpty)
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        color: AppColors.stroke,
                        child: const Icon(
                          Icons.image,
                          size: 48,
                          color: AppColors.subtext,
                        ),
                      ),
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          feed.tag,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(feed.avatarUrl),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feed.author,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                feed.timeLocation,
                                style: const TextStyle(
                                  color: AppColors.subtext,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      feed.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.subtext,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$stopsPlanned stops planned',
                          style: const TextStyle(
                            color: AppColors.subtext,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              size: 18,
                              color: AppColors.subtext,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${feed.likes}',
                              style: const TextStyle(
                                color: AppColors.subtext,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        const Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 18,
                              color: AppColors.subtext,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '12',
                              style: TextStyle(
                                color: AppColors.subtext,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.share_outlined,
                          size: 18,
                          color: AppColors.subtext,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
