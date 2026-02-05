# Roblox UI-Only Incremental Game (UI Simulator)

This repo contains a UI-only incremental Roblox game prototype where all gameplay happens through UI, menus, and animated transitions. The structure is built to be extended in Roblox Studio.

## UI Hierarchy Overview

```
StarterGui
└── IncrementalUI (ScreenGui)
    ├── MainMenu (Frame)
    │   ├── Animated Background (Frame + UIGradient + Orbs)
    │   └── Buttons: Play / Inventory / Settings / Stats
    └── MainHUD (Frame)
        ├── TopNav (Frame -> ScrollingFrame -> Nav Buttons)
        └── Pages (Frame)
            ├── Main
            ├── Rolls
            ├── Inventory
            ├── Auras
            ├── Upgrades
            ├── Rebirth
            ├── Ascension
            ├── Automation
            ├── Achievements
            ├── Stats
            ├── Shop
            └── Settings
```

Each page includes a unique header and a scrolling grid filled with interactive buttons. Locked pages include blur overlays, lock icons, and unlock tooltips.

## Script Structure

```
ReplicatedStorage
└── Modules
    ├── Animation.lua
    ├── Items.lua
    ├── Rarity.lua
    ├── RollLogic.lua
    └── UIController.lua

StarterPlayer
└── StarterPlayerScripts
    └── Bootstrap.client.lua

ServerScriptService
└── DataStore.server.lua
```

### Key Modules

- **Animation.lua**: TweenService helpers for button hover/press, page transitions, glow bursts, screen shake, and number popups.
- **Items.lua**: Item pools per rarity (at least 5 per tier) used for rolls and inventory.
- **Rarity.lua**: Defines all rarity tiers (Common → Omniversal) with color themes and unlock thresholds.
- **RollLogic.lua**: Handles weighted rolling with a luck multiplier.
- **UIController.lua**: Builds the entire UI hierarchy, handles page switching, menu transitions, and rolling effects.

### Data

`DataStore.server.lua` stores currencies, unlocks, and settings in DataStore and mirrors data to clients via `RemoteEvent`.

## How to Use

### A) Import into Roblox Studio (recommended)
1. Open **Roblox Studio** and create/open your place.
2. In the **Explorer**, create these folders if they do not already exist:
   - `ReplicatedStorage/Modules`
   - `StarterPlayer/StarterPlayerScripts`
   - `ServerScriptService`
3. From this repo’s `src/` folder, copy the scripts into the matching services:
   - `src/ReplicatedStorage/Modules/Animation.lua` → `ReplicatedStorage/Modules/Animation` (ModuleScript)
   - `src/ReplicatedStorage/Modules/Items.lua` → `ReplicatedStorage/Modules/Items` (ModuleScript)
   - `src/ReplicatedStorage/Modules/Rarity.lua` → `ReplicatedStorage/Modules/Rarity` (ModuleScript)
   - `src/ReplicatedStorage/Modules/RollLogic.lua` → `ReplicatedStorage/Modules/RollLogic` (ModuleScript)
   - `src/ReplicatedStorage/Modules/UIController.lua` → `ReplicatedStorage/Modules/UIController` (ModuleScript)
   - `src/StarterPlayer/StarterPlayerScripts/Bootstrap.client.lua` → `StarterPlayer/StarterPlayerScripts/Bootstrap` (LocalScript)
   - `src/ServerScriptService/DataStore.server.lua` → `ServerScriptService/DataStore` (Script)
4. Press **Play**. You should see the **Main Menu** with animated background. Click **Play** to enter the main UI.

### B) Manual creation (if you prefer copy/paste)
1. In **Explorer**, right‑click the service and choose **Insert Object**:
   - **ModuleScript** inside `ReplicatedStorage/Modules` for each module.
   - **LocalScript** inside `StarterPlayer/StarterPlayerScripts` for the bootstrap.
   - **Script** inside `ServerScriptService` for the DataStore server script.
2. Name each script exactly as shown below:
   - `Animation`, `Items`, `Rarity`, `RollLogic`, `UIController`
   - `Bootstrap` (LocalScript)
   - `DataStore` (Script)
3. Paste the matching file contents from this repo into each script.

## Notes

- This is UI-only. No 3D gameplay elements are required.
- All UI elements are created in Lua for easy extension.
- If you already have a DataStore system, merge the **default data fields** from `DataStore.server.lua` into your own save format.
- If you see `Infinite yield possible on 'ReplicatedStorage:WaitForChild(\"Modules\")'`, confirm that the **Modules** folder exists under `ReplicatedStorage` and that `UIController` is inside it.
