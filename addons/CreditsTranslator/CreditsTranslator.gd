@tool
extends EditorPlugin


const CreditsTranslationPlugin = preload("res://addons/CreditsTranslator/CreditsTranslationPlugin.gd")
var credits_translation_plugin = CreditsTranslationPlugin.new()

func _enable_plugin() -> void:
	add_translation_parser_plugin(credits_translation_plugin)


func _disable_plugin() -> void:
	remove_translation_parser_plugin(credits_translation_plugin)


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
