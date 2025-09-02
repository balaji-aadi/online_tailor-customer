enum ServiceType { readymade, custom, alterations }

enum OrderStatus { placed, accepted, inProgress, shipped, delivered }

enum AttireType { thobe, kandura, abaya, jalabiya, bisht, other }

enum AlterationType { hem, resize, embroidery, repair, fitting }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String preferredLanguage;
  final List<String> addresses;
  final List<String> favoriteTailorIds;
  final String dateOfBirth;
  final String city;
  final String age;
  final String address;
  final String? gender;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.preferredLanguage = 'en',
    this.addresses = const [],
    this.favoriteTailorIds = const [],
    this.dateOfBirth = '',
    this.city = '',
    this.age = '',
    this.address = '',
    this.gender = "",
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'profileImage': profileImage,
        'preferredLanguage': preferredLanguage,
        'addresses': addresses,
        'favoriteTailorIds': favoriteTailorIds,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        profileImage: json['profileImage'],
        preferredLanguage: json['preferredLanguage'] ?? 'en',
        addresses: List<String>.from(json['addresses'] ?? []),
        favoriteTailorIds: List<String>.from(json['favoriteTailorIds'] ?? []),
      );
}

class Tailor {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final String profileImage;
  final String location;
  final String locationAr;
  final double rating;
  final int reviewCount;
  final List<ServiceType> services;
  final List<AttireType> specialties;
  final double priceFrom;
  final double priceTo;
  final List<String> gallery;
  final bool isOnline;

  Tailor({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.profileImage,
    required this.location,
    required this.locationAr,
    required this.rating,
    required this.reviewCount,
    required this.services,
    required this.specialties,
    required this.priceFrom,
    required this.priceTo,
    this.gallery = const [],
    this.isOnline = true,
  });
}

class TailorService {
  final String id;
  final String tailorId;
  final ServiceType type;
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  final double price;
  final String? imageUrl;
  final List<AttireType> attireTypes;
  final int estimatedDays;

  TailorService({
    required this.id,
    required this.tailorId,
    required this.type,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.price,
    this.imageUrl,
    required this.attireTypes,
    required this.estimatedDays,
  });
}

class Measurement {
  final String id;
  final String name;
  final String nameAr;
  final Map<String, double> measurements;
  final DateTime createdAt;
  final String? notes;
  final String? notesAr;

  Measurement({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.measurements,
    required this.createdAt,
    this.notes,
    this.notesAr,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameAr': nameAr,
        'measurements': measurements,
        'createdAt': createdAt.toIso8601String(),
        'notes': notes,
        'notesAr': notesAr,
      };

  factory Measurement.fromJson(Map<String, dynamic> json) => Measurement(
        id: json['id'],
        name: json['name'],
        nameAr: json['nameAr'],
        measurements: Map<String, double>.from(json['measurements']),
        createdAt: DateTime.parse(json['createdAt']),
        notes: json['notes'],
        notesAr: json['notesAr'],
      );
}

class Order {
  final String id;
  final String userId;
  final String tailorId;
  final String tailorName;
  final String tailorNameAr;
  final ServiceType serviceType;
  final String serviceTitle;
  final String serviceTitleAr;
  final OrderStatus status;
  final double totalAmount;
  final String? measurementId;
  final String? customRequirements;
  final String? customRequirementsAr;
  final List<String> referenceImages;
  final String deliveryAddress;
  final DateTime orderDate;
  final DateTime? estimatedDelivery;
  final List<OrderStatusUpdate> statusUpdates;

  Order({
    required this.id,
    required this.userId,
    required this.tailorId,
    required this.tailorName,
    required this.tailorNameAr,
    required this.serviceType,
    required this.serviceTitle,
    required this.serviceTitleAr,
    required this.status,
    required this.totalAmount,
    this.measurementId,
    this.customRequirements,
    this.customRequirementsAr,
    this.referenceImages = const [],
    required this.deliveryAddress,
    required this.orderDate,
    this.estimatedDelivery,
    this.statusUpdates = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'tailorId': tailorId,
        'tailorName': tailorName,
        'tailorNameAr': tailorNameAr,
        'serviceType': serviceType.name,
        'serviceTitle': serviceTitle,
        'serviceTitleAr': serviceTitleAr,
        'status': status.name,
        'totalAmount': totalAmount,
        'measurementId': measurementId,
        'customRequirements': customRequirements,
        'customRequirementsAr': customRequirementsAr,
        'referenceImages': referenceImages,
        'deliveryAddress': deliveryAddress,
        'orderDate': orderDate.toIso8601String(),
        'estimatedDelivery': estimatedDelivery?.toIso8601String(),
        'statusUpdates': statusUpdates.map((e) => e.toJson()).toList(),
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        userId: json['userId'],
        tailorId: json['tailorId'],
        tailorName: json['tailorName'],
        tailorNameAr: json['tailorNameAr'],
        serviceType: ServiceType.values.byName(json['serviceType']),
        serviceTitle: json['serviceTitle'],
        serviceTitleAr: json['serviceTitleAr'],
        status: OrderStatus.values.byName(json['status']),
        totalAmount: json['totalAmount'].toDouble(),
        measurementId: json['measurementId'],
        customRequirements: json['customRequirements'],
        customRequirementsAr: json['customRequirementsAr'],
        referenceImages: List<String>.from(json['referenceImages'] ?? []),
        deliveryAddress: json['deliveryAddress'],
        orderDate: DateTime.parse(json['orderDate']),
        estimatedDelivery:
            json['estimatedDelivery'] != null ? DateTime.parse(json['estimatedDelivery']) : null,
        statusUpdates:
            (json['statusUpdates'] as List?)?.map((e) => OrderStatusUpdate.fromJson(e)).toList() ??
                [],
      );
}

class OrderStatusUpdate {
  final OrderStatus status;
  final String message;
  final String messageAr;
  final DateTime timestamp;

  OrderStatusUpdate({
    required this.status,
    required this.message,
    required this.messageAr,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'message': message,
        'messageAr': messageAr,
        'timestamp': timestamp.toIso8601String(),
      };

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) => OrderStatusUpdate(
        status: OrderStatus.values.byName(json['status']),
        message: json['message'],
        messageAr: json['messageAr'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class ChatMessage {
  final String id;
  final String orderId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isFromTailor;
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isFromTailor,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'senderId': senderId,
        'senderName': senderName,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'isFromTailor': isFromTailor,
        'imageUrl': imageUrl,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'],
        orderId: json['orderId'],
        senderId: json['senderId'],
        senderName: json['senderName'],
        message: json['message'],
        timestamp: DateTime.parse(json['timestamp']),
        isFromTailor: json['isFromTailor'],
        imageUrl: json['imageUrl'],
      );
}
