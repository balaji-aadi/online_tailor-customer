import 'package:flutter/material.dart';
import 'package:khyate_tailor_app/constants/color_constant.dart';
import 'package:khyate_tailor_app/data/sample_data.dart';
import 'package:khyate_tailor_app/models/models.dart';
import 'package:khyate_tailor_app/screens/service_detail_screen.dart';
import 'package:khyate_tailor_app/services/storage_service.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  // Creates the State instance for HomePageScreen.
  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  String _selectedLanguage = 'en';
  final List<Tailor> _tailors = SampleData.getTailors();
  final List<TailorService> _services = SampleData.getServices();
  List<Tailor> _filteredTailors = [];
  ServiceType? _selectedServiceType;
  final TextEditingController _searchController = TextEditingController();

  // Initializes widget state, loads language, and sets initial filtered tailors.
  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _filteredTailors = _tailors;
  }

  // Loads the saved language from StorageService and updates the state.
  Future<void> _loadLanguage() async {
    final language = await StorageService.getLanguage();
    setState(() => _selectedLanguage = language);
  }

  // Translation helper: returns Arabic or English text based on selected language.
  String _tr(String en, String ar) => _selectedLanguage == 'ar' ? ar : en;

  // Applies search text and selected service type to filter the tailors list.
  void _filterTailors() {
    setState(() {
      _filteredTailors = _tailors.where((tailor) {
        final matchesSearch = _searchController.text.isEmpty ||
            tailor.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            tailor.nameAr.contains(_searchController.text) ||
            tailor.location
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            tailor.locationAr.contains(_searchController.text);

        final matchesService = _selectedServiceType == null ||
            tailor.services.contains(_selectedServiceType);

        return matchesSearch && matchesService;
      }).toList();
    });
  }

  // Builds the Home page UI and applies RTL/LTR direction based on language.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = _selectedLanguage == 'ar';

    return Scaffold(
      backgroundColor: ColorConstants.warmIvory,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 Header with App Title, Search and Filter Section
          Container(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 16, 20, 20),
            decoration: BoxDecoration(
              gradient: ColorConstants.accentGradient,
              boxShadow: [
                BoxShadow(
                  color: ColorConstants.deepNavy.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Title Section
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tr('Khyate - Tailor App', 'خياطة - تطبيق الخياط'),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 28,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _tr('Find the perfect tailor for your needs',
                            'اعثر على الخياط المثالي لاحتياجاتك'),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar with improved styling
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: TextField(
                    controller: _searchController,
                    textDirection:
                        isRTL ? TextDirection.rtl : TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: _tr('Search tailors, services...',
                          'البحث عن الخياطين، الخدمات...'),
                      hintStyle: TextStyle(
                          color: ColorConstants.deepNavy.withOpacity(0.6)),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        child: const Icon(Icons.search,
                            color: ColorConstants.primaryGold, size: 22),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: ColorConstants.softIvory,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 24),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: ColorConstants.primaryGold,
                          width: 2,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      color: ColorConstants.deepNavy,
                      fontSize: 16,
                    ),
                    onChanged: (value) => _filterTailors(),
                  ),
                ),

                // Service Type Filter Chips with better spacing and colors
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            _tr('All', 'الكل'),
                            style: TextStyle(
                              color: _selectedServiceType == null
                                  ? Colors.white
                                  : ColorConstants.deepNavy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: _selectedServiceType == null,
                          selectedColor: ColorConstants.primaryGold,
                          backgroundColor: Colors.white.withOpacity(0.9),
                          checkmarkColor: Colors.white,
                          elevation: 2,
                          shadowColor: ColorConstants.deepNavy.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          onSelected: (selected) {
                            setState(() => _selectedServiceType = null);
                            _filterTailors();
                          },
                        ),
                      ),
                      ...ServiceType.values.map((type) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                _getServiceTypeLabel(type),
                                style: TextStyle(
                                  color: _selectedServiceType == type
                                      ? Colors.white
                                      : ColorConstants.deepNavy,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              selected: _selectedServiceType == type,
                              selectedColor: ColorConstants.primaryGold,
                              backgroundColor: Colors.white.withOpacity(0.9),
                              checkmarkColor: Colors.white,
                              elevation: 2,
                              shadowColor:
                                  ColorConstants.deepNavy.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedServiceType = selected ? type : null;
                                });
                                _filterTailors();
                              },
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 📋 Content with subtle background gradient for depth
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: ColorConstants.backgroundGradient,
              ),
              child: _filteredTailors.isEmpty
                  ? Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 80,
                                color: ColorConstants.grey.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text(
                              _tr('No tailors found',
                                  'لم يتم العثور على خياطين'),
                              style: theme.textTheme.titleLarge?.copyWith(
                                  color: ColorConstants.deepNavy,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _tr('Try adjusting your search or filters',
                                  'جرب تعديل البحث أو المرشحات'),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                  color:
                                      ColorConstants.deepNavy.withOpacity(0.7)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      children: [
                        // Featured Section with enhanced title styling
                        if (_searchController.text.isEmpty &&
                            _selectedServiceType == null) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              _tr('Featured Tailors', 'خياطون مميزون'),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.primaryGold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 32),
                            height: 240,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _filteredTailors.take(3).length,
                              itemBuilder: (context, index) {
                                final tailor = _filteredTailors[index];
                                return _FeaturedTailorCard(
                                  tailor: tailor,
                                  language: _selectedLanguage,
                                );
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              _tr('All Tailors', 'جميع الخياطين'),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.primaryGold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ],

                        // Tailors List with cards
                        ...(_filteredTailors.map((tailor) => Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: _TailorCard(
                                tailor: tailor,
                                language: _selectedLanguage,
                                onTap: () => _showTailorServices(tailor),
                              ),
                            ))),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Returns a localized label for the given ServiceType.
  String _getServiceTypeLabel(ServiceType type) {
    switch (type) {
      case ServiceType.readymade:
        return _tr('Ready-made', 'جاهز');
      case ServiceType.custom:
        return _tr('Custom', 'مخصص');
      case ServiceType.alterations:
        return _tr('Alterations', 'تعديلات');
    }
  }

  // Displays a bottom sheet listing the selected tailor's services; navigates to details on tap.
  void _showTailorServices(Tailor tailor) {
    final tailorServices =
        _services.where((s) => s.tailorId == tailor.id).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: ColorConstants.softIvory,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: ColorConstants.deepNavy.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: ColorConstants.backgroundGradient,
                  border: Border(
                    bottom:
                        BorderSide(color: ColorConstants.grey.withOpacity(0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    _ProfileAvatar(
                      imageUrl: tailor.profileImage,
                      radius: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedLanguage == 'ar'
                                ? tailor.nameAr
                                : tailor.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: ColorConstants.deepNavy,
                                ),
                          ),
                          Text(
                            _selectedLanguage == 'ar'
                                ? tailor.locationAr
                                : tailor.location,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color:
                                      ColorConstants.deepNavy.withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: ColorConstants.deepNavy),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: tailorServices.length,
                  itemBuilder: (context, index) {
                    final service = tailorServices[index];
                    return _ServiceCard(
                      service: service,
                      language: _selectedLanguage,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ServiceDetailScreen(
                              service: service,
                              tailor: tailor,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Disposes controllers and cleans up resources.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _FeaturedTailorCard extends StatelessWidget {
  final Tailor tailor;
  final String language;

  const _FeaturedTailorCard({
    required this.tailor,
    required this.language,
    super.key,
  });

  // Builds the featured tailor card UI.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(right: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: ColorConstants.softIvory,
      shadowColor: ColorConstants.deepNavy.withOpacity(0.1),
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with gradient overlay for premium feel and error handling
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Container(
                    height: 140,
                    width: 180,
                    color: ColorConstants.lightGold.withOpacity(0.2),
                    child: tailor.profileImage.isNotEmpty
                        ? Image.network(
                            tailor.profileImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.person,
                              size: 80,
                              color: ColorConstants.primaryGold,
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: ColorConstants.primaryGold,
                                ),
                              );
                            },
                          )
                        : const Icon(
                            Icons.person,
                            size: 80,
                            color: ColorConstants.primaryGold,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            ColorConstants.deepNavy.withOpacity(0.3)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content with refined padding and typography
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language == 'ar' ? tailor.nameAr : tailor.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: ColorConstants.deepNavy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    language == 'ar' ? tailor.locationAr : tailor.location,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ColorConstants.accentTeal,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TailorCard extends StatelessWidget {
  final Tailor tailor;
  final String language;
  final VoidCallback onTap;

  const _TailorCard({
    required this.tailor,
    required this.language,
    required this.onTap,
    super.key,
  });

  // Builds the tailor list item card with tap handling.
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: ColorConstants.softIvory,
        shadowColor: ColorConstants.deepNavy.withOpacity(0.1),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _ProfileAvatar(
            imageUrl: tailor.profileImage,
            radius: 28,
          ),
          title: Text(
            language == 'ar' ? tailor.nameAr : tailor.name,
            style: const TextStyle(
              color: ColorConstants.deepNavy,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            language == 'ar' ? tailor.locationAr : tailor.location,
            style: TextStyle(color: ColorConstants.accentTeal),
          ),
          trailing: Icon(Icons.arrow_forward_ios,
              color: ColorConstants.primaryGold, size: 20),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final TailorService service;
  final String language;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.language,
    required this.onTap,
    super.key,
  });

  // Builds the service list item card and triggers onTap when pressed.
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: ColorConstants.softIvory,
      shadowColor: ColorConstants.deepNavy.withOpacity(0.1),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          service.title,
          style: const TextStyle(
            color: ColorConstants.deepNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          service.description,
          style: TextStyle(color: ColorConstants.deepNavy.withOpacity(0.7)),
        ),
        trailing: Icon(Icons.chevron_right, color: ColorConstants.accentTeal),
        onTap: onTap,
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;

  const _ProfileAvatar({
    required this.imageUrl,
    required this.radius,
  });

  // Builds a circular avatar that loads an image with error and loading fallbacks.
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: radius * 2,
                height: radius * 2,
                color: ColorConstants.lightGold.withOpacity(0.5),
                child: const Icon(
                  Icons.person,
                  color: ColorConstants.primaryGold,
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Container(
                  width: radius * 2,
                  height: radius * 2,
                  color: ColorConstants.lightGold.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: ColorConstants.primaryGold,
                    ),
                  ),
                );
              },
            )
          : Container(
              width: radius * 2,
              height: radius * 2,
              color: ColorConstants.lightGold.withOpacity(0.5),
              child: const Icon(
                Icons.person,
                color: ColorConstants.primaryGold,
              ),
            ),
    );
  }
}
