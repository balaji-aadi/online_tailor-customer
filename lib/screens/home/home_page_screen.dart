import 'package:flutter/material.dart';
import 'package:khyate_tailor_app/constants/color_constant.dart';
import 'package:khyate_tailor_app/data/sample_data.dart';
import 'package:khyate_tailor_app/models/models.dart';
import 'package:khyate_tailor_app/screens/service_detail_screen.dart';
import 'package:khyate_tailor_app/services/storage_service.dart';


class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _filteredTailors = _tailors;
  }

  Future<void> _loadLanguage() async {
    final language = await StorageService.getLanguage();
    setState(() => _selectedLanguage = language);
  }

  String _tr(String en, String ar) => _selectedLanguage == 'ar' ? ar : en;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = _selectedLanguage == 'ar';

    return Container(
     
      child: Column(
        children: [
          // 🔍 Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: ColorConstants.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: ColorConstants.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: _tr('Search tailors, services...',
                        'البحث عن الخياطين، الخدمات...'),
                    prefixIcon: const Icon(Icons.search,
                        color: ColorConstants.deepNavy),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: ColorConstants.softIvory,
                  ),
                  onChanged: (value) => _filterTailors(),
                ),

                const SizedBox(height: 12),

                // Service Type Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text(_tr('All', 'الكل')),
                        selected: _selectedServiceType == null,
                        selectedColor:
                            ColorConstants.accentTeal.withOpacity(0.2),
                        checkmarkColor: ColorConstants.accentTeal,
                        onSelected: (selected) {
                          setState(() => _selectedServiceType = null);
                          _filterTailors();
                        },
                      ),
                      const SizedBox(width: 8),
                      ...ServiceType.values.map((type) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(_getServiceTypeLabel(type)),
                              selected: _selectedServiceType == type,
                              selectedColor:
                                  ColorConstants.primaryGold.withOpacity(0.25),
                              checkmarkColor: ColorConstants.primaryGold,
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

          // 📋 Content
          Expanded(
            child: _filteredTailors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: ColorConstants.grey),
                        const SizedBox(height: 16),
                        Text(
                          _tr('No tailors found', 'لم يتم العثور على خياطين'),
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: ColorConstants.deepNavy),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tr('Try adjusting your search or filters',
                              'جرب تعديل البحث أو المرشحات'),
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: ColorConstants.grey),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Featured Section
                      if (_searchController.text.isEmpty &&
                          _selectedServiceType == null) ...[
                        Text(
                          _tr('Featured Tailors', 'خياطون مميزون'),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.deepNavy,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
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
                        const SizedBox(height: 24),
                        Text(
                          _tr('All Tailors', 'جميع الخياطين'),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.deepNavy,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Tailors Grid
                      ...(_filteredTailors.map((tailor) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _TailorCard(
                              tailor: tailor,
                              language: _selectedLanguage,
                              onTap: () => _showTailorServices(tailor),
                            ),
                          ))),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

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

  void _showTailorServices(Tailor tailor) {
    final tailorServices =
        _services.where((s) => s.tailorId == tailor.id).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(tailor.profileImage),
                      radius: 24,
                    ),
                    const SizedBox(width: 12),
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
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            _selectedLanguage == 'ar'
                                ? tailor.locationAr
                                : tailor.location,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 120,
                width: 160,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.person,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            ),

            // Content Padding
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language == 'ar' ? tailor.nameAr : tailor.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    language == 'ar' ? tailor.locationAr : tailor.location,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontSize: 12,
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: const Icon(
              Icons.person,
              color: Colors.grey,
            ),
          ),
          title: Text(language == 'ar' ? tailor.nameAr : tailor.name),
          subtitle:
              Text(language == 'ar' ? tailor.locationAr : tailor.location),
          trailing: const Icon(Icons.arrow_forward_ios),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(service.title),
        subtitle: Text(service.description),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
