-- Numbers.applescript
-- EmoMemory
-- The High Scores handler (with an obfuscated file name ;)

--  Created by Aurelio Jargas on 27/03/07.
--  Copyright 2007. All rights reserved.

(*
BETA 1 -- No memorizing
Maximum without shuffle	: 4/12/25
Maximum with shuffle		: 6/49/
Average good				: 10 / 1m5 / 2m50
Looking at screenshot		: ? / 40 / 2m20
Mine best					: 6,7,8 / 49,49,54 / 2m18,2m28,2m32,2m40,2m45,2m50
Stars						: 8 / 50 / 2m20
Default scores				: 30, 45, 60 / 80, 100, 120 / 180, 210, 240


BETA 2 - Memorizing counts
Average good				: 14 / 1m20
Mine best					: 8,9,10,11 / 1m1,1m6,1m5 / 2m31
Stars (total:memorizing)	: 12 : 3 / 1m : 10s / 2m30 : 25s
Default scores				: 30, 45, 60 / 90, 110, 135 / 180, 210, 240
*)


property LI : "" -- list handlers
property theSeed : {{"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-"}, {"R", "W", "M", "X", "Z", "Y", "D", "N", "Q", "K", "H"}}
property nrLevels : 3
property nrScores : 3

property encodedWorm : ""
property splittedWorm : {}
property checkSum : 0
property decodedTable : {} -- {  {score, date},{...},{...} ,  {...} ,  {...}  } -- slots created on init()

property starTimes : {12, 60, 150} -- kid, human, nerd (in seconds)
--property starTimes : {999, 999, 999} -- show all stars
property starMaster : 0
property stars : {} -- { {true, false, false}, {...}, {...}} -- slots created on init()


-- The default score table on first run. Use "Set Default Scores.scpt" to generate this worm.
property defaultWorm : "KMHKKXNMYDYRRTZXHKKXNMYDYRRTKYHKKXNMYDYRRVKQHKKXNMYDYRRTKRRHKKXNMYDYRRTZMRHKKXNMYDYRRVKNRHKKXNMYDYRRTKRWHKKXNMYDYRRTKXWHKKXNMYDYRR"


on _pretty_time(secs)
	set s to secs mod 60 -- mod first because AppleScript floors 1.6 to 2 :/
	set m to (secs - s) / 60 as integer
	set T to ""
	if s is greater than 0 then set T to s & " s"
	if m is greater than 0 then set T to m & " min " & T
	return T as text
end _pretty_time

on _init()
	--log "HS init"
	-- Load list handlers
	set LI to load script (POSIX path of (path to me) & "Contents/Resources/Scripts/List Library.scpt") as POSIX file
	-- Create registers' slots
	repeat nrLevels times
		set end of decodedTable to {}
		set end of stars to {}
		repeat nrScores times
			set end of last item of decodedTable to {}
			set end of last item of stars to false
		end repeat
	end repeat
end _init

-- Updates contents of decodedTable, stars, starMaster
on _update()
	--log "HS _update"
	set starMaster to 0
	set starredCount to {0, 0, 0} -- 1st, 2nd and 3rd places
	
	repeat with i from 1 to nrLevels
		repeat with j from 1 to nrScores
			-- Decode everything and save as "clear" scores
			set {theAmount, theDate} to _decode((item j of item i of splittedWorm) as text)
			set item j of item i of decodedTable to {_pretty_time(theAmount), theDate}
			-- Star fancyness
			if (theAmount as number) is not greater than starTimes's item i then
				set item j of item i of stars to true
				set item j of starredCount to ((item j of starredCount) + 1) -- *j*
				-- Maybe all the 1st (or 2nd or 3rd) places are starred?
				if item j of starredCount is 3 and j is greater than starMaster then set starMaster to j
			else
				set item j of item i of stars to false
			end if
		end repeat
	end repeat
	--log decodedTable
	--log stars
end _update

on _mask(theNumbers)
	--log "HS _mask"
	set {orig, dest} to theSeed
	set theCmd to {"echo", theNumbers, "|", "tr", quoted form of (orig as text), quoted form of (dest as text)}
	set theCode to do shell script LI's _join(theCmd, " ")
	set theCode to (reverse of characters of theCode) as text -- | rev
	--log {theNumbers, theCode}
	return theCode
