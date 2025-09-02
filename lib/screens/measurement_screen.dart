import 'package:flutter/material.dart';
import 'package:khyate_tailor_app/data/sample_data.dart';
import 'package:khyate_tailor_app/models/models.dart';
import 'package:khyate_tailor_app/services/storage_service.dart';

class MeasurementScreen extends StatefulWidget {
  const MeasurementScreen({super.key});

  @override
  State<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  String _selectedLanguage = 'en';
  List<Measurement> _measurements = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // final language = await StorageService.getLanguage();
    // final measurements = await StorageService.getMeasurements();
    setState(() {
      // _selectedLanguage = language;
      // _measurements = measurements;
    });
  }

  String _tr(String en, String ar) => _selectedLanguage == 'ar' ? ar : en;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = _selectedLanguage == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_tr('Measurements', 'القياسات')),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddMeasurementDialog(),
            ),
          ],
        ),
        body: _measurements.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.straighten,
                      size: 64,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _tr('No measurements saved', 'لا توجد قياسات محفوظة'),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _tr('Add your measurements for custom tailoring',
                          'أضف قياساتك للخياطة المخصصة'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showAddMeasurementDialog(),
                      icon: const Icon(Icons.add),
                      label: Text(_tr('Add Measurements', 'إضافة القياسات')),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _measurements.length,
                itemBuilder: (context, index) {
                  final measurement = _measurements[index];
                  return _MeasurementCard(
                    measurement: measurement,
                    language: _selectedLanguage,
                    onEdit: () => _showEditMeasurementDialog(measurement),
                    onDelete: () => _deleteMeasurement(measurement.id),
                  );
                },
              ),
        floatingActionButton: _measurements.isNotEmpty
            ? FloatingActionButton(
                onPressed: () => _showAddMeasurementDialog(),
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  void _showAddMeasurementDialog() {
    _showMeasurementDialog();
  }

  void _showEditMeasurementDialog(Measurement measurement) {
    _showMeasurementDialog(existingMeasurement: measurement);
  }

  void _showMeasurementDialog({Measurement? existingMeasurement}) {
    final isEditing = existingMeasurement != null;
    final controllers = <String, TextEditingController>{};
    final measurementLabels = SampleData.getMeasurementLabels();

    // Initialize controllers
    for (final key in measurementLabels.keys) {
      controllers[key] = TextEditingController(
        text: existingMeasurement?.measurements[key]?.toString() ?? '',
      );
    }

    final nameController = TextEditingController(
      text: existingMeasurement?.name ?? '',
    );
    final nameArController = TextEditingController(
      text: existingMeasurement?.nameAr ?? '',
    );
    final notesController = TextEditingController(
      text: existingMeasurement?.notes ?? '',
    );
    final notesArController = TextEditingController(
      text: existingMeasurement?.notesAr ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEditing
                            ? _tr('Edit Measurements', 'تعديل القياسات')
                            : _tr('Add Measurements', 'إضافة القياسات'),
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

              // Form
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Profile Name
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: _tr('Profile Name (English)',
                                    'اسم الملف (بالإنجليزية)'),
                                border: const OutlineInputBorder(),
                                hintText:
                                    _tr('e.g. Summer 2025', 'مثال: صيف 2025'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: nameArController,
                              textDirection: TextDirection.rtl,
                              decoration: const InputDecoration(
                                labelText: 'اسم الملف (بالعربية)',
                                border: OutlineInputBorder(),
                                hintText: 'مثال: صيف ٢٠٢٥',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Measurements
                      Text(
                        _tr('Body Measurements (cm)', 'قياسات الجسم (سم)'),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),

                      ...measurementLabels.entries.map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextField(
                              controller: controllers[entry.key]!,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                labelText: entry.value,
                                border: const OutlineInputBorder(),
                                suffixText: 'cm',
                              ),
                            ),
                          )),

                      const SizedBox(height: 16),

                      // Notes
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: notesController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: _tr(
                                    'Notes (Optional)', 'ملاحظات (اختياري)'),
                                border: const OutlineInputBorder(),
                                hintText: _tr('Any special notes...',
                                    'أي ملاحظات خاصة...'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: notesArController,
                              textDirection: TextDirection.rtl,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'ملاحظات (بالعربية)',
                                border: OutlineInputBorder(),
                                hintText: 'أي ملاحظات خاصة...',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_tr('Please enter profile name',
                                      'يرجى إدخال اسم الملف')),
                                ),
                              );
                              return;
                            }

                            final measurements = <String, double>{};
                            for (final entry in controllers.entries) {
                              final value =
                                  double.tryParse(entry.value.text.trim());
                              if (value != null && value > 0) {
                                measurements[entry.key] = value;
                              }
                            }

                            if (measurements.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_tr(
                                      'Please enter at least one measurement',
                                      'يرجى إدخال قياس واحد على الأقل')),
                                ),
                              );
                              return;
                            }

                            final measurement = Measurement(
                              id: existingMeasurement?.id ??
                                  'measure_${DateTime.now().millisecondsSinceEpoch}',
                              name: nameController.text.trim(),
                              nameAr: nameArController.text.trim().isNotEmpty
                                  ? nameArController.text.trim()
                                  : nameController.text.trim(),
                              measurements: measurements,
                              createdAt: existingMeasurement?.createdAt ??
                                  DateTime.now(),
                              notes: notesController.text.trim().isNotEmpty
                                  ? notesController.text.trim()
                                  : null,
                              notesAr: notesArController.text.trim().isNotEmpty
                                  ? notesArController.text.trim()
                                  : null,
                            );

                            // await StorageService.saveMeasurement(measurement);
                            Navigator.of(context).pop();
                            _loadData();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEditing
                                      ? _tr('Measurements updated',
                                          'تم تحديث القياسات')
                                      : _tr('Measurements saved',
                                          'تم حفظ القياسات'),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: Text(
                            isEditing
                                ? _tr('Update Measurements', 'تحديث القياسات')
                                : _tr('Save Measurements', 'حفظ القياسات'),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteMeasurement(String measurementId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_tr('Delete Measurement', 'حذف القياسات')),
        content: Text(_tr(
            'Are you sure you want to delete this measurement profile?',
            'هل أنت متأكد من حذف ملف القياسات هذا؟')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_tr('Cancel', 'إلغاء')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(_tr('Delete', 'حذف')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // await StorageService.deleteMeasurement(measurementId);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr('Measurement deleted', 'تم حذف القياسات')),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }
}

class _MeasurementCard extends StatelessWidget {
  final Measurement measurement;
  final String language;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MeasurementCard({
    required this.measurement,
    required this.language,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final measurementLabels = SampleData.getMeasurementLabels();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language == 'ar'
                            ? measurement.nameAr
                            : measurement.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${language == 'ar' ? 'تم الإنشاء في' : 'Created'}: ${_formatDate(measurement.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 18),
                          const SizedBox(width: 8),
                          Text(language == 'ar' ? 'تعديل' : 'Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            language == 'ar' ? 'حذف' : 'Delete',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Measurements Grid
            if (measurement.measurements.isNotEmpty) ...[
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: measurement.measurements.entries.map((entry) {
                  final label = measurementLabels[entry.key] ?? entry.key;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$label: ${entry.value} cm',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // Notes
            if (measurement.notes != null || measurement.notesAr != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language == 'ar' ? 'ملاحظات:' : 'Notes:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      language == 'ar' && measurement.notesAr != null
                          ? measurement.notesAr!
                          : measurement.notes ?? '',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
