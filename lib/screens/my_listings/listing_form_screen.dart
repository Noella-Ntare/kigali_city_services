import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../models/listing_model.dart';
import '../../theme.dart';

class ListingFormScreen extends StatefulWidget {
  final ListingModel? existingListing;
  final String createdBy;

  const ListingFormScreen({
    super.key,
    this.existingListing,
    required this.createdBy,
  });

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _contactCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _latCtrl;
  late TextEditingController _lngCtrl;
  String _selectedCategory = kCategories.first;

  bool get isEditing => widget.existingListing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existingListing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _addressCtrl = TextEditingController(text: e?.address ?? '');
    _contactCtrl = TextEditingController(text: e?.contactNumber ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _latCtrl = TextEditingController(text: e?.latitude.toString() ?? '-1.9441');
    _lngCtrl =
        TextEditingController(text: e?.longitude.toString() ?? '30.0619');
    if (e != null) _selectedCategory = e.category;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    _descCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ListingProvider>();

    final listing = ListingModel(
      id: widget.existingListing?.id ?? '',
      name: _nameCtrl.text.trim(),
      category: _selectedCategory,
      address: _addressCtrl.text.trim(),
      contactNumber: _contactCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      latitude: double.tryParse(_latCtrl.text) ?? -1.9441,
      longitude: double.tryParse(_lngCtrl.text) ?? 30.0619,
      createdBy: widget.createdBy,
      createdAt: widget.existingListing?.createdAt ?? DateTime.now(),
    );

    if (isEditing) {
      await provider.updateListing(listing);
    } else {
      await provider.createListing(listing);
    }

    if (context.mounted && provider.status == ListingStatus.success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? 'Listing updated successfully'
              : 'Listing created successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Listing' : 'Add Listing',
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(_nameCtrl, 'Place / Service Name', Icons.store_outlined,
                  required: true),
              const SizedBox(height: 14),

              // Category dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                dropdownColor: AppColors.navyCard,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category_outlined,
                      color: AppColors.textDim),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.navyLight)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.navyLight)),
                  filled: true,
                  fillColor: AppColors.navyCard,
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                ),
                items: kCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 14),

              _field(_addressCtrl, 'Address', Icons.location_on_outlined,
                  required: true),
              const SizedBox(height: 14),
              _field(_contactCtrl, 'Contact Number', Icons.phone_outlined),
              const SizedBox(height: 14),
              _field(_descCtrl, 'Description', Icons.description_outlined,
                  maxLines: 3),
              const SizedBox(height: 14),

              // Coordinates
              const Text('Geographic Coordinates',
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: _field(_latCtrl, 'Latitude', Icons.gps_fixed,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field(_lngCtrl, 'Longitude', Icons.gps_not_fixed,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true))),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Tip: Get coordinates from Google Maps → Long press a location → copy lat/lng',
                style: TextStyle(color: AppColors.textDim, fontSize: 11),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      provider.status == ListingStatus.loading ? null : _submit,
                  child: provider.status == ListingStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: AppColors.navy, strokeWidth: 2))
                      : Text(isEditing ? 'Save Changes' : 'Create Listing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon, color: AppColors.textDim) : null,
        alignLabelWithHint: maxLines > 1,
      ),
      validator: required
          ? (v) => v == null || v.isEmpty ? 'This field is required' : null
          : null,
    );
  }
}
