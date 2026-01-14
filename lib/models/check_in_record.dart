class CheckInRecord {
  final String id;
  final String employeeId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String? notes;

  CheckInRecord({
    required this.id,
    required this.employeeId,
    required this.checkInTime,
    this.checkOutTime,
    this.notes,
  });

  bool get isCheckedOut => checkOutTime != null;

  Duration? get duration {
    if (checkOutTime == null) return null;
    return checkOutTime!.difference(checkInTime);
  }

  factory CheckInRecord.fromJson(Map<String, dynamic> json) {
    return CheckInRecord(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'checkInTime': checkInTime.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'notes': notes,
    };
  }

  CheckInRecord copyWith({
    String? id,
    String? employeeId,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? notes,
  }) {
    return CheckInRecord(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      notes: notes ?? this.notes,
    );
  }
}
