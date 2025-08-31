// information_accounts.dart
// File ini berisi informasi akun-akun yang terdaftar dalam sistem

class InformationAccounts {
  // Data akun yang terdaftar dalam sistem
  static const List<Map<String, dynamic>> accounts = [
    {
      'id': '1470',
      'email': 'amorfibakery01@gmail.com',
      'role': 'superadmin',
    },
    {
      'id': '2580',
      'email': 'amorfibakery01@gmail.com',
      'role': 'production manager',
    },
    {
      'id': '3690',
      'email': 'amorfibakery01@gmail.com',
      'role': 'ingredients manager',
    }
  ];

  // Method untuk mendapatkan informasi akun berdasarkan ID
  static Map<String, dynamic>? getAccountById(String id) {
    try {
      return accounts.firstWhere((account) => account['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Method untuk mendapatkan akun berdasarkan role
  static List<Map<String, dynamic>> getAccountsByRole(String role) {
    return accounts.where((account) => account['role'] == role).toList();
  }

  // Method untuk mendapatkan semua akun
  static List<Map<String, dynamic>> getAllAccounts() {
    return accounts;
  }
}

// Class untuk model Account
class Account {
  final String id;
  final String email;
  final String role;

  const Account({
    required this.id,
    required this.email,
    required this.role,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
    };
  }

  @override
  String toString() {
    return 'Account(id: $id, email: $email, role: $role)';
  }
}