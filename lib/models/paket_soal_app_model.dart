import 'package:cloud_firestore/cloud_firestore.dart';

class PaketSoalApp {
  final String title;
  final Timestamp createdAt;
  final String? matematikaPackageId;
  final String? indonesiaPackageId;

  PaketSoalApp({
    required this.title,
    required this.createdAt,
    this.matematikaPackageId,
    this.indonesiaPackageId,
  });

  factory PaketSoalApp.fromJson(Map<String, dynamic> json) {
    return PaketSoalApp(
      title: json['title'] as String,
      createdAt: json['createdAt'] as Timestamp,
      matematikaPackageId: json['matematikaPackageId'] as String?,
      indonesiaPackageId: json['indonesiaPackageId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'createdAt': createdAt,
      'matematikaPackageId': matematikaPackageId,
      'indonesiaPackageId': indonesiaPackageId,
    };
  }
}
