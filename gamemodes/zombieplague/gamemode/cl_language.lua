Dictionary = Dictionary or {}

function Dictionary:GetPhrase(PhraseID, ...)
	local Phrase = language.GetPhrase(PhraseID)
	if not Phrase or Phrase == PhraseID then
		Phrase = "{UNKNOWN}"
	end

	if select("#", ...) > 0 then
		local Ok, Formatted = pcall(string.format, Phrase, ...)
		if Ok then
			return Formatted
		end
	end

	return Phrase
end