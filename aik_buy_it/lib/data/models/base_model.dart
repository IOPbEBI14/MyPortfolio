abstract class BaseModel {
  String id;
  DateTime createdAt;
  DateTime updatedAt;
  
  BaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Map<String, dynamic> toJson();
}

