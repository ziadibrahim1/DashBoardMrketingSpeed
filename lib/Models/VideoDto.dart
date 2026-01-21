// ================== API SERVICES ==================
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import '../dashboard/pages/AdminVideoManager.dart';

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

  Future<void> reorderCategories(List<int> categoryIds) async {
    await http.put(
      Uri.parse('$baseUrl/cat/reorder'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'categoryIds': categoryIds}),
    );
  }
}

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
  final bool isVertically;
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
    required this.isVertically,
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
      isVertically: json['isVertically'] ?? false,
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      publishStatus: PublishStatus.values.firstWhere((e) => e.name == json['publishStatus'], orElse: () => PublishStatus.draft),
    );
  }
}

class VideoCategory {
  final int id;
  final String name;
  final int index;

  VideoCategory({required this.id, required this.name, required this.index});

  factory VideoCategory.fromJson(Map<String, dynamic> json) {
    return VideoCategory(
      id: json['id'],
      name: json['name'],
      index: json['index'] ?? 0,
    );
  }
}


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
      'isVertically': 'isVertically',
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
      'drag_to_reorder': 'Drag to reorder categories',
      'order_updated': 'Order updated successfully!',
    },
    'ar': {
      'video_manager': 'إدارة فيديوهات الشرح',
      'manage_content': 'إدارة وتنظيم محتوى الفيديو الخاص بشرح التطبيق',
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
      'isVertically': 'عرض',
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
      'drag_to_reorder': 'اسحب لإعادة ترتيب التصنيفات',
      'order_updated': 'تم تحديث الترتيب بنجاح!',
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
  String get isVertically => translate('isVertically');
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
  String get dragToReorder => translate('drag_to_reorder');
  String get orderUpdated => translate('order_updated');
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
