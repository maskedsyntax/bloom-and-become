# Bloom & Become — Game Jam Specification

## 1. Project Summary

**Game title:** Bloom & Become  
**Jam theme:** Evolution  
**Format:** 2D side-scrolling platformer  
**Target playtime:** 5–10 minutes  
**Recommended team size:** 1 developer  
**Primary goal:** Build a small, polished game where the player evolves from a weak sprout into stronger plant forms to complete a spring-themed level.

### One-Sentence Pitch
A tiny sprout collects sunlight and water to evolve through plant forms, gaining new movement abilities that help it climb, reach, and break through the world to bloom at the end of spring.

---

## 2. Recommended Tech Stack

### Recommended Engine: LÖVE / Love2D
**Language:** Lua  
**Engine:** LÖVE 11.x  
**Why this is the best choice for this project:**

- Very fast for small 2D games.
- Lua is simple and quick to iterate with.
- LÖVE has built-in drawing, input, audio, image loading, collision-friendly APIs, and packaging support.
- Less setup friction than Python/Pygame for a jam-style 2D platformer.
- Easy to keep the codebase tiny and readable.
- Works well for sprite-based and tile-based games.

### Why not Python/Pygame?
Python/Pygame is also viable, especially if the developer is more comfortable with Python. However, for a small game jam platformer, LÖVE is usually quicker because it is purpose-built around a compact game loop and simple asset loading. Pygame often needs more boilerplate for project structure, packaging, and platformer feel.

### Final Decision
Use **Lua + LÖVE** unless the developer is significantly more comfortable in Python.

---

## 3. Core Design Pillars

1. **Evolution must be visible and playable.**  
   Each evolution stage should change the player sprite and unlock a new ability.

2. **Keep the scope tiny.**  
   One short level is enough. Polish matters more than length.

3. **Assets should be reusable and minimal.**  
   Use a single tileset, one player sprite sheet or simple plant sprite variants, a few collectibles, and 2–3 obstacle types.

4. **Spring should be obvious.**  
   Use grass, flowers, sunlight, water drops, seeds, butterflies, and soft background colors.

5. **The game should be suitable for all ages.**  
   No gore, horror, offensive content, or adult themes.

---

## 4. Gameplay Overview

The player starts as a small sprout with limited movement. By collecting sunlight and water droplets, the sprout gains evolution energy. At specific thresholds, the player evolves into a new plant form. Each form unlocks a new ability required to progress through the level.

### Core Loop
1. Move and jump through a spring garden level.
2. Collect sunlight and water.
3. Fill the evolution meter.
4. Evolve into a new plant form.
5. Use the new ability to reach the next section.
6. Reach the final blooming spot and fully bloom.

---

## 5. Player Evolution Stages

### Stage 1: Sprout
**Theme:** fragile beginning  
**Visual:** tiny sprout with two leaves  
**Abilities:**
- Move left/right
- Small jump
- Collect water and sunlight

**Purpose:** Tutorial section. Teach movement and collection.

---

### Stage 2: Vine Sprout
**Theme:** adaptation and reach  
**Visual:** taller sprout with curly vine  
**New ability:** Wall climb / vine grip

**Mechanic:**
- Player can climb marked vine-friendly walls or trellises.
- Keep this simple: allow climbing only when touching special wall tiles.

**Purpose:** Unlock vertical movement.

---

### Stage 3: Bud Plant
**Theme:** preparation to bloom  
**Visual:** plant with flower bud  
**New ability:** Glide / float fall

**Mechanic:**
- Hold jump while falling to slow descent.
- This makes gaps and vertical drops more interesting without requiring many new assets.

**Purpose:** Cross wider gaps and descend safely.

---

### Stage 4: Bloom Form
**Theme:** final evolution  
**Visual:** colorful blooming flower  
**New ability:** Bloom burst

**Mechanic:**
- Press action near cracked root/stone barriers to break them.
- Could also activate final flower shrine.

**Purpose:** Final gate and satisfying ending.

---

## 6. Controls

### Keyboard
- **A / Left Arrow:** Move left
- **D / Right Arrow:** Move right
- **W / Up Arrow / Space:** Jump
- **Hold Space while falling:** Glide after Stage 3
- **E / X:** Bloom burst after Stage 4
- **R:** Restart level
- **Esc:** Quit or pause

### Gamepad Optional
Only add if time remains.

---

## 7. Level Design

### Recommended Scope
Build **one handcrafted level** split into four short sections.

