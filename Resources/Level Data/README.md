# The Billowing Blizzards Level Data Format (Version 1.0)

\*Although I am calling these levels, they will be refered to as days in the game.

**The full specification for the level data format is still not fully implemented.**

## Why?

Because I can

## File name

Under normal circumstances, the file name should be the level number and the extension should be '.bbld' (Billowing Blizzards Level Data). However, the file name can be anything as long as the extension is '.bbld'.

This is because the level data will be loaded by matching the file name with the level number. For example, if the level number is 1, the level data will be loaded from a file named '1.bbld'.

## File format

I am lazy so I will be using JSON as the underlying file format.

## File structure

The file is split up into two primary sections: the header and the enemy data. Additionally, comment lines can be made by preceeding the comment text with `//` and multiline comments can be made with ``/* comment text */``.

### Header

The header section is used to setup the environment for the level but can also be used for some metadata.
Every key in the header data is optional. If a key is not present, the default value will be used.

Keys:

- `version` - The version of the file format. (Currently 1.0)
- `title` - The title of the level. If unset, the file name preceeded by 'Day ' will be used.
- `subtitle` - The subtitle of the level. This will be displayed under the title. If unset, nothing will be displayed.
- `bonus` - The bonus for completing the level, which should usually be the game's currency (snow). If unset, a default value of `level_number * 100` will be used. If there is no level number, the default value will be 0.
  The bonus will be a semicolon separated list of key-value pairs. The key is the name of the bonus and the value is the amount of bonus. For example, if the bonus is `health=100;snow=100` the player will receive 100 health and 100 snow at the end of the level.

More keys will be added in the future.

### Enemy section

The enemy section is used for spawning enemies. It is an array of dictionaries. This dictionary should contain one or more spawning keys (`timestamp` or `trigger`), a `async` key to await for multiple triggers, and an enemy data key named `data`.
The following sections will describe each key.

```json
// example enemy section
"enemies": [
  {
    "trigger": "timestamp=00:01:00",
    "data": [
      {
        "type": "Test Enemy",
        "count": 1,
        "location": "world-random",
        "target": "player"
      }
    ],
    "async": true
  },
  {
    "trigger": "enemyKilled=2",
    "data": [
      {
        "type": "Test Ranged Enemy",
        "count": 3,
        "location": "world-random",
        "radius": 100,
        "target": "player",
        "overrides": {
            "speed": 50
        }
      },
      {
        "type": "Test Ranged Enemy",
        "count": 1,
        "location": "world-random",
        "overrides": {
          "health": 200
        }
      }
    ]
  },
  {
    "trigger": "enemyKilled",
    "data": [
      {
        "type": "Test Enemy",
        "count": 1,
        "location": "screen-random",
        "radius": 0,
        "target": "player",
        "overrides": {
            "health": 100
        }
      }
    ]
  }
]
```

**The file will be read one spawn group at a time unless the parallel key exists and is set to true. Ensure triggers such as timestamps are in order!**

**Spawning enemies**

Spawning enemies can be done using triggers.
Triggers will be a simple string value with some triggers having an optional parameter. For example, if the key is `enemyKilled` the enemy will be spawned when an enemy is killed. If the key is `enemyKilled=2` the enemy will be spawned when the second enemy is killed.

Possible trigger values (\* indicates this parameter is optional):

- `timestamp=isoTimestamp` - Spawn the enemy at the specified timestamp. This timestamp should be specified in the standard ISO 8601 timestamp. For example, `00:01:00` will spawn the enemy 1 minute after the level starts.
- `enemyKilled=int*` - Spawn the enemy when the specified number of enemies are killed.

**Enemy data**

Each value will be an array of "spawning groups". Each spawning group will be a dictionary with the following keys:

- `type` - The type of enemy to spawn. This is a string value. Possible values include:
  - `Test Enemy` - A melee enemy.
  - `Test Ranged Enemy` - A ranged enemy.
- `count` - The number of enemies to spawn. This is an integer value. If unset, the default value will be 1.
- `location` - The location to spawn the enemy. This can be a string value or a 2D Vector with a reference (ex. `world;0,0`). Possible string values include:
  - `world-random` - A random edge of the world. (Default)
  - `world-top` - The top of the world.
  - `world-bottom` - The bottom of the world.
  - `world-left` - The left side of the world.
  - `world-right` - The right side of the world.
  - `world-center` - The center of the world.
  - `screen-random` - A random edge of the screen.
  - `screen-top` - The top of the screen.
  - `screen-bottom` - The bottom of the screen.
  - `screen-left` - The left side of the screen.
  - `screen-right` - The right side of the screen.
  - `screen-center` - The center of the screen. (This is on the player)
- `radius` - Enemies will be spawn in a circle around the location, this value can change the radius of this circle. If unset, the default value will be 0.
- `target` - The target for the enemy. The values expected will vary per enemy. For example, some enemies will accept a position as a target (`world;0,0`) or an angle to charge atFor most enemies you can use one of these values:
  - `player` - The player (Default).
  - `projectile` - The player's projectiles.
- `overrides` - A dictionary of overrides. This is optional. The key is the name of the override and the value is the value of the override. For example, if the key is `health=100` the enemy will have 100 health. If unset, the default values will be used.

## Infinite Level Data

Billowing Blizzards is capable of procedurally generating levels by evaluating expressions given in a 
.bbid (Billowing Blizzards Infinite Data)

Despite the name, the level itself is not infinite, it instead means that a single file will be capable of generating
an inifinite number of levels

### Naming scheme
Just like normal levels, infinite level data files should be named after a day number.
However, in this case, the day number represents the starting level that the infinite data should be used.

For example, if my levels looked like this:
```
0.bbld
1.bbld
2.bbld
*3.bbid*
10.bbld
*11.bbid*
*15.bbid*
```

Then that would mean that levels 0, 1, 2, and 10, will remain as static non-procedural levels.
While levels 3-9, 11-14, and 15+ will be procedurally generated with each section being capable of different generation strategies

### Differences
Infinite data mostly be the same, however, when you specify a a value for something, you can use expressions. For example:
```json
{
  "header": {
    "title": "Infinite Level Data Example!",
    "bonus": "health=randi()%50+50;snow=randi()%100" // On completion, the player will receive between 50-100 health and 0-100 snow
  },
  "enemies": [
    {
      "trigger": "timestamp=random_timestamp('00:00:00', '00:00:10')" 
      /* A random timestamp method will be provided use it with strings timestamps.
         In this case, It this trigger would trigger between 0 to 10 seconds */
      "data": [
        {
          
        }
      ]
    }
  ]
}
```