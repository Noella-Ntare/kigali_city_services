import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class ListingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'listings';

  // Stream all listings (real-time)
  Stream<List<ListingModel>> getAllListings() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => ListingModel.fromFirestore(doc)).toList());
  }

  // Stream listings by current user (real-time)
  Stream<List<ListingModel>> getMyListings(String uid) {
    return _db
        .collection(_collection)
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => ListingModel.fromFirestore(doc)).toList());
  }

  // Create listing
  Future<void> createListing(ListingModel listing) async {
    await _db.collection(_collection).add(listing.toFirestore());
  }

  // Update listing
  Future<void> updateListing(ListingModel listing) async {
    await _db
        .collection(_collection)
        .doc(listing.id)
        .update(listing.toFirestore());
  }

  // Delete listing
  Future<void> deleteListing(String listingId) async {
    await _db.collection(_collection).doc(listingId).delete();
  }
}
