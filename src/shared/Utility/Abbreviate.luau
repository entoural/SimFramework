local Abbreviations = {"k", "M", "B", "T", "Qa", "Qn", "Sx", "Sp", "Oc", "N"} -- Number Abbreviations

local f = math.floor --- Rounds down for example 1.99 becomes 1
local l10 = math.log10 -- Checks how many digits are in a number

return function(Number: number, Decimals: number)
	return f(((Number < 1 and Number) or f(Number) / 10 ^ (l10(Number) - l10(Number) % 3)) * 10 ^ (Decimals or 2)) / 10 ^ (Decimals or 2)..(Abbreviations[f(l10(Number) / 3)] or "")
end