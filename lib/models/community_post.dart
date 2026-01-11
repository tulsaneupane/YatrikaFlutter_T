class CommunityPost {
  final int? id;
  final PostUser? user;
  final String title;
  final String content;
  final int tripDurationDays;
  final double estimatedCost;
  final String coverImageUrl;
  final bool isPublic;
  final int totalLikes;
  final int totalViews;
  final List<PostMedia> media;
  final List<PostDay> days;
  final String? createdAt;

  CommunityPost({
    this.id,
    this.user,
    required this.title,
    required this.content,
    required this.tripDurationDays,
    required this.estimatedCost,
    required this.coverImageUrl,
    this.isPublic = true,
    this.totalLikes = 0,
    this.totalViews = 0,
    required this.media,
    required this.days,
    this.createdAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'],
      user: json['user'] != null ? PostUser.fromJson(json['user']) : null,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      tripDurationDays: json['tripDurationDays'] ?? 0,
      estimatedCost: (json['estimatedCost'] ?? 0).toDouble(),
      coverImageUrl: json['coverImageUrl'] ?? '',
      isPublic: json['isPublic'] ?? true,
      totalLikes: json['totalLikes'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      media: (json['media'] as List?)?.map((m) => PostMedia.fromJson(m)).toList() ?? [],
      days: (json['days'] as List?)?.map((d) => PostDay.fromJson(d)).toList() ?? [],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "content": content,
    "tripDurationDays": tripDurationDays,
    "estimatedCost": estimatedCost,
    "coverImageUrl": coverImageUrl,
    "isPublic": isPublic,
    "media": media.map((m) => m.toJson()).toList(),
    "days": days.map((d) => d.toJson()).toList(),
  };
}

// --- Helper Model: User ---
class PostUser {
  final String username;
  final String fullName;
  final String? profileImage;

  PostUser({required this.username, required this.fullName, this.profileImage});

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      username: json['username'] ?? 'Traveler',
      fullName: json['fullName'] ?? 'Guest',
      profileImage: json['profileImageUrl'],
    );
  }
}

// --- Helper Model: Media ---
class PostMedia {
  final String mediaUrl;
  final String mediaType;
  final String? caption;
  final int dayNumber;

  PostMedia({required this.mediaUrl, this.mediaType = "IMAGE", this.caption, this.dayNumber = 1});

  factory PostMedia.fromJson(Map<String, dynamic> json) => PostMedia(
    mediaUrl: json['mediaUrl'],
    mediaType: json['mediaType'] ?? "IMAGE",
    caption: json['caption'],
    dayNumber: json['dayNumber'] ?? 1,
  );

  Map<String, dynamic> toJson() => {
    "mediaUrl": mediaUrl,
    "mediaType": mediaType,
    "caption": caption,
    "dayNumber": dayNumber,
    "displayOrder": 0
  };
}

// --- Helper Model: Days (Itinerary) ---
class PostDay {
  final int dayNumber;
  final String description;
  final String activities;

  PostDay({required this.dayNumber, required this.description, required this.activities});

  factory PostDay.fromJson(Map<String, dynamic> json) => PostDay(
    dayNumber: json['dayNumber'] ?? 1,
    description: json['description'] ?? '',
    activities: json['activities'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "dayNumber": dayNumber,
    "description": description,
    "activities": activities,
    "accommodation": "N/A",
    "food": "N/A",
    "transportation": "N/A"
  };
}