### Section 1: Seedling Path
- Teaches movement and jumping.
- Low platforms.
- First collectibles.
- Ends with first evolution.

### Section 2: Trellis Climb
- Introduces climbable surfaces.
- Vertical section.
- Avoid complex hazards.
- Ends with second evolution.

### Section 3: Windy Garden Gap
- Introduces gliding.
- Wider gaps.
- Falling leaves or wind particles for atmosphere.
- Ends with third evolution.

### Section 4: Bloom Gate
- Uses bloom burst to break final obstacle.
- Player reaches a sunny clearing.
- Final bloom animation / win screen.

### Level Length Target
- Width: roughly 150–250 tiles
- Tile size: 16x16 or 32x32
- Playtime: 5–10 minutes

---

## 8. Collectibles and Progression

### Collectibles
Use only two collectible types:

1. **Sunlight Orb**
   - Yellow/gold circular icon.
   - Gives evolution energy.

2. **Water Drop**
   - Blue droplet icon.
   - Gives evolution energy.

### Evolution Meter
The player evolves after collecting enough energy.

Suggested thresholds:
- Stage 1 → Stage 2: 5 energy
- Stage 2 → Stage 3: 12 total energy
- Stage 3 → Stage 4: 20 total energy

### Simpler Alternative
Instead of a meter, place three fixed **Evolution Seeds** in the level. Each one instantly evolves the player. This is easier to balance and recommended for a 48-hour jam.

**Recommended choice:** Use fixed Evolution Seeds.

---

## 9. Obstacles and Hazards

Keep obstacle count low.

### Required Obstacles
1. **Basic gaps**
2. **Climbable trellis/vine walls**
3. **Cracked root/stone barriers**

### Optional Hazards
Only add if the core game is finished:

1. **Puddles / mud slows player**
2. **Thorn patches reset player to checkpoint**
3. **Falling petals as harmless decoration**

Avoid enemies unless there is extra time. Enemies increase animation, AI, and balancing complexity.

---

## 10. Art Direction

### Style
- 16x16 or 32x32 pixel art.
- Bright spring palette.
- Cute, readable, all-ages tone.
- Simple animations are enough.

### Visual Priorities
1. Player evolution stages must be readable.
2. Interactable objects must stand out.
3. Background should be pretty but not distracting.
4. Use particles for polish: pollen, petals, sparkle, bloom burst.

---

## 11. Required Assets

### Minimum Required Asset List

#### Player
- Sprout idle/move/jump sprite
- Vine sprout idle/move/jump/climb sprite
- Bud plant idle/move/jump/glide sprite
- Bloom form idle/move/jump/burst sprite

**Shortcut:** If sprite sheets are hard to find, use one generic plant/creature character and recolor or overlay leaves/flowers per evolution stage.

#### Environment
- Grass/dirt tileset
- Platform tiles
- Background sky or garden image
- Climbable vine/trellis tile
- Breakable cracked barrier tile

#### Items
- Sunlight orb
- Water drop
- Evolution seed

#### UI
- Evolution meter or evolution seed counter
- Simple title screen
- Win screen

#### Audio
- Jump sound
- Collect sound
- Evolve sound
- Bloom burst sound
- Short looping spring background music

---

## 12. Asset Sources

All external assets must be declared in the final jam submission. Keep a `CREDITS.md` file from the start.

### Primary Asset Sources

#### 1. itch.io Free Game Assets
Use for platformer tilesets, backgrounds, UI packs, and possibly sprites.

Suggested searches:
- `free platformer tileset spring`
- `free grass platformer tileset`
- `free plant sprite platformer`
- `free nature pixel art tileset`
- `free 2D platformer collectibles`

Useful pages:
- https://itch.io/game-assets/free/genre-platformer
- https://itch.io/game-assets/free/genre-platformer/tag-tileset
- https://itch.io/game-assets/free/tag-tileset

Important: itch.io assets have different licenses depending on the creator. Always check the asset page license before using.

#### 2. OpenGameArt
Use for CC0 or clearly licensed assets, especially tilesets and effects.

Suggested searches:
- `platformer art deluxe`
- `2D platformer tileset`
- `CC0 platformer tileset`
- `plant sprite`
- `nature platformer`

Useful pages:
- https://opengameart.org/
- https://opengameart.org/content/platformer-art-deluxe
- https://opengameart.org/content/2d-platformer-tilesets-0
- https://opengameart.org/content/cc0-resources

