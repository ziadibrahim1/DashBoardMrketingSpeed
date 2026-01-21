import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/VideoDto.dart';
import '../../providers/app_providers.dart';

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
  PublishStatus? _statusFilter;

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
        final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
        final loc = AppLocalizations(localeProvider.locale.languageCode);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // تحديد الألوان بناءً على الوضع
    final Color primaryColor = isDark ? Colors.green : const Color(0xFF1A56DB);
    final Color primaryLight = isDark ? Colors.green.withOpacity(0.1) : const Color(0xFFE3F2FD);
    final Color backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textSecondary = isDark ? Colors.grey.shade400 : const Color(0xFF6B7280);

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final loc = AppLocalizations(localeProvider.locale.languageCode);
        final isRTL = localeProvider.locale.languageCode == 'ar';

        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: backgroundColor,
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _buildHeader(loc, primaryColor, cardColor, isDark),
                        const SizedBox(height: 24),
                        _buildStatsCards(loc, primaryColor, primaryLight),
                        const SizedBox(height: 24),
                        _buildFiltersSection(loc, primaryColor, primaryLight, cardColor, textSecondary),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: _buildVideoGrid(loc, primaryColor, primaryLight, textSecondary),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            ),
          ),
        );
      },
    );
  }

  RenderObjectWidget _buildVideoGrid(AppLocalizations loc, Color primaryColor, Color primaryLight, Color textSecondary) {
    if (_filteredVideos.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 250,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_library,
                    size: 120,
                    color: textSecondary.withOpacity(0.5)),
                const SizedBox(height: 20),
                Text(
                  loc.noVideos,
                  style: TextStyle(
                    fontSize: 20,
                    color: textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
            (context, i) {
          final video = _filteredVideos[i];
          return VideoCard(
            video: video,
            onEdit: () => showDialog(
              context: context,
              builder: (_) => EditVideoDialog(
                video: video,
                videoService: _videoService,
                categories: _categories,
                onVideoUpdated: _loadData,
                languageCode: Provider.of<LocaleProvider>(context, listen: false).locale.languageCode,
              ),
            ),
            onDelete: () async {
              final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
              final loc = AppLocalizations(localeProvider.locale.languageCode);

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
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      child: Text(loc.delete),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await _videoService.deleteVideo(video.id);
                _loadData();
              }
            },
          );
        },
        childCount: _filteredVideos.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.91,
      ),
    );
  }

  Widget _buildHeader(AppLocalizations loc, Color primaryColor, Color cardColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 6,
        shadowColor: primaryColor.withOpacity(0.25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.green.withOpacity(0.7), Colors.green.withOpacity(0.4)]
                  : [const Color(0xFF4FB5F5), const Color(0xFF1B367A)],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// ===== Left Side =====
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.video_library,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        loc.videoManager,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        loc.manageContent,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              /// ===== Actions =====
              Row(
                children: [
                  _buildActionButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => ManageCategoriesDialog(
                        categories: _categories,
                        categoryService: _categoryService,
                        onCategoriesUpdated: _loadData,
                        languageCode: Provider.of<LocaleProvider>(context, listen: false).locale.languageCode,
                      ),
                    ),
                    icon: Icons.category,
                    label: loc.categories,
                    backgroundColor: Colors.white.withOpacity(0.18),
                  ),
                  const SizedBox(width: 10),
                  _buildActionButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AddVideoDialog(
                        videoService: _videoService,
                        categories: _categories,
                        onVideoAdded: _loadData,
                        languageCode: Provider.of<LocaleProvider>(context, listen: false).locale.languageCode,
                      ),
                    ),
                    icon: Icons.add,
                    label: loc.addVideo,
                    backgroundColor: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildStatsCards(AppLocalizations loc, Color primaryColor, Color primaryLight) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(loc.total, '${_videos.length}', Icons.video_library, primaryColor)),
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

  Widget _buildFiltersSection(AppLocalizations loc, Color primaryColor, Color primaryLight, Color cardColor, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: loc.searchVideos,
              prefixIcon: Icon(Icons.search, color: primaryColor),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                _searchController.clear();
                _applyFilters();
              })
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
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
                primaryColor: primaryColor,
                textSecondary: textSecondary,
                primaryLight: primaryLight,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: primaryLight, borderRadius: BorderRadius.circular(20)),
                child: Text('${_filteredVideos.length} ${loc.videos}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
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
    required Color primaryColor,
    required Color textSecondary,
    required Color primaryLight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border.all(color: primaryColor.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              style: TextStyle(color: textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

enum PublishStatus { draft, published, pending }

class VideoCard extends StatelessWidget {
  final VideoDto video;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const VideoCard({
    super.key,
    required this.video,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  String? _extractYouTubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
    if (uri.host.contains('youtube.com')) return uri.queryParameters['v'];
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final loc = AppLocalizations(localeProvider.locale.languageCode);
    final isRTL = localeProvider.locale.languageCode == 'ar';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(video),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            video.title.isEmpty ? loc.untitled : video.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      video.description.isEmpty ? loc.noDescription : video.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    _buildActionButtons(theme, isRTL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(VideoDto video) {
    final youtubeId = video.videoUrl != null ? _extractYouTubeId(video.videoUrl!) : null;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (video.videoType == 'youtube' && youtubeId != null)
            Image.network(
              'https://img.youtube.com/vi/$youtubeId/mqdefault.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          else
            _placeholder(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.red, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, bool isRTL) {
    return Row(
      mainAxisAlignment: isRTL ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: isRTL
          ? [
        _iconButton(
          icon: Icons.edit_outlined,
          color: Colors.blueAccent,
          onPressed: onEdit,
          tooltip: 'تعديل',
        ),
        const SizedBox(width: 8),
        _iconButton(
          icon: Icons.delete_outline_rounded,
          color: Colors.redAccent,
          onPressed: onDelete,
          tooltip: 'حذف',
        ),
      ]
          : [
        _iconButton(
          icon: Icons.edit_outlined,
          color: Colors.blueAccent,
          onPressed: onEdit,
          tooltip: 'Edit',
        ),
        const SizedBox(width: 8),
        _iconButton(
          icon: Icons.delete_outline_rounded,
          color: Colors.redAccent,
          onPressed: onDelete,
          tooltip: 'Delete',
        ),
      ],
    );
  }

  Widget _iconButton({required IconData icon, required Color color, required VoidCallback onPressed, String? tooltip}) {
    return Material(
      color: color.withOpacity(0.1),
      shape: const CircleBorder(),
      child: IconButton(
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(8),
        icon: Icon(icon, size: 18, color: color),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  Widget _placeholder() => Container(
    color: Colors.grey.shade200,
    child: const Center(child: Icon(Icons.videocam_off_outlined, size: 40, color: Colors.grey)),
  );
}

class AddVideoDialog extends StatelessWidget {
  final VideoApiService videoService;
  final List<VideoCategory> categories;
  final VoidCallback onVideoAdded;
  final String languageCode;

  const AddVideoDialog({
    super.key,
    required this.videoService,
    required this.categories,
    required this.onVideoAdded,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.green : const Color(0xFF1A56DB);
    final loc = AppLocalizations(languageCode);
    final isRTL = languageCode == 'ar';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.addNewVideo,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: isRTL
                  ? [
                _option(context, Icons.upload_file, loc.uploadFile, loc.uploadVideoFile, primaryColor,
                        () => _uploadDialog(context)),
                const SizedBox(width: 24),
                _option(context, Icons.youtube_searched_for, loc.youtube, loc.addFromYoutube, Colors.red,
                        () => _youtubeDialog(context)),
              ]
                  : [
                _option(context, Icons.youtube_searched_for, loc.youtube, loc.addFromYoutube, Colors.red,
                        () => _youtubeDialog(context)),
                const SizedBox(width: 24),
                _option(context, Icons.upload_file, loc.uploadFile, loc.uploadVideoFile, primaryColor,
                        () => _uploadDialog(context)),
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
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text(desc,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(ctx).hintColor)),
          ],
        ),
      ),
    );
  }

  void _youtubeDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.green : const Color(0xFF1A56DB);
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
          backgroundColor: theme.cardColor,
          title: Row(
            children: [
              const Icon(Icons.youtube_searched_for, color: Colors.red),
              const SizedBox(width: 12),
              Text(loc.addYoutubeVideo),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: urlC,
                  decoration: InputDecoration(
                    labelText: loc.youtubeUrl,
                    hintText: loc.youtubeUrlHint,
                    prefixIcon: const Icon(Icons.link),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleC,
                  decoration: InputDecoration(
                    labelText: loc.title,
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descC,
                  decoration: InputDecoration(
                    labelText: loc.description,
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<VideoCategory>(
                  value: selectedCat,
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedCat = v),
                  decoration: InputDecoration(
                    labelText: loc.category,
                    prefixIcon: Icon(Icons.category, color: primaryColor.withOpacity(0.8)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.cancel)),
            ElevatedButton(
              onPressed: () async {
                final url = urlC.text.trim();
                final videoId = url;
                if (titleC.text.isNotEmpty) {
                  try {
                    await videoService.addYouTube(
                        title: titleC.text,
                        description: descC.text,
                        videoId: videoId,
                        categoryId: selectedCat?.id);
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                    onVideoAdded();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.videoAdded), backgroundColor: Colors.green));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${loc.error}: $e'), backgroundColor: Colors.red));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.invalidUrl), backgroundColor: Colors.red));
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: Text(loc.add, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _uploadDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.green : const Color(0xFF1A56DB);
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
          backgroundColor: theme.cardColor,
          title: Row(
            children: [
              Icon(Icons.upload_file, color: primaryColor),
              const SizedBox(width: 12),
              Text(loc.uploadVideo),
            ],
          ),
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
                          await videoService.uploadVideoFile(
                              bytes: bytes,
                              fileName: file.name,
                              title: titleC.text.isNotEmpty ? titleC.text : file.name,
                              description: descC.text,
                              categoryId: selectedCat?.id);
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                          onVideoAdded();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.videoAdded), backgroundColor: Colors.green));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${loc.uploadFailed}: $e'), backgroundColor: Colors.red));
                        }
                      });
                    });
                  },
                  icon: const Icon(Icons.file_upload),
                  label: Text(fileName ?? loc.chooseVideo),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleC,
                  decoration: InputDecoration(
                    labelText: loc.title,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descC,
                  decoration: InputDecoration(
                    labelText: loc.description,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<VideoCategory>(
                  value: selectedCat,
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedCat = v),
                  decoration: InputDecoration(
                    labelText: loc.category,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.cancel)),
          ],
        ),
      ),
    );
  }
}

class EditVideoDialog extends StatefulWidget {
  final VideoDto video;
  final VideoApiService videoService;
  final List<VideoCategory> categories;
  final VoidCallback onVideoUpdated;
  final String languageCode;

  const EditVideoDialog({
    super.key,
    required this.video,
    required this.videoService,
    required this.categories,
    required this.onVideoUpdated,
    required this.languageCode,
  });

  @override
  State<EditVideoDialog> createState() => _EditVideoDialogState();
}

class _EditVideoDialogState extends State<EditVideoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleC, descC, urlC;
  VideoCategory? selectedCat;
  bool isActive = true;
  bool isVertically = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleC = TextEditingController(text: widget.video.title);
    descC = TextEditingController(text: widget.video.description);
    urlC = TextEditingController(text: widget.video.videoUrl ?? '');
    selectedCat = widget.categories.firstWhere(
          (c) => c.id == widget.video.categoryId,
      orElse: () => widget.categories.first,
    );
    isActive = widget.video.isActive;
    isVertically = widget.video.isVertically;
  }

  @override
  void dispose() {
    titleC.dispose();
    descC.dispose();
    urlC.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate(AppLocalizations loc) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final updateData = {
        'title': titleC.text.trim(),
        'description': descC.text.trim(),
        'categoryId': selectedCat?.id,
        'isActive': isActive,
        'isVertically': isVertically,
      };

      if (widget.video.videoType == 'youtube') {
        updateData['videoUrl'] = urlC.text.trim();
      }

      await widget.videoService.updateVideo(widget.video.id, updateData);

      if (!mounted) return;
      Navigator.pop(context);
      widget.onVideoUpdated();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.videoUpdated),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.error}: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.green : const Color(0xFF1A56DB);
    final loc = AppLocalizations(widget.languageCode);
    final isArabic = widget.languageCode == 'ar';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 550,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.edit_note_rounded, color: primaryColor, size: 30),
                  const SizedBox(width: 12),
                  Text(
                    loc.editVideo,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    splashRadius: 20,
                  )
                ],
              ),
              const Divider(height: 32),

              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: titleC,
                        label: loc.title,
                        icon: Icons.title,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: descC,
                        label: loc.description,
                        icon: Icons.description_outlined,
                        maxLines: 3,
                        primaryColor: primaryColor,
                      ),
                      if (widget.video.videoType == 'youtube') ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: urlC,
                          label: loc.youtubeUrl,
                          icon: Icons.play_circle_filled,
                          hint: loc.youtubeUrlHint,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                          primaryColor: primaryColor,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                              child: _buildDropdown<VideoCategory>(
                                label: loc.category,
                                value: selectedCat,
                                items: widget.categories
                                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                                    .toList(),
                                onChanged: (v) => setState(() => selectedCat = v),
                                primaryColor: primaryColor,
                              )),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(loc.active, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(isArabic
                            ? "جعل هذا الفيديو مرئي للمستخدمين"
                            : "Make this video visible to users"),
                        value: isActive,
                        activeColor: primaryColor,
                        onChanged: (v) => setState(() => isActive = v),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(loc.isVertically, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(isArabic
                            ? "جعل هذا الفيديو بالعرض الطولي"
                            : "Make this video isVertically to users"),
                        value: isVertically,
                        activeColor: primaryColor,
                        onChanged: (v) => setState(() => isVertically = v),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(loc.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _handleUpdate(loc),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(loc.save, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? hint,
    String? Function(String?)? validator,
    required Color primaryColor,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 1.5)),
        filled: true,
        fillColor: theme.cardColor,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required Color primaryColor,
  }) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: theme.cardColor,
      ),
    );
  }
}

