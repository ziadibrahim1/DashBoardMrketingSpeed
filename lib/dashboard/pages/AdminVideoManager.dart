import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdminAboutAppScreen extends StatefulWidget {
  const AdminAboutAppScreen({Key? key}) : super(key: key);
  @override
  State<AdminAboutAppScreen> createState() => _AdminAboutAppScreenState();
}
enum PublishStatus { draft, review, published }
extension PublishStatusExtension on PublishStatus {
  String label(Map<String, String> localizedStrings) {
    switch (this) {
      case PublishStatus.draft:
        return localizedStrings['draft'] ?? 'Draft';
      case PublishStatus.review:
        return localizedStrings['review'] ?? 'Review';
      case PublishStatus.published:
        return localizedStrings['published'] ?? 'Published';
    }
  }

  Color get color {
    switch (this) {
      case PublishStatus.draft:
        return Colors.grey;
      case PublishStatus.review:
        return Colors.orange;
      case PublishStatus.published:
        return Colors.green;
    }
  }
}

final Map<String, Map<String, String>> localizedValues = {
  'ar': {
    'review': 'قيد المراجعة',
    'all': 'الكل',
    'educational': 'تعليمي',
    'promotional': 'ترويجي',
    'explanatory': 'توضيحي',
    'other': 'آخر',
    'search_hint': 'بحث بالعنوان أو الوصف',
    'filter_category': 'القسم',
    'publish_status': 'حالة النشر',
    'add_video': 'رفع فيديو',
    'add_youtube': 'إضافة فيديو يوتيوب',
    'delete_confirm_title': 'تأكيد الحذف',
    'delete_confirm_text_local': 'هل أنت متأكد من حذف هذا الفيديو؟ لا يمكن التراجع عن هذا الإجراء.',
    'delete_confirm_text_youtube': 'هل أنت متأكد من حذف رابط فيديو اليوتيوب هذا؟',
    'cancel': 'إلغاء',
    'delete': 'حذف',
    'edit_video_data': 'تعديل بيانات الفيديو',
    'title': 'العنوان',
    'description': 'الوصف',
    'youtube_url': 'رابط اليوتيوب',
    'youtube_url_hint': 'https://www.youtube.com/watch?v=xxxx',
    'add': 'إضافة',
    'invalid_youtube_url': 'رابط يوتيوب غير صالح',
    'no_videos': 'لم يتم رفع أي فيديو بعد',
    'no_videos_found': 'لا يوجد فيديوهات تطابق البحث',
    'video_without_title': 'فيديو بدون عنوان',
    'no_description': 'لا يوجد وصف',
    'added_date': 'تاريخ الإضافة',
    'title_sort': 'العنوان',
    'close_preview': 'إغلاق المعاينة',
    'draft': 'مسودة',
    'published': 'منشور',
    'archived': 'مؤرشف',
  },
  'en': {
    'all': 'All',
    'draft': 'Draft',
    'review': 'Under Review',
    'published': 'Published',
    'educational': 'Educational',
    'promotional': 'Promotional',
    'explanatory': 'Explanatory',
    'other': 'Other',
    'search_hint': 'Search by title or description',
    'filter_category': 'Category',
    'publish_status': 'Publish Status',
    'add_video': 'Upload Video',
    'add_youtube': 'Add YouTube Video',
    'delete_confirm_title': 'Confirm Deletion',
    'delete_confirm_text_local': 'Are you sure you want to delete this video? This action cannot be undone.',
    'delete_confirm_text_youtube': 'Are you sure you want to delete this YouTube video link?',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'edit_video_data': 'Edit Video Info',
    'title': 'Title',
    'description': 'Description',
    'youtube_url': 'YouTube URL',
    'youtube_url_hint': 'https://www.youtube.com/watch?v=xxxx',
    'add': 'Add',
    'invalid_youtube_url': 'Invalid YouTube URL',
    'no_videos': 'No videos uploaded yet',
    'no_videos_found': 'No videos match your search',
    'video_without_title': 'Untitled Video',
    'no_description': 'No description',
    'added_date': 'Date Added',
    'title_sort': 'Title',
    'close_preview': 'Close Preview',
    'archived': 'Archived',
  },
};

