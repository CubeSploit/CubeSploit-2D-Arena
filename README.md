# CubeSploit-2D-Arena

WIP

CubeSploit 2D Arena is a 2D space shooter game based on engineering.


## Milestones

* Ship editor 80%
	TODO:
	* Needs design on bigger scaled tiles

	* Soft Block
	* Generator
	* Capacitor
	* Shield generator
	* Light emitor
	* Mirror
	* Lens
	* Piston
	* Sticky Piston
	* Conveyor Belt
	* Servo motor
	* Explosive tile
	* Cockpit
	* Energy Wire
	* Energy Switch
	* Resistance
	* Logic Wire
	* Signal Delayer
	* Not, Or, And
	* Add, Sub, Mul, Div, Mod
	* Equal, Superior, Inferior
	* Constant emitters
	* Wireless Signal Emitter
	* Wireless Signal Receptor
	* Subspace Signal Emitter
	* Subspace Signal Receptor

	* Wires can be connected from one layer to another.
	* Default core tile

	* Style layer

* Team editor 0%
* Testing arena 0%
* Ship instantiator 0%
* Ship updater 0%

## Arena

The arena is a closed or looped area where ships can fight each other.
There are objects procedurally generated such as asteroids.
Ships are controlled by players or by AI.

## Ship editor/designer

The ship editor allows the player to create his "ship model" by placing tiles (also called blocks) that have different functionality.
Ship designs can be stored and loaded by files.
The ship model can be tested in a simulator that allows the player to test his ship in a closed solo player arena. (X)
All ships have at least a ship core tile.
A ship model cannot contain several core tile.
A ship is composed of many layers:

* A basic layer, forms the ship's structure. Tiles of the basic layer can be set as "floor" without collision shape. Other ships, players and objects can pass in. To avoid ships to be entirely set as floor, floor tiles have lesser resistance and weight.
* Wiring layers. Several layers can be created for wiring, one colour is given to wiring layers and wires will be colored the same way. Wires can be connected from one layer to another. Wires are set on a tile by first clicking on the tile that will be the input direction, then click on the tile that will contain the wire, then the tile that will be the output direction. The two last click can count as the first two of another wire.
* Style layer. A style layer can be added to cover tiles and hide mechanism for players that are exterior to the ship.

## Team editor/designer

