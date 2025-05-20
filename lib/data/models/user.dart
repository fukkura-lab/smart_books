class User {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final String? phone;
  final String? businessType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final String subscriptionStatus;
  final DateTime? subscriptionEndDate;
  
  User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.phone,
    this.businessType,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    required this.subscriptionStatus,
    this.subscriptionEndDate,
  });
  
  // JSONからUserモデルを作成
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      phone: json['phone'],
      businessType: json['business_type'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
      subscriptionStatus: json['subscription_status'] ?? 'free',
      subscriptionEndDate: json['subscription_end_date'] != null 
        ? DateTime.parse(json['subscription_end_date']) 
        : null,
    );
  }
  
  // UserモデルをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'business_type': businessType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'subscription_status': subscriptionStatus,
      'subscription_end_date': subscriptionEndDate?.toIso8601String(),
    };
  }
  
  // コピーコンストラクタ
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    String? phone,
    String? businessType,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    String? subscriptionStatus,
    DateTime? subscriptionEndDate,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      businessType: businessType ?? this.businessType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
    );
  }
  
  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, fullName: $fullName, '
        'phone: $phone, businessType: $businessType, createdAt: $createdAt, '
        'updatedAt: $updatedAt, lastLogin: $lastLogin, '
        'subscriptionStatus: $subscriptionStatus, subscriptionEndDate: $subscriptionEndDate)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.username == username &&
        other.email == email;
  }
  
  @override
  int get hashCode => id.hashCode ^ username.hashCode ^ email.hashCode;
}

// トークンの情報を保持するモデル
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  
  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });
  
  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresAt: DateTime.now().add(Duration(seconds: json['expires_in'])),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
    };
  }
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
