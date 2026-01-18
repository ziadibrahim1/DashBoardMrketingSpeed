import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'package:flutter/material.dart' hide VoidCallback;
import 'package:admin_dashboard/core/app_config.dart';
import 'package:http/http.dart' as http;

class VideoManagerScreen extends StatefulWidget {
  const VideoManagerScreen({super.key});

  @override
  State<VideoManagerScreen> createState() => _VideoManagerScreenState();
}

class _VideoManagerScreenState extends State<VideoManagerScreen> {
  final VideoApiService _videoService = VideoApiService();
  final CategoryApiService _categoryService = CategoryApiService();
  final TextEditingController _searchController = TextEditingController();

  List<VideoDto> _videos = [];
  List<VideoCategory> _categories = [];
  List<VideoDto> _filteredVideos = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _languageFilter = 'all';

  // Colors
  final Color _primaryColor = const Color(0xFF1A56DB);
  final Color _primaryLight = const Color(0xFFE3F2FD);
  final Color _primaryDark = const Color(0xFF0D47A1);
  final Color _backgroundColor = const Color(0xFFF8FAFC);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF1F2937);
  final Color _textSecondary = const Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final videos = await _videoService.getVideos();
      final categories = await _categoryService.getCategories();

      setState(() {
        _videos = videos;
        _categories = categories;
        _filteredVideos = videos;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredVideos = _videos.where((video) {
        bool statusFilter = _selectedFilter == 'all' ||
            (_selectedFilter == 'active' && video.isActive) ||
            (_selectedFilter == 'inactive' && !video.isActive);

        bool languageFilter = _languageFilter == 'all' ||
            video.language == _languageFilter;

        bool searchFilter = _searchController.text.isEmpty ||
            video.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            video.description.toLowerCase().contains(_searchController.text.toLowerCase());

        return statusFilter && languageFilter && searchFilter;
      }).toList();
    });
  }

  Future<void> _showAddVideoDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AddVideoDialog(
        videoService: _videoService,
        categories: _categories,
        onVideoAdded: _loadData,
        primaryColor: _primaryColor,
      ),
    );
  }


  Future<void> _confirmDeleteVideo(int id) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video'),
        content: const Text('Are you sure you want to delete this video?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _videoService.deleteVideo(id);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Video deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to delete video'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Filters and Search
            _buildFiltersSection(),
            const SizedBox(height: 24),


          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Video Manager',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage and organize your video content',
              style: TextStyle(
                fontSize: 16,
                color: _textSecondary,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _showAddVideoDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add New Video',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search videos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _applyFilters();
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _primaryColor, width: 2),
              ),
            ),
            onChanged: (_) => _applyFilters(),
          ),
          const SizedBox(height: 16),

          // Filters Row
          Row(
            children: [
              // Status Filter
              _buildFilterDropdown(
                label: 'Status',
                value: _selectedFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Status')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: (value) {
                  setState(() => _selectedFilter = value!);
                  _applyFilters();
                },
              ),
              const SizedBox(width: 16),

              // Language Filter
              _buildFilterDropdown(
                label: 'Language',
                value: _languageFilter,
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('All Languages')),
                  const DropdownMenuItem(value: 'ar', child: Text('Arabic')),
                  const DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (value) {
                  setState(() => _languageFilter = value!);
                  _applyFilters();
                },
              ),

              const Spacer(),

              // Results Count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_filteredVideos.length} videos',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: _primaryColor.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              style: TextStyle(color: _textColor, fontSize: 14),
              borderRadius: BorderRadius.circular(8),
              icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildStatusBadge(VideoDto video) {
    Color badgeColor;
    Color textColor;
    String text;

    if (!video.isActive) {
      badgeColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      text = 'Inactive';
    } else {
      switch (video.publishStatus) {
        case PublishStatus.published:
          badgeColor = Colors.green.shade50;
          textColor = Colors.green.shade700;
          text = 'Published';
          break;
        case PublishStatus.draft:
          badgeColor = Colors.orange.shade50;
          textColor = Colors.orange.shade700;
          text = 'Draft';
          break;
        case PublishStatus.pending:
          badgeColor = Colors.blue.shade50;
          textColor = Colors.blue.shade700;
          text = 'Pending';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// Add Video Dialog
class AddVideoDialog extends StatelessWidget {
  final VideoApiService videoService;
  final List<VideoCategory> categories;
  final VoidCallback onVideoAdded;
  final Color primaryColor;

  const AddVideoDialog({
    super.key,
    required this.videoService,
    required this.categories,
    required this.onVideoAdded,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add New Video',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Choose how you want to add a video'),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // YouTube Option
                _buildOptionCard(
                  icon: Icons.youtube_searched_for,
                  title: 'YouTube Video',
                  description: 'Add a video from YouTube',
                  color: Colors.red,
                  onTap: () => _showYouTubeDialog(context),
                ),
                const SizedBox(width: 24),

                // File Upload Option
                _buildOptionCard(
                  icon: Icons.upload_file,
                  title: 'Upload File',
                  description: 'Upload a video file',
                  color: primaryColor,
                  onTap: () => _showUploadDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  void _showYouTubeDialog(BuildContext context) {
    // Implement YouTube dialog
  }

  void _showUploadDialog(BuildContext context) {
    // Implement file upload dialog
  }
}

// Edit Video Dialog

// Enums and Services (keep your existing code)
enum PublishStatus { draft, published, pending }

class VideoDto {
  final int id;
  late final String title;
  late final String description;
  final String videoType;
  final String? videoUrl;
  final String? filePath;
  final int? duration;
  final String language;
  final DateTime createdAt;
  final bool isActive;
  late final int? categoryId;
  final String? categoryName;
  late final PublishStatus publishStatus;

  VideoDto({
    required this.id,
    required this.title,
    required this.description,
    required this.videoType,
    this.videoUrl,
    this.filePath,
    this.duration,
    required this.language,
    required this.createdAt,
    required this.isActive,
    this.categoryId,
    this.categoryName,
    required this.publishStatus,
  });

  factory VideoDto.fromJson(Map<String, dynamic> json) {
    return VideoDto(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      videoType: json['videoType'],
      videoUrl: json['videoUrl'],
      filePath: json['filePath'],
      duration: json['duration'],
      language: json['language'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      publishStatus: PublishStatus.values.firstWhere(
            (e) => e.name == json['publishStatus'],
        orElse: () => PublishStatus.draft,
      ),
    );
  }
}

class VideoApiService {
  final String baseUrl = '${AppConfig.baseUrl}tutorial-videos';

  Future<List<VideoDto>> getVideos() async {
    final res = await http.get(Uri.parse(baseUrl));
    final List data = jsonDecode(res.body);
    return data.map((e) => VideoDto.fromJson(e)).toList();
  }

  Future<void> addYouTube({required String title, required String description, required String videoId, int? categoryId}) async {
    await http.post(
      Uri.parse('$baseUrl/youtube'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'description': description, 'videoUrl': videoId, 'categoryId': categoryId, 'language': 'ar'}),
    );
  }

  Future<void> uploadVideoFile({required Uint8List bytes, required String fileName, required String title, String? description, int? categoryId}) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
    request.fields['title'] = title;
    if (description != null) request.fields['description'] = description;
    if (categoryId != null) request.fields['categoryId'] = categoryId.toString();
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));
    await request.send();
  }

  Future<void> updateVideo(int id, Map<String, dynamic> data) async {
    await http.put(Uri.parse('$baseUrl/$id'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
  }

  Future<void> deleteVideo(int id) async {
    await http.delete(Uri.parse('$baseUrl/$id'));
  }
}
class VideoCategory {
  final int id;
  final String name;

  VideoCategory({required this.id, required this.name});

  factory VideoCategory.fromJson(Map<String, dynamic> json) {
    return VideoCategory(id: json['id'], name: json['name']);
  }
}

class CategoryApiService {
  final String baseUrl = '${AppConfig.baseUrl}tutorial-videos';

  Future<List<VideoCategory>> getCategories() async {
    final res = await http.get(Uri.parse('$baseUrl/cat'));
    final List data = jsonDecode(res.body);
    return data.map((e) => VideoCategory.fromJson(e)).toList();
  }

  Future<void> addCategory(String name) async {
    await http.post(Uri.parse('$baseUrl/addcat'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'name': name}));
  }

  Future<void> updateCategory(int id, String name) async {
    await http.put(Uri.parse('$baseUrl/updatecat/$id'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'name': name}));
  }

  Future<void> deleteCategory(int id) async {
    await http.delete(Uri.parse('$baseUrl/delcat/$id'));
  }
}
