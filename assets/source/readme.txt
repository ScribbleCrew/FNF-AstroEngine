./readme.txt

Information:
    You can make custom states using Haxe or Lua.
    How to open:
        - States:
            MusicBeatState.switchState("<CUSTOM_STATE_NAME>", [<args here>]);
        - Substates:
            openSubState(new MusicBeatSubstate("<CUSTOM_SUBSTATE_NAME>", [<args here>]));

GlobalScript:
    Anything that starts with the global will be run every state change.
    Example:
        - global.hx
        - globalExample.hx
        - global_example.hx (preferred, doesn't make a difference though).

Allowed file extensions:
    Haxe (HScript):
        - *.hx
        - *.hxc
        - *.hxp
        - *.hscript
    
    Lua:
        - *.lua
        - *.funkinlua