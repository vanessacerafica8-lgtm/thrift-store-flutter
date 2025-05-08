class Item {
  final int id;
  final String title;
  final String description;
  final double price;
  final String contactInfo;
  final String uploadedBy;
  final String uploaderEmail;
  final String imageUrl;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.contactInfo,
    required this.uploadedBy,
    required this.uploaderEmail,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Item.fromMap(Map<String, dynamic> m) => Item(
    id:             m['id'],
    title:          m['title'],
    description:    m['description'],
    price:          (m['price'] as num).toDouble(),
    contactInfo:    m['contact_info'],
    uploadedBy:     m['uploaded_by']   ?? 'Unknown',
    uploaderEmail:  m['uploader_email']?? '',
    imageUrl:       m['image_url'],
    createdAt:      DateTime.parse(m['created_at']),
  );
}
