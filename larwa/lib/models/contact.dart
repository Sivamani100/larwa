// lib/models/contact.dart

class Contact {
  final String id;
  final String phone;
  final String name;
  final bool isVip;
  final String? notes;
  final DateTime createdAt;

  const Contact({
    required this.id,
    required this.phone,
    required this.name,
    this.isVip = false,
    this.notes,
    required this.createdAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        id: json['id'] ?? '',
        phone: json['phone'] ?? '',
        name: json['name'] ?? '',
        isVip: json['is_vip'] ?? false,
        notes: json['notes'],
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'name': name,
        'is_vip': isVip,
        'notes': notes,
      };
}
