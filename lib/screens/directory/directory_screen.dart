import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../models/listing_model.dart';
import '../../theme.dart';
import '../detail/listing_detail_screen.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kigali City',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppColors.gold, shape: BoxShape.circle),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Category pills
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', ...kCategories].map((cat) {
                final selected = provider.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => provider.setCategory(cat),
                    selectedColor: AppColors.gold,
                    backgroundColor: AppColors.navyCard,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.navy : AppColors.textMuted,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: selected ? AppColors.gold : AppColors.navyLight,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search for a service...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textDim),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.navyLight),
                ),
              ),
              onChanged: provider.setSearch,
            ),
          ),
          const SizedBox(height: 12),

          // Listings
          Expanded(child: _buildListings(context, provider)),
        ],
      ),
    );
  }

  Widget _buildListings(BuildContext context, ListingProvider provider) {
    if (provider.status == ListingStatus.loading &&
        provider.allListings.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.gold));
    }

    if (provider.status == ListingStatus.error) {
      return Center(
        child: Text(provider.errorMessage ?? 'Error loading listings',
            style: const TextStyle(color: AppColors.textMuted)),
      );
    }

    final listings = provider.allListings;

    if (listings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: AppColors.textDim, size: 48),
            SizedBox(height: 12),
            Text('No listings found',
                style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: listings.length,
      itemBuilder: (_, i) => _ListingCard(listing: listings[i]),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final ListingModel listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ListingDetailScreen(listing: listing)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                ),
                child: Icon(_categoryIcon(listing.category),
                    color: AppColors.gold, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(listing.category,
                        style: const TextStyle(
                            color: AppColors.textDim, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.gold, size: 12),
                        const SizedBox(width: 3),
                        const Text('4.3',
                            style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on_outlined,
                            color: AppColors.textDim, size: 12),
                        Text(listing.address,
                            style: const TextStyle(
                                color: AppColors.textDim, fontSize: 11),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.textDim, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Hospital':
        return Icons.local_hospital_outlined;
      case 'Police Station':
        return Icons.local_police_outlined;
      case 'Library':
        return Icons.menu_book_outlined;
      case 'Restaurant':
        return Icons.restaurant_outlined;
      case 'Café':
        return Icons.coffee_outlined;
      case 'Park':
        return Icons.park_outlined;
      case 'Tourist Attraction':
        return Icons.photo_camera_outlined;
      case 'Pharmacy':
        return Icons.medication_outlined;
      default:
        return Icons.place_outlined;
    }
  }
}
