**Chexcore** is an evolving solution for creating games in the [LÖVE game engine](https://love2d.org/). It's meant to be a viable solution for most 2D games—but it's especially optimized for *pixel-based* games right now. 

Special class builders are used to greatly reduce the complexity of object-oriented design in Lua; all classes are also added to an inheritance chain which supply useful methods for familial relationships and serialization.

Many base classes are provided to streamline the development process. **Scenes** hold **Layers**, which contain both **Props** (game objects) and a **Canvas** to draw them to. **Canvases** have independent resolutions, can be ordered both within and between **Layers**, and can attach to GLSL **Shaders**, enabling graphically complex 2D scenes.

**Props** contain interfaces for sizing, anchoring, and collision, and they interact with **Rays**, enabling axis-independent collision solutions. **Tilemaps** efficiently break down arbitrarily large tiled structures and handle collision detection with **Props**.

Chexcore has detailed documentation currently living on [Notion](https://chex.notion.site/Documentation-727f7fce6a2f4576ace0c09053a77102).
