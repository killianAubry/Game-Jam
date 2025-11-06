local Timer = {}
Timer.__index = Timer

function Timer.new(duration)
    local self = setmetatable({}, Timer)
    self.duration = duration
    self.remaining = duration
    self.running = false
    return self
end

function Timer:start()
    if not self.running then
        self.running = true
        self:startTimer()
    end
end

function Timer:stop()
    self.running = false
end

function Timer:startTimer()
    if self.remaining > 0 and self.running then
        print("Timer started for " .. self.remaining .. " seconds.")
        self:countDown()
    end
end

function Timer:countDown()
    if self.remaining > 0 and self.running then
        self.remaining = self.remaining - 1
        print("Time remaining: " .. self.remaining .. " seconds.")
        os.execute("sleep 1")
        self:countDown()
    else
        self:reset()
    end
end

function Timer:reset()
    self.remaining = self.duration
    self.running = false
    print("Timer reset.")
end

return Timer