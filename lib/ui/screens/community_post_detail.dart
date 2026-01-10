// import 'package:flutter/material.dart';

// import '../components/app_colors.dart';
// import '../components/community_post_feed_card.dart';

// class CommunityPostDetail extends StatelessWidget {
//   const CommunityPostDetail({super.key, required this.feed});

//   final CommunityFeed feed;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: const BackButton(color: Colors.black),
//         title: const Text('Community', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
//         actions: [
//           IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: AppColors.subtext)),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Likes column
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//                 child: Column(
//                   children: [
//                     const Icon(Icons.favorite_border, color: Color(0xFF9CA3AF)),
//                     const SizedBox(height: 8),
//                     Text('${feed.likes}', style: const TextStyle(color: AppColors.subtext)),
//                   ],
//                 ),
//               ),

//               // Content column
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Header row: avatar, author, time
//                       Row(
//                         children: [
//                           CircleAvatar(radius: 20, backgroundImage: NetworkImage(feed.avatarUrl)),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(feed.author, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
//                                 const SizedBox(height: 2),
//                                 Text(feed.timeLocation, style: const TextStyle(color: AppColors.subtext, fontSize: 12)),
//                               ],
//                             ),
//                           ),
//                           // small spacer for top-right
//                         ],
//                       ),

//                       const SizedBox(height: 12),

//                       Text(feed.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                         decoration: BoxDecoration(color: const Color(0xFFE6F6EE), borderRadius: BorderRadius.circular(8)),
//                         child: Text(feed.tag, style: const TextStyle(color: Color(0xFF10884F))),
//                       ),

//                       const SizedBox(height: 12),

//                       // Images: left large, right tall
//                       SizedBox(
//                         height: 180,
//                         child: Row(
//                           children: [
//                             Expanded(
//                               flex: 2,
//                               child: ClipRRect(borderRadius: BorderRadius.circular(8), child: feed.images.isNotEmpty ? Image.network(feed.images[0], fit: BoxFit.cover) : Container(color: AppColors.stroke)),
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               flex: 1,
//                               child: ClipRRect(borderRadius: BorderRadius.circular(8), child: feed.images.length > 1 ? Image.network(feed.images[1], fit: BoxFit.cover) : Container(color: AppColors.stroke)),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 12),

//                       // Itinerary box (simple bordered container)
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.stroke)),
//                         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                           Row(children: const [
//                             Text('DAY', style: TextStyle(fontWeight: FontWeight.w700)),
//                             SizedBox(width: 8),
//                             Text('1', style: TextStyle(fontWeight: FontWeight.w700)),
//                           ]),
//                           const SizedBox(height: 8),
//                           ...feed.itinerary.map((s) => Padding(
//                                 padding: const EdgeInsets.symmetric(vertical: 4),
//                                 child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                                   const Text('• ', style: TextStyle(fontSize: 14)),
//                                   Expanded(child: Text(s)),
//                                 ]),
//                               )),
//                         ]),
//                       ),

//                       const SizedBox(height: 12),

//                       // Action buttons
//                       Row(
//                         children: [
//                           OutlinedButton.icon(
//                             onPressed: () {},
//                             icon: const Icon(Icons.map, color: Color(0xFF0F7A54)),
//                             label: const Text('Map', style: TextStyle(color: Color(0xFF0F7A54))),
//                             style: OutlinedButton.styleFrom(backgroundColor: const Color(0xFFEFFAF3), side: const BorderSide(color: Color(0xFFE6F6EE))),
//                           ),
//                           const SizedBox(width: 8),
//                           OutlinedButton.icon(
//                             onPressed: () {},
//                             icon: const Icon(Icons.share, color: Color(0xFF0F7A54)),
//                             label: const Text('Share', style: TextStyle(color: Color(0xFF0F7A54))),
//                             style: OutlinedButton.styleFrom(backgroundColor: const Color(0xFFEFFAF3), side: const BorderSide(color: Color(0xFFE6F6EE))),
//                           ),
//                           const Spacer(),
//                           ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.open_in_new), label: const Text('Visit'))
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../components/app_colors.dart';
import '../components/community_post_feed_card.dart';
import '../../shared/widgets/smart_image.dart'; // Import your new shared widget

class CommunityPostDetail extends StatelessWidget {
  const CommunityPostDetail({super.key, required this.feed});

  final CommunityFeed feed;

  @override
  Widget build(BuildContext context) {
    // Unique tag for Hero animation matching the card
    final String heroTag = 'post_${feed.title}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Trip Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
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
                  height: 210,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            SmartImage(
                              url: feed.images.isNotEmpty ? feed.images.first : '',
                              heroTag: heroTag,
                              borderRadius: BorderRadius.zero,
                            ),
                            Positioned(
                              left: 12,
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
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
                      Expanded(
                        child: SmartImage(
                          url: feed.images.length > 1 ? feed.images[1] : '',
                          heroTag: '${heroTag}_2',
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.stroke,
                            child: ClipOval(
                              child: SmartImage(
                                url: feed.avatarUrl,
                                heroTag: '${heroTag}_avatar',
                                width: 36,
                                height: 36,
                              ),
                            ),
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
                      const SizedBox(height: 12),
                      Text(
                        feed.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.schedule,
                                  size: 16,
                                  color: AppColors.subtext,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Day 1 Itinerary',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...feed.itinerary.take(4).toList().asMap().entries.map((entry) {
                              final index = entry.key + 1;
                              final step = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$index',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.subtext,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        step,
                                        style: const TextStyle(
                                          color: AppColors.text,
                                          fontSize: 13,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
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
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.share_outlined,
                            size: 18,
                            color: AppColors.subtext,
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text('Use This Plan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10884F),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
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
          ),
        ),
      ),
    );
  }

  
}