This is where:
* Ships are loaded, put together (smaller ships in bigger ships's docking stations)
* Default player positions are set (on background tile)


## Tile types:

Tiles types or descriptions that are marked with an ? are to be discussed


* Normal block: constitutes the hull of the ship, not too heavy, not too weak
* Hard Block: Heavy, moderate resistance against energy and impact
* Soft Block: lightweight, very resistant against impacts and energy damage WHEN they are moderately low. The curve of damage absorption is shaped like 1/e^-x. May be ideal for ship internal controlled explosions.

* Generator : throughput fixed amount of energy.
* Capacitor : is filled with energy slowly then can liberate it quickly

* Shield generator : Generates an energy shield, the size/resistance ratio can be set, but the effective power of the shield is fixed by the quantity of shield generator tile put together. Very resistant against energy damage, very weak against impact damage, consumes energy from capacitor when receiving damage. Let high velocity object pass

* Light emitor: Emits light in a forward direction
* Mirror : change direction of emitted light, direction can be changed with input command (isn't this useful as a shield too?) (probably has will have a resistance treshold)
* Lens : Focus light in the form of a laser that will be able to deal damage. Lasers damage depend of their range and loose damage per distance travelled. The range of a laser depends of the size of the lens and of the light energy


* Thruster : adds a linear thrust to its group of tiles, if group is connected to the core, applies it directly to the entire ship.
* Piston : pushes a group of block if possible when activated, stacked piston pushes further
* Sticky Piston : Same but when deactivated, pulls the group back if possible
* Conveyor Belt : Pushes a neighbour block to the side when activated if possible
* Servo motor : Rotates a sub group of block in a given direction and given speed
* Explosive tile : explodes when activated or impacted, produces impact and energy damage reduced by distance


* Cockpit : a block that can be connected to logic wires. When a player is placed on cockpits tiles, the connected logic wires that output information can be connected to GUI displayers, the connected logic wires that takes input from the player can be connected to GUI commands or to keyboard shortcuts.


* ?Life Support System: Pressurises a closed area, players that aren't in a space suit, in a not closed area or an area without life support DIE.
* ?Space Suit Dresser : When a player walks on a Space Suit Dresser tile, he wear puts on or off a space suit

* Energy Wire : transport energy, forking energy wires is not allowed. If many wires are set as output of a generator, the generator will divide energy equally.
* Energy Switch : separates energy between two energy wires, can receive a float to set the ratio
* Resistance : Lowers the energy that goes through an energy wire, can receive a float to set the ratio


* Logic Wire : transport information: boolean, number, float, string
* Signal Delayer: Adds a parametrizable delay in the received signal
* Not, Or, And
* Add, Sub, Mul, Div, Mod
* Equal, Superior, Inferior
* Constant emitters: Boolean, Int, Float, String
* ?Programmable Micro Chip
* Wireless Signal Emitter : emission frequency can be set, has limited range
* Wireless Signal Receptor : reception frequency can be set
* Subspace Signal Emitter : emission frequency can be set, some of the frequencies are encouraged to be used to communicate with enemies, unlimited range
* Subspace Signal Receptor : reception frequency can be set


## Ship instantiator

The ship instantiator is the module responsible to set up the ship's node tree and mechanisms.
Tiles attached to each other form a group of tiles.
Tiles can be neighbour but set to not be attached to each other.
A ship may be made out of many groups of tiles.
Groups can be attached to the ship's core or not.
Background tiles and some specific tiles aren't collidable

Ship instantiator computes: groups, their metadata and their shapes (greedy meshing of the collidable tiles)


## Ship updater

The ship updater is called X times per second
It is responsible for updating the ship's state. Damage and player's inputs aren't handled in that loop.

At the beginning of an update, the ship updater computes the logic signals
It starts from the signal emitters and spread the value through the wires until reaching the end of the network.
Concurrent data on a wire will NOT be considered as an "OR" function.

When an actuator is activated and tries to move a group

The ship updater :
* computes The list of groups that are going to be moved by the actuator, if one of them is connected to the core, none can move
* put the combination of the shapes of the groups into a kinematic or rigidbody, test if they can move, and do move them. By default, shapes of groups are maintained in the ship's body, and then moved dynamically for local tests.
* When a group is not neighbouring any other group, the group is detached from the ship and considered as a foreigner ship (TODO: open for suggestions considering projectiles.)
* When a ship collides another ship, the ship updater computes the collision damage (to be designed)



## Damage updater

Ship's damage are computed in the normal game loop
There are two ways of dealing damage: Impact, and Energy

An impact damage is done by basically colliding two entities with a certain velocity

Energy damage are typically lasers

Explosions apply both impact damage and energy damage

TODO: define damage computing functions


## Piloting

Players can move their character inside a ship
Their update is handled in the normal game loop

When entering a cockpit tile, the player becomes "locked" in, a GUI appears, the keyboard shorcuts change, and the zoom parameter is set to the cockpit's default zoom level.

The player can pilote whatever command is connected to that cockpit and can watch whatever information is given and displayed to the cockpit.

When selecting a string input, the keyboard shortcuts change to allow player to write something.


GUI Input elements:
* Button : boolean input
* Slider : float input
* Text Area : string input

GUI Output elements:
* Led : boolean output
* Progress Bar : (or anything looking like it) Any number kind output
* Label : String output (can be anything that can be converted to string)
* ?Speaker : can convert string to voice to nearby player, or number to sound.



