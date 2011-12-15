-- Address Book Handler.applescript
-- EmoMemory

--  Created by Aurelio Jargas on 14/03/07.
--  Copyright 2007. All rights reserved.


property abPicturesFolder : POSIX path of (path to application support from user domain) & "AddressBook/Images/"


on get_ab_groups()
	--log "get_ab_groups"
	tell application "Address Book" to set theGroups to name of every group
	return theGroups
end get_ab_groups

on get_ab_picture_count()
	--log "get_ab_picture_count"
	tell application "Address Book"
		set imgCount to 0
		set theImages to image of every person
		repeat with i from 1 to count theImages
			if item i of theImages is not missing value then set imgCount to imgCount + 1
		end repeat
	end tell
	return imgCount
end get_ab_picture_count

on set_playable_ab_groups(levelPictures)
	--log "set_playable_ab_groups"
	set playableGroups to {{}, {}, {}} -- hardcoded - increase when adding a new level
	tell application "Address Book"
		set allGroups to name of every group
		repeat with i from 1 to count allGroups
			set thisGroup to item i of allGroups
			set imgCount to 0
			-- Get the number of contacts with picture (with top limit)
			set theImages to image of every person of group named thisGroup
			repeat with i from 1 to count theImages
				if item i of theImages is not missing value then set imgCount to imgCount + 1
				if imgCount is greater than item 3 of levelPictures then exit repeat
			end repeat
			-- Distribute the group on the right (allowed) slots
			repeat with i from 1 to (count levelPictures)
				if imgCount is not less than item i of levelPictures then
					set end of playableGroups's item i to thisGroup
				end if
			end repeat
		end repeat
	end tell
	return playableGroups
end set_playable_ab_groups

-- Address Book picture filename is the first part of the person ID
-- "F732C918-8776-11D9-B6ED-000D9331DD3A:ABPerson"
--
on get_ab_pictures(theGroup)
	--log "get_ab_pictures"
	set allPictures to {}
	tell application "Address Book"
		set userABid to id of my card
		if theGroup is "" then
			set {theIDs, theImages} to {id, image} of every person
		else
			set {theIDs, theImages} to {id, image} of every person of group named theGroup
		end if
		repeat with i from 1 to count theIDs
			if item i of theImages is not missing value then
				if item i of theIDs is not userABid then -- ignore "My Card"
					set AppleScript's text item delimiters to ":"
					set end of allPictures to abPicturesFolder & text item 1 of item i of theIDs
					set AppleScript's text item delimiters to ""
				end if
			end if
		end repeat
	end tell
	return allPictures
end get_ab_pictures


on ab_activate()
	tell application "Address Book" to activate
end ab_activate