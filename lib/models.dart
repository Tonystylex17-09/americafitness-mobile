class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String phone;
  final String role;
  final int totalPoints;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.totalPoints,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'],
      totalPoints: json['total_points'] ?? 0,
    );
  }
}

class Gym {
  final int id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? email;

  Gym({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'] != null ? json['latitude'].toDouble() : null,
      longitude: json['longitude'] != null ? json['longitude'].toDouble() : null,
      phone: json['phone'],
      email: json['email'],
    );
  }
}

class CheckIn {
  final int id;
  final int gymId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;

  CheckIn({
    required this.id,
    required this.gymId,
    required this.checkInTime,
    this.checkOutTime,
  });

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['id'],
      gymId: json['gym_id'],
      checkInTime: DateTime.parse(json['check_in_time']),
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'])
          : null,
    );
  }
}

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int? pointsPrice;
  final String? imageUrl;
  final int stock;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.pointsPrice,
    this.imageUrl,
    required this.stock,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: json['price'].toDouble(),
      pointsPrice: json['points_price'],
      imageUrl: json['image_url'],
      stock: json['stock'],
      category: json['category'],
    );
  }
}

class CartItemModel {
  final int id;
  final int productId;
  final String name;
  final double price;
  final int? pointsPrice;
  final String? imageUrl;
  int quantity;
  double subtotal;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    this.pointsPrice,
    this.imageUrl,
    required this.quantity,
    required this.subtotal,
  });
}
