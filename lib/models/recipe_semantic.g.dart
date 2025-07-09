// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_semantic.dart';

TroubleshootingTip _$TroubleshootingTipFromJson(Map<String, dynamic> json) {
  return TroubleshootingTip(
    problem: json['problem'] as String,
    solution: json['solution'] as String,
    sensoryCue: json['sensory_cue'] as String,
  );
}

Map<String, dynamic> _$TroubleshootingTipToJson(TroubleshootingTip instance) =>
    <String, dynamic>{
      'problem': instance.problem,
      'solution': instance.solution,
      'sensory_cue': instance.sensoryCue,
    };

Ingredient _$IngredientFromJson(Map<String, dynamic> json) {
  return Ingredient(
    id: json['id'] as String,
    name: json['name'] as String,
    quantity: (json['quantity'] as num).toDouble(),
    unit: json['unit'] as String,
    category: json['category'] as String,
    notes: json['notes'] as String,
  );
}

Map<String, dynamic> _$IngredientToJson(Ingredient instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'category': instance.category,
      'notes': instance.notes,
    };

Instruction _$InstructionFromJson(Map<String, dynamic> json) {
  return Instruction(
    id: json['id'] as String,
    action: json['action'] as String,
    details: json['details'] as String,
    timeMinutes: json['time_minutes'] as int?,
    safetyWarning: json['safety_warning'] as String?,
    priority: json['priority'] as String,
    ingredientsUsed: (json['ingredients_used'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    utensilsUsed:
        (json['utensils_used'] as List<dynamic>).map((e) => e as String).toList(),
    troubleshooting: (json['troubleshooting'] as List<dynamic>)
        .map((e) => TroubleshootingTip.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$InstructionToJson(Instruction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'action': instance.action,
      'details': instance.details,
      'time_minutes': instance.timeMinutes,
      'safety_warning': instance.safetyWarning,
      'priority': instance.priority,
      'ingredients_used': instance.ingredientsUsed,
      'utensils_used': instance.utensilsUsed,
      'troubleshooting': instance.troubleshooting.map((e) => e.toJson()).toList(),
    };

StoragePeriod _$StoragePeriodFromJson(Map<String, dynamic> json) {
  return StoragePeriod(
    duration: json['duration'] as int,
    instructions: json['instructions'] as String,
  );
}

Map<String, dynamic> _$StoragePeriodToJson(StoragePeriod instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'instructions': instance.instructions,
    };

StorageAndReheating _$StorageAndReheatingFromJson(Map<String, dynamic> json) {
  return StorageAndReheating(
    refrigeratorStorage: StoragePeriod.fromJson(
        json['refrigerator_storage'] as Map<String, dynamic>),
    freezerStorage:
        StoragePeriod.fromJson(json['freezer_storage'] as Map<String, dynamic>),
    reheatingInstructions: json['reheating_instructions'] as String,
  );
}

Map<String, dynamic> _$StorageAndReheatingToJson(StorageAndReheating instance) =>
    <String, dynamic>{
      'refrigerator_storage': instance.refrigeratorStorage.toJson(),
      'freezer_storage': instance.freezerStorage.toJson(),
      'reheating_instructions': instance.reheatingInstructions,
    };

SuccessMetrics _$SuccessMetricsFromJson(Map<String, dynamic> json) {
  return SuccessMetrics(
    visualCues: json['visual_cues'] as String,
    textureGoal: json['texture_goal'] as String,
    flavorProfile: json['flavor_profile'] as String,
    aromaIndicators: json['aroma_indicators'] as String,
  );
}

Map<String, dynamic> _$SuccessMetricsToJson(SuccessMetrics instance) =>
    <String, dynamic>{
      'visual_cues': instance.visualCues,
      'texture_goal': instance.textureGoal,
      'flavor_profile': instance.flavorProfile,
      'aroma_indicators': instance.aromaIndicators,
    };

Recipe _$RecipeFromJson(Map<String, dynamic> json) {
  return Recipe(
    recipeId: json['recipe_id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    ingredients: (json['ingredients'] as List<dynamic>)
        .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
        .toList(),
    instructions: (json['instructions'] as List<dynamic>)
        .map((e) => Instruction.fromJson(e as Map<String, dynamic>))
        .toList(),
    variations:
        (json['variations'] as List<dynamic>).map((e) => e as String).toList(),
    chefGuidance: (json['chef_guidance'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    aiConversationPrompts: (json['ai_conversation_prompts'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    storageAndReheating: StorageAndReheating.fromJson(
        json['storage_and_reheating'] as Map<String, dynamic>),
    commonTroubleshooting: (json['common_troubleshooting'] as List<dynamic>)
        .map((e) => TroubleshootingTip.fromJson(e as Map<String, dynamic>))
        .toList(),
    successMetrics: SuccessMetrics.fromJson(
        json['success_metrics'] as Map<String, dynamic>),
    prepTimeMinutes: json['prep_time_minutes'] as int?,
    cookTimeMinutes: json['cook_time_minutes'] as int?,
    servings: json['servings'] as int?,
    tags:
        (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
      'recipe_id': instance.recipeId,
      'title': instance.title,
      'description': instance.description,
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'instructions': instance.instructions.map((e) => e.toJson()).toList(),
      'variations': instance.variations,
      'chef_guidance': instance.chefGuidance,
      'ai_conversation_prompts': instance.aiConversationPrompts,
      'storage_and_reheating': instance.storageAndReheating.toJson(),
      'common_troubleshooting':
          instance.commonTroubleshooting.map((e) => e.toJson()).toList(),
      'success_metrics': instance.successMetrics.toJson(),
      'prep_time_minutes': instance.prepTimeMinutes,
      'cook_time_minutes': instance.cookTimeMinutes,
      'servings': instance.servings,
      'tags': instance.tags,
    };

AdaptedRecipeResponse _$AdaptedRecipeResponseFromJson(Map<String, dynamic> json) {
  return AdaptedRecipeResponse(
    originalRecipeId: json['original_recipe_id'] as String,
    constraintApplied: json['constraint_applied'] as String,
    suggestedChangesText: (json['suggested_changes_text'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    adaptedRecipe:
        Recipe.fromJson(json['adapted_recipe'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$AdaptedRecipeResponseToJson(
        AdaptedRecipeResponse instance) =>
    <String, dynamic>{
      'original_recipe_id': instance.originalRecipeId,
      'constraint_applied': instance.constraintApplied,
      'suggested_changes_text': instance.suggestedChangesText,
      'adapted_recipe': instance.adaptedRecipe.toJson(),
    };

