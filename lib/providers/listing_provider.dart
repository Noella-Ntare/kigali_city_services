import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/listing_model.dart';
import '../services/listing_service.dart';

enum ListingStatus { initial, loading, success, error }

class ListingProvider extends ChangeNotifier {
  final ListingService _service;
  bool _isDisposed = false;

  ListingProvider(this._service);

  List<ListingModel> _allListings = [];
  List<ListingModel> _myListings = [];
  ListingStatus _status = ListingStatus.initial;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  StreamSubscription<List<ListingModel>>? _allSub;
  StreamSubscription<List<ListingModel>>? _mySub;

  List<ListingModel> get allListings => _filteredListings();
  List<ListingModel> get myListings => _myListings;
  ListingStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<ListingModel> _filteredListings() {
    return _allListings.where((l) {
      final matchCategory =
          _selectedCategory == 'All' || l.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          l.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void subscribeToAllListings() {
    _allSub?.cancel();
    _allSub = null;
    _status = ListingStatus.loading;
    notifyListeners();

    _allSub = _service.getAllListings().listen(
      (listings) {
        if (_isDisposed) return;
        _allListings = listings;
        _status = ListingStatus.success;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        if (_isDisposed) return;
        _errorMessage = 'Failed to load listings: $e';
        _status = ListingStatus.error;
        notifyListeners();
      },
    );
  }

  void subscribeToMyListings(String uid) {
    _mySub?.cancel();
    _mySub = null;

    _mySub = _service.getMyListings(uid).listen(
      (listings) {
        if (_isDisposed) return;
        _myListings = listings;
        notifyListeners();
      },
      onError: (e) {
        if (_isDisposed) return;
        _errorMessage = 'Failed to load your listings: $e';
        notifyListeners();
      },
    );
  }

  Future<void> createListing(ListingModel listing) async {
    _errorMessage = null;
    try {
      await _service.createListing(listing);
      // Stream will automatically update _allListings via subscription
    } catch (e) {
      _errorMessage = 'Failed to create listing: $e';
      _status = ListingStatus.error;
      notifyListeners();
    }
  }

  Future<void> updateListing(ListingModel listing) async {
    _errorMessage = null;
    try {
      await _service.updateListing(listing);
      // Stream will automatically update via subscription
    } catch (e) {
      _errorMessage = 'Failed to update listing: $e';
      _status = ListingStatus.error;
      notifyListeners();
    }
  }

  Future<void> deleteListing(String id) async {
    _errorMessage = null;
    try {
      await _service.deleteListing(id);
      // Stream will automatically update via subscription
    } catch (e) {
      _errorMessage = 'Failed to delete listing: $e';
      _status = ListingStatus.error;
      notifyListeners();
    }
  }

  void cancelSubscriptions() {
    _allSub?.cancel();
    _mySub?.cancel();
    _allSub = null;
    _mySub = null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    cancelSubscriptions();
    super.dispose();
  }
}
