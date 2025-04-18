-- This module provides utility functions for creating and manipulating timers.
-- @module timer
-- author: Ricardo A.
local timer = {}
local timers = {}

-- This function creates a timer that executes a callback at regular intervals
-- @params interval -> number (in seconds)
-- @params callback -> function (to execute at each interval)
function timer.every(interval, callback)
    local t = { interval = interval, callback = callback, elapsed = 0 }
    table.insert(timers, t)
    return {
        stop = function()
            for i, timer in ipairs(timers) do
                if timer == t then
                    table.remove(timers, i)
                    break
                end
            end
        end
    }
end

-- This function creates a one-time timer that executes a callback after a delay
-- @params delay -> number (in seconds)
-- @params callback -> function (to execute after the delay)
function timer.after(delay, callback)
    table.insert(timers, { interval = delay, callback = callback, elapsed = 0, oneTime = true })
end

-- This function creates a timer that executes a callback at regular intervals for a specific duration
-- @params duration -> number (total duration in seconds)
-- @params interval -> number (time between each execution in seconds)
-- @params callback -> function (to execute at each interval)
function timer.start(duration, interval, callback)
    local elapsed = 0
    -- Create the repeating timer
    local repeatingTimer = timer.every(interval, function()
        elapsed = elapsed + interval
        callback()
    end)
    -- Stop the repeating timer after the duration
    timer.after(duration, function()
        repeatingTimer:stop()
    end)
end

-- This function updates all timers (to be called periodically, e.g., in a game loop)
-- @params dt -> number (delta time since the last update, in seconds)
function timer.update(dt)
    for i = #timers, 1, -1 do
        local t = timers[i]
        t.elapsed = t.elapsed + dt
        if t.elapsed >= t.interval then
            t.callback()
            if t.oneTime then
                table.remove(timers, i) -- Remove one-time timer after execution
            else
                t.elapsed = t.elapsed - t.interval
            end
        end
    end
end

return timer
