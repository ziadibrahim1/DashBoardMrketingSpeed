import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:admin_dashboard/core/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../providers/app_providers.dart';

// ================== LOCALIZATION ==================
class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'video_manager': 'Video Manager',
      'manage_content': 'Manage and organize your video content',
      'categories': 'Categories',
      'add_video': 'Add Video',
      'published': 'Published',
      'pending': 'Pending',
      'drafts': 'Drafts',
      'total': 'Total',
      'search_videos': 'Search videos...',
      'status': 'Status',
      'language': 'Language',
      'all': 'All',
      'active': 'Active',
      'inactive': 'Inactive',
      'arabic': 'Arabic',
      'english': 'English',
      'videos': 'videos',
      'no_videos': 'No videos found',
      'untitled': 'Untitled',
      'no_description': 'No description',
      'draft': 'Draft',
      'add_new_video': 'Add New Video',
      'youtube': 'YouTube',
      'add_from_youtube': 'Add from YouTube',
      'upload_file': 'Upload File',
      'upload_video_file': 'Upload video file',
      'cancel': 'Cancel',
      'add_youtube_video': 'Add YouTube Video',
      'youtube_url': 'YouTube URL',
      'youtube_url_hint': 'https://www.youtube.com/watch?v=xxxx',
      'title': 'Title',
      'description': 'Description',
      'category': 'Category',
      'add': 'Add',
      'upload_video': 'Upload Video File',
      'choose_video': 'Choose Video File',
      'edit_video': 'Edit Video',
      'save': 'Save',
      'delete_video': 'Delete Video?',
      'delete_confirm': 'This action cannot be undone.',
      'delete': 'Delete',
      'manage_categories': 'Manage Categories',
      'add_category': 'Add Category',
      'edit_category': 'Edit Category',
      'delete_category': 'Delete Category?',
      'category_name': 'Category Name',
      'video_added': 'Video added successfully!',
      'video_updated': 'Video updated successfully!',
      'video_deleted': 'Video deleted successfully!',
      'category_added': 'Category added successfully!',
      'category_updated': 'Category updated successfully!',
      'category_deleted': 'Category deleted successfully!',
      'error': 'Error',
      'invalid_url': 'Invalid URL or missing title',
      'upload_failed': 'Upload failed',
    },
    'ar': {
      'video_manager': 'إدارة الفيديوهات',
      'manage_content': 'إدارة وتنظيم محتوى الفيديو الخاص بك',
      'categories': 'التصنيفات',
      'add_video': 'إضافة فيديو',
      'published': 'منشور',
      'pending': 'قيد الانتظار',
      'drafts': 'مسودات',
      'total': 'الإجمالي',
      'search_videos': 'بحث عن فيديوهات...',
      'status': 'الحالة',
      'language': 'اللغة',
      'all': 'الكل',
      'active': 'نشط',
      'inactive': 'غير نشط',
      'arabic': 'عربي',
      'english': 'إنجليزي',
      'videos': 'فيديو',
      'no_videos': 'لا توجد فيديوهات',
      'untitled': 'بدون عنوان',
      'no_description': 'بدون وصف',
      'draft': 'مسودة',
      'add_new_video': 'إضافة فيديو جديد',
      'youtube': 'يوتيوب',
      'add_from_youtube': 'إضافة من يوتيوب',
      'upload_file': 'رفع ملف',
      'upload_video_file': 'رفع ملف فيديو',
      'cancel': 'إلغاء',
      'add_youtube_video': 'إضافة فيديو يوتيوب',
      'youtube_url': 'رابط يوتيوب',
      'youtube_url_hint': 'https://www.youtube.com/watch?v=xxxx',
      'title': 'العنوان',
      'description': 'الوصف',
      'category': 'التصنيف',
      'add': 'إضافة',
      'upload_video': 'رفع ملف فيديو',
      'choose_video': 'اختر ملف فيديو',
      'edit_video': 'تعديل الفيديو',
      'save': 'حفظ',
      'delete_video': 'حذف الفيديو؟',
      'delete_confirm': 'لا يمكن التراجع عن هذا الإجراء.',
      'delete': 'حذف',
      'manage_categories': 'إدارة التصنيفات',
      'add_category': 'إضافة تصنيف',
      'edit_category': 'تعديل التصنيف',
      'delete_category': 'حذف التصنيف؟',
      'category_name': 'اسم التصنيف',
      'video_added': 'تم إضافة الفيديو بنجاح!',
      'video_updated': 'تم تحديث الفيديو بنجاح!',
      'video_deleted': 'تم حذف الفيديو بنجاح!',
      'category_added': 'تم إضافة التصنيف بنجاح!',
      'category_updated': 'تم تحديث التصنيف بنجاح!',
      'category_deleted': 'تم حذف التصنيف بنجاح!',
      'error': 'خطأ',
      'invalid_url': 'رابط غير صالح أو عنوان مفقود',
      'upload_failed': 'فشل الرفع',
    },
  };

  String translate(String key) {
    return _localizedValues[languageCode]?[key] ?? key;
  }

  String get videoManager => translate('video_manager');
  String get manageContent => translate('manage_content');
  String get categories => translate('categories');
  String get addVideo => translate('add_video');
  String get published => translate('published');
  String get pending => translate('pending');
  String get drafts => translate('drafts');
  String get total => translate('total');
  String get searchVideos => translate('search_videos');
  String get status => translate('status');
  String get language => translate('language');
  String get all => translate('all');
  String get active => translate('active');
  String get inactive => translate('inactive');
  String get arabic => translate('arabic');
  String get english => translate('english');
  String get videos => translate('videos');
  String get noVideos => translate('no_videos');
  String get untitled => translate('untitled');
  String get noDescription => translate('no_description');
  String get draft => translate('draft');
  String get addNewVideo => translate('add_new_video');
  String get youtube => translate('youtube');
  String get addFromYoutube => translate('add_from_youtube');
  String get uploadFile => translate('upload_file');
  String get uploadVideoFile => translate('upload_video_file');
  String get cancel => translate('cancel');
  String get addYoutubeVideo => translate('add_youtube_video');
  String get youtubeUrl => translate('youtube_url');
  String get youtubeUrlHint => translate('youtube_url_hint');
  String get title => translate('title');
  String get description => translate('description');
  String get category => translate('category');
  String get add => translate('add');
  String get uploadVideo => translate('upload_video');
  String get chooseVideo => translate('choose_video');
  String get editVideo => translate('edit_video');
  String get save => translate('save');
  String get deleteVideo => translate('delete_video');
  String get deleteConfirm => translate('delete_confirm');
  String get delete => translate('delete');
  String get manageCategories => translate('manage_categories');
  String get addCategory => translate('add_category');
  String get editCategory => translate('edit_category');
  String get deleteCategory => translate('delete_category');
  String get categoryName => translate('category_name');
  String get videoAdded => translate('video_added');
  String get videoUpdated => translate('video_updated');
  String get videoDeleted => translate('video_deleted');
  String get categoryAdded => translate('category_added');
  String get categoryUpdated => translate('category_updated');
  String get categoryDeleted => translate('category_deleted');
  String get error => translate('error');
  String get invalidUrl => translate('invalid_url');
  String get uploadFailed => translate('upload_failed');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale.languageCode);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// ================== LANGUAGE PROVIDER ==================