late Map<String, String> _localizedStrings;
class _AdminAboutAppScreenState extends State<AdminAboutAppScreen> {
  List<_VideoItem> videos = [];
  int _viewIdCounter = 0;

  late List<String> categories;
  String filterCategory = '';
  String searchQuery = '';
  String sortBy = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initLocalization();
  }

  void _initLocalization() {
    final locale = Localizations.localeOf(context);
    _localizedStrings = localizedValues[locale.languageCode] ?? localizedValues['en']!;
    categories = [
      _localizedStrings['all']!,
      _localizedStrings['educational']!,
      _localizedStrings['promotional']!,
      _localizedStrings['explanatory']!,
      _localizedStrings['other']!,
    ];

    filterCategory = categories[0];
    sortBy = _localizedStrings['added_date']!;
  }

  void _addDragDropListener() {
    html.document.body!.addEventListener('dragover', (event) {
      event.preventDefault();
    });

    html.document.body!.addEventListener('drop', (event) {
      event.preventDefault();
      final html.Event e = event;
      final dataTransfer = (e as dynamic).dataTransfer;

      if (dataTransfer != null) {
        final files = dataTransfer.files;
        if (files != null && files.isNotEmpty) {
          for (final file in files) {
            if (file.type.startsWith('video/')) {
              final url = html.Url.createObjectUrl(file);
              _generateVideoThumbnail(url).then((thumbnailUrl) {
                setState(() {
                  videos.add(_VideoItem(
                    file: file,
                    url: url,
                    thumbnailUrl: thumbnailUrl,
                    category: categories[1],
                    publishStatus: PublishStatus.draft,
                    addedAt: DateTime.now(),
                  ));
                });
              });
            }
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _addDragDropListener();
  }

  void _pickVideo() {
    final uploadInput = html.FileUploadInputElement()
      ..accept = 'video/*'
      ..multiple = true
      ..click();

    uploadInput.onChange.listen((event) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        for (var file in files) {
          final url = html.Url.createObjectUrl(file);
          String? thumbnailUrl = await _generateVideoThumbnail(url);
          setState(() {
            videos.add(_VideoItem(
              file: file,
              url: url,
              thumbnailUrl: thumbnailUrl,
              category: categories[1],
              publishStatus: PublishStatus.draft,
              addedAt: DateTime.now(),
            ));
          });
        }
      }
    });
  }

  Future<String?> _generateVideoThumbnail(String videoUrl) async {
    try {
      final video = html.VideoElement()
        ..src = videoUrl
        ..muted = true
        ..autoplay = false
        ..style.display = 'none';

      html.document.body!.append(video);

      await video.play();
      await Future.delayed(const Duration(milliseconds: 200));

      final canvas = html.CanvasElement(width: 320, height: 180);
      final ctx = canvas.context2D;

      ctx.drawImageScaled(video, 0, 0, 320, 180);

      final thumbnailDataUrl = canvas.toDataUrl('image/png');

      video.remove();
      return thumbnailDataUrl;
    } catch (e) {
      return null;
    }
  }

  void _deleteVideo(BuildContext context, _VideoItem video) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_localizedStrings['delete_confirm_title']!),
        content: Text(
          video.isYouTube
              ? _localizedStrings['delete_confirm_text_youtube']!
              : _localizedStrings['delete_confirm_text_local']!,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(_localizedStrings['cancel']!),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            child: Text(_localizedStrings['delete']!),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      setState(() {
        if (!video.isYouTube) {
          html.Url.revokeObjectUrl(video.url);
        }
        videos.remove(video);
      });
    }
  }

  void _editVideoInfo(_VideoItem video) {
    final titleController = TextEditingController(text: video.title);
    final descController = TextEditingController(text: video.description);
    String currentCategory = video.category;
    PublishStatus currentStatus = video.publishStatus;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_localizedStrings['edit_video_data']!),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: _localizedStrings['title'],
                  prefixIcon: const Icon(Icons.title),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: _localizedStrings['description'],
                  prefixIcon: const Icon(Icons.description),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: currentCategory,
                items: categories
                    .where((c) => c != categories[0])
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    currentCategory = val;
                  }
                },
                decoration: InputDecoration(
                  labelText: _localizedStrings['filter_category'],
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PublishStatus>(
                value: currentStatus,
                items: PublishStatus.values
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(
                    video.publishStatus.label(_localizedStrings),
                    style: TextStyle(color: status.color),
                  ),
                ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    currentStatus = val;
                  }
                },
                decoration: InputDecoration(
                  labelText: _localizedStrings['publish_status'],
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(_localizedStrings['cancel']!),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                video.title = titleController.text.trim();
                video.description = descController.text.trim();
                video.category = currentCategory;
                video.publishStatus = currentStatus;
              });
              Navigator.of(context).pop();
            },
            child: Text(_localizedStrings['add']!),
          ),
        ],
      ),
    );
  }

  void _showVideoPreview(_VideoItem video) {
    final viewId = 'preview-video-${_viewIdCounter++}';

    late final html.Element element;

    if (video.isYouTube) {
      element = html.IFrameElement()
        ..width = '100%'
        ..height = '100%'
        ..src = 'https://www.youtube.com/embed/${video.url}'
        ..style.border = 'none';
    } else {
      element = html.VideoElement()
        ..src = video.url
        ..controls = true
        ..autoplay = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.borderRadius = '12px';
    }

    ui.platformViewRegistry.registerViewFactory(viewId, (_) => element);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: 720,
          height: 420,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                video.title.isEmpty ? _localizedStrings['video_without_title']! : video.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: HtmlElementView(viewType: viewId),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                label: Text(_localizedStrings['close_preview']!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _extractYouTubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
    } else if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    }
    return null;
  }

  void _showAddYouTubeDialog() {
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_localizedStrings['add_youtube']!),
        content: TextField(
          controller: urlController,
          decoration: InputDecoration(
            labelText: _localizedStrings['youtube_url'],
            hintText: _localizedStrings['youtube_url_hint'],
            prefixIcon: const Icon(Icons.link),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_localizedStrings['cancel']!),
          ),
          ElevatedButton(
            onPressed: () {
              final url = urlController.text.trim();
              final videoId = _extractYouTubeId(url);
              if (videoId != null) {
                setState(() {
                  videos.add(_VideoItem(
                    url: videoId,
                    isYouTube: true,
                    title: '',
                    description: '',
                    category: categories[1],
                    publishStatus: PublishStatus.draft,
                    addedAt: DateTime.now(),
                    thumbnailUrl: 'https://img.youtube.com/vi/$videoId/0.jpg',
                  ));
                });
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(_localizedStrings['invalid_youtube_url']!),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: Text(_localizedStrings['add']!),
          ),
        ],
      ),
    );
  }

  List<_VideoItem> get filteredVideos {
    List<_VideoItem> filtered = videos;

    if (filterCategory != categories[0]) {
      filtered = filtered.where((v) => v.category == filterCategory).toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      filtered = filtered
          .where((v) =>
      v.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          v.description.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    if (sortBy == _localizedStrings['title_sort']) {
      filtered.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortBy == _localizedStrings['added_date']) {
      filtered.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    }

    return filtered;
  }

  Widget _hoverableButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
  }) {
    return StatefulBuilder(builder: (context, setLocalState) {
      bool isHovered = false;
      return MouseRegion(
        onEnter: (_) => setLocalState(() => isHovered = true),
        onExit: (_) => setLocalState(() => isHovered = false),
        child: AnimatedScale(
          scale: isHovered ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18,color:Colors.white),
            label: Text(label, style: const TextStyle(fontSize: 14,color:Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: isHovered ? 8 : 4,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildVideoCard(_VideoItem video) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StatefulBuilder(builder: (context, setLocalState) {
      bool isHovered = false;

      return MouseRegion(
        onEnter: (_) => setLocalState(() => isHovered = true),
        onExit: (_) => setLocalState(() => isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: isHovered ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
          decoration: BoxDecoration(
            boxShadow: isHovered
                ? [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
            ]
                : [
              BoxShadow(
                color:isDark? Colors.green.withOpacity(0.12):Colors.blue.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
            borderRadius: BorderRadius.circular(12),
            color: isDark ? Colors.grey[800] : Colors.white,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showVideoPreview(video),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _editVideoInfo(video),
                    child: Text(
                      video.title.isEmpty ? _localizedStrings['video_without_title']! : video.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color:isDark?Colors.green:Colors.blue[900],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video.description.isEmpty ? _localizedStrings['no_description']! : video.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.green.shade900.withOpacity(0.3) : Colors.blue[900],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          video.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: video.publishStatus.color.withOpacity(isDark ? 0.3 : 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          video.publishStatus.label(_localizedStrings),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: video.publishStatus.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: video.thumbnailUrl != null
                          ? Image.network(
                        video.thumbnailUrl!,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        child: Center(
                          child: Icon(
                            Icons.videocam_off,
                            size: 40,
                            color: isDark ? Colors.grey.shade400 : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _hoverableButton(
                        onPressed: () => _editVideoInfo(video),
                        icon: Icons.edit,
                        label: _localizedStrings['edit_video_data']!,
                        backgroundColor: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 10),
                      _hoverableButton(
                        onPressed: () => _deleteVideo(context, video),
                        icon: Icons.delete,
                        label: _localizedStrings['delete']!,
                        backgroundColor: Colors.red.shade700,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],

      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        child: Column(
          children: [
            // Search & Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: _localizedStrings['search_hint'],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
                    onChanged: (value) => setState(() {
                      searchQuery = value;
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: filterCategory,
                  items: categories
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) => setState(() {
                    if (val != null) filterCategory = val;
                  }),
                  underline: Container(),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: sortBy,
                  items: [
                    _localizedStrings['added_date']!,
                    _localizedStrings['title_sort']!,
                  ].map((sort) => DropdownMenuItem(value: sort, child: Text(sort))).toList(),
                  onChanged: (val) => setState(() {
                    if (val != null) sortBy = val;
                  }),
                  underline: Container(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Add buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _hoverableButton(
                  onPressed: _pickVideo,
                  icon: Icons.file_upload,
                  label: _localizedStrings['add_video']!,
                  backgroundColor: isDark?Colors.green:Colors.blue,
                ),
                const SizedBox(width: 10),
                _hoverableButton(
                  onPressed: _showAddYouTubeDialog,
                  icon: Icons.video_library,
                  label: _localizedStrings['add_youtube']!,
                  backgroundColor: isDark?Colors.green:Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Video list
            Expanded(
              child: filteredVideos.isEmpty
                  ? Center(
                child: Text(
                  searchQuery.isEmpty
                      ? _localizedStrings['no_videos']!
                      : _localizedStrings['no_videos_found']!,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              )
                  : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.68,
                ),
                itemCount: filteredVideos.length,
                itemBuilder: (context, index) {
                  return _buildVideoCard(filteredVideos[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoItem {
  final html.File? file; // اجعلها nullable
  final String url;
  final bool isYouTube; // جديد
  String title;
  String description;
  String category;
  String? thumbnailUrl;
  PublishStatus publishStatus;
  DateTime addedAt;

  _VideoItem({
    this.file,
    required this.url,
    this.isYouTube = false,
    this.title = '',
    this.description = '',
    this.category = '',
    this.thumbnailUrl,
    this.publishStatus = PublishStatus.draft,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();
}
