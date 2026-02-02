import 'package:cloud_firestore/cloud_firestore.dart';

class PaketSoalApp {
  final String title;
  final Timestamp createdAt;
  // final String packageId;

  PaketSoalApp({
    required this.title,
    required this.createdAt,
    // required this.packageId,
  });

  factory PaketSoalApp.fromJson(Map<String, dynamic> json) {
    return PaketSoalApp(
      title: json['title'] as String,
      createdAt: json['createdAt'] as Timestamp,
      // packageId: json['packageId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'createdAt': createdAt,
      // 'packageId': packageId,
    };
  }
}
