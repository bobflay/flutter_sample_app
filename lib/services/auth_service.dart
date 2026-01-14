import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/employee.dart';

class AuthService {
  static const String _employeeKey = 'current_employee';

  // Mock employee data for demonstration
  static final List<Employee> _mockEmployees = [
    Employee(
      id: '1',
      name: 'John Smith',
      email: 'john.smith@company.com',
      department: 'Engineering',
    ),
    Employee(
      id: '2',
      name: 'Jane Doe',
      email: 'jane.doe@company.com',
      department: 'Marketing',
    ),
    Employee(
      id: '3',
      name: 'Bob Johnson',
      email: 'bob.johnson@company.com',
      department: 'Sales',
    ),
  ];

  Future<Employee?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock authentication - in production, this would call an API
    // For demo purposes, any password works with valid emails
    final employee = _mockEmployees.firstWhere(
      (e) => e.email.toLowerCase() == email.toLowerCase(),
      orElse: () => Employee(id: '', name: '', email: '', department: ''),
    );

    if (employee.id.isEmpty) {
      return null;
    }

    // Store employee in shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_employeeKey, jsonEncode(employee.toJson()));

    return employee;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_employeeKey);
  }

  Future<Employee?> getCurrentEmployee() async {
    final prefs = await SharedPreferences.getInstance();
    final employeeJson = prefs.getString(_employeeKey);

    if (employeeJson == null) {
      return null;
    }

    return Employee.fromJson(jsonDecode(employeeJson));
  }

  Future<bool> isLoggedIn() async {
    final employee = await getCurrentEmployee();
    return employee != null;
  }
}