class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }


}

// ================== MAIN SCREEN ==================
class VideoManagerScreen extends StatefulWidget {
  const VideoManagerScreen({super.key});

  @override
  State<VideoManagerScreen> createState() => _VideoManagerScreenState();
}

class _VideoManagerScreenState extends State<VideoManagerScreen> {
  final VideoApiService _videoService = VideoApiService();
  final CategoryApiService _categoryService = CategoryApiService();
  final TextEditingController _searchController = TextEditingController();
  final LanguageProvider _languageProvider = LanguageProvider();

  List<VideoDto> _videos = [];
  List<VideoCategory> _categories = [];
  List<VideoDto> _filteredVideos = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _languageFilter = 'all';
  PublishStatus? _statusFilter;

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
    setState(() => _isLoading = true);
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
      setState(() => _isLoading = false);
      if (mounted) {
        final loc = AppLocalizations(_languageProvider.locale.languageCode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.error}: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredVideos = _videos.where((video) {
        bool statusFilter = _selectedFilter == 'all' ||
            (_selectedFilter == 'active' && video.isActive) ||
            (_selectedFilter == 'inactive' && !video.isActive);

        bool publishStatusFilter = _statusFilter == null ||
            video.publishStatus == _statusFilter;

        bool languageFilter = _languageFilter == 'all' ||
            video.language == _languageFilter;

        bool searchFilter = _searchController.text.isEmpty ||
            video.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            video.description.toLowerCase().contains(_searchController.text.toLowerCase());

        return statusFilter && languageFilter && searchFilter && publishStatusFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _languageProvider,
      builder: (context, _) {
        final localeProvider = Provider.of<LocaleProvider>(context);
        final loc = AppLocalizations(localeProvider.locale.languageCode);
        return Directionality(
          textDirection: localeProvider.locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: _backgroundColor,
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(loc),
                  const SizedBox(height: 24),
                  _buildStatsCards(loc),
                  const SizedBox(height: 24),
                  _buildFiltersSection(loc),
                  const SizedBox(height: 24),
                  _buildVideoGrid(loc),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildVideoGrid(AppLocalizations loc) {
    if (_filteredVideos.isEmpty) {
      return Container(
        height: 400,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, size: 80, color: _textSecondary.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text(loc.noVideos, style: TextStyle(fontSize: 20, color: _textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredVideos.length,
      itemBuilder: (_, i) => VideoCard(
        video: _filteredVideos[i],
        onEdit: () => showDialog(
          context: context,
          builder: (_) => EditVideoDialog(
            video: _filteredVideos[i],
            videoService: _videoService,
            categories: _categories,
            onVideoUpdated: _loadData,
            primaryColor: _primaryColor,
            languageCode: _languageProvider.locale.languageCode,
          ),
        ),
        onDelete: () async {
          final loc = AppLocalizations(_languageProvider.locale.languageCode);
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(loc.deleteVideo),
              content: Text(loc.deleteConfirm),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(loc.cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(loc.delete),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await _videoService.deleteVideo(_filteredVideos[i].id);
            _loadData();
          }
        },
      ),
    );
  }
  Widget _buildHeader(AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_primaryColor, _primaryDark]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: _primaryColor.withOpacity(0.3), blurRadius: 12)],
              ),
              child: const Icon(Icons.video_library, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.videoManager, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _primaryDark)),
                const SizedBox(height: 4),
                Text(loc.manageContent, style: TextStyle(fontSize: 16, color: _textSecondary)),
              ],
            ),
          ],
        ),
        Row(
          children: [
            _buildActionButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ManageCategoriesDialog(
                  categories: _categories,
                  categoryService: _categoryService,
                  onCategoriesUpdated: _loadData,
                  primaryColor: _primaryColor,
                  languageCode: _languageProvider.locale.languageCode,
                ),
              ),
              icon: Icons.category,
              label: loc.categories,
              backgroundColor: Colors.deepPurple,
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AddVideoDialog(
                  videoService: _videoService,
                  categories: _categories,
                  onVideoAdded: _loadData,
                  primaryColor: _primaryColor,
                  languageCode: _languageProvider.locale.languageCode,
                ),
              ),
              icon: Icons.add,
              label: loc.addVideo,
              backgroundColor: _primaryColor,
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildActionButton({required VoidCallback onPressed, required IconData icon, required String label, required Color backgroundColor}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildStatsCards(AppLocalizations loc) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(loc.published, '${_videos.where((v) => v.publishStatus == PublishStatus.published).length}', Icons.check_circle, Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(loc.pending, '${_videos.where((v) => v.publishStatus == PublishStatus.pending).length}', Icons.pending, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(loc.drafts, '${_videos.where((v) => v.publishStatus == PublishStatus.draft).length}', Icons.edit_note, Colors.grey)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(loc.total, '${_videos.length}', Icons.video_library, _primaryColor)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.1), color.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: loc.searchVideos,
              prefixIcon: Icon(Icons.search, color: _primaryColor),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                _searchController.clear();
                _applyFilters();
              })
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryColor, width: 2)),
            ),
            onChanged: (_) => _applyFilters(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFilterDropdown(
                label: loc.status,
                value: _selectedFilter,
                items: [
                  DropdownMenuItem(value: 'all', child: Text(loc.all)),
                  DropdownMenuItem(value: 'active', child: Text(loc.active)),
                  DropdownMenuItem(value: 'inactive', child: Text(loc.inactive)),
                ],
                onChanged: (v) {
                  setState(() => _selectedFilter = v!);
                  _applyFilters();
                },
              ),
              const SizedBox(width: 16),
              _buildFilterDropdown(
                label: loc.language,
                value: _languageFilter,
                items: [
                  DropdownMenuItem(value: 'all', child: Text(loc.all)),
                  DropdownMenuItem(value: 'ar', child: Text(loc.arabic)),
                  DropdownMenuItem(value: 'en', child: Text(loc.english)),
                ],
                onChanged: (v) {
                  setState(() => _languageFilter = v!);
                  _applyFilters();
                },
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(20)),
                child: Text('${_filteredVideos.length} ${loc.videos}', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({required String label, required String value, required List<DropdownMenuItem<String>> items, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textSecondary)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border.all(color: _primaryColor.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(value: value, items: items, onChanged: onChanged),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoList(AppLocalizations loc) {
    if (_filteredVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, size: 80, color: _textSecondary.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text(loc.noVideos, style: TextStyle(fontSize: 20, color: _textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: 0.75),
      itemCount: _filteredVideos.length,
      itemBuilder: (_, i) => VideoCard(
        video: _filteredVideos[i],

        onEdit: () => showDialog(context: context, builder: (_) => EditVideoDialog(video: _filteredVideos[i], videoService: _videoService, categories: _categories, onVideoUpdated: _loadData, primaryColor: _primaryColor, languageCode: _languageProvider.locale.languageCode)),
        onDelete: () async {
          final loc = AppLocalizations(_languageProvider.locale.languageCode);
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(loc.deleteVideo),
              content: Text(loc.deleteConfirm),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.cancel)),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text(loc.delete)),
              ],
            ),
          );
          if (confirmed == true) {
            await _videoService.deleteVideo(_filteredVideos[i].id);
            _loadData();
          }
        },
      ),
    );
  }
}