Prefer CC0 assets when possible because they are easiest to declare and reuse.

#### 3. Kenney Assets
Use if a clean, consistent style is needed.

Useful page:
- https://kenney.nl/assets

Suggested packs:
- Platformer pack
- Nature pack
- UI pack
- Particle pack

Kenney assets are usually very jam-friendly and consistent, but still verify the exact license for the pack used.

#### 4. Freesound
Use for audio effects.

Useful page:
- https://freesound.org/

Suggested searches:
- `jump blip`
- `collect coin soft`
- `magic sparkle`
- `plant grow`
- `spring ambience`

Important: Freesound licenses vary. Prefer CC0 sounds.

#### 5. OpenGameArt Audio
Use for CC0/Creative Commons music and sound effects.

Suggested searches:
- `spring music loop`
- `happy chiptune loop`
- `nature ambience`
- `collect sound`

---

## 13. Asset Strategy for Fast Development

### Best Practical Approach
Use a single free platformer tileset and modify the game idea around it.

Do not search for the perfect plant character. Instead:
- Use a simple placeholder rectangle first.
- Add plant sprites later.
- If no perfect plant sprite is found, draw a very simple 16x16 sprout manually or generate simple shapes in code.

### Low-Asset Player Alternative
Represent the player using simple drawn shapes in LÖVE:
- Stage 1: green stem + two leaves
- Stage 2: taller stem + vine curl
- Stage 3: stem + bud
- Stage 4: flower petals

This avoids relying on internet sprites for the most important character.

### Recommended Asset Priority
1. Tileset
2. Collectible icons
3. Player evolution visuals
4. Sound effects
5. Background music
6. UI polish

---

## 14. Required Credits File

Create `CREDITS.md` with this format:

```md
# Credits

## Code
- Game code created during the jam.
- AI assistance: ChatGPT was used for ideation, specification, and code assistance.

## Art Assets
- Asset name:
- Author:
- Source URL:
- License:
- Changes made:

## Audio Assets
- Sound/music name:
- Author:
- Source URL:
- License:
- Changes made:

## Fonts
- Font name:
- Author:
- Source URL:
- License:
```

The jam rules require premade assets and AI-generated/AI-assisted code to be declared.

---

## 15. Code Architecture

### Suggested Folder Structure

```txt
bloom-and-become/
  main.lua
  conf.lua
  README.md
  CREDITS.md
  spec.md
  assets/
    sprites/
      player/
      items/
      environment/
    audio/
      sfx/
      music/
    fonts/
  src/
    player.lua
    level.lua
    collision.lua
    camera.lua
    particles.lua
    ui.lua
    audio.lua
    states/
      title.lua
      game.lua
      win.lua
```

### Main Systems

#### Game State System
States:
- Title
- Playing
- Win
- Pause optional

#### Player System
Tracks:
- Position
- Velocity
- Grounded state
- Current evolution stage
- Unlocked abilities
- Animation state

#### Level System
Tracks:
- Tilemap
- Collision tiles
- Climbable tiles
- Breakable barriers
- Collectibles
- Evolution seeds
- Checkpoints

#### Collision System
Use simple AABB collision.

Required collision types:
- Solid tiles
- Climbable tiles
- Collectibles
- Evolution seeds
- Breakable barriers
- Win trigger

#### Camera System
Simple side-scrolling camera following player.

#### UI System
Displays:
- Current form
- Evolution progress or collected seeds
- Controls hint when a new ability unlocks

#### Audio System
Centralized sound playback:
- `playSfx("jump")`
- `playSfx("collect")`
- `playSfx("evolve")`
- `playMusic("spring_loop")`

---

## 16. Physics and Movement Feel

### Suggested Values
These should be tuned during development.

```lua
PLAYER_SPEED = 120
PLAYER_ACCEL = 900
PLAYER_FRICTION = 800
GRAVITY = 700
JUMP_VELOCITY = -260
GLIDE_GRAVITY = 180
CLIMB_SPEED = 80
```

### Movement Requirements
- Movement should feel responsive, not realistic.
- Coyote time and jump buffering are optional but recommended if time allows.
- The player should not need pixel-perfect jumps.

---

## 17. Win Condition

The player wins by reaching the final sunny clearing after unlocking Bloom Form.

### Ending Sequence
1. Player presses action near final flower spot.
2. Bloom burst plays.
3. Screen fills with flowers/petals.
4. Text appears: `You Bloomed!`
5. Show restart/quit options.

