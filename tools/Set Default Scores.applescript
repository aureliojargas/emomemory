on join(theList, theSeparator)
	set AppleScript's text item delimiters to theSeparator
	set theText to theList as text
	set AppleScript's text item delimiters to ""
	return theText
end join


tell application "EmoMemory"
	
	-- KID: 1 min: smart child
	set theNumbers to {{30, 45, 60}, {80, 100, 120}, {180, 210, 240}} -- beta 1 (!memorizing)
	set theNumbers to {{30, 45, 60}, {90, 110, 135}, {180, 210, 240}}
	repeat with i from 1 to count theNumbers
		repeat with j from 1 to count item i of theNumbers
			
			-- encode_score
			
			set theDate to do shell script "date +%s" -- today
			-- sourceforge: date --date "20070101" +"%s" -- anyday
			set theDate to "1167638400"
			
			set encoded to do shell script "echo " & theDate & "-" & item j of item i of theNumbers & "| sed \"y/1234567890-/RWMXZYDNQKH/\" | rev"
			set item j of item i of theNumbers to encoded
			
		end repeat
	end repeat
	set multiWorm to theNumbers
	repeat with i from 1 to count multiWorm
		set item i of multiWorm to my join(item i of multiWorm, "T")
	end repeat
	set theWorm to my join(multiWorm, "V")
	
end tell
