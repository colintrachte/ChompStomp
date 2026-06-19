# GODOT PROJECT ARCHITECTURE RULES

This project targets Godot 4.x.

The project should be implemented using native Godot systems whenever practical.

## Scene Composition

Entities should generally be implemented as .tscn scenes rather than pure GDScript classes.

Prefer:

- Scene instancing
- Inspector configuration
- Exported variables

Over:

- Large manager scripts
- Hard-coded constants
- Pure procedural construction

## Physics

Use:

- CharacterBody2D for moving actors
- Area2D for sensors, pickups, attacks, and triggers
- CollisionShape2D for collision geometry

Do not implement custom collision systems unless there is a demonstrated performance or gameplay reason.

## Signals

Favor event-driven architecture.

Use signals for:

- death
- spawning
- collection
- food consumption
- wave completion
- score events

Avoid polling object state every frame when a signal is sufficient.

## UI

Use Godot Control nodes:

- Button
- TextureButton
- Label
- Container nodes

Do not create custom button hitboxes unless required by gameplay.

## Animation

Prefer:

- Tween
- AnimationPlayer

Over manual interpolation code.

## Rendering

Procedural rendering using _draw() is allowed when it materially benefits gameplay, customization, procedural generation, or debugging.

Do not replace procedural geometry with sprites solely to follow engine conventions.

## Shaders

Use shaders for:

- visual effects
- flashing
- outlines
- distortion
- glow
- palette shifts

Do not use shaders to replace gameplay logic.

## Resources

Prefer custom Resource types (.tres) for tunable game data.

Enemy stats, food definitions, weapon definitions, and progression values should be data-driven whenever practical.

## AI Output Requirements

When implementing a feature:

Be mindful some godot functionality has to be set up from the editor by a human. At every step, call out exactly what the user must do manually.

Step 1:
Propose scene hierarchy.

Step 2:
Propose signals.

Step 3:
Propose resources/data structures.

Step 4:
Write GDScript implementation.

Assume scene composition first and scripting second.