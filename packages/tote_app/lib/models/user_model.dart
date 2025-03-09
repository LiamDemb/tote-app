class UserModel {
  final String id;
  final String email;
  final String? firebaseUid;
  final String? firstName;
  final String? lastName;
  final String? authProvider;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? preferences;

  UserModel({
    required this.id,
    required this.email,
    this.firebaseUid,
    this.firstName,
    this.lastName,
    this.authProvider,
    required this.createdAt,
    required this.updatedAt,
    this.preferences,
  });

  // Create a UserModel from JSON data
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      firebaseUid: json['firebaseUid'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      authProvider: json['authProvider'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      preferences: json['preferences'] != null 
          ? Map<String, dynamic>.from(json['preferences']) 
          : null,
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firebaseUid': firebaseUid,
      'firstName': firstName,
      'lastName': lastName,
      'authProvider': authProvider,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'preferences': preferences,
    };
  }

  // Get full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return email.split('@').first; // Use email username as fallback
    }
  }

  // Create a copy of this UserModel with some updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? firebaseUid,
    String? firstName,
    String? lastName,
    String? authProvider,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      authProvider: authProvider ?? this.authProvider,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
    );
  }
} 