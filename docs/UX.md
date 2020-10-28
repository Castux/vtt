# Multiplayer online board game sandbox

*Aka. a Virtual Table Top*

There are a few existing ones, with each their own characteristics. Which means of course I want to make my own.

Some design principles:

- keep it simple but versatile
- in browser, no install needed
- click and drag 2D interface, compatible with mobile
- no account needed: join rooms by URL or room code
- no security concerns: play with people you trust (no protection from cheating of griefing beyond the secret room code/URL)
- fully open source, open file formats and open specs
- free to use, main backend service funded by donations (and free to run own backend)
- no chat, player rankings, etc.

## Comparison with existing systems

- Tabletop Simulator: requires download, paid program, 3D
- Tabletopia: no sandbox (that I could find), free users can only create one game through a studio interface, also 3D
- Boardgame Arena: requires account, making games is complex (implement rules and UI in PHP, JS and HTML)
- Roll20, Vassal, Fantasy Grounds, etc.: oriented for RPGs or wargames, all great systems, but require accounts or downloads, often quite clunky, although very feature rich. High barrier of entry.
- playingcards.io: quite similar to this vision. Has some odd restrictions that require workarounds. Implementing big games is a hassle, as the platform is more intended for card games and abstracts. Closed platform with rare updates by the author.

# Game elements

## Entity

The basic game entity is used for most things:

- One or more pictures ("faces"). One for a token, two for a card, more for dice or elements with multiple states.
- Move
- Flip (cycle through the faces)
- Flip to random face (rolling dice, flipping coins)
- Rotate (predefined quick access for 4 and 6 symmetries, plus a free rotate)

Some actions available only in edit mode:

- Resize
- Change color (mostly for pawns with a simple shape to avoid having to upload the same image with just the color changed)
- Lock to background, for boards

## Stack

All game entities are stackable. A stack is just an ordered collection of entities.

- Move
- Shuffle
- Flip (cycle all faces and invert order, behaves as expected for a stack of cards, mostly)

All elements of a stack are displayed centered on the same point, making the top element visible only. If other elements are rotated, or a larger size, they will be visible too, as expected.

A stack can be made into a bag by giving it its own image, which will be displayed instead of all the elements inside.

- Elements are dragged from the top of the stack
- Stacks can be "peeked" into to see all elements inside and drag one specific one out

## Hand

Each connected player has a special zone where entities are only visible to them. It works like a single stack, but is displayed spread out for them.

Other players don't see other players hands, of course.

## Extra items

These can be moved only in edit mode

- Label (to edit in edit mode)
- Counter (labels with numbers only and buttons to increase, decrease). Might be redundant.
- Stack holder. A snapping point for stacks, possibly labeled. Can help keep things tidy, and make named points for automation, otherwise not actually necessary.

## Automation

In PCIO, there is minimal automation: recall a deck and shuffle it. Programmable buttons to move and flip cards, or shuffle decks, or change counters. It is based on named deck holders and having decks associated to them.

No opinions about this yet. The option to automate some common actions is nice, but finding a convenient interface to set it up is less easy. It tends to get tedious (but is it less tedious that doing all things by hand in the playground?)

Giving full programmable options would probably be simple thanks to the Lua scripting, but does that go towards the spirit of the platform?

# Room view

- Normally a single fixed view, fullscreen or almost (PCIO uses 1600x1000 as reference resolution)
- When bigger games are needed, give the option to zoom out and then zoom back in to an adjacent view. No free panning or zooming, just two levels of zoom, and fixed camera spots arranged as a grid. Most games should need only a handful of views, given the experience on PCIO.
- The game space is still continuous, so elements (especially game boards) can span multiple views
- Other players taps/mouse moves are seen as colored circles
- All entity manipulations are seen almost in real time.

Ideas:
- Consider a multiple item selection, to quickly grab and move a large amount of tokens? Possibly edit them too?
- Grouping of objects like in drawing programs, to move, rotate, etc. as a whole? Could be used to simulate placing tokens on a tile, and moving the entire tile.

# Usability

(There is no difference between players and hosts, except in terms of user journey. I mean here as "host" the player(s) who set up a game and invite others to play.)

## Basic user journey

- Host creates an empty room, get a room code and URL
- Host can then edit the room by adding entities, placing them, etc.
- There is a library of common items that can be readily used (tokens, boards, standard decks of cards, etc.)
- Any image can be used by URL or upload
- Players join simply by opening the URL, or entering the code on the site's main page
- In play mode, there are many less options: it is mostly moving entities, flipping them.
- There are no role differences, players can also enter edit mode to modify the room, add more elements, etc.
- The room keeps its state saved at all times, even when all users disconnected. Next time they visit the room, it will be as they left it (unused rooms can be deleted after a certain delay)

## Setups

After setting up a room, a user might want to save it for reuse later, especially with complex board games.

- A room can be exported at any time, giving the user a single file
- That file can then be imported into a room, replacing the current state entirely
- Room states can also be loaded by URL, if they are hosted online
- Rooms can be created from a file or URL, making starting a game as easy a clicking a saved link
- Rooms can be duplicated, creating a new room with the same state

State files are plain text (optionally zipped), in JSON or Lua, with a clear documented structure that can be edited offline or with alternate tools.

Images can be embedded in the state file (as base64 for instance), or as packaged files like in PCIO.

There is a text editor in the website directly, to edit the game state directly instead of having to download the file, edit it, and reupload it.

Importing PCIO files should be quite easy for the most part, since these features are a superset of PCIO's (with the exception of automation).

## User access

There is no authentication or user accounts. The only mechanism to that effect is the secrecy of the room codes. Within a room, all users can manipulate, edit, see all entities, and cheat to their hearts content. Some of these actions will be visible to the other players (flipping cards, peeking at stacks), but a tech savvy user could just check the browser's dev mode. They could even be using a custom client, for all we know.

This is for technical reasons (much easier to duplicate state in all clients than handle permissions in the server), as well as ideological. The tool should be simple and simulate a table. Playing requires trust. Cheaters will always manage to cheat, and that is not a battle I'm interested in.