// ================== MODELS ==================
enum PublishStatus { draft, published, pending }

class VideoDto {
  final int id;
  final String title;
  final String description;
  final String videoType;
  final String? videoUrl;
  final String? filePath;
  final int? duration;
  final String language;
  final DateTime createdAt;
  final bool isActive;
  final int? categoryId;
  final String? categoryName;
  final PublishStatus publishStatus;

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
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoType: json['videoType'] ?? 'youtube',
      videoUrl: json['videoUrl'],
      filePath: json['filePath'],
      duration: json['duration'],
      language: json['language'] ?? 'ar',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      publishStatus: PublishStatus.values.firstWhere((e) => e.name == json['publishStatus'], orElse: () => PublishStatus.draft),
    );
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

// ================== API SERVICES ==================
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

// ================== VIDEO CARD ==================
class VideoCard extends StatelessWidget {
  final VideoDto video;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VideoCard({super.key, required this.video, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    String? _extractYouTubeId(String url) {
      final uri = Uri.tryParse(url);
      if (uri == null) return null;
      if (uri.host.contains('youtu.be')) return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      if (uri.host.contains('youtube.com')) return uri.queryParameters['v'];
      return null;
    }
    final loc = AppLocalizations(localeProvider.locale.languageCode);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: video.videoType == 'youtube' && video.videoUrl != null
                  ? Stack(
                children: [
                  Image.network('https://img.youtube.com/vi/${_extractYouTubeId( video.videoUrl!)}/hqdefault.jpg', fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder()),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withOpacity(0), Colors.black.withOpacity(0.3)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
                  Center(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle), child: const Icon(Icons.play_arrow, color: Colors.red, size: 32))),
                ],
              )
                  : _placeholder(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(video.title.isEmpty ? loc.untitled : video.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis)),
                      _statusBadge(video, loc),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(video.description.isEmpty ? loc.noDescription : video.description, style: TextStyle(fontSize: 13, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.language, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(video.language.toUpperCase(), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      const Spacer(),
                      IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, size: 20, color: Colors.orange), padding: EdgeInsets.zero),
                      IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, size: 20, color: Colors.red), padding: EdgeInsets.zero),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(color: Colors.grey.shade200, child: const Center(child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white70)));

  Widget _statusBadge(VideoDto v, AppLocalizations loc) {
    final Map<PublishStatus, Map<String, dynamic>> styles = {
      PublishStatus.published: {'bg': Colors.green.shade50, 'text': Colors.green.shade700, 'label': loc.published},
      PublishStatus.draft: {'bg': Colors.orange.shade50, 'text': Colors.orange.shade700, 'label': loc.draft},
      PublishStatus.pending: {'bg': Colors.blue.shade50, 'text': Colors.blue.shade700, 'label': loc.pending},
    };
    final style = styles[v.publishStatus]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: style['bg'], borderRadius: BorderRadius.circular(12)),
      child: Text(style['label'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: style['text'])),
    );
  }
}

