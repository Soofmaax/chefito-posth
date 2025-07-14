// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recognition_result.dart';

RecognizedItem _$RecognizedItemFromJson(Map<String, dynamic> json) {
  return RecognizedItem(
    name: json['name'] as String,
    confidence: (json['confidence'] as num).toDouble(),
    visualDescription: json['visual_description'] as String,
    tactileDescription: json['tactile_description'] as String,
    olfactoryDescription: json['olfactory_description'] as String,
  );
}

Map<String, dynamic> _$RecognizedItemToJson(RecognizedItem instance) => <String, dynamic>{
      'name': instance.name,
      'confidence': instance.confidence,
      'visual_description': instance.visualDescription,
      'tactile_description': instance.tactileDescription,
      'olfactory_description': instance.olfactoryDescription,
    };

RecognitionResponse _$RecognitionResponseFromJson(Map<String, dynamic> json) {
  return RecognitionResponse(
    recognizedItems: (json['recognized_items'] as List<dynamic>)
        .map((e) => RecognizedItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$RecognitionResponseToJson(RecognitionResponse instance) => <String, dynamic>{
      'recognized_items': instance.recognizedItems.map((e) => e.toJson()).toList(),
    };
