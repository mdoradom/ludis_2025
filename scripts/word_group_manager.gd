class_name LetterWordGroupManager extends Node

enum LetterState {
	FLOATING,
	SNAPPED
}

@export var letter_rb: RigidBody2D

var word_group: WordGroup
var state: LetterState = LetterState.FLOATING

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
