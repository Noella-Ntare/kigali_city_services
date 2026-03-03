import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/listing_model.dart';
import '../../theme.dart';
import 'listing_form_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingProvider>();
    final uid = context.read<AuthProvider>().firebaseUser?.uid ?? '';
    final listings = provider.myListings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navy,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ListingFormScreen(createdBy: uid)),
        ),
        child: const Icon(Icons.add),
      ),
      body: listings.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_location_alt_outlined,
                      color: AppColors.textDim, size: 56),
                  SizedBox(height: 12),
                  Text('No listings yet',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Tap + to add your first listing',
                      style: TextStyle(
                          color: AppColors.textDim, fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listings.length,
              itemBuilder: (_, i) =>
                  _MyListingCard(listing: listings[i], uid: uid),
            ),
    );
  }
}

class _MyListingCard extends StatelessWidget {
  final ListingModel listing;
  final String uid;
  const _MyListingCard({required this.listing, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.gold.withOpacity(0.3)),
                  ),
                  child: Text(listing.category,
                      style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.textMuted, size: 18),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingFormScreen(
                          existingListing: listing, createdBy: uid),
                    ),
                  ),
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 18),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(listing.name,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
            const SizedBox(height: 4),
            Text(listing.address,
                style: const TextStyle(
                    color: AppColors.textDim, fontSize: 12)),
            const SizedBox(height: 4),
            Text(listing.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.navyCard,
        title: const Text('Delete Listing',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Delete "${listing.name}"? This cannot be undone.',
            style: const TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ListingProvider>().deleteListing(listing.id);
    }
  }
}
