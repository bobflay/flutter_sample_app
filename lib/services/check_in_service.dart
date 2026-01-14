import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/check_in_record.dart';

class CheckInService {
  static const String _recordsKey = 'check_in_records';

  Future<List<CheckInRecord>> getRecords(String employeeId) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getString(_recordsKey);

    if (recordsJson == null) {
      return [];
    }

    final List<dynamic> recordsList = jsonDecode(recordsJson);
    return recordsList
        .map((json) => CheckInRecord.fromJson(json))
        .where((record) => record.employeeId == employeeId)
        .toList()
      ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
  }

  Future<CheckInRecord?> getActiveCheckIn(String employeeId) async {
    final records = await getRecords(employeeId);
    try {
      return records.firstWhere((r) => !r.isCheckedOut);
    } catch (_) {
      return null;
    }
  }

  Future<CheckInRecord> checkIn(String employeeId, {String? notes}) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getString(_recordsKey);

    List<Map<String, dynamic>> recordsList = [];
    if (recordsJson != null) {
      recordsList = List<Map<String, dynamic>>.from(jsonDecode(recordsJson));
    }

    final newRecord = CheckInRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: employeeId,
      checkInTime: DateTime.now(),
      notes: notes,
    );

    recordsList.add(newRecord.toJson());
    await prefs.setString(_recordsKey, jsonEncode(recordsList));

    return newRecord;
  }

  Future<CheckInRecord> checkOut(String recordId) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getString(_recordsKey);

    if (recordsJson == null) {
      throw Exception('No records found');
    }

    List<Map<String, dynamic>> recordsList =
        List<Map<String, dynamic>>.from(jsonDecode(recordsJson));

    final index = recordsList.indexWhere((r) => r['id'] == recordId);
    if (index == -1) {
      throw Exception('Record not found');
    }

    final record = CheckInRecord.fromJson(recordsList[index]);
    final updatedRecord = record.copyWith(checkOutTime: DateTime.now());

    recordsList[index] = updatedRecord.toJson();
    await prefs.setString(_recordsKey, jsonEncode(recordsList));

    return updatedRecord;
  }

  Future<List<CheckInRecord>> getTodayRecords(String employeeId) async {
    final records = await getRecords(employeeId);
    final today = DateTime.now();
    return records.where((r) {
      return r.checkInTime.year == today.year &&
          r.checkInTime.month == today.month &&
          r.checkInTime.day == today.day;
    }).toList();
  }
}
