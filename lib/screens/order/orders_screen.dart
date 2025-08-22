import 'package:flutter/material.dart';
import 'package:zayyan/models/models.dart';
import 'package:zayyan/services/storage_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedLanguage = 'en';
  List<Order> _orders = [];
  ServiceType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final language = await StorageService.getLanguage();
    final orders = await StorageService.getOrders();
    setState(() {
      _selectedLanguage = language;
      _orders = orders..sort((a, b) => b.orderDate.compareTo(a.orderDate));
    });
  }

  String _tr(String en, String ar) => _selectedLanguage == 'ar' ? ar : en;

  List<Order> get _filteredOrders {
    if (_selectedFilter == null) return _orders;
    return _orders
        .where((order) => order.serviceType == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = _selectedLanguage == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_tr('My Orders', 'طلباتي')),
          centerTitle: false,
        ),
        body: Column(
          children: [
            // Filter Section
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(_tr('All Orders', 'جميع الطلبات')),
                      selected: _selectedFilter == null,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = null);
                      },
                    ),
                    const SizedBox(width: 8),
                    ...ServiceType.values.map((type) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(_getServiceTypeLabel(type)),
                            selected: _selectedFilter == type,
                            onSelected: (selected) {
                              setState(() =>
                                  _selectedFilter = selected ? type : null);
                            },
                          ),
                        )),
                  ],
                ),
              ),
            ),

            // Orders List
            Expanded(
              child: _filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _tr('No orders found', 'لا توجد طلبات'),
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _tr('Your orders will appear here',
                                'ستظهر طلباتك هنا'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = _filteredOrders[index];
                        return _OrderCard(
                          order: order,
                          language: _selectedLanguage,
                          onTap: () => _showOrderDetails(order),
                        );
                      },
                    ),
            ),
          ],
        ),
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

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _tr('Order Details', 'تفاصيل الطلب'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: _OrderDetailsContent(
                    order: order,
                    language: _selectedLanguage,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final String language;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      language == 'ar'
                          ? order.serviceTitleAr
                          : order.serviceTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusBadge(status: order.status, language: language),
                ],
              ),

              const SizedBox(height: 8),

              // Tailor Info
              Text(
                language == 'ar' ? order.tailorNameAr : order.tailorName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 12),

              // Order Info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language == 'ar' ? 'رقم الطلب' : 'Order ID',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        Text(
                          '#${order.id.substring(order.id.length - 8)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language == 'ar' ? 'تاريخ الطلب' : 'Order Date',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        Text(
                          _formatDate(order.orderDate),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'AED ${order.totalAmount.toInt()}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (order.estimatedDelivery != null)
                        Text(
                          language == 'ar'
                              ? 'التسليم: ${_formatDate(order.estimatedDelivery!)}'
                              : 'Delivery: ${_formatDate(order.estimatedDelivery!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  final String language;

  const _StatusBadge({
    required this.status,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case OrderStatus.placed:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        label = language == 'ar' ? 'مقدم' : 'Placed';
        break;
      case OrderStatus.accepted:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        label = language == 'ar' ? 'مقبول' : 'Accepted';
        break;
      case OrderStatus.inProgress:
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade700;
        label = language == 'ar' ? 'قيد التنفيذ' : 'In Progress';
        break;
      case OrderStatus.shipped:
        backgroundColor = Colors.teal.shade100;
        textColor = Colors.teal.shade700;
        label = language == 'ar' ? 'تم الشحن' : 'Shipped';
        break;
      case OrderStatus.delivered:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        label = language == 'ar' ? 'تم التسليم' : 'Delivered';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OrderDetailsContent extends StatelessWidget {
  final Order order;
  final String language;

  const _OrderDetailsContent({
    required this.order,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order Summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language == 'ar' ? 'ملخص الطلب' : 'Order Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  label: language == 'ar' ? 'رقم الطلب' : 'Order ID',
                  value: '#${order.id.substring(order.id.length - 8)}',
                ),
                _InfoRow(
                  label: language == 'ar' ? 'الخدمة' : 'Service',
                  value: language == 'ar'
                      ? order.serviceTitleAr
                      : order.serviceTitle,
                ),
                _InfoRow(
                  label: language == 'ar' ? 'الخياط' : 'Tailor',
                  value:
                      language == 'ar' ? order.tailorNameAr : order.tailorName,
                ),
                _InfoRow(
                  label: language == 'ar' ? 'المبلغ الإجمالي' : 'Total Amount',
                  value: 'AED ${order.totalAmount.toInt()}',
                ),
                _InfoRow(
                  label: language == 'ar' ? 'تاريخ الطلب' : 'Order Date',
                  value: _formatDate(order.orderDate),
                ),
                if (order.estimatedDelivery != null)
                  _InfoRow(
                    label: language == 'ar'
                        ? 'التسليم المتوقع'
                        : 'Estimated Delivery',
                    value: _formatDate(order.estimatedDelivery!),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Custom Requirements
        if (order.customRequirements != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language == 'ar'
                        ? 'المتطلبات الخاصة'
                        : 'Special Requirements',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    language == 'ar' && order.customRequirementsAr != null
                        ? order.customRequirementsAr!
                        : order.customRequirements!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Delivery Address
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language == 'ar' ? 'عنوان التسليم' : 'Delivery Address',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  order.deliveryAddress,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Status Updates
        if (order.statusUpdates.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language == 'ar' ? 'تحديثات الحالة' : 'Status Updates',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...order.statusUpdates.reversed.map((update) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    language == 'ar'
                                        ? update.messageAr
                                        : update.message,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDateTime(update.timestamp),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
