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
  String get label {
    switch (this) {
      case PublishStatus.draft:
        return 'مسودة';
      case PublishStatus.review:
        return 'قيد المراجعة';
      case PublishStatus.published:
        return 'منشور';
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

class _AdminAboutAppScreenState extends State<AdminAboutAppScreen> {
  List<_VideoItem> videos = [];
  int _viewIdCounter = 0;

  final List<String> categories = [
    'الكل',
    'تعليمي',
    'ترويجي',
    'توضيحي',
    'آخر',
  ];

  String filterCategory = 'الكل';
  String searchQuery = '';
  String sortBy = 'تاريخ الإضافة';

  @override
  void initState() {
    super.initState();
    _addDragDropListener();
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
        title: const Text('تأكيد الحذف'),
        content: Text(
          video.isYouTube
              ? 'هل أنت متأكد من حذف رابط فيديو اليوتيوب هذا؟'
              : 'هل أنت متأكد من حذف هذا الفيديو؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      setState(() {
        // فقط في حالة الفيديو المحلي (وليس YouTube)
        if (!video.isYouTube) {
          html.Url.revokeObjectUrl(video.url);
        }

        // حذف الفيديو من القائمة
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
        title: const Text("تعديل بيانات الفيديو"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "العنوان",
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: "الوصف",
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: currentCategory,
                items: categories
                    .where((c) => c != 'الكل')
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    currentCategory = val;
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'القسم',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PublishStatus>(
                value: currentStatus,
                items: PublishStatus.values
                    .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(
                      status.label,
                      style: TextStyle(color: status.color),
                    )))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    currentStatus = val;
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'حالة النشر',
                  border: OutlineInputBorder(),
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
            child: const Text("إلغاء"),
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
            child: const Text("حفظ"),
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
                video.title.isEmpty ? 'فيديو بدون عنوان' : video.title,
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
                label: const Text("إغلاق المعاينة"),
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
        title: const Text("إضافة رابط فيديو من يوتيوب"),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            labelText: "رابط اليوتيوب",
            hintText: "https://www.youtube.com/watch?v=xxxx",
            prefixIcon: Icon(Icons.link),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("إلغاء"),
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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("رابط يوتيوب غير صالح"),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: const Text("إضافة"),
          ),
        ],
      ),
    );
  }


  List<_VideoItem> get filteredVideos {
    List<_VideoItem> filtered = videos;

    if (filterCategory != 'الكل') {
      filtered =
          filtered.where((v) => v.category == filterCategory).toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      filtered = filtered
          .where((v) =>
      v.title.contains(searchQuery) ||
          v.description.contains(searchQuery))
          .toList();
    }
    if (sortBy == 'العنوان') {
      filtered.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortBy == 'تاريخ الإضافة') {
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
            icon: Icon(icon, size: 18),
            label: Text(label, style: const TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          color: Colors.deepPurple.withOpacity(0.12),
          blurRadius: 6,
          offset: const Offset(0, 3),
        )
        ],
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
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
      video.title.isEmpty ? "فيديو بدون عنوان" : video.title,
      style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: Colors.deepPurple.shade900,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      ),
      ),
      const SizedBox(height: 4),
      Text(
      video.description.isEmpty ? "لا يوجد وصف" : video.description,
      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 6),
      Row(
      children: [
      Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
      color: Colors.deepPurple.shade50,
      borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
      video.category,
      style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: Colors.deepPurple.shade700,
      ),
      ),
      ),
      const SizedBox(width: 10),
      Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
      color: video.publishStatus.color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
      video.publishStatus.label,
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
      color: Colors.grey.shade300,
      child: const Center(
      child: Icon(Icons.videocam_off,
      size: 40, color: Colors.grey),
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
      label: "تعديل",
      backgroundColor: Colors.orange.shade700,
      ),
      const SizedBox(width: 10),
      _hoverableButton(
      onPressed: () async {
      final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
      title: const Text('تأكيد الحذف'),
      content: const Text(
      'هل أنت متأكد من حذف هذا الفيديو؟ لا يمكن التراجع عن هذا الإجراء.'),
      actions: [
      TextButton(
      onPressed: () => Navigator.of(ctx).pop(false),
      child: const Text('إلغاء'),
      ),
      ElevatedButton(
      onPressed: () => Navigator.of(ctx).pop(true),
      style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red.shade700),
      child: const Text('حذف'),
      ),
      ],
      ),
      );

      if (confirm ?? false) {
      setState(() {
      // لا تقم بحذف الـ URL إذا كان من YouTube
      if (!video.isYouTube) {
      html.Url.revokeObjectUrl(video.url);
      }
      videos.remove(video);
      });
      }
      },
      icon: Icons.delete,
      label: "حذف",
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("إدارة نبذة عن البرنامج"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "بحث بالعنوان أو الوصف",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (val) => setState(() => searchQuery = val),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: filterCategory,
                  items: categories
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => filterCategory = val);
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: sortBy,
                  items: ['تاريخ الإضافة', 'العنوان']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => sortBy = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
                child: Row(
    children: [
    ElevatedButton.icon(
    onPressed: _pickVideo,
    icon: const Icon(Icons.upload_rounded),
    label: const Text("رفع فيديو"),
    ),
    const SizedBox(width: 10),
    ElevatedButton.icon(
    onPressed: _showAddYouTubeDialog,
    icon: const Icon(Icons.video_library),
    label: const Text("إضافة فيديو يوتيوب"),
    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
    ),
    ],
    ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredVideos.isEmpty
                  ? Center(
                child: Text(
                  searchQuery.isEmpty
                      ? "لم يتم رفع أي فيديو بعد"
                      : "لا يوجد فيديوهات تطابق البحث",
                  style:
                  const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
                  : GridView.builder(
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.99,
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
