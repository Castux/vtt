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

- Backend is a glorified echo server, synchronising state between clients, but handling little to no logic itself (except room creation and maintenance).
- Rooms are in memory when in use, plus stored regularly to prevent data loss and reduce memory usage when inactive.

## Room states

Pure data, kept in memory as Lua tables, and transferred/stored as JSON. The two formats are mostly equivalent.

Most entities might have common fields:

- unique ID
- position, rotation, size
- list of faces as images
- current face
- model (for duplication)

As well as tags or free fields for automation (source deck, type of card, etc.)

TBD:

- stacks (list of references, or nested objects?)
- inherited attributes from decks (like common faces)
- named resources (to avoid duplication of data/URLs)

Complete definitions are kept up to date in docs

## Protocol

Instead of a list of commands to modify state in the backend (and keep it synchronised on frontends, with duplicated logic):

> All modifications of room states are sent as JSON/Lua table diffs.

Whether from normal UI use, direct advanced mode text modification, or automation, when a client modifies their room state, a diff is created from the previous known state, and sent to the backend.

The backend patches its own room state, and forwards the diff to the other connected clients. Very little (or no) validation happens in backend.

In case of conflicts, new clients, etc., the full room state is sent.

Pros:

- Simple and consistent
- Covers all possible actions in frontend (no need to list possible actions and arguments in a protocol)
- Batching changes is built-in
- Automation is supported as is: any and all changes to room state are expressed the same way

Cons:

- Cheating/griefing is trivial, but be decided not to care

TBD:

- Version control. Each state can be stored with an ID, that clients must send along with their patches. Backend refuses the patch if the ID is wrong (and resends the whole state). If the patch is accepted, it is sent back with the new state ID.
    - Merging diffs OK if no conflicts?
    - Does this require full-room hashing (based on deterministic JSONification or something else?)
    - Keeping the last "few" versions to allow sending only smaller diffs to clients instead of whole states?
- "Realtime" info (mouse positions, items mid-dragging, etc.) Could be sent and forwarded, but not stored as part of the room state.
