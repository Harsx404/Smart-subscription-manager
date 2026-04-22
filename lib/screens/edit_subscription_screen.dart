import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../utils/constants.dart';

class EditSubscriptionScreen extends StatefulWidget {
  final Subscription subscription;

  const EditSubscriptionScreen({super.key, required this.subscription});

  @override
  State<EditSubscriptionScreen> createState() =>
      _EditSubscriptionScreenState();
}

class _EditSubscriptionScreenState extends State<EditSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _costController;
  late final TextEditingController _notesController;

  late String _currency;
  late BillingCycle _billingCycle;
  late DateTime _nextBillingDate;
  late String _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.subscription;
    _nameController = TextEditingController(text: s.name);
    _costController = TextEditingController(text: s.cost.toString());
    _notesController = TextEditingController(text: s.notes ?? '');
    _currency = s.currency;
    _billingCycle = s.billingCycle;
    _nextBillingDate = s.nextBillingDate;
    _category = s.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextBillingDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _nextBillingDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final updated = widget.subscription.copyWith(
      name: _nameController.text.trim(),
      cost: double.parse(_costController.text),
      currency: _currency,
      billingCycle: _billingCycle,
      nextBillingDate: _nextBillingDate,
      category: _category,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    await context.read<SubscriptionProvider>().updateSubscription(updated);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${updated.name} updated!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Subscription'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Service Name',
                prefixIcon: Icon(Icons.subscriptions_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: DropdownButtonFormField<String>(
                    initialValue: _currency,
                    decoration: const InputDecoration(labelText: 'Currency'),
                    items: AppConstants.currencies
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _currency = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _costController,
                    decoration: const InputDecoration(
                      labelText: 'Cost',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Cost is required';
                      if (double.tryParse(v) == null) return 'Invalid number';
                      if (double.parse(v) <= 0) return 'Must be > 0';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BillingCycle>(
              initialValue: _billingCycle,
              decoration: const InputDecoration(
                labelText: 'Billing Cycle',
                prefixIcon: Icon(Icons.repeat_rounded),
              ),
              items: const [
                DropdownMenuItem(
                    value: BillingCycle.monthly, child: Text('Monthly')),
                DropdownMenuItem(
                    value: BillingCycle.yearly, child: Text('Yearly')),
              ],
              onChanged: (v) => setState(() => _billingCycle = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: AppConstants.categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Text(AppConstants.categoryIcons[c] ?? '📦'),
                            const SizedBox(width: 8),
                            Text(c),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Next Billing Date',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  '${_nextBillingDate.day}/${_nextBillingDate.month}/${_nextBillingDate.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_saving ? 'Saving...' : 'Update Subscription'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
