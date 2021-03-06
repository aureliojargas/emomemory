
# EmoMemory game source code 

*Brazil, 2011-12-15*

Source files for the EmoMemory game, MIT licensed.

 * **release** — The .DMG file with the compiled game, this is the official 1.0 release from 2007.

 * **tools** — Helper AppleScript tools used during the game development.

  * [EmoMemory Code Gen.applescript](https://github.com/aureliojargas/emomemory/blob/master/tools/EmoMemory%20Code%20Gen.applescript) — Given the user email, generates the Registration Code
  * [Set Default Scores.applescript](https://github.com/aureliojargas/emomemory/blob/master/tools/Set%20Default%20Scores.applescript) — Reset all the scores from the app

 * **xcode** — The game source files, created in Xcode 3 in Mac OS X Leopard.

  * [Address Book Handler.applescript](https://github.com/aureliojargas/emomemory/blob/master/xcode/Address%20Book%20Handler.applescript) — Address Book.app routines
  * [List Library.applescript](https://github.com/aureliojargas/emomemory/blob/master/xcode/List%20Library.applescript) — Lists (arrays) routines
  * [Numbers.applescript](https://github.com/aureliojargas/emomemory/blob/master/xcode/Numbers.applescript) — High Score routines
  * [Remember Me?.applescript](https://github.com/aureliojargas/emomemory/blob/master/xcode/Remember%20Me%3F.applescript) — Main script, still using a beta name


## About the code 

This is the original code from the game 1.0 release (April 2007). I haven't touched this code ever since. It used to compile in Xcode 3 running in my Leopard (Mac OS X 10.5) machine.

The game is written in AppleScript, using the now deprecated AppleScript Studio framework that was supported in Xcode from Mac OS X 10.2 to 10.5 (Jaguar to Leopard). So, you'll need an old machine if you want to recompile the game.

The AppleScript Studio was replaced by the AppleScriptObjC framework in Snow Leopard. The game will compile in newer machines if you adapt the code to use this new framework. I don't know how hard can that be.

This code can be a valuable source of information for those who are learning the AppleScript language. Study all the .applescript files.

Note: Info.plist file says "1.0 beta 1", but it's really "1.0". I forgot to update it for the release.

## About EmoMemory 

Released in April 2007, this is a memory game for Mac OS X that uses pictures from your Address Book contacts, or any chosen folder.

As of now (December 2011), the compiled 1.0 version of the game still runs in OS X Lion. But the Address Book integration is broken.

EmoMemory website: http://aurelio.net/projects/emomemory/

## About the author 

Aurelio Jargas
http://aurelio.net

