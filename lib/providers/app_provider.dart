import 'package:flutter/foundation.dart';

import '../models/check_in_record.dart';
import '../models/employee.dart';
import '../services/auth_service.dart';
import '../services/check_in_service.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final CheckInService _checkInService = CheckInService();

  Employee? _currentEmployee;
  CheckInRecord? _activeCheckIn;
  List<CheckInRecord> _checkInHistory = [];
  bool _isLoading = false;
  String? _error;

  Employee? get currentEmployee => _currentEmployee;
  CheckInRecord? get activeCheckIn => _activeCheckIn;
  List<CheckInRecord> get checkInHistory => _checkInHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCheckedIn => _activeCheckIn != null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentEmployee = await _authService.getCurrentEmployee();
      if (_currentEmployee != null) {
        await _loadCheckInData();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentEmployee = await _authService.login(email, password);
      if (_currentEmployee != null) {
        await _loadCheckInData();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _currentEmployee = null;
    _activeCheckIn = null;
    _checkInHistory = [];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadCheckInData() async {
    if (_currentEmployee == null) return;

    _activeCheckIn =
        await _checkInService.getActiveCheckIn(_currentEmployee!.id);
    _checkInHistory = await _checkInService.getRecords(_currentEmployee!.id);
  }

  Future<void> checkIn({String? notes}) async {
    if (_currentEmployee == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _activeCheckIn = await _checkInService.checkIn(
        _currentEmployee!.id,
        notes: notes,
      );
      _checkInHistory = await _checkInService.getRecords(_currentEmployee!.id);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkOut() async {
    if (_activeCheckIn == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _checkInService.checkOut(_activeCheckIn!.id);
      _activeCheckIn = null;
      if (_currentEmployee != null) {
        _checkInHistory =
            await _checkInService.getRecords(_currentEmployee!.id);
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _loadCheckInData();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
