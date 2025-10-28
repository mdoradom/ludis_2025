# Audio Assets and Licenses

This document lists all audio assets used in the game and their respective licenses.

## Sound Effects

### UI Sounds

- **switch_006.ogg** - Used for button clicks and UI interactions
  - Source: [Kenney.nl UI Audio Pack](https://www.kenney.nl/assets/interface-sounds)
  - License: CC0 1.0 Universal (Public Domain)
  - Usage: Button clicks, menu navigation

- **confirmation_004.ogg** - Used for confirmation sounds and positive feedback
  - Source: [Kenney.nl UI Audio Pack](https://www.kenney.nl/assets/interface-sounds)
  - License: CC0 1.0 Universal (Public Domain)
  - Usage: Word completion, successful actions, positive feedback

### Game Sounds

- **letter_snap_1.wav** - First letter snap sound (derived from letter_snap.wav)
  - Source: Derived from [Freesound - KVV_Audio](https://freesound.org/s/830221/)
  - License: Attribution 4.0 International (CC BY 4.0)
  - Usage: Letter snapping mechanics - variant 1
  - Author: KVV_Audio (original), Modified for game use
  - Attribution: "SPRTIndor_Billiard Cue Ball Strike 01_KVV AUDIO_FREE by KVV_Audio"

- **letter_snap_2.wav** - Second letter snap sound (derived from letter_snap.wav)
  - Source: Derived from [Freesound - KVV_Audio](https://freesound.org/s/830221/)
  - License: Attribution 4.0 International (CC BY 4.0)
  - Usage: Letter snapping mechanics - variant 2
  - Author: KVV_Audio (original), Modified for game use
  - Attribution: "SPRTIndor_Billiard Cue Ball Strike 01_KVV AUDIO_FREE by KVV_Audio"

### Sticker Book Sounds

- **sfx_stickerripper_foil_05.wav** - Sticker placement sound
  - Source: [Freesound - MrFossy](https://freesound.org/people/MrFossy/sounds/590323/)
  - License: CC0 1.0 Universal (Public Domain)
  - Usage: Sticker book interactions, placing stickers
  - Author: MrFossy

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
The Creative Commons CC0 Public Domain Dedication waives copyright interest in a work you've created and dedicates it to the world-wide public domain.

**What this means for our project:**
- These assets can be used for any purpose, including commercial use
- No attribution is required (though appreciated)
- Assets can be modified, distributed, and used without restrictions

### Attribution 4.0 International (CC BY 4.0)
This license allows reusers to distribute, remix, adapt, and build upon the material in any medium or format, so long as attribution is given to the creator.

**What this means for our project:**
- These assets can be used for any purpose, including commercial use
- Attribution is required and must be clearly visible
- Assets can be modified and distributed with proper credit


### Source Attribution
We acknowledge the following creators:
- **Kenney Vleugels** (kenney.nl) for providing high-quality, free game assets to the community
- **MrFossy** (Freesound.org) for contributing sticker sound effects to the public domain
- **KVV_Audio** (Freesound.org) for the letter snap sound effect under CC BY 4.0


## Audio File Locations
```
assets/
└── audio/
    ├── effects/
    │   ├── switch_006.ogg
    │   ├── confirmation_004.ogg
    │   ├── sfx_stickerripper_foil_05.wav
    │   └── letter_snap_1.wav
    │   └── letter_snap_2.wav
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
