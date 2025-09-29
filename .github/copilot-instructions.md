## Quick context

This is a small Godot (4.5) game project. The entry point is `scenes/game/main.tscn` (script: `scripts/game_manager.gd`). The repo uses Godot scenes and scripts under `scenes/` and `scripts/` and stores reusable resources in `scripts/resources/`.

## Big-picture architecture (how things connect)

- `Main` scene (`scenes/game/main.tscn`) -> `GameManager` (`scripts/game_manager.gd`) is the coordinator.
- `GameManager` builds `available_objects` (instances of `BreakableObject`, class in `scripts/resources/brekable_object.gd`) and spawns `BreakableSprite` instances from `scenes/object.tscn` (`scripts/object.gd`).
- When a `BreakableSprite` emits `broken`, `GameManager` calls `LetterManager.spawn_letters_from_object(...)`.
- `LetterManager` (class in `scripts/letter_manager.gd`) instantiates letters from `scenes/letter.tscn` (`scripts/letter.gd`) and manages the word drop area.
- When letters dropped in the bottom word area form a word that matches an entry in `available_objects`, `LetterManager` emits `word_formed`, and `GameManager` spawns the corresponding `BreakableObject`.

Signals and handshake points to watch:
- `BreakableSprite` emits `broken(object_data, position)` (`scripts/object.gd`).
- `Letter` emits `letter_dragged`, `letter_released` (used by `LetterManager`).
- `LetterManager` emits `word_formed(word, letters)` which `GameManager` listens to.

Key data flows and patterns to follow
- Game state is lightweight and mostly driven by signals rather than a central store. Follow that pattern when adding features.
- `available_objects` is a Dictionary (word -> BreakableObject instance) created in `game_manager.gd.create_available_objects()` — add new game items here or refactor to load them from a `WordDictionary` resource (`scripts/resources/word_dictionary.gd`) if you need data-driven content.
- Letters are RigidBody2D nodes used for both physics and drag tooling. `letter.gd` sets `sleeping` and `linear_velocity` during drag / release.

Developer workflows (how to run, test, debug)
- Open `project.godot` in Godot editor (4.x). Run the `Main` scene or the project to start the game.
- No automated tests or build steps are present. Use the editor's play and remote debugger. Insert `print()` statements or use Godot's debug profiler for hotspots.
- To add a new object/word: update `scripts/game_manager.gd::create_available_objects()` with a new `BreakableObject.new("WORD", "res://path.png", ["W","O","R","D"])` and set `taps_to_break`, `letter_spawn_radius`, etc.

Project-specific conventions
- Resources under `scripts/resources/` use `class_name` (e.g., `BreakableObject`, `WordDictionary`) — treat them as typed data objects.
- UI/interaction logic is in `LetterManager` (word area, arrangement, validation). Avoid duplicating word-formation logic elsewhere.
- The project currently checks valid words using `available_objects` (not `WordDictionary.is_valid_word`). If you add a dictionary resource, wire it into `LetterManager.set_available_objects()` or update `_check_current_word()` accordingly.

Common edits and examples
- Add new visual sprite: place image under repo, reference path in `BreakableObject.sprite_path`, and assign when creating the object in `create_available_objects()`.
- Adjust break difficulty: modify `taps_to_break` on the BreakableObject instance in `game_manager.gd`.
- Change word area size/position: edit `_setup_word_area()` in `scripts/letter_manager.gd` (it builds an Area2D and sets `word_area_rect`).

Notes for AI edits
- Preserve signal names and signatures (`broken`, `word_formed`, `letter_dragged`, `letter_released`) — other code depends on them.
- Keep `available_objects` as the canonical mapping for spawning words unless you also update `LetterManager._check_current_word()` to consult a new source.
- When changing physics/drag behaviour in `letter.gd`, keep the interplay of `sleeping`, `linear_velocity` and `is_dragging` consistent to avoid regressions in user dragging.

If anything here is ambiguous or you want the file to include additional examples (e.g., how to add a WordDictionary-driven workflow), tell me which area to expand and I will update this guidance.
