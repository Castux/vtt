# Architecture

Some design principles:

- The only security concern is secrecy of the room codes/URLs (users are assumed to share room codes to trusted parties)
- Simplicity
- Convention over configuration
- Lightweight backend, logic in frontend

```
      +-------------------------------------------+
      |                                           |
      | +-----------+ +-----------+ +-----------+ |
      | |           | |           | |           | |
      | | Room JSON | | Room JSON | | Room JSON | | Persistent storage
      | |           | |           | |           | |
      | +-----+-----+ +-----+-----+ +-----+-----+ |
      |       |             |             |       |
      +-------------------------------------------+
              |             |             |
      +-------------------------------------------+
      |       |             |             |       |
      | +-----+-----+ +-----+-----+ +-----+-----+ |
      | |           | |           | |           | |
      | |   Room    | |   Room    | |   Room    | | Backend
      | |           | |           | |           | |
      | +-----------+ +-----+-----+ +-----------+ |
      |                     |                     |
      +-------------------------------------------+
                            |
             +----------------------------+         Websockets
             |              |             |
+------------+---+ +--------+-------+ +---+------------+
|                | |                | |                |
| Client browser | | Client browser | | Client browser |
|                | |                | |                |
+----------------+ +----------------+ +----------------+
```

- Backend is a glorified echo server, synchronizing state between clients, but handling little to no logic itself (except room creation and maintenance).
- Rooms are in memory when in use, plus stored regularly to prevent data loss and reduce memory usage when inactive.
- The backend also serves the client files (HTML, JS, CSS, Lua, etc.) via regular HTTP, although technically that could be hosted somewhere else.

Whichever the room they want, the client fetches "/" and then connects to the room's websocket on "/ws/<room code>". Client facing URL could be either "/<room code>" (which the server still serves as "/") or "/?room=<room code>". It doesn't matter much.

A new room can be created with a GET to "/new", which returns the code of the new room. Client can then as usual connect to the associated websocket and receive the (empty or default) room state.

## Room states

Pure data, kept in memory as Lua tables, and transferred/stored as JSON. The two formats are mostly equivalent. Lua tables can use both number and string indices, acting as array, dictionary or both at the same time. As long as we restrict Lua tables to act as array *or* dictionary, the JSON middle ground will be lossless.

Most entities might have common fields:

- unique ID
- position, rotation, size
- list of faces as images
- current face
- ...

As well as tags or free user defined fields for automation (source deck, type of card, etc.)

TBD:

- stacks (list of references, or nested objects?)
- inherited attributes from decks (like common faces)
- named resources (to avoid duplication of data/URLs)

Complete definitions are kept up to date in docs.

## Protocol

Instead of a list of commands to modify state in the backend (and keep it synchronized on frontends, with duplicated logic):

> All modifications of room states are sent as Lua table diffs.

Whether from normal UI use, direct advanced-mode text modification, or automation, when a client modifies their room state, a diff is created from the previous known state, and sent to the backend.

The backend patches its own room state, and forwards the diff to the other connected clients. Very little (or no) validation happens in backend.

In case of conflicts, new clients, etc., the full room state is sent. A basic version control is in place, with each state having an ID, and the client sending their diff with the ID of their last known state. In case of mismatch, the diff is rejected and the client is sent back the full room state and ID.

Pros:

- Simple and consistent
- Covers all possible actions in frontend (no need to list possible actions and arguments in a protocol)
- Future proof: once the transport protocol is created, all possible new features are already supported
- Batching changes is built-in
- Automation is supported as is: any and all changes to room state are expressed the same way
- It shifts development to the front-end:
    - UI to generate the room changes
    - Handling the diffs sent back from the server. A smart mapping of entity properties to SVG/HTML ones might even automate a large part of that.

Cons:

- Cheating/griefing is trivial, but we be decided not to care
- Is sometimes more verbose than specific commands, but all transfers are compressed anyway, and I'd rather focus on simplicity rather than optimization

TBD:

- "Realtime" info (mouse positions, items mid-dragging, etc.) Could be sent and forwarded, but not stored as part of the room state.

## Automation

Automation is entirely handled in the client. For simplicity:

- Full Lua environment
- A script is executed in a sandbox (no access to libraries, and only to the common use globals)
- Some internals are exposed:
    - Access to the room state, modifiable at will
    - Helper functions to find or iterate on objects, and for common tasks

With a sufficiently complete documentation of how the room state is represented, room creators will have the power to automate as much as they wish, with less (or no) need of maintenance from the platform developers.

Since all scripts are executed locally in browsers, and rooms are assumed to be shared only with trusted parties, there are no concerns for safety. People can shoot themselves in the foot if they like.

We can of course provide ready made script templates for common tasks, or even set some of these via UI.

## Room observers

By deciding to forego any kind of access control, we lose the ability to have roles, especially observers. Since this is meant as a boardgaming platform, it could be useful to post public links during tournaments, of for demo rooms to be duplicated, etc.

When a room is created, along with its secret code, another random code is generated for the matching "observation room". Its state mirrors entirely that of the main room, and for the client, it works exactly the same.

The only difference is that the server never accepts diffs for it. The "official" client also disables editing, obviously.

Simple solution for a big value from little development effort.
