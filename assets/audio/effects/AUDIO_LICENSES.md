# Audio Assets and Licenses

This document lists all audio assets used in the game and their respective licenses.

## Sound Effects

### UI Sounds
- **switch_006.ogg** - Used for button clicks and UI interactions
  - Source: [Kenney.nl UI Audio Pack](https://kenney.nl/assets/ui-audio)
  - License: CC0 1.0 Universal (Public Domain)
  - Usage: Button clicks, menu navigation

### Game Sounds
- **Break Sound** - For when breakable objects are destroyed
  - Status: Not implemented
  - Planned usage: `AudioManager.SFX.BREAK_SOUND`

- **Tap Sound** - For tapping/touching objects
  - Status: Not implemented
  - Planned usage: `AudioManager.SFX.TAP_SOUND`

- **Letter Snap** - For when letters snap together
  - Status: Not implemented
  - Planned usage: `AudioManager.SFX.LETTER_SNAP`

- **Complete Word** - For successful word formation
  - Status: Not implemented
  - Planned usage: `AudioManager.SFX.COMPLETE_WORD`

### Sticker Book Sounds
- **Slide Plastic** - For page turning in sticker book
  - Status: Not implemented
  - Planned usage: `AudioManager.SFX.SLIDE_PLASTIC`

- **Stick Sticker** - For placing stickers
  - Status: Not implemented
  - Planned usage: `AudioManager.SFX.STICK_STICKER`

## Music Tracks

### Background Music
- **Main Menu Music** - Background music for main menu
  - Status: Not implemented
  - Planned usage: `AudioManager.play_music(AudioManager.MUSIC.MAIN_MENU)`

- **Gameplay Music** - Background music during gameplay
  - Status: Not implemented
  - Planned usage: `AudioManager.play_music(AudioManager.MUSIC.GAMEPLAY)`

- **Sticker Book Music** - Background music for sticker book
  - Status: Not implemented
  - Planned usage: `AudioManager.play_music(AudioManager.MUSIC.STICKER_BOOK)`

## License Information

### CC0 1.0 Universal (Public Domain)
The Creative Commons CC0 Public Domain Dedication waives copyright interest in a work you've created and dedicates it to the world-wide public domain. Use CC0 to opt out of copyright entirely and ensure your work has the widest reach.

**What this means for our project:**
- These assets can be used for any purpose, including commercial use
- No attribution is required (though appreciated)
- Assets can be modified, distributed, and used without restrictions

### Source Attribution
While not required by the CC0 license, we acknowledge:
- **Kenney Vleugels** (kenney.nl) for providing high-quality, free game assets to the community

## Audio File Locations
```
assets/
└── audio/
    ├── effects/
    │   └── switch_006.ogg
    └── music/
        └── (placeholder for future music files)
```

## Implementation Notes
- All audio is managed through the `AudioManager` autoload singleton
- Sound effects use the `AudioManager.SFX` enum for type-safe access
- Music tracks use the `AudioManager.MUSIC` enum for type-safe access
- Audio settings are saved to `user://audio_settings.cfg`
- Three audio buses: Master, Effects, and Music with independent volume controls

---

*Last updated: October 28, 2025*
*Game: Paraulina*