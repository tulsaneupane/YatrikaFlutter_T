import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tour_guide/services/auth_service.dart';
// ✅ ADD THIS IMPORT TO SYNC TOKEN
import '../../services/api_client.dart';
import '../components/app_colors.dart';
import '../components/community_post_feed_card.dart';
import '../../services/community_service.dart';
import '../../services/file_upload_service.dart';
import '../../models/community_post.dart' as ModelPost;
import '../../shared/widgets/shimmer_loading.dart';

class DayItineraryControllers {
  final TextEditingController description = TextEditingController();
  final TextEditingController activities = TextEditingController();
  final int dayNumber;

  DayItineraryControllers({required this.dayNumber});

  void dispose() {
    description.dispose();
    activities.dispose();
  }
}

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<CommunityFeed> _posts = [];
  bool _loading = true;
  bool _isUploadingGlobal = false;
  String? _error;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  CommunityFeed _mapPostToFeed(ModelPost.CommunityPost p) {
  // Helper to filter out placeholder "string" text from backend
  String? validateUrl(String? url) {
    if (url == null || url == "string" || url.isEmpty) return null;
    return url;
  }

  return CommunityFeed(
    author: p.user?.fullName ?? 'Anonymous',
    avatarUrl: ApiClient.getFullImageUrl(validateUrl(p.user?.profileImage)),
    timeLocation: _formatDisplayDate(p.createdAt),
    title: p.title,
    tag: "\$${p.estimatedCost.toInt()}",
    // Filter out any "string" values from the media list
    images: p.media
        .map((m) => validateUrl(m.mediaUrl))
        .where((url) => url != null)
        .map((url) => ApiClient.getFullImageUrl(url!))
        .toList(),
    itinerary: p.days.map((d) => d.activities).toList(),
    likes: p.totalLikes,
  );
}

  String _formatDisplayDate(String? date) {
    if (date == null) return "Just now";
    return date.split('T').first;
  }

  Future<void> _loadPosts() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final posts = await CommunityService.getPublicPosts();
      if (mounted) {
        setState(() {
          _posts = posts.map((p) => _mapPostToFeed(p)).toList();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = "Check connection or API.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openCreatePostSheet() {
    // 1. Initialize controllers locally
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    List<DayItineraryControllers> dayControllers = [
      DayItineraryControllers(dayNumber: 1),
    ];
    List<XFile> selectedImages = [];
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Header with logic
                _buildModalHeader(ctx, isSubmitting, () async {
                  // Validation
                  if (titleCtrl.text.isEmpty || selectedImages.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Title and images are required"),
                      ),
                    );
                    return;
                  }

                  setModalState(() => isSubmitting = true);
                  setState(() => _isUploadingGlobal = true);

                  try {
                    final token = await AuthService.getToken();
                    if (token == null) throw Exception("Please login again.");

                    // Sync token to ApiClient
                    ApiClient.setAuthToken(token);

                    // Upload Images
                    final files = selectedImages
                        .map((x) => File(x.path))
                        .toList();
                    final uploadedUrls = await FileUploadService.uploadFiles(
                      files: files,
                      type: UploadType.post,
                      token: token,
                    );

                    if (uploadedUrls.isEmpty) {
                      throw Exception("Image upload failed.");
                    }

                    // Build Payload
                    final Map<String, dynamic> payload = {
                      "title": titleCtrl.text.trim(),
                      "content": contentCtrl.text.trim(),
                      "tripDurationDays": dayControllers.length,
                      "estimatedCost": double.tryParse(costCtrl.text) ?? 0,
                      "coverImageUrl": uploadedUrls.first,
                      "isPublic": true,
                      "media": uploadedUrls
                          .asMap()
                          .entries
                          .map(
                            (e) => {
                              "mediaUrl": e.value,
                              "mediaType": "IMAGE",
                              "dayNumber": 1,
                              "displayOrder": e.key,
                            },
                          )
                          .toList(),
                      "days": dayControllers
                          .map(
                            (d) => {
                              "dayNumber": d.dayNumber,
                              "description": d.description.text.trim(),
                              "activities": d.activities.text.trim(),
                              "accommodation": "Standard",
                              "food": "Local",
                              "transportation": "Public",
                            },
                          )
                          .toList(),
                    };

                    // Send to API
                    final created = await CommunityService.createRaw(payload);

                    if (mounted) {
                      setState(() => _posts.insert(0, _mapPostToFeed(created)));

                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Adventure shared!")),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().replaceAll("Exception: ", ""),
                        ),
                      ),
                    );
                  } finally {
                    if (mounted) {
                      setModalState(() => isSubmitting = false);
                      setState(() => _isUploadingGlobal = false);
                    }
                  }
                }),

                if (isSubmitting)
                  const LinearProgressIndicator(color: Color(0xFF10884F)),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildLabel("TRIP OVERVIEW"),
                      _buildTextField(titleCtrl, "Where did you go?"),
                      _buildTextField(
                        contentCtrl,
                        "Describe your experience...",
                        maxLines: 3,
                      ),
                      _buildTextField(
                        costCtrl,
                        "Total Budget (\$)",
                        isNumber: true,
                      ),
                      const SizedBox(height: 20),
                      _buildLabel("PHOTOS"),
                      _buildImagePicker(selectedImages, setModalState),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel("ITINERARY"),
                          TextButton.icon(
                            onPressed: () => setModalState(() {
                              dayControllers.add(
                                DayItineraryControllers(
                                  dayNumber: dayControllers.length + 1,
                                ),
                              );
                            }),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text("Add Day"),
                          ),
                        ],
                      ),
                      ...dayControllers
                          .map(
                            (day) => Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Day ${day.dayNumber}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF10884F),
                                        ),
                                      ),
                                      if (dayControllers.length > 1)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () => setModalState(() {
                                            day.dispose();
                                            dayControllers.remove(day);
                                          }),
                                        ),
                                    ],
                                  ),
                                  _buildTextField(
                                    day.description,
                                    "What did you see?",
                                  ),
                                  _buildTextField(
                                    day.activities,
                                    "Activities (Hiking, Dinner, etc.)",
                                  ),
                                ],
                              ),
                            ),
                          )
                          ,
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModalHeader(
    BuildContext ctx,
    bool loading,
    VoidCallback onPost,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: loading ? null : () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          const Text(
            "New Adventure",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          loading
              ? const SizedBox(
                  width: 40,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : ElevatedButton(
                  onPressed: onPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10884F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Post"),
                ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(
    List<XFile> images,
    Function(void Function()) setModalState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty)
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(right: 12, top: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(images[i].path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: GestureDetector(
                        onTap: () => setModalState(() => images.removeAt(i)),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            // 1. Check if the limit is already reached
            if (images.length >= 5) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Maximum 5 photos allowed")),
              );
              return;
            }

            try {
              final picked = await _picker.pickMultiImage();

              if (picked.isNotEmpty) {
                setModalState(() {
                  // 2. Calculate how many more can be added
                  int spaceLeft = 5 - images.length;

                  // 3. Only add up to the limit
                  if (picked.length > spaceLeft) {
                    images.addAll(picked.take(spaceLeft));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Only added $spaceLeft photos to stay within the 5-photo limit.",
                        ),
                      ),
                    );
                  } else {
                    images.addAll(picked);
                  }
                });
              }
            } catch (e) {
              debugPrint("Picker Error: $e");
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Color(0xFF10884F),
                ),
                SizedBox(width: 8),
                Text(
                  "Add Trip Photos",
                  style: TextStyle(
                    color: Color(0xFF10884F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 12),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Colors.grey,
      ),
    ),
  );

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Travel Community',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF10884F),
                  size: 28,
                ),
                onPressed: _openCreatePostSheet,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadPosts,
            color: const Color(0xFF10884F),
            child: _loading
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 3,
                    itemBuilder: (context, index) => _buildSkeletonCard(),
                  )
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _loadPosts,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) =>
                        CommunityPostFeedCard(feed: _posts[index]),
                  ),
          ),
        ),
        if (_isUploadingGlobal)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    "Sharing your adventure...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              ShimmerLoading(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              SizedBox(width: 12),
              ShimmerLoading(width: 100, height: 12),
            ],
          ),
          const SizedBox(height: 16),
          const ShimmerLoading(
            width: double.infinity,
            height: 150,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ],
      ),
    );
  }
}