// ================== ADD VIDEO DIALOG ==================
class AddVideoDialog extends StatelessWidget {
  final VideoApiService videoService;
  final List<VideoCategory> categories;
  final VoidCallback onVideoAdded;
  final Color primaryColor;
  final String languageCode;

  const AddVideoDialog({super.key, required this.videoService, required this.categories, required this.onVideoAdded, required this.primaryColor, required this.languageCode});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(languageCode);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.addNewVideo, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _option(context, Icons.youtube_searched_for, loc.youtube, loc.addFromYoutube, Colors.red, () => _youtubeDialog(context)),
                const SizedBox(width: 24),
                _option(context, Icons.upload_file, loc.uploadFile, loc.uploadVideoFile, primaryColor, () => _uploadDialog(context)),
              ],
            ),
            const SizedBox(height: 24),
            TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.cancel)),
          ],
        ),
      ),
    );
  }

  Widget _option(BuildContext ctx, IconData icon, String title, String desc, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
        child: Column(children: [Icon(icon, size: 48, color: color), const SizedBox(height: 16), Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)), const SizedBox(height: 8), Text(desc, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600))]),
      ),
    );
  }

  void _youtubeDialog(BuildContext context) {
    final loc = AppLocalizations(languageCode);
    final urlC = TextEditingController();
    final titleC = TextEditingController();
    final descC = TextEditingController();
    VideoCategory? selectedCat;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [const Icon(Icons.youtube_searched_for, color: Colors.red), const SizedBox(width: 12), Text(loc.addYoutubeVideo)]),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: urlC, decoration: InputDecoration(labelText: loc.youtubeUrl, hintText: loc.youtubeUrlHint, prefixIcon: const Icon(Icons.link), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 16),
                TextField(controller: titleC, decoration: InputDecoration(labelText: loc.title, prefixIcon: const Icon(Icons.title), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 16),
                TextField(controller: descC, decoration: InputDecoration(labelText: loc.description, prefixIcon: const Icon(Icons.description), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), maxLines: 3),
                const SizedBox(height: 16),
                DropdownButtonFormField<VideoCategory>(
                  value: selectedCat,
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => selectedCat = v),
                  decoration: InputDecoration(labelText: loc.category, prefixIcon: const Icon(Icons.category), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.cancel)),
            ElevatedButton(
              onPressed: () async {
                final url = urlC.text.trim();
                final videoId = _extractYouTubeId(url);
                if (videoId != null && titleC.text.isNotEmpty) {
                  try {
                    await videoService.addYouTube(title: titleC.text, description: descC.text, videoId: videoId, categoryId: selectedCat?.id);
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                    onVideoAdded();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.videoAdded), backgroundColor: Colors.green));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.error}: $e'), backgroundColor: Colors.red));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.invalidUrl), backgroundColor: Colors.red));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: Text(loc.add, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _uploadDialog(BuildContext context) {
    final loc = AppLocalizations(languageCode);
    final titleC = TextEditingController();
    final descC = TextEditingController();
    VideoCategory? selectedCat;
    String? fileName;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [Icon(Icons.upload_file, color: primaryColor), const SizedBox(width: 12), Text(loc.uploadVideo)]),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final input = html.FileUploadInputElement()..accept = 'video/*';
                    input.click();
                    input.onChange.listen((e) {
                      final file = input.files!.first;
                      setState(() => fileName = file.name);

                      final reader = html.FileReader();
                      reader.readAsArrayBuffer(file);
                      reader.onLoadEnd.listen((event) async {
                        final bytes = reader.result as Uint8List;
                        try {
                          await videoService.uploadVideoFile(bytes: bytes, fileName: file.name, title: titleC.text.isNotEmpty ? titleC.text : file.name, description: descC.text, categoryId: selectedCat?.id);
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                          onVideoAdded();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.videoAdded), backgroundColor: Colors.green));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.uploadFailed}: $e'), backgroundColor: Colors.red));
                        }
                      });
                    });
                  },
                  icon: const Icon(Icons.file_upload),
                  label: Text(fileName ?? loc.chooseVideo),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
                const SizedBox(height: 16),
                TextField(controller: titleC, decoration: InputDecoration(labelText: loc.title, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 16),
                TextField(controller: descC, decoration: InputDecoration(labelText: loc.description, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), maxLines: 3),
                const SizedBox(height: 16),
                DropdownButtonFormField<VideoCategory>(
                  value: selectedCat,
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => selectedCat = v),
                  decoration: InputDecoration(labelText: loc.category, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.cancel))],
        ),
      ),
    );
  }

  String? _extractYouTubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
    if (uri.host.contains('youtube.com')) return uri.queryParameters['v'];
    return null;
  }
}

