# Worm Wars — Borrowed Code & References (vetted)

I searched for existing open-source work and examined it critically. Here is what's worth borrowing, what to borrow from it, and the license catch on each. Read the license column before copying anything — it determines whether you can paste code or only learn from it.

## The short version

The networking is the hard part, and someone already solved the exact zero-IP-typing problem for a snake game. Borrow that pattern. For everything else, learn the structure but write fresh, because the best-matching full game is GPL (see below).

## Reference table

| Project | What to take | License | Verdict |
|---|---|---|---|
| **GodotEasyLAN** (perons / Henrique Alves) | The LAN auto-discovery pattern: host broadcasts UDP packets with its IP + a room code to the broadcast address; clients listen and build a host list; connect via Godot high-level multiplayer. This is *exactly* the "host taps Start, client taps Join, no IP typing" flow in the spec. | Check the repo (addon, permissive-leaning) — verify before pasting | **Borrow the pattern, ideally the code.** Same author wrote a versus-snake game with it, so it's proven for this use case. |
| **SnakePro** (mar511n) | Architecture reference only: Godot 4.3, LAN over IPv4, Android export, touchscreen controls, in-game items, replays, multiple maps. Closest existing thing to your game. | **GPL v3** | **Learn from, do NOT copy.** GPL would force you to license your whole game GPL. Study how they structure items/replays/maps, then write your own. For a family project that's fine, but cleaner to stay independent. |
| **Thunder Plugins LAN Multiplayer for Godot 4** | A server-browser plugin with an explicit Android-fix history (v1.4 "Now Fixes Android Issues"). | Check itch listing | **Use as a cross-check.** Even if you don't use it, its changelog tells you Android LAN has real gotchas — read it before debugging blind. |
| **amitkumarraikwar/snake-game-using-godot-engine** | Clean beginner reference for grid movement, dynamic segment instancing (PackedScene), food spawning, collision. Good scaffolding to read. | **MIT** | **Free to borrow.** But note: it's grid-based. Chloe wants a chunky free-moving worm, so use it for segment-instancing patterns, not movement feel. |
| **henriquelalves WebRTC versus-snake** (DEV article + GitHub) | Conceptual: how to structure two snakes in a versus match, host-authoritative vs peer thinking. | Check repo | **Read the article.** It walks through the exact architectural fork (authoritative server vs P2P) you face. Good background even though you'll use LAN/ENet, not WebRTC. |

## The one thing to copy carefully: LAN discovery

Every other approach found online makes the user **type an IP address** — a dealbreaker for kids. GodotEasyLAN's broadcast pattern is the answer. The mechanism, in plain terms:

- Host opens a UDP socket and repeatedly sends a small packet (its IP + a room code) to the subnet broadcast address.
- Clients open a UDP socket, listen for those packets, and assemble a list of available hosts.
- When a client picks one, it uses the broadcast-supplied IP to open the real ENet connection via Godot's high-level multiplayer API.
- Host stops broadcasting once the match starts.

Two warnings the forum posts surfaced, worth baking into the build:
1. **Subnet mask gotcha.** Broadcast works cleanly on a 255.255.255.0 subnet (typical home/hotspot). On wider subnets it can fail. Your hotspot mode will be 255.255.255.0, so you're fine, but test it.
2. **Android LAN quirks are real.** Multiple plugins ship explicit "Android fixes." Expect to debug Android-specific networking behavior, and test on the actual tablets early (Stage 2), not just the desktop.

## License rule of thumb for this project

- **MIT / permissive** → free to copy into your code.
- **GPL (SnakePro)** → learn from, don't paste, unless you're willing to GPL the whole game.
- **Unsure** → treat as "read and reimplement," which is what you'd do for most of this anyway. For a non-distributed family project the legal risk is near zero, but staying clean now keeps options open if you ever share it with other families.

## How this feeds the build prompts

When you reach **Stage 2 (networking)** in `03_BUILD_PROMPTS.md`, add this to the prompt:

> Base the LAN discovery on the GodotEasyLAN broadcast pattern: host broadcasts its IP plus a room code over UDP to the subnet broadcast address; client listens, lists hosts, and connects via high-level multiplayer using the broadcast IP. Account for the 255.255.255.0 subnet requirement and known Android LAN quirks — we are testing on real Android tablets. Do not require anyone to type an IP address.

That single addition turns the riskiest stage from "invent it" into "adapt a proven pattern."
