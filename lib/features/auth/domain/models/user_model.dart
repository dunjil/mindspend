class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final String subscriptionStatus; // 'free', 'trial', 'premium'
  final DateTime? subscriptionExpiresAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.subscriptionStatus = 'free',
    this.subscriptionExpiresAt,
  });

  bool get isPremium =>
      subscriptionStatus == 'premium' || subscriptionStatus == 'trial';

  bool get isTrialActive {
    if (subscriptionStatus != 'trial') return false;
    if (subscriptionExpiresAt == null) return false;
    return DateTime.now().isBefore(subscriptionExpiresAt!);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'created_at': createdAt.millisecondsSinceEpoch,
      'subscription_status': subscriptionStatus,
      'subscription_expires_at': subscriptionExpiresAt?.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      displayName: map['display_name'],
      photoUrl: map['photo_url'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      subscriptionStatus: map['subscription_status'] ?? 'free',
      subscriptionExpiresAt: map['subscription_expires_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['subscription_expires_at'])
          : null,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    String? subscriptionStatus,
    DateTime? subscriptionExpiresAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
    );
  }
}