---

## 18. MVP Scope

This is the version that must be finished first.

### MVP Features
- One playable level
- Player movement and jumping
- Tile collision
- Three evolution seeds
- Four evolution stages
- Stage 2 climbing
- Stage 3 gliding
- Stage 4 breaking barrier
- Win trigger
- Basic title and win screen
- Basic sound effects
- Credits file

### MVP Exclusions
Do not implement these until the MVP is done:
- Enemies
- Multiple levels
- Inventory
- Dialogue
- Procedural generation
- Complex animations
- Complex UI
- Multiple endings

---

## 19. Polish Features

Only add after MVP is fully playable.

### High-Value Polish
1. Screen shake on bloom burst
2. Particle effects for evolve/bloom
3. Simple parallax background
4. Short tutorial text signs
5. Smooth camera follow
6. Collectible sparkle animation
7. Better jump feel with coyote time
8. Music fade-in/fade-out

### Lower Priority Polish
1. Gamepad support
2. Extra collectibles
3. Secret flower pickups
4. Time score
5. Additional levels

---

## 20. 48-Hour Development Plan

### Hours 0–2: Setup and Prototype
- Create LÖVE project.
- Add placeholder player rectangle.
- Add basic movement and jumping.
- Add simple tile collision.

### Hours 2–6: Level and Core Abilities
- Build test level.
- Add climbable tiles.
- Add glide ability.
- Add breakable barrier.

### Hours 6–10: Evolution System
- Add evolution stages.
- Add evolution seed pickups.
- Add ability unlock messages.
- Add placeholder sprites/colors for each form.

### Hours 10–16: Real Level
- Build one complete level.
- Place collectibles and evolution seeds.
- Add checkpoints if needed.
- Add win trigger.

### Hours 16–24: Assets and Audio
- Import tileset.
- Import/create player visuals.
- Add item sprites.
- Add sound effects and music.
- Create credits file.

### Hours 24–32: Menus and Polish
- Add title screen.
- Add win screen.
- Add particles.
- Add camera smoothing.
- Add UI.

### Hours 32–40: Testing and Tuning
- Play from start to finish repeatedly.
- Fix collision bugs.
- Tune movement values.
- Make jumps easier.
- Ensure no softlocks.

### Hours 40–46: Packaging
- Package game.
- Verify assets and credits.
- Add README.
- Add controls screen.
- Test on a clean machine if possible.

### Hours 46–48: Final Submission
- Record screenshots/GIF.
- Write jam page description.
- Mention theme connection clearly.
- Declare premade assets and AI assistance.

---

## 21. README Contents

Create `README.md` with:

```md
# Bloom & Become

A 2D spring platformer made for a 48-hour game jam with the theme Evolution.

## Controls
- Move: A/D or Arrow Keys
- Jump: Space/W/Up
- Glide: Hold Space after unlocking Bud Form
- Bloom Burst: E/X after unlocking Bloom Form
- Restart: R
- Quit: Esc

## Theme
The player evolves from a sprout into a blooming flower, unlocking new abilities with each growth stage.

## Credits
See CREDITS.md.
```

---

## 22. Jam Page Description

Use this as the submission description:

```md
Bloom & Become is a short spring-themed 2D platformer about evolution through growth.

You begin as a tiny sprout and evolve into stronger plant forms by finding magical evolution seeds. Each new form unlocks a new ability: climbing, gliding, and finally blooming through barriers. Reach the sunny clearing and complete your transformation.

Made for the game jam theme: Evolution.
```

---

## 23. Risk Management

### Biggest Risks
1. Spending too long searching for perfect assets.
2. Overbuilding ecosystem/simulation mechanics.
3. Adding enemies too early.
4. Making the level too large.
5. Not declaring asset sources.

### Solutions
- Use placeholders immediately.
- Build the full game loop before importing final art.
- Use one level only.
- Use simple player-drawn shapes if sprites are unavailable.
- Maintain `CREDITS.md` during development, not at the end.

---

## 24. Final Recommendation

Build **Bloom & Become** as a small LÖVE/Lua platformer with one polished level, four evolution stages, and three ability unlocks. Keep the assets minimal, use free tilesets from itch.io, OpenGameArt, or Kenney, and draw the plant player manually if no suitable sprite is found quickly.

The goal is not to make the biggest game. The goal is to make a complete, readable, charming game that clearly expresses Evolution and springtime.