class ManageCategoriesDialog extends StatefulWidget {
  final List<VideoCategory> categories;
  final CategoryApiService categoryService;
  final VoidCallback onCategoriesUpdated;
  final String languageCode;

  const ManageCategoriesDialog({
    super.key,
    required this.categories,
    required this.categoryService,
    required this.onCategoriesUpdated,
    required this.languageCode,
  });

  @override
  State<ManageCategoriesDialog> createState() => _ManageCategoriesDialogState();
}

class _ManageCategoriesDialogState extends State<ManageCategoriesDialog> {
  late List<VideoCategory> _reorderedCategories;

  @override
  void initState() {
    super.initState();
    _reorderedCategories = List.from(widget.categories)..sort((a, b) => a.index.compareTo(b.index));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.green : const Color(0xFF1A56DB);
    final loc = AppLocalizations(widget.languageCode);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.cardColor,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.category, color: primaryColor, size: 28),
                    const SizedBox(width: 12),
                    Text(loc.manageCategories,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(height: 32),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc.dragToReorder,
                      style: TextStyle(color: primaryColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ReorderableListView.builder(
                itemCount: _reorderedCategories.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _reorderedCategories.removeAt(oldIndex);
                    _reorderedCategories.insert(newIndex, item);
                  });
                },
                itemBuilder: (_, i) {
                  final cat = _reorderedCategories[i];
                  return Card(
                    key: ValueKey(cat.id),
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    color: theme.cardColor,
                    child: ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.drag_handle, color: theme.hintColor),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: primaryColor.withOpacity(0.1),
                            child: Text('${i + 1}',
                                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _editCategory(cat)),
                          IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCategory(cat)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addCategory,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(loc.addCategory, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveOrder,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(loc.save, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveOrder() async {
    final loc = AppLocalizations(widget.languageCode);
    try {
      final categoryIds = _reorderedCategories.map((c) => c.id).toList();
      await widget.categoryService.reorderCategories(categoryIds);

      Navigator.pop(context);
      widget.onCategoriesUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.orderUpdated), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.error}: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _addCategory() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.green : const Color(0xFF1A56DB);
    final loc = AppLocalizations(widget.languageCode);
    final nameC = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(loc.addCategory),
        content: TextField(
          controller: nameC,
          decoration: InputDecoration(
            labelText: loc.categoryName,
            filled: true,
            fillColor: theme.cardColor,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (nameC.text.isNotEmpty) {
                await widget.categoryService.addCategory(nameC.text);
                Navigator.pop(context);
                Navigator.pop(context);
                widget.onCategoriesUpdated();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: Text(loc.add),
          ),
        ],
      ),
    );
  }

  void _editCategory(VideoCategory cat) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.green : const Color(0xFF1A56DB);
    final loc = AppLocalizations(widget.languageCode);
    final nameC = TextEditingController(text: cat.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(loc.editCategory),
        content: TextField(
          controller: nameC,
          decoration: InputDecoration(
            labelText: loc.categoryName,
            filled: true,
            fillColor: theme.cardColor,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (nameC.text.isNotEmpty) {
                await widget.categoryService.updateCategory(cat.id, nameC.text);
                Navigator.pop(context);
                Navigator.pop(context);
                widget.onCategoriesUpdated();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(VideoCategory cat) async {
    final theme = Theme.of(context);
    final loc = AppLocalizations(widget.languageCode);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(loc.deleteCategory),
        content: Text(loc.deleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(loc.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.categoryService.deleteCategory(cat.id);
      Navigator.pop(context);
      widget.onCategoriesUpdated();
    }
  }
}