scriptId = 'com.thalmic.jprange.displayinfo'
platform = 'MacOS'
debug = true
vibrate = true
state = 'start'

scrollingState = false
curRoll = 0

secondFraction = 0

startStatePinkyTime = 0
doubleGestureTimeout = 5000

myo.debug("\n\n NEW RUN GENTLEMEN");

function activeAppName()
    return 'WebsiteControl'
end

function onForegroundWindowChange(app,title)
    myo.debug("App: " .. app)
    myo.debug("title: " .. title)

    if string.match(app, 'Chrome') then 
        if title == '' then state = 'start'
        elseif (
                string.match(title, 'reddit:') or 
                string.match(title, 'Hacker News') or
                string.match(title, 'Facebook') or
                string.match(title, 'Twitter') or
                string.match(title, '9GAG') or
                string.match(title, 'Google+') or
                string.match(title, 'TweetDeck')
            ) then state = 'site'
        elseif string.match(title, 'New Tab') then state = 'browser'
        end
    end
    return true
end

function onActiveChange(isActive)
end

function onPoseEdge(pose,edge)
    -- myo.debug("onPoseEdge | pose: " .. pose)
    -- myo.debug("onPoseEdge | edge: " .. edge)
    myo.debug("onPoseEdge | state: " .. state)

    -- A somewhat global gesture (invokes the extension)

    --[[ 
    States:
        - start
        - browser
        - extension 
        - site (supported: Reddit, HN)
        - secondary site (any arrivals from site)
    ]]--

    -- Start state: no browser running yet
    if state == 'start' then
        if pose == 'fist' and edge == 'off' then
            startStatePinkyTime = myo.getTimeMilliseconds()
            myo.vibrate('short')

        elseif pose == 'fingersSpread' and edge == 'off' then
            diff = myo.getTimeMilliseconds() - startStatePinkyTime
            if diff > doubleGestureTimeout then
                return
            end
            myo.vibrate('short')
            openChrome()
            state = 'browser'
        end

    -- Browser state: no extention running yet
    elseif state == 'browser' then
        if pose == 'thumbToPinky' and edge == 'off' then
            myo.keyboard('tab', 'press')
            myo.keyboard('tab', 'press')
            myo.keyboard('m', 'press', 'control')
            wait(100) -- wait for extension to pop up
            state = 'extension'

        elseif pose == 'fist' and edge == 'off' then
            myo.vibrate('long')
            myo.keyboard('w', 'press', 'command')
            state = 'start'
        
        end

    -- Extension state: extension open, options presented
    elseif state == 'extension' then
        if pose == 'waveIn' and edge == 'on' then
            myo.vibrate('short')
            -- myo.debug('onPoseEdge | Detected waveIn')
            myo.keyboard('tab', 'press', 'shift')

        elseif pose == 'waveOut' and edge == 'on' then
            myo.vibrate('short')
            -- myo.debug('onPoseEdge | Detected waveOut')
            myo.keyboard('tab', 'press')

        elseif pose == 'fingersSpread' and edge == 'on' then
            myo.vibrate('short')
            -- myo.debug('onPoseEdge | Detected fingersSpread')
            myo.keyboard('return', 'press', 'shift')
            state = 'site'

        elseif pose == 'thumbToPinky' and edge == 'off' then
            myo.keyboard('m', 'press', 'control')
            wait(100) -- wait for extension to pop up
            state = 'extension'

        elseif pose == 'fist' and edge == 'off' then
            myo.vibrate('long')
            myo.keyboard('w', 'press', 'command')
            state = 'start'
        end

    -- Site state: one of the supported sites open
    elseif state == 'site' then
        if pose == 'waveIn' and edge == 'on' then
            myo.vibrate('short')
            -- myo.debug('onPoseEdge | Detected waveIn')
            myo.keyboard('j', 'press')

        elseif pose == 'waveOut' and edge == 'on' then
            myo.vibrate('short')
            -- myo.debug('onPoseEdge | Detected waveOut')
            myo.keyboard('k', 'press')

        elseif pose == 'fingersSpread' and edge == 'on' then
            myo.vibrate('short')
            -- myo.debug('onPoseEdge | Detected fingersSpread')
            myo.keyboard('l', 'press', 'shift')
            state = 'secondary_site'
            curRoll = myo.getRoll()
        	scrollingState = true

        elseif pose == 'fist' and edge == 'off' then
            myo.vibrate('long')
            myo.keyboard('w', 'press', 'command')
            scrollingState = false

        elseif pose == 'thumbToPinky' and edge == 'on' then
            myo.keyboard('tab', 'press')
            myo.keyboard('tab', 'press')
            myo.keyboard('m', 'press', 'control')
            wait(100) -- wait for extension to pop up
            state = 'extension'
        end

    -- Secondary site state: any arrivals from 'site' state
    elseif state == 'secondary_site' then
        curRoll = myo.getRoll()
        scrollingState = true

        if pose == 'fist' and edge == 'off' then
            myo.vibrate('long')
            myo.keyboard('w', 'press', 'command')
            state = 'site'
            scrollingState = false

        elseif pose == 'thumbToPinky' and edge == 'on' then
            myo.keyboard('tab', 'press')
            myo.keyboard('tab', 'press')
            myo.keyboard('m', 'press', 'control')
            wait(100) -- wait for extension to pop up
            state = 'extension'
            scrollingState = false
        end
    end
