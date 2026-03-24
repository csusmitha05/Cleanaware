class IssueModel {
  final String id;
  final String userId;
  final String description;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final String imageBase64;
  final DateTime timestamp;
  final String status;

  IssueModel({
    required this.id,
    required this.userId,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.imageBase64,
    required this.timestamp,
    required this.status,
  });

  bool get hasImage => imageUrl.isNotEmpty || imageBase64.isNotEmpty;

  factory IssueModel.fromMap(String id, Map<String, dynamic> map) {
    return IssueModel(
      id: id,
      userId: map['userId'] ?? '',
      description: map['description'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      imageUrl: map['imageURL'] ?? '',
      imageBase64: map['imageBase64'] ?? '',
      timestamp: (map['timestamp'] as dynamic).toDate(),
      status: map['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'imageURL': imageUrl,
      'imageBase64': imageBase64,
      'timestamp': timestamp,
      'status': status,
    };
  }
}
