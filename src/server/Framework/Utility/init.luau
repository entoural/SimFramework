local Utility = {}

Utility.Clock = require(script.Clock)

function Utility.Assert(Value: any, Message: string): nil
    if not Value then
        warn(Message)
    end
end

return Utility