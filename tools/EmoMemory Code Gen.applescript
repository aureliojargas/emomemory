-- Copy the email to the clipboard and run

on split(theText, theSeparator)
	if theText is "" then return {}
	set AppleScript's text item delimiters to theSeparator
	set theList to text items of theText
	set AppleScript's text item delimiters to ""
	return theList
end split

on gen_code(email)
	set magic to 84 -- D. cell
	set mask to {"A", "C", "5", "2", "D", "B", "3", "F", "8", "7"}
	set sum to 0
	-- E-mail chars -> numbers, add all of them in one big number
	repeat with i from 1 to count email
		set sum to sum + (((ASCII number character i of email) + magic + i))
	end repeat
	-- Make sure we have at least 7 digits
	set sum to sum * 333 as text
	-- Mask numbers to fake hexa
	set sumHexa to ""
	repeat with c in characters of sum
		set sumHexa to sumHexa & item (c + 1) of mask
	end repeat
	return email & ":" & sumHexa
end gen_code

set email to the clipboard
gen_code(email)
