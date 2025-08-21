import 'package:flutter/material.dart';
import 'package:zayyan/models/models.dart';
import 'package:zayyan/services/storage_service.dart';
import 'package:zayyan/screens/measurement_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final TailorService service;
  final Tailor tailor;

  const ServiceDetailScreen({
    super.key,
    required this.service,
    required this.tailor,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  String _selectedLanguage = 'en';
  bool _isLoading = false;
  final _requirementsController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedMeasurementId;
  List<Measurement> _measurements = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final language = await StorageService.getLanguage();
    final measurements = await StorageService.getMeasurements();
    setState(() {
      _selectedLanguage = language;
      _measurements = measurements;
    });
  }

  String _tr(String en, String ar) => _selectedLanguage == 'ar' ? ar : en;

  Future<void> _placeOrder() async {
    if (widget.service.type == ServiceType.custom || widget.service.type == ServiceType.alterations) {
      if (_selectedMeasurementId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_tr('Please select measurements', 'يرجى اختيار القياسات'))),
        );
        return;
      }
    }

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_tr('Please enter delivery address', 'يرجى إدخال عنوان التسليم'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final user = await StorageService.getCurrentUser();
    final order = Order(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      userId: user?.id ?? 'guest',
      tailorId: widget.tailor.id,
      tailorName: widget.tailor.name,
      tailorNameAr: widget.tailor.nameAr,
      serviceType: widget.service.type,
      serviceTitle: widget.service.title,
      serviceTitleAr: widget.service.titleAr,
      status: OrderStatus.placed,
      totalAmount: widget.service.price,
      measurementId: _selectedMeasurementId,
      customRequirements: _requirementsController.text.trim().isNotEmpty 
          ? _requirementsController.text.trim() 
          : null,
      deliveryAddress: _addressController.text.trim(),
      orderDate: DateTime.now(),
      estimatedDelivery: DateTime.now().add(Duration(days: widget.service.estimatedDays)),
      statusUpdates: [
        OrderStatusUpdate(
          status: OrderStatus.placed,
          message: 'Order placed successfully',
          messageAr: 'تم تقديم الطلب بنجاح',
          timestamp: DateTime.now(),
        ),
      ],
    );

    await StorageService.saveOrder(order);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr('Order placed successfully!', 'تم تقديم الطلب بنجاح!')),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = _selectedLanguage == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_tr('Service Details', 'تفاصيل الخدمة')),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () async {
                await StorageService.toggleFavorite(widget.tailor.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_tr('Added to favorites', 'أضيف للمفضلة')),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Image
              if (widget.service.imageUrl != null)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(widget.service.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (widget.service.imageUrl != null) const SizedBox(height: 16),

              // Service Info
              Text(
                _selectedLanguage == 'ar' ? widget.service.titleAr : widget.service.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                _selectedLanguage == 'ar' ? widget.service.descriptionAr : widget.service.description,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Tailor Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.tailor.profileImage),
                        radius: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedLanguage == 'ar' ? widget.tailor.nameAr : widget.tailor.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.tailor.rating} (${widget.tailor.reviewCount})',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Text(
                              _selectedLanguage == 'ar' ? widget.tailor.locationAr : widget.tailor.location,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Order Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tr('Order Details', 'تفاصيل الطلب'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Measurements Section (for Custom and Alterations)
                      if (widget.service.type == ServiceType.custom || widget.service.type == ServiceType.alterations) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _tr('Measurements', 'القياسات'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const MeasurementScreen(),
                                ),
                              ).then((_) => _loadData()),
                              icon: const Icon(Icons.add),
                              label: Text(_tr('Add New', 'إضافة جديد')),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (_measurements.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.colorScheme.outline),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.straighten,
                                  size: 48,
                                  color: theme.colorScheme.outline,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _tr('No measurements saved', 'لا توجد قياسات محفوظة'),
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _tr('Add measurements to continue', 'أضف القياسات للمتابعة'),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          DropdownButtonFormField<String>(
                            value: _selectedMeasurementId,
                            decoration: InputDecoration(
                              labelText: _tr('Select Measurement Profile', 'اختر ملف القياسات'),
                              border: const OutlineInputBorder(),
                            ),
                            items: _measurements.map((measurement) {
                              return DropdownMenuItem(
                                value: measurement.id,
                                child: Text(
                                  _selectedLanguage == 'ar' ? measurement.nameAr : measurement.name,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedMeasurementId = value),
                          ),

                        const SizedBox(height: 16),
                      ],

                      // Custom Requirements
                      TextField(
                        controller: _requirementsController,
                        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: _tr('Special Requirements (Optional)', 'متطلبات خاصة (اختياري)'),
                          hintText: _tr(
                            'Any specific details or preferences...',
                            'أي تفاصيل أو تفضيلات خاصة...'
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Delivery Address
                      TextField(
                        controller: _addressController,
                        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: _tr('Delivery Address *', 'عنوان التسليم *'),
                          hintText: _tr(
                            'Enter your complete delivery address',
                            'أدخل عنوان التسليم الكامل'
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Order Summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _tr('Service Price', 'سعر الخدمة'),
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  'AED ${widget.service.price.toInt()}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _tr('Estimated Delivery', 'التسليم المتوقع'),
                                  style: theme.textTheme.bodyMedium,
                                ),
                                Text(
                                  '${widget.service.estimatedDays} ${_tr('days', 'أيام')}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
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

              const SizedBox(height: 24),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _tr('Place Order - AED ${widget.service.price.toInt()}', 'تقديم الطلب - ${widget.service.price.toInt()} درهم'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _requirementsController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}