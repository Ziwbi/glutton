--Modified from http://lua-users.org/wiki/FormattingNumbers
local function comma_value(amount)
    local formatted = amount
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
            break
        end
    end
    return formatted
end
local function round(val, decimal)
    if (decimal) then
        return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
    else
        return math.floor(val+0.5)
    end
end
local function format_num(amount, decimal)
    local formatted, famount

    famount = math.abs(round(amount,decimal))
    famount = math.floor(famount)

    -- comma to separate the thousands
    formatted = comma_value(famount)

    return formatted
end

return {
    comma_value = comma_value,
    round = round,
    format_num = format_num
}