end

function onPeriodic() 
    --Timing
    secondFraction = secondFraction + 1
    if (secondFraction > 100) then
        secondFraction = 0
    end


    if scrollingState then
        roll = myo.getRoll() - curRoll
        myo.debug("onPeriodic | roll : " .. roll )

        scrollingspeed = -1 * math.floor(roll/0.25)



        if scrollingspeed > 10 and scrollingspeed > 0 then
        	scrollingspeed = 10
        end
        if scrollingspeed < -10 and scrollingspeed < 0.1 then
        	scrollingspeed = -10
        end

        waitTime = math.floor(30/math.abs(scrollingspeed))

        key = ''

        if scrollingspeed < 0.1 then
        	key = 'up_arrow'
        elseif scrollingspeed > 0 then
        	key = 'down_arrow'
        else
        	waitTime = 101
        end

        myo.debug('onPeriodic | key' .. key)

        if secondFraction % waitTime == 0 then
            i = 0
            while i < scrollingspeed do
        	   myo.keyboard(key, 'press')
               i = i + 1
            end
        end
        
        myo.debug('onPeriodic | scrollingspeed : ' .. scrollingspeed)
    end
end

function openChrome()
    -- myo.debug('openChrome | attempting to write space-command')
    myo.keyboard("space", "press", "command")
    wait(100)
    myo.keyboard('backspace', 'press')
    myo.keyboard('backspace', 'press')
    wait(100)
    letters = {'g', 'o','o', 'g', 'l', 'e', 'space', 'c', 'h', 'r', 'o', 'm', 'e'}
    i = 1
    while letters[i] ~= nil do
        myo.keyboard(letters[i], "press")
        i = i + 1
    end

    wait(200)

    -- myo.debug('openChrome | About to press RETURN')
    myo.keyboard("return", "press")
    -- -- myo.debug('openChrome | Return Pressed!')


    wait(300)
    myo.keyboard("l", "press", "control")
    wait(300)
    letters = {'w','w','w','period','h','a','c','k','t','h','e','n','o','r','t','h','period','c','o','m'}
    i = 1
    while letters[i] ~= nil do
        
        myo.keyboard(letters[i], "press")
        i = i + 1
    end
    myo.keyboard("return", "press")
    wait(200)
    for i=1,7 do
     myo.keyboard('tab', 'press')
    end
    myo.keyboard("return", "press")
end

function wait(millis) --guarantee wait of longer or equal than time given
    startTime = myo.getTimeMilliseconds()

    while myo.getTimeMilliseconds() - startTime < millis do

    end

end


--myo.vibrate(vibrationType) 
--myo.getArm() 
--myo.getXDirection()
--myo.getTimeMilliseconds()
--myo.debug(output)
--myo.getRoll()
--myo.getPitch()
--myo.getYaw()
--myo.keyboard(key,edge,modifiers)
--rest, fist, wavein, waveout, fingersSpread, thumbToPinky, unknown