./README ASAP.txt

# Information:

- You can make custom states using Haxe or Lua.
- How to open:
    - States:
        - `MusicBeatState.switchState("<CUSTOM_STATE_NAME>", [<args here>]);`
    - Substates:
        - `openSubState(new MusicBeatSubstate("<CUSTOM_SUBSTATE_NAME>", [<args here>]));`
- Any script that starts with "~" will be ignored.
```
    API(s):
        State API: `~State_API.hx`
        Substate API: `~Substate_API.hx`
```

# GlobalScript:

- Anything that starts with the global will be run every state change.
- Example:
    - Allowed:
        - `global.hx`
        - `globalExample.hx`
        - `global_example.hx` (preferred, doesn't make a difference though).
        - `global.example.hx` (why would you even do this?)
    - Not Allowed:
        - `exampleGlobal.hx`
        - `example_global.hx`
        - `example.global.hx`

# Allowed file extensions:

```
    Haxe (HScript):
        - *.hx
        - *.hxc
        - *.hscript

    Lua:
        - *.lua
        - *.funkinlua
```
