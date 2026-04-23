import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../utils/constants.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  String _currency = 'INR';
  BillingCycle _billingCycle = BillingCycle.monthly;
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));
  String _category = 'Entertainment';
  bool _saving = false;

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
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _nextBillingDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final sub = Subscription(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      cost: double.parse(_costController.text),
      currency: _currency,
      billingCycle: _billingCycle,
      nextBillingDate: _nextBillingDate,
      category: _category,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await context.read<SubscriptionProvider>().addSubscription(sub);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${sub.name} added successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save subscription: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Subscription')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildNameField(),
            const SizedBox(height: 16),
            _buildCostRow(),
            const SizedBox(height: 16),
            _buildBillingCycleField(),
            const SizedBox(height: 16),
            _buildCategoryField(),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildNotesField(),
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
              label: Text(_saving ? 'Saving...' : 'Save Subscription'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Service Name',
        prefixIcon: Icon(Icons.subscriptions_outlined),
        hintText: 'e.g. Netflix, Spotify, Adobe',
      ),
      textCapitalization: TextCapitalization.words,
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'Name is required' : null,
    );
  }

  Widget _buildCostRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: DropdownButtonFormField<String>(
            initialValue: _currency,
            decoration: const InputDecoration(labelText: 'Currency'),
            items: AppConstants.currencies
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Cost is required';
              if (double.tryParse(v) == null) return 'Enter a valid number';
              if (double.parse(v) <= 0) return 'Must be greater than 0';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBillingCycleField() {
    return DropdownButtonFormField<BillingCycle>(
      initialValue: _billingCycle,
      decoration: const InputDecoration(
        labelText: 'Billing Cycle',
        prefixIcon: Icon(Icons.repeat_rounded),
      ),
      items: const [
        DropdownMenuItem(value: BillingCycle.monthly, child: Text('Monthly')),
        DropdownMenuItem(value: BillingCycle.yearly, child: Text('Yearly')),
      ],
      onChanged: (v) => setState(() => _billingCycle = v!),
    );
  }

  Widget _buildCategoryField() {
    return DropdownButtonFormField<String>(
      initialValue: _category,
      decoration: const InputDecoration(
        labelText: 'Category',
        prefixIcon: Icon(Icons.category_outlined),
      ),
      items: AppConstants.categories
          .map(
            (c) => DropdownMenuItem(
              value: c,
              child: Row(
                children: [
                  Text(AppConstants.categoryIcons[c] ?? '📦'),
                  const SizedBox(width: 8),
                  Text(c),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _category = v!),
    );
  }

  Widget _buildDateField() {
    return InkWell(
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
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes (optional)',
        prefixIcon: Icon(Icons.notes_rounded),
        hintText: 'e.g. Family plan, shared account',
      ),
      maxLines: 2,
    );
  }
}