end _mask

on _unmask(theCode)
	--log "HS _unmask"
	set {orig, dest} to theSeed
	set theCmd to {"echo", theCode, "|", "tr", quoted form of (dest as text), quoted form of (orig as text)}
	set theNumbers to do shell script LI's _join(theCmd, " ")
	set theNumbers to (reverse of characters of theNumbers) as text -- | rev
	--log {theCode, theNumbers}
	return theNumbers
end _unmask

on _encode(elapsedSecs)
	--log "HS _encode"
	set theDate to do shell script LI's _join({"date", "+%s"}, " ") -- today (hidden from "strings" command)
	set encoded to _mask(theDate & "-" & elapsedSecs)
	--log {elapsedSecs, encoded}
	return encoded
end _encode

on _decode(theCode)
	-- Set a delta to use AppleScript's date mechanism for "date string"
	--log "HS _decode"
	try
		set theCode to _unmask(theCode)
		set {theDateEpoched, theAmount} to LI's _split(theCode, "-")
		set now to do shell script LI's _join({"date", "+%s"}, " ") -- hide from "strings" command
		set theDelta to now - theDateEpoched
		set theDate to date string of ((current date) - theDelta)
		--log {theAmount, theDate}
		return {theAmount, theDate}
	on error
		return {(60 * 99) as text, "Error reading scores"}
	end try
end _decode

on _get_checksum(scoresWorm)
	-- remove separators, translate to numbers, add them and multiply for len()
	--log "HS _get_checksum"
	try
		set theCmd to {"echo", scoresWorm, "|", "tr", "-d", "TVH"} -- del separators
		set theNumbers to _unmask(do shell script LI's _join(theCmd, " ")) -- unhide: 136789...
		set theSum to run script LI's _join(characters of theNumbers, "+") -- eval "1+3+6+..."
		return theSum * (count theNumbers)
	on error
		return 0
	end try
end _get_checksum

on _split_worm(theWorm)
	--log "HS _split_worm"
	-- T connect same level, V delimit levels:  ...T...T...V...T...T...V...T...T... 
	set multiWorm to LI's _split(theWorm, "V")
	repeat with i from 1 to count multiWorm
		set item i of multiWorm to LI's _split(item i of multiWorm, "T")
	end repeat
	return multiWorm
end _split_worm

on _join_worm(multiWorm)
	--log "HS _join_worm"
	set theWorm to {}
	repeat with i from 1 to count multiWorm
		set end of theWorm to LI's _join(item i of multiWorm, "T")
	end repeat
	set theWorm to LI's _join(theWorm, "V")
	return theWorm
end _join_worm

on _is_new_record(theLevel, theAmount)
	--log "HS _is_new_record"
	
	set levelScores to item theLevel of splittedWorm
	set {lastScore, lastDate} to _decode(last item of levelScores)
	--log "last score: " & lastScore & ", elapsed: " & theAmount
	return theAmount is less than lastScore
end _is_new_record

on _insert(theLevel, newScore)
	--log "HS _insert"
	
	set levelScores to item theLevel of splittedWorm
	set nrScores to count levelScores
	
	-- Scan current scores and insert the new on the right place
	repeat with i from 1 to nrScores
		set {thisScore, thisDate} to _decode(item i of levelScores)
		if newScore is less than thisScore then
			set inserted to LI's _insert(levelScores, _encode(newScore), i)
			set splittedWorm's item theLevel to items 1 thru nrScores of inserted -- slice and set
			exit repeat
		end if
	end repeat
	
	-- Update registers
	set encodedWorm to _join_worm(splittedWorm)
	set checkSum to _get_checksum(encodedWorm)
end _insert

on _validate()
	--log "HS _validate"
	
	if checkSum is 0 or encodedWorm is "" or _get_checksum(encodedWorm) is not checkSum then
		--log "Scores checksum failed, resetting..." -- user edited?
		set encodedWorm to defaultWorm
		set checkSum to _get_checksum(encodedWorm)
	end if
	
	set splittedWorm to _split_worm(encodedWorm)
end _validate
