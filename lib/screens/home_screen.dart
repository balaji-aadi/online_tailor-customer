import 'package:flutter/material.dart';
import 'package:zayyan/models/models.dart';
import 'package:zayyan/data/sample_data.dart';
import 'package:zayyan/services/storage_service.dart';
import 'package:zayyan/screens/service_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
            tailor.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            tailor.nameAr.contains(_searchController.text) ||
            tailor.location.toLowerCase().contains(_searchController.text.toLowerCase()) ||
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_tr('Zayyan - UAE Tailors', 'زين - خياطو الإمارات')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_tr('No new notifications', 'لا توجد إشعارات جديدة')),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: _tr(
                      'Search tailors, services...',
                      'البحث عن الخياطين، الخدمات...'
                    ),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.background,
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
          
          // Content
          Expanded(
            child: _filteredTailors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _tr('No tailors found', 'لم يتم العثور على خياطين'),
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tr(
                            'Try adjusting your search or filters',
                            'جرب تعديل البحث أو المرشحات'
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Featured Section
                      if (_searchController.text.isEmpty && _selectedServiceType == null) ...[
                        Text(
                          _tr('Featured Tailors', 'خياطون مميزون'),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
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
    final tailorServices = _services.where((s) => s.tailorId == tailor.id).toList();
    
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
                            _selectedLanguage == 'ar' ? tailor.nameAr : tailor.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _selectedLanguage == 'ar' ? tailor.locationAr : tailor.location,
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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(tailor.profileImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language == 'ar' ? tailor.nameAr : tailor.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${tailor.rating} (${tailor.reviewCount})',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    language == 'ar' ? tailor.locationAr : tailor.location,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AED ${tailor.priceFrom.toInt()} - ${tailor.priceTo.toInt()}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(tailor.profileImage),
                radius: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language == 'ar' ? tailor.nameAr : tailor.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      language == 'ar' ? tailor.descriptionAr : tailor.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: theme.colorScheme.outline),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            language == 'ar' ? tailor.locationAr : tailor.location,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${tailor.rating} (${tailor.reviewCount})',
                          style: theme.textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Text(
                          'AED ${tailor.priceFrom.toInt()}+',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (service.imageUrl != null)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(service.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (service.imageUrl != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language == 'ar' ? service.titleAr : service.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      language == 'ar' ? service.descriptionAr : service.description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'AED ${service.price.toInt()}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${service.estimatedDays} ${language == 'ar' ? 'أيام' : 'days'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}