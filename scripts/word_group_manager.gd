class_name LetterWordGroupManager extends Node

@onready var world_group_scene = preload("res://scenes/word_group.tscn")

enum LetterState {
	FLOATING,
	SNAPPED
}

@export var letter_rb: RigidBody2D
@export var LWD: Node2D

var word_group: WordGroup
var state: LetterState = LetterState.FLOATING

var callable_action: Callable

func _ready() -> void:
	LWD.candidate_found.connect(_on_candidate_found)

func _on_candidate_found(target):
	if target is Letter:
		callable_action = Callable(self, "snap_to_letter").bind(target)
	elif target is WordGroup:
		callable_action = Callable(self, "snap_to_word").bind(target)
	else:
		callable_action = Callable()

func snap_to_group(group: WordGroup, slot_index: int):
	letter_rb.freeze = true
	word_group = group
	state = LetterState.SNAPPED
	group.add_letter(letter_rb, slot_index)

func detach_from_group():
	if word_group:
		word_group.remove_letter(letter_rb)
	word_group = null
	letter_rb.freeze = false
	state = LetterState.FLOATING

func snap_to_letter(other: Letter):
	# create a new WordGroup if neither has one
	if not word_group and not other.WGM.word_group:
		var group = world_group_scene.instantiate()
		get_tree().root.add_child(group)

		# set group position to this letter’s position (anchor)
		group.global_position = other.global_position

		# now snap both letters into the group
		snap_to_group(group, 0)
		other.WGM.snap_to_group(group, 1)

	# join existing group if other is already in one
	elif not word_group and other.WGM.word_group:
		#other.WGM.word_group.add_letter(letter_rb, other.slot_index + 1)
		var slot_index = other.WGM.word_group.get_nearest_slot_index(letter_rb.global_position)
		snap_to_group(other.WGM.word_group, slot_index)

	# merge two groups (we need this?)
	#elif word_group and other.word_group and word_group != other.word_group:
		#word_group.merge_group(other.word_group)
	
func _snap_to_word(group: WordGroup):
	var slot_index = group.get_nearest_slot_index(letter_rb.global_position)
	snap_to_group(group, slot_index)

func _on_letter_letter_released(letter: Variant) -> void:
	if callable_action.is_valid():
		callable_action.call()
	
	# This is made for make letters not collide when in a group
	# It should not work but it works :p
	letter_rb.collision_mask = 1


func _on_letter_letter_dragged(letter: Variant) -> void:
	# This is made for make letters not collide when in a group
	# It should not work but it works :p
	letter_rb.collision_mask = 0
