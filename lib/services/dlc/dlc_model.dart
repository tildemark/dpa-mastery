/// Model representing a Downloadable Content (DLC) Expansion Pack.
class DlcPack {
  const DlcPack({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.badge,
    required this.totalQuestions,
    required this.estimatedSize,
    required this.version,
    required this.tags,
    this.isInstalled = false,
    this.isAvailable = false,
    this.statusNote = 'Coming Soon / In Preparation',
    this.assetPath,
    this.remoteUrl,
    this.author = 'DPA Advisory Board',
  });

  final String id;
  final String title;
  final String description;
  final String category; // e.g. 'Exam Simulation', 'Regulatory Rules', 'Case Studies'
  final String badge; // e.g. 'Essential', 'Advanced', 'Specialized'
  final int totalQuestions;
  final String estimatedSize;
  final int version;
  final List<String> tags;
  final bool isInstalled;
  final bool isAvailable;
  final String statusNote;
  final String? assetPath;
  final String? remoteUrl;
  final String author;

  DlcPack copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? badge,
    int? totalQuestions,
    String? estimatedSize,
    int? version,
    List<String>? tags,
    bool? isInstalled,
    bool? isAvailable,
    String? statusNote,
    String? assetPath,
    String? remoteUrl,
    String? author,
  }) {
    return DlcPack(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      badge: badge ?? this.badge,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      estimatedSize: estimatedSize ?? this.estimatedSize,
      version: version ?? this.version,
      tags: tags ?? this.tags,
      isInstalled: isInstalled ?? this.isInstalled,
      isAvailable: isAvailable ?? this.isAvailable,
      statusNote: statusNote ?? this.statusNote,
      assetPath: assetPath ?? this.assetPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      author: author ?? this.author,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'badge': badge,
      'total_questions': totalQuestions,
      'estimated_size': estimatedSize,
      'version': version,
      'tags': tags,
      'is_installed': isInstalled,
      'is_available': isAvailable,
      'status_note': statusNote,
      'asset_path': assetPath,
      'remote_url': remoteUrl,
      'author': author,
    };
  }

  factory DlcPack.fromJson(Map<String, dynamic> json, {bool isInstalled = false}) {
    return DlcPack(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String? ?? 'Expansion',
      badge: json['badge'] as String? ?? 'Add-on',
      totalQuestions: json['total_questions'] as int? ?? (json['totalQuestions'] as int? ?? 0),
      estimatedSize: json['estimated_size'] as String? ?? (json['estimatedSize'] as String? ?? '~30 KB'),
      version: json['version'] as int? ?? 1,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      isInstalled: json['is_installed'] as bool? ?? isInstalled,
      isAvailable: json['is_available'] as bool? ?? (json['isAvailable'] as bool? ?? false),
      statusNote: json['status_note'] as String? ?? (json['statusNote'] as String? ?? 'Coming Soon / In Preparation'),
      assetPath: json['asset_path'] as String? ?? json['assetPath'] as String?,
      remoteUrl: json['remote_url'] as String? ?? json['remoteUrl'] as String?,
      author: json['author'] as String? ?? 'DPA Advisory Board',
    );
  }
}

/// Learning progress statistics for a DLC expansion pack.
class DlcPackProgress {
  const DlcPackProgress({
    required this.total,
    required this.unlearned,
    required this.apprentice,
    required this.guruPlus,
  });

  final int total;
  final int unlearned;
  final int apprentice;
  final int guruPlus;

  int get started => apprentice + guruPlus;
  double get guruRatio => total > 0 ? (guruPlus / total).clamp(0.0, 1.0) : 0.0;
  double get apprenticeRatio => total > 0 ? (apprentice / total).clamp(0.0, 1.0) : 0.0;
  String get percentageLabel => '${(guruRatio * 100).round()}%';
}
