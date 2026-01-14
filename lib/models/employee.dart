class Employee {
  final String id;
  final String name;
  final String email;
  final String department;
  final String? photoUrl;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    this.photoUrl,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      department: json['department'] as String,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'photoUrl': photoUrl,
    };
  }
}
