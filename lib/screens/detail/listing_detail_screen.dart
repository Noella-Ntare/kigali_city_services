import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/listing_model.dart';
import '../../theme.dart';

class ListingDetailScreen extends StatelessWidget {
  final ListingModel listing;
  const ListingDetailScreen({super.key, required this.listing});

  Future<void> _launchNavigation() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${listing.latitude},${listing.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final latLng = LatLng(listing.latitude, listing.longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text(listing.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map with marker
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 200,
                // NOTE: Requires Google Maps API key in AndroidManifest.xml
                // See step-by-step guide for setup
                child: GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: latLng, zoom: 15),
                  markers: {
                    Marker(
                      markerId: MarkerId(listing.id),
                      position: latLng,
                      infoWindow: InfoWindow(title: listing.name),
                    ),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(listing.category,
                  style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
            const SizedBox(height: 12),

            Text(listing.name,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),

            // Info rows
            _InfoRow(icon: Icons.location_on_outlined, text: listing.address),
            _InfoRow(icon: Icons.phone_outlined, text: listing.contactNumber),
            _InfoRow(
              icon: Icons.gps_fixed,
              text:
                  '${listing.latitude.toStringAsFixed(5)}, ${listing.longitude.toStringAsFixed(5)}',
            ),
            const SizedBox(height: 16),

            // Description
            const Text('About',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
            const SizedBox(height: 8),
            Text(listing.description,
                style: const TextStyle(
                    color: AppColors.textMuted, height: 1.6, fontSize: 14)),
            const SizedBox(height: 24),

            // Navigation Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _launchNavigation,
                icon: const Icon(Icons.navigation_outlined),
                label: const Text('Get Directions'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
