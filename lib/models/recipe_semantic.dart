import 'package:json_annotation/json_annotation.dart';

part 'recipe_semantic.g.dart';

@JsonSerializable(explicitToJson: true)
class TroubleshootingTip {
  final String problem;
  final String solution;
  @JsonKey(name: 'sensory_cue')
  final String sensoryCue;

  TroubleshootingTip({
    required this.problem,
    required this.solution,
    required this.sensoryCue,
  });

  factory TroubleshootingTip.fromJson(Map<String, dynamic> json) =>
      _$TroubleshootingTipFromJson(json);
  Map<String, dynamic> toJson() => _$TroubleshootingTipToJson(this);
}

@JsonSerializable()
class Ingredient {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final String notes;

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.notes,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Instruction {
  final String id;
  final String action;
  final String details;
  @JsonKey(name: 'time_minutes')
  final int? timeMinutes;
  @JsonKey(name: 'safety_warning')
  final String? safetyWarning;
  final String priority;
  @JsonKey(name: 'ingredients_used')
  final List<String> ingredientsUsed;
  @JsonKey(name: 'utensils_used')
  final List<String> utensilsUsed;
  final List<TroubleshootingTip> troubleshooting;

  Instruction({
    required this.id,
    required this.action,
    required this.details,
    this.timeMinutes,
    this.safetyWarning,
    required this.priority,
    required this.ingredientsUsed,
    required this.utensilsUsed,
    required this.troubleshooting,
  });

  factory Instruction.fromJson(Map<String, dynamic> json) =>
      _$InstructionFromJson(json);
  Map<String, dynamic> toJson() => _$InstructionToJson(this);
}

@JsonSerializable()
class StoragePeriod {
  final int duration;
  final String instructions;

  StoragePeriod({required this.duration, required this.instructions});

  factory StoragePeriod.fromJson(Map<String, dynamic> json) =>
      _$StoragePeriodFromJson(json);
  Map<String, dynamic> toJson() => _$StoragePeriodToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StorageAndReheating {
  @JsonKey(name: 'refrigerator_storage')
  final StoragePeriod refrigeratorStorage;
  @JsonKey(name: 'freezer_storage')
  final StoragePeriod freezerStorage;
  @JsonKey(name: 'reheating_instructions')
  final String reheatingInstructions;

  StorageAndReheating({
    required this.refrigeratorStorage,
    required this.freezerStorage,
    required this.reheatingInstructions,
  });

  factory StorageAndReheating.fromJson(Map<String, dynamic> json) =>
      _$StorageAndReheatingFromJson(json);
  Map<String, dynamic> toJson() => _$StorageAndReheatingToJson(this);
}

@JsonSerializable()
class SuccessMetrics {
  @JsonKey(name: 'visual_cues')
  final String visualCues;
  @JsonKey(name: 'texture_goal')
  final String textureGoal;
  @JsonKey(name: 'flavor_profile')
  final String flavorProfile;
  @JsonKey(name: 'aroma_indicators')
  final String aromaIndicators;

  SuccessMetrics({
    required this.visualCues,
    required this.textureGoal,
    required this.flavorProfile,
    required this.aromaIndicators,
  });

  factory SuccessMetrics.fromJson(Map<String, dynamic> json) =>
      _$SuccessMetricsFromJson(json);
  Map<String, dynamic> toJson() => _$SuccessMetricsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Recipe {
  @JsonKey(name: 'recipe_id')
  final String recipeId;
  final String title;
  final String description;
  final List<Ingredient> ingredients;
  final List<Instruction> instructions;
  final List<String> variations;
  @JsonKey(name: 'chef_guidance')
  final List<String> chefGuidance;
  @JsonKey(name: 'ai_conversation_prompts')
  final List<String> aiConversationPrompts;
  @JsonKey(name: 'storage_and_reheating')
  final StorageAndReheating storageAndReheating;
  @JsonKey(name: 'common_troubleshooting')
  final List<TroubleshootingTip> commonTroubleshooting;
  @JsonKey(name: 'success_metrics')
  final SuccessMetrics successMetrics;
  @JsonKey(name: 'prep_time_minutes')
  final int? prepTimeMinutes;
  @JsonKey(name: 'cook_time_minutes')
  final int? cookTimeMinutes;
  final int? servings;
  final List<String> tags;

  Recipe({
    required this.recipeId,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.variations,
    required this.chefGuidance,
    required this.aiConversationPrompts,
    required this.storageAndReheating,
    required this.commonTroubleshooting,
    required this.successMetrics,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.servings,
    required this.tags,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AdaptedRecipeResponse {
  @JsonKey(name: 'original_recipe_id')
  final String originalRecipeId;
  @JsonKey(name: 'constraint_applied')
  final String constraintApplied;
  @JsonKey(name: 'suggested_changes_text')
  final List<String> suggestedChangesText;
  @JsonKey(name: 'adapted_recipe')
  final Recipe adaptedRecipe;

  AdaptedRecipeResponse({
    required this.originalRecipeId,
    required this.constraintApplied,
    required this.suggestedChangesText,
    required this.adaptedRecipe,
  });

  factory AdaptedRecipeResponse.fromJson(Map<String, dynamic> json) =>
      _$AdaptedRecipeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AdaptedRecipeResponseToJson(this);
}