// ================== EDIT VIDEO DIALOG ==================
class EditVideoDialog extends StatefulWidget {
  final VideoDto video;
  final VideoApiService videoService;
  final List<VideoCategory> categories;
  final VoidCallback onVideoUpdated;
  final Color primaryColor;
  final String languageCode;

  const EditVideoDialog({super.key, required this.video, required this.videoService, required this.categories, required this.onVideoUpdated, required this.primaryColor, required this.languageCode});

  @override
  State<EditVideoDialog> createState() => _EditVideoDialogState();
}

class _EditVideoDialogState extends State<EditVideoDialog> {
  late TextEditingController titleC;
  late TextEditingController descC;
  late TextEditingController urlC;
  VideoCategory? selectedCat;
  PublishStatus? selectedStatus;
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    titleC = TextEditingController(text: widget.video.title);
    descC = TextEditingController(text: widget.video.description);
    urlC = TextEditingController(text: widget.video.videoUrl ?? '');
    selectedCat = widget.categories.firstWhere((c) => c.id == widget.video.categoryId, orElse: () => widget.categories.first);
    selectedStatus = widget.video.publishStatus;
    isActive = widget.video.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(widget.languageCode);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.editVideo, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: widget.primaryColor)),
            const SizedBox(height: 24),
            TextField(controller: titleC, decoration: InputDecoration(labelText: loc.title, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            TextField(controller: descC, decoration: InputDecoration(labelText: loc.description, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), maxLines: 3),
            const SizedBox(height: 16),
            if (widget.video.videoType == 'youtube')
              TextField(
                controller: urlC,
                decoration: InputDecoration(
                  labelText: loc.youtubeUrl,
                  hintText: loc.youtubeUrlHint,
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            if (widget.video.videoType == 'youtube') const SizedBox(height: 16),
            DropdownButtonFormField<VideoCategory>(
              value: selectedCat,
              items: widget.categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => selectedCat = v),
              decoration: InputDecoration(labelText: loc.category, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PublishStatus>(
              value: selectedStatus,
              items: PublishStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => selectedStatus = v),
              decoration: InputDecoration(labelText: loc.status, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(loc.active),
              value: isActive,
              onChanged: (v) => setState(() => isActive = v),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.cancel)),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final updateData = {
                        'title': titleC.text,
                        'description': descC.text,
                        'categoryId': selectedCat?.id,
                        'publishStatus': selectedStatus?.name,
                        'isActive': isActive,
                      };


                      if (widget.video.videoType == 'youtube' && urlC.text.isNotEmpty) {
                        final videoId = urlC.text;
                        if (videoId != null) {
                          updateData['videoUrl'] = videoId;
                        }
                      }

                      await widget.videoService.updateVideo(widget.video.id, updateData);
                      Navigator.pop(context);
                      widget.onVideoUpdated();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.videoUpdated), backgroundColor: Colors.green));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.error}: $e'), backgroundColor: Colors.red));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: widget.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: Text(loc.save, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}

