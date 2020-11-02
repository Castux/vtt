# Virtual Tabletop

A 2D browser-based virtual tabletop to play board games and card games online. Simulates cards, tokens, stacks, bags and other basic elements, but does not enforce any rules.

Fully customisable with user-provided images, to reproduce virtually any board game. Lua automation available to reduce tedious manipulations.

Inspired by cardgames.io, Tabletop Simulator and others.

## Installing

The server runs on luvit 2.0, with the weblit application layer. On Unix-like platforms, run these steps to checkout the repo, get the luvit binaries and the dependencies:

```
git clone https://github.com/Castux/vtt.git
cd vtt
curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh
./lit install creationix/weblit
```

You can now run the server with `./luvit server.lua`
