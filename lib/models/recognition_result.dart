import 'dart:io';
import 'package:json_annotation/json_annotation.dart';

part 'recognition_result.g.dart';

@JsonSerializable()
class RecognizedItem {
  final String name;
  final double confidence;
  @JsonKey(name: 'visual_description')
  final String visualDescription;
  @JsonKey(name: 'tactile_description')
  final String tactileDescription;
  @JsonKey(name: 'olfactory_description')
  final String olfactoryDescription;

  RecognizedItem({
    required this.name,
    required this.confidence,
    required this.visualDescription,
    required this.tactileDescription,
    required this.olfactoryDescription,
  });

  factory RecognizedItem.fromJson(Map<String, dynamic> json) =>
      _$RecognizedItemFromJson(json);
  Map<String, dynamic> toJson() => _$RecognizedItemToJson(this);
}

@JsonSerializable()
class RecognitionResponse {
  @JsonKey(name: 'recognized_items')
  final List<RecognizedItem> recognizedItems;

  RecognitionResponse({required this.recognizedItems});

  factory RecognitionResponse.fromJson(Map<String, dynamic> json) =>
      _$RecognitionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RecognitionResponseToJson(this);
}
