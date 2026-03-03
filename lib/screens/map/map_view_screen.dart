import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/listing_provider.dart';
import '../../theme.dart';
import '../detail/listing_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  // Kigali city center
  static const _kigaliCenter = LatLng(-1.9441, 30.0619);

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingProvider>().allListings;

    final markers = listings.map((l) {
      return Marker(
        markerId: MarkerId(l.id),
        position: LatLng(l.latitude, l.longitude),
        infoWindow: InfoWindow(
          title: l.name,
          snippet: l.category,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: l)),
          ),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );
    }).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColors.gold),
            onPressed: () => _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(_kigaliCenter, 13),
            ),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition:
            const CameraPosition(target: _kigaliCenter, zoom: 13),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        onMapCreated: (c) => _mapController = c,
      ),
    );
  }
}
