-- List Library.applescript
--  Created by Aurelio Jargas on 27/03/07.


-- Sorts a list (copied verbatim from Apple docs)
on _sort(my_list)
	set the index_list to {}
	set the sorted_list to {}
	repeat (count my_list) times
		set the low_item to ""
		repeat with i from 1 to (count my_list)
			if i is not in the index_list then
				set this_item to item i of my_list as text
				if the low_item is "" then
					set the low_item to this_item
					set the low_item_index to i
				else if this_item comes before the low_item then
					set the low_item to this_item
					set the low_item_index to i
				end if
			end if
		end repeat
		set the end of sorted_list to the low_item
		set the end of the index_list to the low_item_index
	end repeat
	return the sorted_list
end _sort

-- Walk the list and swap each item with another whose index is chosen at random
on _shuffle(L)
	--return L -- turns shuffle OFF
	set max to count L
	repeat with i from 1 to max
		set x to random number from 1 to max
		tell item i of L -- swap
			set item i of L to item x of L
			set item x of L to it
		end tell
	end repeat
	return L
end _shuffle

on _split(theText, theSeparator)
	if theText is "" then return {}
	set AppleScript's text item delimiters to theSeparator
	set theList to text items of theText
	set AppleScript's text item delimiters to ""
	return theList
end _split

on _join(theList, theSeparator)
	set AppleScript's text item delimiters to theSeparator
	set theText to theList as text
	set AppleScript's text item delimiters to ""
	return theText
end _join

(*
on _count(theList, theItem) -- count_item
	if theItem is not in theList then return 0
	set counter to 0
	repeat with i from 1 to count of theList
		if item i of theList is equal to theItem then
			set counter to counter + 1
		end if
	end repeat
	return counter
end _count
*)

on _insert(theList, theNewItem, theIndex)
	if class of theNewItem is not list then set theNewItem to {theNewItem}
	if theIndex is less than 2 then
		return theNewItem & theList
	else if theIndex is greater than (count theList) then
		return theList & theNewItem
	else
		return items 1 thru (theIndex - 1) of theList & theNewItem & items theIndex thru -1 of theList
	end if
end _insert

on _index(theList, theItem)
	repeat with i from 1 to count of theList
		if item i of theList is theItem then return i
	end repeat
	return 0
end _index
