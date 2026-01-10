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
        // Added scrolling for long itineraries
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Author info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.stroke,
                      child: ClipOval(
                        child: SmartImage(
                          url: feed.avatarUrl,
                          heroTag: '${heroTag}_avatar',
                          width: 44,
                          height: 44,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feed.author,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
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
                    const Spacer(),
                    const Icon(Icons.favorite_border, color: AppColors.subtext),
                    const SizedBox(width: 4),
                    Text(
                      '${feed.likes}',
                      style: const TextStyle(color: AppColors.subtext),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Text(
                  feed.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),

                // Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F6EE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    feed.tag,
                    style: const TextStyle(
                      color: Color(0xFF10884F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (feed.images.isNotEmpty)
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: feed.images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SmartImage(
                            url: feed.images[index],
                            // Only the first image gets the Hero tag to match the feed card
                            heroTag: index == 0 ? heroTag : '${heroTag}_$index',
                            height: 200,
                            width: MediaQuery.of(context).size.width * 0.75,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 20),
                const Text(
                  'Itinerary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),

                // MODERN VERTICAL TIMELINE UI
                ...feed.itinerary.asMap().entries.map((entry) {
                  int idx = entry.key;
                  String step = entry.value;
                  bool isLast = idx == feed.itinerary.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline line and dot
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10884F),
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 40,
                              color: const Color(0xFFE6F6EE),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Itinerary text
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            step,
                            style: const TextStyle(fontSize: 15, height: 1.4),
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                const Divider(height: 32),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton(Icons.map, 'Map'),
                    _buildActionButton(Icons.share, 'Share'),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.navigation),
                      label: const Text('Start Trip'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10884F),
                        foregroundColor: Colors.white,
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
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: const Color(0xFF0F7A54), size: 18),
      label: Text(label, style: const TextStyle(color: Color(0xFF0F7A54))),
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFFEFFAF3),
        side: const BorderSide(color: Color(0xFFE6F6EE)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
