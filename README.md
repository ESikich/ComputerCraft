# Auto-Miner for ComputerCraft Minecraft Plugin
This Lua program is designed for the ComputerCraft Minecraft plugin. It allows a turtle to efficiently auto-mine using a Hilbert curve path in a 1x2 tunnel. The program handles inventory management, fuel consumption, torch placement, and ore detection.

## Features
- Efficient mining using Hilbert curve path
- Inventory management
- Auto torch placement
- Fuel consumption tracking
- Ore detection and mining
## Usage
1. Install the ComputerCraft Minecraft plugin.
2. Copy the Lua code provided in this repository to a turtle in the game.
3. Run the program using the lua command followed by the filename.
## Program Overview
The program begins by designating specific inventory slots for certain blocks, such as stone, cobblestone, gravel, dirt, sand, torches, and an ender chest. It then sets global variables for minimum fuel count, torch spacing, and initializes other necessary variables.

The main mining function, TunnelForward, mines a 1x2 tunnel forward for a given number of units. It checks the inventory, fuel, and torches along the way. The turtle follows a Hilbert curve path for efficient mining.

In addition to the main mining function, the program contains several utility functions:

- <b>BlockHandler:</b> Handles block detection and mining.
- <b>CheckInventory:</b> Checks inventory and consolidates items.
- <b>FuelCheck:</b> Checks fuel levels and refuels if necessary.
- <b>TorchCheck:</b> Places torches at specified intervals.
- <b>IsOre:</b> Determines if a detected block is an ore.
## Contributing
Contributions are welcome! Please feel free to submit issues or pull requests for improvements, bug fixes, or new features.

## License
This project is licensed under the MIT License.
