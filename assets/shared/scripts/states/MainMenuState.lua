-- You can do anything you would usually do on a normal lua script.
function onCreate()
    print('{'..scriptName..'}: LUA');
end

function onBeatHit()
    print('{'..scriptName..'}: beat')
end

function onDestroy()
    print('{'..scriptName..'}: destroyed')
end