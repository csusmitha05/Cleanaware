class TipModel {
  final String title;
  final String image;
  final String description;

  TipModel({
    required this.title,
    required this.image,
    required this.description,
  });

  factory TipModel.fromMap(Map<String, dynamic> map) {
    return TipModel(
      title: map['title'] ?? '',
      image: map['image'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
