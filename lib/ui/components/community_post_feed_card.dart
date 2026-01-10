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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left vertical likes and heart
                Column(
                  children: [
                    const Icon(Icons.favorite_border, color: Color(0xFF9CA3AF)),
                    const SizedBox(height: 6),
                    Text(
                      '${feed.likes}',
                      style: const TextStyle(
                        color: AppColors.subtext,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Main card content
                Expanded(
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      feed.author,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      feed.timeLocation,
                                      style: const TextStyle(
                                        color: AppColors.subtext,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  feed.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Tag chip
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F6EE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              feed.tag,
                              style: const TextStyle(
                                color: Color(0xFF10884F),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Images row: left big, right tall
                      SizedBox(
                        height: 120,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                    (feed.images.isNotEmpty &&
                                        feed
                                            .images[0]
                                            .isNotEmpty) // ✅ Check both
                                    ? Image.network(
                                        feed.images[0],
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: AppColors.stroke,
                                        child: const Icon(Icons.image),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                    (feed.images.length > 1 &&
                                        feed
                                            .images[1]
                                            .isNotEmpty) // ✅ Check both
                                    ? Image.network(
                                        feed.images[1],
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: AppColors.stroke,
                                        child: const Icon(Icons.image),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Itinerary box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: AppColors.subtext,
                                  fontSize: 12,
                                ),
                                children: [
                                  const TextSpan(text: 'DAY\u001F '),
                                  TextSpan(
                                    text: '1',
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...feed.itinerary.map(
                              (s) => Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '• ',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Expanded(
                                    child: Text(
                                      s,
                                      style: const TextStyle(
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Action buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.map,
                              color: Color(0xFF0F7A54),
                              size: 18,
                            ),
                            label: const Text(
                              'Map',
                              style: TextStyle(
                                color: Color(0xFF0F7A54),
                                fontSize: 12,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE6F6EE)),
                              backgroundColor: const Color(0xFFEFFAF3),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.share,
                              color: Color(0xFF0F7A54),
                              size: 18,
                            ),
                            label: const Text(
                              'Share',
                              style: TextStyle(
                                color: Color(0xFF0F7A54),
                                fontSize: 12,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE6F6EE)),
                              backgroundColor: const Color(0xFFEFFAF3),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: const Text(
                              'Visit',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007BFF),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
