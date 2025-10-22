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
var candidate_target = null

func _ready() -> void:
	LWD.candidate_found.connect(_on_candidate_found)

func _process(delta: float) -> void:
	if candidate_target is WordGroup:
		candidate_target.show_preview_at_index(candidate_target.get_nearest_slot_index(letter_rb.global_position))
	
func _on_candidate_found(target):
	if !target:
		candidate_target = null
		return
	
	if target is not Letter: return
	
	if !target.WGM.word_group:
		candidate_target = target
	else:
		candidate_target = target.WGM.word_group

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
	var group = world_group_scene.instantiate()
	get_tree().root.add_child(group)

	# set group position to this letter’s position (anchor)
	group.global_position = other.global_position

	# now snap both letters into the group
	snap_to_group(group, 0)
	other.WGM.snap_to_group(group, 1)

	# merge two groups (we need this?)
	#elif word_group and other.word_group and word_group != other.word_group:
		#word_group.merge_group(other.word_group)
	
func _snap_to_word(group: WordGroup):
	var slot_index = group.get_nearest_slot_index(letter_rb.global_position)
	snap_to_group(group, slot_index)

func _on_letter_released(letter: Variant) -> void:
	if !candidate_target:
		if word_group:
			detach_from_group()
		return
	
	if candidate_target is WordGroup:
		_snap_to_word(candidate_target)
		candidate_target.show_preview_at_index()
		candidate_target = null
	else:
		snap_to_letter(candidate_target)
	
	# This is made for make letters not collide when in a group
	# It should not work but it works :p
	letter_rb.collision_mask = 1


func _on_letter_dragged(letter: Variant) -> void:
	# This is made for make letters not collide when in a group
	# It should not work but it works :p
	letter_rb.collision_mask = 0
	
	if word_group:
		detach_from_group()