// ================== MANAGE CATEGORIES DIALOG ==================
class ManageCategoriesDialog extends StatefulWidget {
  final List<VideoCategory> categories;
  final CategoryApiService categoryService;
  final VoidCallback onCategoriesUpdated;
  final Color primaryColor;
  final String languageCode;

  const ManageCategoriesDialog({super.key, required this.categories, required this.categoryService, required this.onCategoriesUpdated, required this.primaryColor, required this.languageCode});

  @override
  State<ManageCategoriesDialog> createState() => _ManageCategoriesDialogState();
}

class _ManageCategoriesDialogState extends State<ManageCategoriesDialog> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(widget.languageCode);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Icon(Icons.category, color: widget.primaryColor, size: 28), const SizedBox(width: 12), Text(loc.manageCategories, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))]),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(height: 32),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: widget.categories.length,
                itemBuilder: (_, i) {
                  final cat = widget.categories[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(Icons.folder, color: widget.primaryColor)),
                      title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _editCategory(cat)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteCategory(cat)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addCategory,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(loc.addCategory, style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: widget.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addCategory() {
    final loc = AppLocalizations(widget.languageCode);
    final nameC = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.addCategory),
        content: TextField(controller: nameC, decoration: InputDecoration(labelText: loc.categoryName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (nameC.text.isNotEmpty) {
                await widget.categoryService.addCategory(nameC.text);
                Navigator.pop(context);
                widget.onCategoriesUpdated();
              }
            },
            child: Text(loc.add),
          ),
        ],
      ),
    );
  }

  void _editCategory(VideoCategory cat) {
    final loc = AppLocalizations(widget.languageCode);
    final nameC = TextEditingController(text: cat.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.editCategory),
        content: TextField(controller: nameC, decoration: InputDecoration(labelText: loc.categoryName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (nameC.text.isNotEmpty) {
                await widget.categoryService.updateCategory(cat.id, nameC.text);
                Navigator.pop(context);
                widget.onCategoriesUpdated();
              }
            },
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(VideoCategory cat) async {
    final loc = AppLocalizations(widget.languageCode);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.deleteCategory),
        content: Text(loc.deleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.cancel)),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text(loc.delete)),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.categoryService.deleteCategory(cat.id);
      widget.onCategoriesUpdated();
    }
  }
}