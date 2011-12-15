-- Remember Me?.applescript -- Legacy name :(
-- EmoMemory

--  Created by Aurelio Jargas on 04/03/07.
--  Copyright 2007. All rights reserved.

--Release Checklist:
-- OK Settings default in user Pics in IB
-- OK TEST ALL MENUS AND BUTTONS AND EVERYTHING
-- OK Rebuild the Help
-- OK LOG commenter: ^(\s*)log\s    "$1--@log " 
-- OK Clear All & Build
-- Test on the clear user, no internet

--v2:
-- TODO load folder: big pictures warning
-- TODO sound for starred (YEAH!)
-- TODO scores for memorizing mode: zero errors on game play (1 error, game ends)
-- TODO Adium support (PRO ? v2? mkt++)
-- TODO arrastar folder pro text field do tab "folder"
-- TODO choose iChat folder, like Flags ?
-- TODO checkboxes on tab "folder" to filter filetypes [] gif  [] jpg ...)
-- TODO /Library/Printers/hp/Icons (selecionar alguns diferentes entre si)
-- TODO /Library/Printers/Lexmark/Printer Icons (idem)
-- TODO check for updates
-- XXX cada vez que carrega o jogo, consumo de RAM aumenta. ver notas sobre "load image" :(
--        parece ser problema de image view + matrix. se deletar a matriz e recriar, resolve?
--        deu 230MB quando eu tava testando o nivel hard :(
-- world: show country?
-- Open Recent -- how to populate it? save folder + level
-- TODO pt_BR! (info.plist nao precisa, AS tem que separar frases num arquivo)
-- sparkle pra update automatico
-- Tooltips with the full name and other info on the memorization time
-- memorization mode, where one error terminates the game

---- Other:
-- TODO gwm: som desligado por default
-- TODO gwm: tirar os 3 botoes do meio
-- TODO gwm: square eh confuso e sem muita utilidade
-- Botao verde e vermelho nas preferences, pro cara saber que escolheu algo bom (ficou muito carregado, muitas images e cores)
-- TODO list of Recent Folders (local) no File > Recent (automatic?)
-- arrastar grupo de imagens pra janela do jogo (v2, se funcionar no ASS)
-- arrastar dir, pega todas as imagens de dentro
-- salvar image sets
-- pegar das imagens de wallpaper (pesaaaaado) /Library/Desktop Pictures
-- album do iphoto (get thumbs) [gwm]
-- tela de config?
-- mais sons , animacoes e firulas
-- 1 2 3 4: 12 Slowly Fading Fast.wav NUFAN
-- TODO help files (foto > icone toolbar > foto nova - pra ilustrar funcionamento)
-- iTunes artwork? (nao sao imagens...)
-- Thanks: Neuron image by http://medgadget.com/archives/2005/12/how_the_neuron.html
-- XXX pq a drawer "engasga" ao abrir/fechar? (nao eh "will open/close")
-- XXX: pause only if requested by users. Each game is just around 2 minutes. 

-- Startup on clear user is 4s (with AB) -- 1.0b1

property myVersion : "1.0" -- Remember to update the About screen
property myUrl : "http://aurelio.net/soft/emomemory/"
property scoresUrl : myUrl & "scores.php"
property testimonialUrl : myUrl & "users.php"
property registerUrl : myUrl & "buy.php"

property theBoard : {} -- saves all board images paths
property theBoardImages : {} -- saves all board images
property boardSize : {4, 4} -- default at start up
property boardLoaded : false
property levelSizes : {4, 6, 8}
property levelPictures : {} -- calculated from levelSizes
property starTimes : {12, 60, 150} -- kid, human, nerd (in seconds)
property playableGroups : {}
property theState : 0 -- 0 user turn / 1 one card revealed / 2 two cards / 99 waiting game's first click / 10 victory / -1 gave up or switched window
property openedCells : {} -- row, col
property keyImage : ""
property missingFriends : 0
property soundOK : ""
property soundOuch : ""
property soundStart : ""
property soundClick : ""
property soundVictory : ""
property soundHiScore : ""
property totalFolderPictures : 0
property systemFolders : {"/Library/User Pictures", "/Library/Widgets", "/Library/Application Support/Apple/iChat Icons"}
property systemFoldersPreview : {}
property systemFoldersCount : {}
property totalAbPictures : 0
property resourcesPath : ""
property userABid : ""
property timeInit : ""
property initDone : false
property AB : "" -- Will load the the AB handler
property LI : "" -- Will load the List Library
property HS : "" -- Will load the High Scores handler

-- Preferences
property localFolder : ""
property playSounds : true
property useAB : true

property isRegistered : false
property isExpired : false

-- Messages
property scoredMessages : {"Yeah!", "Hey Beavis, we scored!", "Yahoo!", "Woohoo!", "Da dada da da...", "Super!", "Great!"}
property starMasterLabels : {"You rule!", "Wow, two stars mastered!", "Perfect scores. You're the master."}
property startupTips : {Â
	"You can resize the game window at ANY time.", Â
	"Choose an emotional Address Book group, like Family or Friends.", Â
	"All your settings are saved automatically, don't worry.", Â
	"Submit your scores to the World Ranking to join our party!", Â
	"The toolbar is customizable. Check out the View menu.", Â
	"Have you got any stars? They're so cool!", Â
	"Turn off the TV.", Â
	"Increase the window size and use the Zoom button!", Â
	"Some people are faster on memorizing, some on try & error.", Â
	"Pay special attention to the four corners!", Â
	"This heart-logo is so cute, isn't it?", Â
	"Try to reveal pictures in a sequence.", Â
	"Paired pictures near to each other are easy to remember.", Â
	"Stretch!", Â
	"The clock won't wait, try to click faster!", Â
	"Can you win with NO errors?", Â
	"Print the World Ranking and stick to your wall.", Â
	"Don't let the Nerd level scare you, just beat it!", Â
	"A silent room will help.", Â
	"The more you play, faster you become.", Â
	"Good memories will make you remember more.", Â
	"Invite some of these friends for a dinner!", Â
	"Maximize the window and use the View > Square Board option.", Â
	"Speak the names of your friends when memorizing.", Â
	"When you get blank, get back to good old try & error.", Â
	"Seek for friends with some relationship near to each other.", Â
	"Can you click as faster as your thoughts?", Â
	"Don't give up!", Â
	"Yellowcard is a great band.", Â
	"Collect stars and see the Hi-Scores icon changing!"}

(* property giveupMessages : {Â
	{"No! Please try again, ppp-leeeease?", "Leaving so soon!", "I think you could make it, try again!", "Next time you'll win!"}, Â
	{"Maybe next time?", "Well, come back soon!", "No as easy as it seemed, don't it?", "See you!"}, Â
	{"What's that letter after K and before M?", "Ok. Children's out.", "Once *again*?", "Ha! I knew you couldn't make it."}}
*)

on to_bool(val)
	if val is in {false, 0, "0", "", {}} then return false
	return true
end to_bool

on strip(theText)
	set theBlanks to {" ", tab, return, ASCII character 10} -- 10 for text view
	try
		repeat while (first character of theText is in theBlanks)
			set theText to characters 2 thru -1 of theText as text
		end repeat
		repeat while (last character of theText is in theBlanks)
			set theText to characters 1 thru -2 of theText as text
		end repeat
	on error
		return "" -- theText is now empty
	end try
	return theText
end strip

on select_abgroup_popup_title(theTitle)
	--@log "select_abgroup_popup_title"
	tell popup button "abgroup" of tab view item "ab" of tab view 1 of window "settings"
		set theTitles to title of menu items
		repeat with i from 1 to count theTitles
			if item i of theTitles is theTitle then
				set current menu item to menu item i
				return
			end if
		end repeat
	end tell
end select_abgroup_popup_title

on check_code(theCode) -- Example: verde@aurelio.net:CCAAB3B
	--@log "check_code: " & theCode
	set magic to 84 -- D. cell
	set mask to {"A", "C", "5", "2", "D", "B", "3", "F", "8", "7"}
	set sum to 0
	-- Try to generate the hexa sum on the fly to compare with user informed
	try
		-- Parse and sanity
		set {email, code} to LI's _split(theCode, ":")
		if (count email) is less than 6 then return false -- minimum: a@a.tv, avoids empty gotchas
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
		--@log {code, sumHexa}
	on error
		return false
	end try
	return sumHexa is equal to code
end check_code

on get_install_date()
	--@log "get_install_date"
	set now to do shell script LI's _join({"date", "+%s"}, " ")
	set ver to myVersion's character 1 & myVersion's character 3 -- 1.0 -> 10
	--@log (now & ver) as text
	return (now & ver) as text
end get_install_date

on check_expired(installDate)
	--@log "check_expired :: " & installDate
	set trialDays to 20
	
	-- First run?
	if installDate is "" then
		--@log "--FIRST RUN"
		set_config("tick", get_install_date())
		set isExpired to false
		return
	end if
	
	-- Split values date+version
	try
		set installVersion to (character -2 of installDate) & "." & (character -1 of installDate)
		set installDate to (characters 1 thru -3 of installDate) as text
	on error
		--@log "--HACKED: FORMAT ERROR"
		set isExpired to true
		return
	end try
	
	-- If user updated to new version, reset trial
	if installVersion is less than myVersion then
		--@log "--UPDATED TRIAL"
		set_config("tick", get_install_date())
		set isExpired to false
		return
	end if
	
	-- Calculate elapsed trial time
	set now to do shell script LI's _join({"date", "+%s"}, " ")
	set timeDelta to (now as number) - (installDate as number)
	--@log {timeDelta, installVersion, myVersion}
	
	-- User hacked?
	if timeDelta is less than 0 or installVersion is greater than myVersion then
		--@log "--HACKED BY USER"
		set isExpired to true
		return
	end if
	
	-- Trial expired?
	if timeDelta is greater than (trialDays * 24 * 60 * 60) then
		--@log "--EXPIRED"
		set isExpired to true
		return
	end if
end check_expired

on check_level_matrix(pictAmount)
	--@log "check_level_matrix"
	tell matrix "level" of window "settings"
		repeat with i from 1 to count levelPictures
			set enabled of cell i to (pictAmount is not less than item i of levelPictures)
		end repeat
	end tell
end check_level_matrix

on reset_state()
	set theState to 0
	set keyImage to ""
	set openedCells to {}
end reset_state

on clear_board()
	--@log "clear_board"
	tell window "main"
		if theState is 10 then set visible of image view "checked" to false
		set visible of image view "no focus" to false
		delete image of every cell of matrix "board"
		my set_status_bar("")
		update
		set boardLoaded to false
	end tell
end clear_board

on show_all_pictures()
	--@log "show_all_pictures"
	try
		tell matrix "board" of window "main"
			repeat with i from 1 to item 1 of boardSize
				repeat with j from 1 to item 2 of boardSize
					set current row to i
					set current column to j
					set theImage to item j of item i of theBoardImages
					--					set image of current cell to load image theImage
					set image of current cell to theImage
				end repeat
			end repeat
		end tell
	end try
end show_all_pictures

on set_status_bar(txt)
	set content of text field "statusbar" of window "main" to txt
end set_status_bar

on set_tip(tipIndex)
	set max to count startupTips
	if tipIndex is 0 then -- loop
		set tipIndex to max
	else if tipIndex is greater than max then
		set tipIndex to 1
	end if
	set_config("tip", tipIndex)
	set contents of text field "tip" of window "tips" to item tipIndex of startupTips
end set_tip

on expand_tilde(thePath)
	if thePath starts with "~" then set thePath to do shell script "echo ~" & characters 2 thru -1 of thePath as text
	return thePath
end expand_tilde

on update_stats()
	set_status_bar("Level " & title of current cell of matrix "level" of window "settings" & ", " & missingFriends & " pictures are missing")
end update_stats

on get_config(theKey)
	return contents of default entry theKey of user defaults
end get_config

on set_config(theKey, theValue)
	set contents of default entry theKey of user defaults to theValue
end set_config

on flip_config(theKey)
	set_config(theKey, not get_config(theKey))
end flip_config

on shout(thisSound)
	if playSounds then play thisSound
	-- if get_config("playSounds") then play thisSound -- too slow
end shout

on get_sys_folder_pictures(folderIndex)
	set theFilter to ""
	if folderIndex is 2 then set theFilter to "\\.wdgt/Icon.png$" -- Widgets
	return get_folder_pictures(item folderIndex of systemFolders, theFilter)
end get_sys_folder_pictures

-- TODO loop to load each picture to an image view, to test it and get the real picture count
-- TODO how to get pictures with no extension? file * ?
-- TODO maybe create a thumb when the pictures are too big? ( [ ] checkbox at New Game)
on get_folder_pictures(theFolder, theFilter)
	--@log "get_folder_pictures"
	if theFilter is "" then set theFilter to "."
	set shellCmd to "find " & quoted form of expand_tilde(theFolder) & " -type f | egrep -si \"\\.(tiff?|png|gif|jpe?g|bmp|icns)$\" | egrep \"" & theFilter & "\"; true" -- always true
	return LI's _split(do shell script shellCmd, return)
end get_folder_pictures

on set_scale_method()
	--@log "set_scale_method"
	
	if get_config("zoomed") then
		set image scaling of every cell of matrix "board" of window "main" to scale to fit
		--set image of toolbar item "zoom" of toolbar 1 of window "main" to load image "unzoom"
		set title of menu item "zoom" of sub menu of menu item "view" of main menu to "Unzoom"
	else
		set image scaling of every cell of matrix "board" of window "main" to scale proportionally
		--set image of toolbar item "zoom" of toolbar 1 of window "main" to load image "zoom"
		set title of menu item "zoom" of sub menu of menu item "view" of main menu to "Zoom"
	end if
	update window "main"
end set_scale_method

on set_sound_system()
	--@log "set_sound_system"
	if playSounds then
		set image of toolbar item "sound" of toolbar 1 of window "main" to load image "sound-on"
		set title of menu item "sound" of sub menu of menu item "game" of main menu to "Turn Sound Off"
	else
		set image of toolbar item "sound" of toolbar 1 of window "main" to load image "sound-off"
		set title of menu item "sound" of sub menu of menu item "game" of main menu to "Turn Sound On"
	end if
end set_sound_system

on set_score_submit(theState)
	--@log "set_score_submit"
	set_config("scoresSubmit", theState)
	tell window "submit"
		if theState is 0 then
			set contents of text field "status" to "Scores sent successfully!"
			set title of button "cancel submit" to "Close"
		else
			set contents of text field "status" to ""
			set title of button "cancel submit" to "Cancel"
		end if
	end tell
end set_score_submit

on set_ab_mode(theRow)
	--@log "set_ab_mode"
	tell tab view item "ab" of tab view 1 of window "settings"
		if theRow is greater than 0 then set current row of matrix "abmode" to theRow
		set currRow to current row of matrix "abmode"
		set enabled of popup button "abgroup" to currRow is 2 -- Groups popup linked to row 2		
	end tell
	if currRow is 2 then
		set enabled of cells of matrix "level" of window "settings" to true -- Groups: levels are always ON
	else
		my check_level_matrix(totalAbPictures) -- All cards
	end if
end set_ab_mode

on set_sys_folder(theNewRow)
	--@log "set_sys_folder"
	tell tab view item "sys" of tab view 1 of window "settings"
		if theNewRow is greater than 0 then set current row of matrix "sys folder" to theNewRow
		set theIndex to current row of matrix "sys folder"
		set image of image view "preview" to item theIndex of systemFoldersPreview
	end tell
end set_sys_folder

on set_local_folder(theFolder)
	--@log "set_local_folder"
	set localFolder to theFolder
	set totalFolderPictures to count get_folder_pictures(localFolder, "")
	set contents of text field "folder path" of tab view item "folder" of tab view 1 of window "settings" to localFolder
	set contents of text field "folder stats" of tab view item "folder" of tab view 1 of window "settings" to "This folder has " & totalFolderPictures & " pictures."
end set_local_folder

on populate_internal_matrix(theData)
	--@log "populate_internal_matrix"
	set {y, x} to boardSize
	set totalPics to (y * x) / 2 as integer
	set missingFriends to totalPics
	
	if (count theData) is less than totalPics then
		display alert "Insufficient pictures" as warning message "I need " & totalPics & " pictures to build this level, but I just have " & (count theData) & ". Please, don't blame me, I'm just a dumb peace of software. Could you try again?"
		return
	end if
	-- Shuffle all, slice to board size, double and reshuffle
	set theData to items 1 thru totalPics of LI's _shuffle(theData)
	--	set theData to items 1 thru totalPics of shuffle(theData)
	set theData to LI's _shuffle(theData & theData)
	--	set theData to shuffle(theData & theData)
	set theBoard to {}
	set theBoardImages to {}
	repeat y times
		set the end of theBoard to {}
		set the end of theBoardImages to {}
		repeat x times
			set the end of last item of theBoard to first item of theData
			set the end of last item of theBoardImages to load image (first item of theData) -- save loaded images on the board
			set theData to rest of theData
		end repeat
	end repeat
	set boardLoaded to true
end populate_internal_matrix

--on resize_matrix(theAmount)
on resize_matrix(newSize)
	--@log "resize_matrix"
	
	if newSize is equal to item 1 of boardSize then
		--@log "NO NEED TO RESIZE"
		return -- already done
	end if
	set theMatrix to matrix "board" of window "main"
	set theAmount to newSize - (item 1 of boardSize)
	-- Add or remove?
	if theAmount is less than 0 then
		repeat with i from theAmount to -1
			call method "removeColumn:" of object theMatrix with parameter 1
			call method "removeRow:" of object theMatrix with parameter 1
		end repeat
	else
		repeat theAmount times
			call method "addColumn" of object theMatrix
			call method "addRow" of object theMatrix
		end repeat
		set_scale_method()
		set control view of every cell of matrix "board" of window "main" to missing value
	end if
	-- Save new dimensions
	set y to call method "numberOfRows" of object theMatrix
	set x to call method "numberOfColumns" of object theMatrix
	set boardSize to {y, x}
	--@log boardSize
	-- Increase/decrease the window by 1 pixel just to force the matrix redraw with the new size
	set extraPixel to 1
	if theAmount is less than 0 then set extraPixel to -1
	set winSize to size of window "main"
	set winSize's item 1 to (winSize's item 1) + extraPixel
	set size of window "main" to winSize
	tell window "main" to update
end resize_matrix

on populate_ab_group_popup(isUpdate)
	--@log "populate_ab_group_popup"
	
	-- Enable just the groups with sufficient pictures to play the current level
	set currLevelIndex to current row of matrix "level" of window "settings"
	set okGroups to playableGroups's item currLevelIndex
	
	tell popup button "abgroup" of tab view item "ab" of tab view 1 of window "settings"
		-- Create or update
		if isUpdate then
			repeat with thisItem in menu items
				set enabled of thisItem to thisItem's title is in okGroups
			end repeat
		else
			try
				delete every menu item of menu of it
			end try
			tell AB to set abGroups to get_ab_groups()
			if abGroups is {} then
				-- Fake item to avoid extra IFs on the code
				make new menu item at the end of menu items of menu of it with properties {|title|:"", |enabled|:false}
			else
				repeat with thisGroup in my LI's _sort(abGroups) -- ASCII_Sort(abGroups)
					make new menu item at the end of menu items of menu of it with properties {|title|:thisGroup, |enabled|:thisGroup is in okGroups}
				end repeat
			end if
		end if
	end tell
end populate_ab_group_popup

on check_settings()
	--@log "check_settings"
	set currTab to current tab view item of tab view 1 of window "settings"
	set currLevel to current cell of matrix "level" of window "settings"
	set playButton to button "play" of window "settings"
	
	-- The common situation is the state of the current level to command the OK button (exception:ab)
	
	if name of currTab is "ab" then
		set abgroupPopup to popup button "abgroup" of currTab
		
		if current row of matrix "abmode" of currTab is 1 then
			-- All cards
			set enabled of abgroupPopup to false
			check_level_matrix(totalAbPictures)
			set enabled of playButton to enabled of currLevel
		else
			-- Group
			set enabled of abgroupPopup to true
			set enabled of cells of matrix "level" of window "settings" to true -- Groups, level is always ON
			set enabled of playButton to enabled of current menu item of abgroupPopup
		end if
		
	else if name of currTab is "sys" then
		set sysFolderIndex to current row of matrix "sys folder" of currTab
		set pictCount to item sysFolderIndex of systemFoldersCount
		check_level_matrix(pictCount)
		set enabled of playButton to (enabled of currLevel and enabled of current cell of matrix "sys folder" of currTab)
		
	else if name of currTab is "folder" then
		if localFolder is "" then
			set enabled of cells of matrix "level" of window "settings" to true -- always ON
			set enabled of playButton to false
		else
			check_level_matrix(totalFolderPictures)
			set enabled of playButton to enabled of currLevel
		end if
	end if
	(*
	if enabled of playButton then
		set image of image view "settings ok" of window "settings" to load image "settings-ok"
	else
		set image of image view "settings ok" of window "settings" to load image "settings-nok"
	end if
	*)
	
end check_settings

on level_changed()
	if useAB then populate_ab_group_popup(true)
	check_settings()
end level_changed

on load_level()
	set currLevelIndex to current row of matrix "level" of window "settings"
	set levelSize to item currLevelIndex of levelSizes
	resize_matrix(levelSize)
end load_level

on load_highscores()
	--@log "load_highscores"
	
	HS's _update()
	
	set hiScores to HS's decodedTable
	
	set starred to false
	set starMaster to 0
	tell drawer "scores" of window "main"
		
		-- First remove all stars (image cell doesn't have the visible property :( )
		repeat with i from 1 to 3
			delete image of every cell of matrix ("star" & i)
		end repeat
		
		-- Read all encoded scores and populate the drawer
		repeat with i from 1 to count hiScores
			repeat with j from 1 to count item i of hiScores
				set {theScore, theDate} to item j of item i of hiScores
				set contents of cell j of matrix ("time" & i) to theScore
				set contents of cell j of matrix ("date" & i) to theDate
				
				if item j of item i of HS's stars then
					set image of cell j of matrix ("star" & i) to load image ("star-" & j)
					set starred to true
				end if
			end repeat
		end repeat
		
		-- XXX sux but "update" doesn't work and the stars are not updated automatically
		if starred and initDone and state is drawer opened then
			close drawer
			delay 0.5
			open drawer
		end if
	end tell
	
	-- Level starring mastering, the toolbar icons changes
	if HS's starMaster is greater than 0 then
		tell toolbar 1 of window "main"
			set image of toolbar item "scores" to load image "scores-starred-" & HS's starMaster
			set tool tip of toolbar item "scores" to item (HS's starMaster) of starMasterLabels
		end tell
		tell window "main" to update
	end if
end load_highscores

on load_game()
	set_status_bar("Loading pictures...")
	set enabled of matrix "board" of window "main" to false
	
	set theSettingsTab to current tab view item of tab view 1 of window "settings"
	set pictSource to name of theSettingsTab
	
	if pictSource is "sys" then
		set i to current row of matrix "sys folder" of theSettingsTab
		set thePictures to get_sys_folder_pictures(i)
		
	else if pictSource is "ab" then
		if not useAB then
			set_status_bar("Address Book support disabled, please load a new game.")
			return
		end if
		if current row of matrix "abmode" of theSettingsTab is 1 then
			tell AB to set thePictures to get_ab_pictures("") -- all
		else
			set theGroup to title of current menu item of popup button "abgroup" of theSettingsTab
			tell AB to set thePictures to get_ab_pictures(theGroup)
		end if
		
	else if pictSource is "folder" then
		set thePictures to get_folder_pictures(localFolder, "") -- TODO checkboxes for file extension
	else
		return -- unknown tab
	end if
	
	populate_internal_matrix(thePictures)
	show_all_pictures()
	shout(soundStart)
	set theState to 99
	set_status_bar("Time to memorize! The clock is ticking...")
	
	if boardLoaded then
		set enabled of matrix "board" of window "main" to true
		set enabled of menu item "zoom" of sub menu of menu item "view" of main menu to true
	else
		set_status_bar("Something strange happened. Please, start a new game.")
	end if
	tell window "main" to update
	set timeInit to current date
	--@log "CLOCK STARTED"
end load_game

on victory()
	set timeEnd to current date
	set elapsedSecs to timeEnd - timeInit
	set theState to 10
	
	set visible of image view "checked" of window "main" to true
	set_status_bar("Elapsed time: " & HS's _pretty_time(elapsedSecs))
	
	if soundVictory is "" then set soundVictory to load sound "Glass3"
	shout(soundVictory)
	
	-- New record?
	set levelIndex to current row of matrix "level" of window "settings"
	if not HS's _is_new_record(levelIndex, elapsedSecs) then return -- loser
	
	-- Ok, we've got a record!
	
	--@log "NEW RECORD!"
	if soundHiScore is "" then set soundHiScore to load sound "Applause"
	shout(soundHiScore)
	set enabled of matrix "board" of window "main" to false
	set_score_submit(1) -- Re-enable the Submit button to send this new record
	
	HS's _insert(levelIndex, elapsedSecs) -- save record
	
	-- Warn the user!
	--set_status_bar("\\o/")
	load_highscores()
	
	set theLevel to title of current cell of matrix "level" of window "settings"
	display alert (some item of scoredMessages) as warning message "New record for the " & theLevel & " level: " & HS's _pretty_time(elapsedSecs) attached to window "main"
	tell drawer "scores" of window "main" to open drawer
	
	save_defaults() -- Do something useful when waiting for user button pressing
	set_status_bar("") -- To clear save_defaults() message
end victory

on save_defaults()
	--@log "save_defaults"
	-- set_status_bar("Saving preferences...") -- Better hide it from curious hackers
	
	-- playerName is binded on IB to the text field, saved on TAB, Enter and "Send" button click (not Cancel)
	
	tell window "settings"
		set lastTabView to name of current tab view item of tab view 1
		set lastLevel to current row of matrix "level"
		set lastAbGroup to title of current menu item of popup button "abgroup" of tab view item "ab" of tab view 1
		set lastAbMode to current row of matrix "abmode" of tab view item "ab" of tab view 1
		set lastSysFolder to current row of matrix "sys folder" of tab view item "sys" of tab view 1
	end tell
	tell drawer "scores" of window "main"
		set scoresVisible to state is drawer opened
		set drawerSize to content size
	end tell
	set windowSize to size of window "main"
	set scoresWorm to HS's encodedWorm
	set scoresSum to HS's checkSum
	
	try
		tell user defaults -- save current state
			set contents of default entry "soundOn" to playSounds
			set contents of default entry "lastTabView" to lastTabView
			set contents of default entry "lastLevel" to lastLevel
			set contents of default entry "lastAbMode" to lastAbMode
			set contents of default entry "lastAbGroup" to lastAbGroup
			set contents of default entry "lastSysFolder" to lastSysFolder
			set contents of default entry "scoresVisible" to scoresVisible
			set contents of default entry "windowSize" to windowSize
			set contents of default entry "drawerSize" to drawerSize
			set contents of default entry "registrationSeed" to scoresWorm
			set contents of default entry "scores" to scoresSum
			set contents of default entry "useAB" to useAB
		end tell
		call method "synchronize" of object user defaults -- Save in disk
	end try
end save_defaults

on awake from nib theObject
	--@log "  event: awake from nib"
	
	-- ./~ Everybody center now! ./~
	tell every window to center
	
	tell window "loading"
		set contents of text field "startup tip" to "Startup Tip: " & some item of startupTips -- random
		tell progress indicator 1 to start
		show
		-- activate -- TODO how to activate it?
	end tell
	
	set resourcesPath to POSIX path of (path to me) & "Contents/Resources/"
	set LI to load script (resourcesPath & "Scripts/List Library.scpt") as POSIX file
	set HS to load script (resourcesPath & "Scripts/Numbers.scpt") as POSIX file
	HS's _init()
	
	---------------------------------------------------------------------------------------------------------- 
	-- USER DEFAULTS
	-- Read the values now, saves on high score, force save on "will quit".
	--
	--@log "reading preferences..."
	
	tell user defaults
		-- Create entries
		make new default entry at end with properties {name:"NSNavLastCurrentDirectory", contents:""} -- mac
		make new default entry at end with properties {name:"drawerSize", contents:{}}
		make new default entry at end with properties {name:"lastAbGroup", contents:""}
		make new default entry at end with properties {name:"lastAbMode", contents:1}
		make new default entry at end with properties {name:"lastLevel", contents:1}
		make new default entry at end with properties {name:"lastSysFolder", contents:1}
		make new default entry at end with properties {name:"lastTabView", contents:""}
		make new default entry at end with properties {name:"playerName", contents:""}
		make new default entry at end with properties {name:"registrationSeed", contents:""}
		make new default entry at end with properties {name:"registrationDate", contents:""}
		make new default entry at end with properties {name:"registrationVersion", contents:""}
		make new default entry at end with properties {name:"keycode", contents:""}
		make new default entry at end with properties {name:"tick", contents:""}
		make new default entry at end with properties {name:"scores", contents:0}
		make new default entry at end with properties {name:"scoresVisible", contents:false}
		make new default entry at end with properties {name:"scoresSubmit", contents:false}
		make new default entry at end with properties {name:"testimonialSent", contents:false}
		make new default entry at end with properties {name:"useAB", contents:true}
		make new default entry at end with properties {name:"soundOn", contents:true}
		make new default entry at end with properties {name:"zoomed", contents:false}
		make new default entry at end with properties {name:"tip", contents:1}
		make new default entry at end with properties {name:"windowSize", contents:{}}
		-- Normalize defaults
		repeat with entryName in {"scoresVisible", "scoresSubmit", "testimonialSent", "useAB", "soundOn", "zoomed"}
			set contents of default entry entryName to my to_bool(contents of default entry entryName)
			-- Note that string values will raise error on startup, because they're read before
		end repeat
		-- Read values: globals
		set playSounds to contents of default entry "soundOn"
		set useAB to contents of default entry "useAB"
		set localFolder to contents of default entry "NSNavLastCurrentDirectory"
		-- Read values: locals
		set installDate to contents of default entry "tick"
		set keyCode to contents of default entry "keycode"
		set registrationDate to contents of default entry "registrationDate"
		set encodedScores to contents of default entry "registrationSeed"
		set encodedScoresSum to contents of default entry "scores"
		set lastTabView to contents of default entry "lastTabView"
		set lastLevel to contents of default entry "lastLevel"
		set lastAbMode to contents of default entry "lastAbMode"
		set lastAbGroup to contents of default entry "lastAbGroup"
		set lastSysFolder to contents of default entry "lastSysFolder"
		set windowSize to contents of default entry "windowSize"
		set drawerSize to contents of default entry "drawerSize"
	end tell
	
	set HS's encodedWorm to encodedScores
	set HS's checkSum to (encodedScoresSum as integer)
	
	---------------------------------------------------------------------------------------------------------- 
	-- KEYCODE
	--
	--@log "checking keycode..."
	
	set isRegistered to check_code(keyCode)
	if isRegistered then
		--@log "REGISTERED"
		set isExpired to false -- just to make sure
	end if
	
	---------------------------------------------------------------------------------------------------------- 
	-- EXPIRATION
	--
	--@log "checking expiration..."
	
	if not isRegistered then
		if installDate is "" and windowSize is not {} then -- !first run, user edited
			--@log "--USER DELETED tick KEY"
			set isExpired to true
		else
			check_expired(installDate)
		end if
	end if
	
	---------------------------------------------------------------------------------------------------------- 
	-- BYPASS CHECKINGS
	--set isExpired to true
	--set isRegistered to false
	--set useAB to false
	
	---------------------------------------------------------------------------------------------------------- 
	-- SCORES
	--
	--@log "checking scores..."
	
	HS's _validate()
	
	-- Adjust scores drawer
	tell drawer "scores" of window "main"
		set background color of window of content view to {63000, 63000, 63000}
		if drawerSize is not {} then set content size to drawerSize
	end tell
	
	
	---------------------------------------------------------------------------------------------------------- 
	-- TOOLBAR
	--
	--@log "creating toolbar..."
	
	-- Make the new toolbar, giving it a unique identifier
	set theToolbar to make new toolbar at end with properties {name:"toolbar", identifier:"toolbar id", allows customization:true, auto sizes cells:true, display mode:default display mode, size mode:default size mode}
	tell theToolbar
		set allowed identifiers to {"load id", "retry id", "zoom id", "square id", "sound id", "scores id", "space item identifier", "flexible space item identifier", "separator item identifier"}
		set default identifiers to {"load id", "retry id", "flexible space item identifer", "zoom id", "sound id", "flexible space item identifer", "scores id"}
		
		-- Create the toolbar items, adding them to the toolbar.
		make new toolbar item at end of toolbar items with properties {identifier:"load id", name:"load", label:"New", tool tip:"Load a new game, choosing new pictures or a different level", image name:"load"}
		make new toolbar item at end of toolbar items with properties {identifier:"retry id", name:"retry", label:"Retry", tool tip:"Retry this level, shuffling the pictures", image name:"retry"}
		make new toolbar item at end of toolbar items with properties {identifier:"zoom id", name:"zoom", label:"Zoom", tool tip:"Zoom/unzoom tiny images to fill all the available area", image name:"zoom"}
		make new toolbar item at end of toolbar items with properties {identifier:"square id", name:"square", label:"Square", tool tip:"Force the board to be a square (after you resized and distorted it)", image name:"square"}
		make new toolbar item at end of toolbar items with properties {identifier:"sound id", name:"sound", label:"Sound", tool tip:"Do you prefer sounds or silence?", image name:"sound-on"}
		make new toolbar item at end of toolbar items with properties {identifier:"scores id", name:"scores", label:"Hi-Scores", tool tip:"Show your best times in all levels", image name:"scores"}
		
		-- Duplicate every "label" to "palette label"
		repeat with i from 1 to count toolbar items
			tell item i of toolbar items to set palette label to label
		end repeat
	end tell
	
	-- Assign our toolbar to the window
	set toolbar of window "main" to theToolbar
	
	set_tip(get_config("tip"))
	
	if windowSize is not {} then set size of window "main" to windowSize -- put after toolbar
	
	set_sound_system()
	set_scale_method()
	
	-- Calculate the number of pictures needed for each level
	repeat with thisSize in levelSizes
		set end of levelPictures to (thisSize * thisSize) / 2 as integer
	end repeat
	
	-- Load sounds at startup
	set soundOK to load sound "Ping" -- "Hero" -- "Blow"
	set soundOuch to load sound "Funk"
	set soundClick to load sound "Pop"
	set soundStart to load sound "Blow" -- "1234"
	-- set soundStart to load sound "Clock" -- hangs when repeated fast
	
	-- Load the current high scores
	load_highscores()
	
	-- Read once at startup since it won't change during execution
	if useAB then
		set AB to load script (resourcesPath & "Scripts/Address Book Handler.scpt") as POSIX file
		tell AB
			set totalAbPictures to get_ab_picture_count()
			set playableGroups to set_playable_ab_groups(levelPictures)
		end tell
		set contents of text field "stats" of tab view item "ab" of tab view 1 of window "settings" to "(" & totalAbPictures & " pictures)"
		populate_ab_group_popup(false)
	else
		tell tab view item "ab" of tab view 1 of window "settings"
			-- Disable the only empty menu item (for check_settings disable the play button)
			set enabled of current menu item of popup button "abgroup" to false
			set enabled of matrix "abmode" to false
			set visible of text field "stats" to false
			set visible of text field "ab disabled" to true
		end tell
	end if
	
	set systemFoldersPreview to {load image "preview-userpics", load image "preview-widgets", load image "preview-ichat"}
	
	-- Not visible at startup, let them at the end of this handler
	if localFolder is not "" and not isExpired then set_local_folder(localFolder)
	if lastLevel is not 1 then
		set current row of matrix "level" of window "settings" to lastLevel
		load_level()
	end if
	if lastAbMode is not 1 then set_ab_mode(lastAbMode)
	if lastAbGroup is not "" then select_abgroup_popup_title(lastAbGroup)
	if lastSysFolder is not 1 then set_sys_folder(lastSysFolder)
	
	-- Set player name if empty
	set playerName to get_config("playerName")
	if playerName is "" then
		try
			if useAB then tell application "Address Book" to set playerName to name of my card
		end try
		if playerName is "" then set playerName to do shell script "whoami"
	end if
	set_config("playerName", playerName)
	
	tell tab view 1 of window "settings"
		-- Sets on start up, never changes
		repeat with i from 1 to count systemFolders
			set end of systemFoldersCount to count my get_sys_folder_pictures(i)
			set contents of cell i of matrix "stats" of tab view item "sys" to item i of systemFoldersCount
		end repeat
		-- Put after setting systemFoldersCount, it's needed by check_settings()
		if lastTabView is not "" then set current tab view item to tab view item lastTabView
	end tell
	
	-- Trial version expired, let's do the dirty job of locking everything
	if isExpired then
		tell tab view item "ab" of tab view 1 of window "settings"
			set enabled of current menu item of popup button "abgroup" to false -- disable play button
			set visible of matrix "abmode" to false
			set visible of text field "stats" to false
			set visible of popup button "abgroup" to false
			set visible of text field "ab disabled" to false
			set visible of text field "expired" to true
			set visible of button "register" to true
		end tell
		tell tab view item "folder" of tab view 1 of window "settings"
			set visible of text field "folder stats" to false
			set contents of text field "folder path" to "" -- disable play button
			set visible of text field "folder path" to false
			set visible of button "choose folder" to false
			set visible of text field "expired" to true
			set visible of button "register" to true
		end tell
		tell window "register"
			set content of text field "instructions" to "The trial period has expired. Have you enjoyed playing memory with your friends?" & return & return & "Now your mission is to get a lifetime registration code to unlock all the features." & return & return & "All you need is that \"Get code\" button and US$ 7." & return & return & "Just seven bucks? For a full game? Yeah!"
		end tell
	end if
	
	-- Registered user, let's change the register window a little...
	if isRegistered then
		tell window "register"
			set title of button "close" to "Close"
			set enabled of button "get code" to false
			set visible of image view "ok" to true
			set enabled of text field "code" to false
			set content of text field "instructions" to "Thank you very much for registering." & return & return & "Your support will help me to keep improving this game. If you have any issue or idea, write me at verde@aurelio.net" & return & return & "And now, let's beat that record down!" & return & return & ":)"
			try
				set content of text field "registration date" to date string of registrationDate
			end try
		end tell
	end if
	
	-- Exchange windows
	tell window "loading" to close
	tell window "main"
		update
		center -- Repeated here because toolbar and setSize
		show
	end tell
	
	-- Tip: Doesn't work automatically if I bind the visible state to the scoresVisible preference :(
	if get_config("scoresVisible") then tell drawer "scores" of window "main" to open drawer
	
	check_settings()
	
	-- Show register window at first run or when expired
	if isExpired or windowSize is {} then tell window "register" to show
	
	set initDone to true
	
	if enabled of button "play" of window "settings" then
		load_game()
	else
		action_new_game()
	end if
	
	--@log "  init done"
end awake from nib

on action_new_game()
	--@log "action_new_game"
	display window "settings" attached to window "main"
	clear_board()
end action_new_game

on action_restart()
	--@log "action_restart"
	clear_board()
	load_game()
end action_restart

on action_scale()
	flip_config("zoomed")
	set_scale_method()
end action_scale

on action_square()
	-- Resizes all cells to squares, always changing the X axis.
	-- Changing Y involves toolbar size and after the resize, the toolbar drag doesn't mode the window
	set {cellX, cellY} to call method "cellSize" of object (matrix "board" of window "main")
	if cellX is equal to cellY then return
	set {winX, winY} to size of window "main"
	set nrCells to item 1 of boardSize
	-- Resizes the window X axis, then the matrix is resized automatically
	set size of window "main" to {cellY * nrCells + 4 * nrCells, winY}
end action_square

on action_sound()
	flip_config("soundOn")
	set playSounds to get_config("soundOn") -- save for shout() fastness
	shout(soundClick) -- Play sound *after* setting the state (works inverted)
	set_sound_system()
end action_sound

on action_world_ranking()
	open location scoresUrl --TODO  & "?hl=" & get_encoded_url(playerName)
end action_world_ranking

on action_choose_folder()
	set can choose directories of open panel to true
	set can choose files of open panel to false
	display open panel
	if the result is 1 then
		set_local_folder(directory of open panel)
		check_settings()
	end if
end action_choose_folder

on clicked theObject
	--@log "  event: clicked :: " & name of theObject
	
	if name of theObject is not "board" then shout(soundClick)
	
	-- Handle user clicks on the board
	if name of theObject is "board" then
		
		if not boardLoaded then return
		
		if missingFriends is 0 then
			clear_board()
			load_game()
			return
		end if
		
		set theRow to current row of theObject
		set theCol to current column of theObject
		set theImage to item theCol of item theRow of theBoardImages
		set theImagePath to item theCol of item theRow of theBoard
		
		-- The game logic starts here. The rest is junk.
		
		if theState is 99 then -- First click to start game
			set theState to 0
			clear_board()
			update_stats()
			set boardLoaded to true
			--set timeInit to current date
			--return -- When enabled, this click doesn't reveal the card
			
		else if theState is 2 then -- Click after two cards revealed (and no match)
			-- Close last 2 cards
			repeat with thisCell in openedCells
				set current row of theObject to item 1 of thisCell
				set current column of theObject to item 2 of thisCell
				delete image of current cell of theObject
			end repeat
			reset_state()
			set current row of theObject to theRow
			set current column of theObject to theCol
		end if
		
		if not (exists (image of current cell of theObject)) then -- Clicked empty cell
			-- Show the picture for this card
			if theState is less than 2 then
				--				if theImage is not "" then set image of current cell of theObject to load image theImage
				set image of current cell of theObject to theImage
				set theState to theState + 1
				set the end of openedCells to {theRow, theCol}
			end if
			-- Post processing
			if theState is 1 then -- One card reveled, this will be the key card
				set keyImage to theImagePath
				
			else if theState is 2 then -- Two cards revealed, they're equal?
				if theImagePath is equal to keyImage then
					set missingFriends to missingFriends - 1
					reset_state()
					if missingFriends is 0 then
						tell window "main" to update
						victory()
						return
					end if
					shout(soundOK)
				else
					shout(soundOuch)
				end if
			end if
			update_stats()
		end if
		
	else if name of theObject is "level" then
		load_level()
		level_changed()
		
	else if name of theObject is "abmode" then
		set_ab_mode(0)
		check_settings()
		
	else if name of theObject is "choose folder" then
		action_choose_folder()
		
	else if name of theObject is "sys folder" then
		set_sys_folder(0)
		check_settings()
		
	else if name of theObject is "icon" then
		set currTab to current tab view item of tab view 1 of window "settings"
		
		if name of currTab is "ab" then
			tell application "Address Book" to activate
			
		else if name of currTab is "sys" then
			--@log "here"
			set theIndex to current row of matrix "sys folder" of currTab
			--@log theIndex
			set theFolder to item theIndex of systemFolders
			tell application "Finder"
				activate
				reveal theFolder as POSIX file
			end tell
			
		else if name of currTab is "folder" then
			if localFolder is not "" then
				tell application "Finder"
					activate
					reveal my expand_tilde(localFolder) as POSIX file
				end tell
			end if
		end if
		
	else if name of theObject is "read testimonials" then
		open location testimonialUrl
		
	else if name of theObject is "send testimonial" then
		
		tell window of theObject
			
			if isExpired then
				set contents of text field "status" to "Testimonial submit will be reactivated when you register."
				return
			end if
			
			set theName to content of text field "name"
			set theTestimonial to content of text view "testimonial" of scroll view 1
			set theTestimonial to my strip(theTestimonial) -- needs to be in two lines
			
			if theTestimonial is "" then
				set contents of text field "status" to "Please, fill your testimonial."
				return
			end if
			
			tell progress indicator 1 to start
			set contents of text field "status" to "Sending testimonial..."
			
			set postVars to {"-d", quoted form of ("t=" & theTestimonial), "-d", quoted form of ("n=" & theName), "-d", quoted form of ("k=" & my get_config("keycode")), "-d", quoted form of ("v=" & myVersion)}
			set theCmd to "curl --connect-timeout 8 " & LI's _join(postVars, " ") & " " & testimonialUrl
			--@log theCmd
			try
				set serverResponse to do shell script theCmd & "; true"
				--@log serverResponse
			on error
				set serverResponse to "local error"
			end try
			
			tell progress indicator 1 to stop
			
			if serverResponse is "ok" then
				my set_config("testimonialSent", true)
				set contents of text field "status" to "Testimonial sent successfully!"
				set title of button "cancel testimonial" to "Close"
			else
				set contents of text field "status" to "Connection error. Please try again later."
			end if
		end tell
		
	else if name of theObject is "world" then
		action_world_ranking()
		
		--TODO connected elements didn't do POP sound :( 
		
		-- else if name of theObject is "submit" then -- Connected on IB
		
		--else if name of theObject is "cancel submit" then -- Connected on IB
		--	close window "submit"
		--		set enabled of text field "player name" of window "submit" to true
		
	else if name of theObject is "send scores" then
		
		-- Tip: Must use text field instead of preference. When clearing the text field, the preference isn't updated
		set playerName to contents of text field "player name" of window of theObject
		set playerName to strip(playerName)
		set_config("playerName", playerName)
		
		if isExpired then
			set contents of text field "status" of window of theObject to "Scores submit will be reactivated when you register."
			return
		end if
		
		if playerName is "" then
			set contents of text field "status" of window of theObject to "Please, fill your name."
			return
		end if
		
		tell window of theObject
			tell progress indicator 1 to start
			set contents of text field "status" of window of theObject to "Connecting to server..."
		end tell
		
		set scoresWorm to HS's encodedWorm
		set scoresSum to HS's checkSum as text
		
		-- TODO send number of errors
		set postVars to {"-d", quoted form of ("x=" & scoresSum), "-d", quoted form of ("y=" & scoresWorm), "-d", quoted form of ("z=" & playerName), "-d", quoted form of ("k=" & get_config("keycode")), "-d", quoted form of ("v=" & myVersion)}
		set theCmd to "curl --connect-timeout 8 " & LI's _join(postVars, " ") & " " & scoresUrl
		--@log theCmd
		try
			set serverResponse to do shell script theCmd & "; true"
			--@log serverResponse
		on error
			set serverResponse to "local error"
		end try
		
		tell progress indicator 1 of window of theObject to stop
		
		if serverResponse is "ok" then
			set_score_submit(0)
		else
			set contents of text field "status" of window of theObject to "Connection error. Scores not sent, try again later."
		end if
		
	else if name of theObject is "get code" then
		open location registerUrl
		
	else if name of theObject is "next tip" then
		set_tip(get_config("tip") + 1)
	else if name of theObject is "previous tip" then
		set_tip(get_config("tip") - 1)
		
		-- Panel handling is manual
	else if name of theObject is "play" then
		close panel (window of theObject) with result 1
	else if name of theObject is "quit" then -- not used anymore
		close panel (window of theObject)
	end if
	
end clicked

on choose menu item theObject
	--@log "  event: choose menu item :: " & name of theObject
	
	if name of theObject is not "sound" then shout(soundClick) -- Sound is inverted
	
	-- Chosing an item from the Ab groups, always enables OK, because the groups are already checked
	if name of theObject is "abgroup" then
		set enabled of button "play" of window "settings" to true
		
	else if name of theObject is "load" then
		action_new_game()
	else if name of theObject is "retry" then
		action_restart()
	else if name of theObject is "zoom" then
		action_scale()
	else if name of theObject is "square" then
		action_square()
	else if name of theObject is "sound" then
		action_sound()
	else if name of theObject is "scores" then
		call method "toggle:" of object (drawer "scores" of window "main")
	else if name of theObject is "website" then
		open location myUrl
	else if name of theObject is "e-mail" then
		open location "mailto:verde@aurelio.net?subject=EmoMemory%20(v" & myVersion & ")%20feedback"
		
		--	else if name of theObject is "world" then -- Mapped to button click on IB
		--	else if name of theObject is "submit" then -- Mapped to button click on IB
		--	else if name of theObject is "register" then -- Mapped to window on IB
		--	else if name of theObject is "testimonial" then -- Mapped to window on IB
		
	else if name of theObject is "open folder" then
		tell tab view 1 of window "settings" to set current tab view item to tab view item "folder"
		action_new_game()
		if not isExpired then action_choose_folder()
		
	else if name of theObject is "tips" then -- Swap visible state
		tell window "tips"
			if not visible then
				show
			else
				close
			end if
		end tell
	end if
end choose menu item

on clicked toolbar item theObject
	--@log "  event: clicked toolbar item :: " & name of theObject
	
	if name of theObject is not "sound" then shout(soundClick) -- Sound is inverted
	
	if name of theObject is "load" then
		action_new_game()
	else if name of theObject is "retry" then
		action_restart()
	else if name of theObject is "zoom" then
		action_scale()
	else if name of theObject is "square" then
		action_square()
	else if name of theObject is "sound" then
		action_sound()
	else if name of theObject is "scores" then
		call method "toggle:" of object (drawer "scores" of window "main")
	end if
end clicked toolbar item

on will select tab view item theObject tab view item tabViewItem
	--@log "  event: will select tab view item :: " & name of tabViewItem
	shout(soundClick)
	
	set image of button "icon" of window "settings" to load image "settings-" & name of tabViewItem
	set enabled of button "icon" of window "settings" to not ((name of tabViewItem is "ab" and not useAB) or (name of tabViewItem is in {"folder", "ab"} and isExpired))
end will select tab view item

on selected tab view item theObject tab view item tabViewItem
	--@log "  event: selected tab view item :: " & name of tabViewItem
	
	check_settings() -- check after selecting, it "looks" faster
end selected tab view item

on panel ended theObject with result withResult
	--@log "  event: panel ended :: " & name of theObject
	
	if name of theObject is "settings" then
		if withResult is 1 then load_game() -- button Play
	end if
end panel ended

on alert ended theObject with reply withReply
	--@log "  event: alert ended :: " & name of theObject
	if button returned of withReply is "Quit" then
		close panel (window "settings")
		tell me to quit
	end if
end alert ended

-- This event handler is called whenever the state of the toolbar items needs to be changed.
-- We return true in order to enable the toolbar item, otherwise we would return false
on update toolbar item theObject
	if not initDone then return false -- all disabled at start up
	
	-- Active when board is loaded	
	if name of theObject is in {"zoom", "square"} then
		return boardLoaded
		
		-- "Retry" is a little trickier
		--else if name of theObject is "retry" then
		-- if theState is 99 then return false -- First click (Kimie said it's strategy not cheating)
		--if theState is -1 then return true -- Switched window
		--return boardLoaded
	end if
	
	-- Otherwise, they're active
	return true
end update toolbar item

on will pop up theObject
	--@log "  event: will pop up :: " & name of theObject
	shout(soundClick)
end will pop up

on will open theObject
	--@log "  event: will open :: " & name of theObject
	
	if name of theObject is "submit" then
		if isExpired then
			tell window "submit" to close
			tell window "register" to show
		else
			shout(soundClick) -- because binding buttons on IB cancels shout() calling
		end if
	else if name of theObject is "register" then
		shout(soundStart) -- groovy!
		
	else if name of theObject is "testimonial" then
		shout(soundStart) -- groovy!
		set contents of text field "name" of theObject to get_config("playerName")
	end if
end will open

on should close theObject
	--@log "  event: should close :: " & name of theObject
	
	-- Using "should close" because "will close" is called twice :(
	if name of theObject is "submit" then
		shout(soundClick)
		return true
	end if
end should close

on will close theObject
	--@log "  event: will close :: " & name of theObject
	
	if name of theObject is "main" then
		tell me to quit
	end if
end will close

on will quit theObject
	--@log "  event: will quit :: " & name of theObject
	save_defaults()
end will quit

-- Window lost focus
-- Terminate game to avoid screenshot cheat
on resigned main theObject
	--@log "  event: resigned main :: " & name of theObject
	if boardLoaded and theState is 99 then -- just before first click
		set visible of image view "no focus" of window "main" to true
		set_status_bar("Oops! Window focus is lost, please start again.")
		set theState to -1
		set enabled of matrix "board" of window "main" to false
	end if
end resigned main

on closed theObject
	--@log "  event: closed :: " & name of theObject
	
	if name of theObject is "scores" then
		set state of menu item "scores" of sub menu of menu item "view" of main menu to 0
	end if
end closed

on opened theObject
	--@log "  event: opened :: " & name of theObject
	
	if name of theObject is "scores" then
		set state of menu item "scores" of sub menu of menu item "view" of main menu to 1
	end if
end opened

on keyboard up theObject event theEvent
	--@log "  event: keyboard up :: " & name of theObject
	if name of theObject is "code" then
		if ":" is in content of theObject then
			if check_code(content of theObject) then
				set enabled of theObject to false
				set enabled of button "get code" of window "register" to false
				set visible of image view "ok" of window "register" to true
				if soundVictory is "" then set soundVictory to load sound "Glass3"
				shout(soundVictory)
				display alert "Registered!" as warning message "Thank you VERY MUCH for supporting my project." & return & return & "Now just quit the game and launch it again to take advantage of the full features." attached to window "register" default button "Quit"
				set_config("keycode", content of theObject) -- make sure, don't trust IB bind
				set_config("registrationDate", current date)
				set_config("registrationVersion", myVersion)
			end if
		end if
	end if
end keyboard up

on action theObject
	(*Add your script here.*)
end action
