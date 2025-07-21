./readme.md

# GlobalScript Modules

## Information:
- umm, i don't know, sorry :(

### HScript Example:
```haxe
package modules;

function focusGained()
{
	trace('focus gained!!!');
}

function focusLost()
{
	trace('focus lost!!!');
}

function beatHit(beat)
{
	trace('beat hit!!! $beat');
}

function stepHit(step)
{
	trace('step hit!!! $step');
}
```

reference stolen from [`MODULE_test1.hx`](./MODULE_test1.hx)

---

### Lua Example:
```lua
function focusGained()
	print("focus gained!!!");
end;

function focusLost()
	print("focus gained!!!");
end;

function beatHit()
	print("beat hit!!! " + beat);
end;

function stepHit()
	print("step hit!!! " + step);
end;
```

reference stolen from [`MODULE_test2.lua`](./MODULE_test2.lua)
