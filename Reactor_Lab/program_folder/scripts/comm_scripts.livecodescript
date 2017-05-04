script "comm scripts"
-- The Reactor Lab was released as open-source software under the 
-- GNU General Public License v3.0 in April, 2017.
-- View the license at https://www.gnu.org/licenses/gpl.html 
-- All Reactor Lab stacks and scripts prior to this date were designed and written
-- by Richard K. Herz 

-- stacks and scripts by Richard K. Herz, all rights reserved, 2001-2016
--
-- original May 2001
-- revised October 2002
-- revised February 2003
-- revised May-August 2003, engine startUp in "engine" stack
-- revised March-April 2004, changed conference from many cgi posts to socket communications
-- revised July-Aug 2008, merge RL and PWL scripts, see -- new for merge
-- revised Aug 2008, combine all in to integrated "newlab," see -- new for newlab
-- revised July 2010, eliminate use of stack "check connection" - do all with stack "download progress"
-- revised August 2014, change .rev and .rev.gz filename extensions to .livecode
-- revised December 2016, move command logHistory from confer_scripts.livecode to here & revise

local lStime
local lCancelled 
local lStartTicks
local lDownloadProgressStack

global gPathToEngineFolder -- set in home stack
global gHomeURLDefault -- set below in initEngine
global gHistory -- initialized below in bootstep02 and logged in logHistory

-- new for merge
global gHomeStackShortName -- set in home stack
global gHomeStackFileName -- set in home stack

-- below set in comm scripts
global gSupportEmail
global gMainLabWebSiteUrlShort
global gPingURL

--------------------------------

on logHistory
 
    constant kLoggerURL="http://reactorlab.net/openlab/logger/logger.lc" 
   
   # this adds any previously unlogged history to gHistory
   # then sends gHistory to server via HTTP POST if possible or, if not,
   # appends it to disk file for sending later
   put gPathToEngineFolder into tClientLogFilePath
   put "/program_folder/scripts" after tClientLogFilePath
   if there is a directory tClientLogFilePath then
      # directory exists
   else
      create directory tClientLogFilePath
   end if
   put "/list.txt" after tClientLogFilePath
   put "file:" & tClientLogFilePath into tClientLogFileURL
   if there is a file tClientLogFilePath then
      # get from client log file any previous history not logged to server
      put url tClientLogFileURL into tPreHistory
      put fLineEndingFix(tPreHistory) into tPreHistory
      -- don't want user's disk to fill up 
      if the number of characters in tPreHistory > 1000000 then
         put "DELETE BIG HISTORY > 1000000 characters!" into tPreHistory
      end if
      -- empty the log file on client
      put empty into url tClientLogFileURL
   end if 
   
   -- logger on server will strip any empty lines
   put tPreHistory & LF before gHistory
   
   -- use session start seconds to identify session, since IP address may change if user moves on WIFI
   -- during session, logger will add this IP address at server, in any event
   put the cSessionStartSeconds of stack "Directory" into tStart
   put tStart && "seconds from 1-Jan-1970 GMT at session start" into tSessionID
   if the environment is "development" then
      put LF & "** GITHUB - DEVELOPMENT ENVIRONMENT **" after tSessionID
      put LF & "in comm scripts, logHistory, just before post, server removes empty lines" & LF & LF into tMsg 
      put "------------" & LF & tSessionID & LF & gHistory & LF & "---------------" & LF & LF after tMsg
      tester tMsg
   end if
   post tSessionID & LF & gHistory to URL kLoggerURL
   if the result is empty then
      # worked OK
      put "OK" into tLogResult
   else
      # didn't work
      put "error" into tLogResult
   end if
   if tLogResult is not "OK" then
      # write gHistory to disk file
      put gHistory into url tClientLogFileURL
   end if
   put empty into gHistory
end logHistory

# ------------------------------

on tester tText # for development
   if the environment is "development" then
      put LF & tText & LF into tText
      if there is a stack "test" then
         put tText after field 1 of stack "test"
         set the scroll of field 1 of stack "test" to 1e6 -- xxx check for better way to scroll to end
      else
         if the cFirstDevMsg of me is false then
            answer "Open stack test.livecode to see developent messages."
            set the cFirstDevMsg of me to true
         end if
      end if
   end if
end tester

# ------------------------------

-- new for merge
-- Differences between RL and PWL home stacks and scripts folder after merge:
-- short name of home stack
-- first two lines below in bootStep02 in comm scripts

on bootStep02
   
   -- WARNING: do not change gMainLabWebSiteUrlShort and tMainFolder 
   --                  unless you know what you are doing!
   --    put "ReactorLab.net" into gMainLabWebSiteUrlShort
   --    put "ReactorLab.github.io" into gMainLabWebSiteUrlShort
   put "richardherz.github.io/ReactorLab" into gMainLabWebSiteUrlShort
   put "support@reactorlab.net" into gSupportEmail
   --    put "rl_net_new" into tMainFolder
   --    put "openlab" into tMainFolder 
   put "Reactor_Lab/program_folder" into tMainFolder 
   
   -- the next lines are from initEngine moved here
   
   -- gHomeURLDefault is URL checked if all others don't download a LiveCode stack
   --    put "http://" & gMainLabWebSiteUrlShort & "/" & tMainFolder into gHomeURLDefault
   put "https://" & gMainLabWebSiteUrlShort & "/" & tMainFolder into gHomeURLDefault
   
   -- specify list of URLs to stacks on servers; more than one in case preferred one is down
   -- xxx not sure if this feature has been implemented
   
   -- new for merge
   -- the next lines are from pingOnStartup moved here
   --
   -- xxx if no hardware connection to net, then can get
   -- xxx hung up in liburl's ulGetFormat when it calls
   -- xxx engine's hostNameToAddress(), which contacts a
   -- xxx name server to get IP address BUT problem if no net connection!
   put gHomeURLDefault & "/ping.txt" into gPingURL
   
   set cursor to watch
   set the cFirstDevMsg of me to false -- used in tester command in this stack
   # need to put this script into the backScripts (with "into back")
   # or it won't get any messages sent by engine stack connect button
   insert the script of me into back
   set the directory to gPathToEngineFolder
   startLibUrl
   initEngine
   hide stack gHomeStackShortName -- new for merge # hide the "engine" stack
   # setting vis to false doesn't seem to work when engine is standalone
   put empty into gHistory # initialize so other scripts can append to it
   put gPathToEngineFolder & "/program_folder/scripts/Directory.livecode" into tPath
   
   if there is a stack tPath then
      
      if the environment is not "development" then
         -- FOR WEB BROWSER altBrowser
         -- need to set externals before opening stack OR set in stack then close/destroy and reopen
         -- only need this set for one stack that stays in message path, so set for stack "Directory"
         -- NOTE STARTING WITH REV 2.9.0-dp1 if you do this while in development, where
         -- external already set apparently on Rev startup, then revBrowserBeforeNavigate and "over"
         -- callbacks don't work
         put gPathTOengineFolder & "/program_folder/scripts/" into pathTOaltBrowser
         -- xxx should add check for existence of dll file and bundle folder
         if the platform is "Win32" then
            put "revbrowser.dll" after pathTOaltBrowser
            if there is a file pathTOaltBrowser then
               set the externals of stack tPath to pathTOaltBrowser
            end if
         else if the platform is "MacOS" then
            put "revbrowser.bundle" after pathTOaltBrowser
            if there is a file pathTOaltBrowser then
               set the externals of stack tPath to pathTOaltBrowser -- FOR LOCATION IN comm_scripts.livecode
               -- set the externals of stack tClientScriptFilePath to pathTOaltBrowser -- FOR LOCATION IN rl_updater.livecode
            end if
         else
            -- Deactivate this notice when LOCATION in rl_updater.livecode
            answer "Browser not available on this platform." & LF & "Email " & gSupportEmail -- new for merge
         end if
         -- WARNING: ALSO SEE THIS IN UPDATER STACK which closes and reopens updated Directory stack
         -- but BE CAREFUL IF COPY since name of stack whose externals are being set are different
      end if
      
      go stack tPath
   else
      answer "Missing Directory file!"
   end if
end bootStep02

on startLibUrl
  -- NOTE: I used to have the libURL script in a separate stack
  -- and this worked up until libURL v.1.1b2 but not with later versions.
  -- Might have something to do with change in how "library" stacks are handled.
  -- Now make sure in standalone to include "internet" library when saving as standalone.
  -- Trying to use libURL in separate stack was attempt to allow live updates
  -- of libURL but don't think this worked anyway.
  --
  --  global gPathToEngine
  --  put gPathToEngineFolder & "/program_folder/scripts/liburl.rev" into tPath
  --  if there is a stack tPath then
  --    start using stack tPath
  --  else
  --    set the itemDelimiter to "/"
  --    put "liburl," into tPath
  --    put the last item of gPathToEngine after tPath
  --    set the stackfiles of me to tPath
  --    start using stack "default liburl" # substack of home (app) stack
  --  end if
end startLibUrl

on initEngine
  
  # if there is a button "secure mode" then
  # set the hilite of button "secure mode" to false
  # end if
  
  if there is a button "info" then
    if the platform is "WinOS" then
      set the textFont of button "info" to "courier new"
    else
      set the textFont of button "info" to "courier"
    end if
  end if
  
  displayStatus empty
    
end initEngine

# -------------------------------

function fDisplayDownloadTitle pText
   -- WARNING: when update comm scripts and download progress stack
   -- the new comm scripts is in effect in same session after update
   -- but the old download progress stack is active so be careful
   -- about changing names!
   if there is a field "title" of stack lDownloadProgressStack then
      put pText into field "title" of stack lDownloadProgressStack
   else if there is a field "url" of stack lDownloadProgressStack then
      put pText into field "url" of stack lDownloadProgressStack
   end if
   return empty
end fDisplayDownloadTitle

# -------------------------------

function fLineEndingFix tText
   -- reactor lab file lists and file updates need LF line endings
   -- but CR and CRLF line endings may be added by desktop editors
   -- command "replace CR with LF in tText" does not work
   -- so scan byte-by-byte
   put the number of bytes of tText into tNum
   repeat with k = tNum down to 1
      if charToNum(byte k of tText) is 13 then -- byte k is CR
         if charToNum(byte k+1 of tText) is 10 then -- byte k+1 is LF (false & no error when k = tNum)
            delete byte k of tText -- delete CR since followed by LF
         else
            put numToChar(10) into byte k of tText -- replace CR with LF
         end if
      end if
   end repeat
   return tText
end fLineEndingFix

# -------------------------------

on pingCancel
   put true into lCancelled
end pingCancel

# -------------------------------

on pingOnStartUp
   
   tester "comm scripts, enter pingOnStartUp, gPingURL = " & LF & gPingURL
   
   -- use to check network connection on first start of Lab
   -- and do nonblocking load so user can cancel the check
   setInfo "Checking network connection..."
   loadGoStartPing gPingURL -- new for merge
   
   tester "comm scripts, at end pingOnStartUp"
   
end pingOnStartUp

# -------------------------------

function pingPassive
   -- this is called several places in the Directory stack
   
   # xxx if no hardware connection to net, then can get
   # xxx hung up in liburl's ulGetFormat when it calls
   # xxx engine's hostNameToAddress(), which contacts a
   # xxx name server to get IP address BUT problem if no net connection!
   put gPingURL into tPingURL -- new for merge
   put "offline" into tResult
   
   tester "comm scripts, function pingPassive, tPingURL = " & tPingURL
   
   -- repeat get url because doesn't always work first time or two
   put 10 into tRepeatAttempts
   put 0 into tRepeats
   put empty into it
   repeat until it is not empty
      add 1 to tRepeats
      get url tPingURL
      if tRepeats = tRepeatAttempts then
         exit repeat
      end if
   end repeat
   
   if the result is empty then
      
      put it into tPage
      put fLineEndingFix(tPage) into tPage
      
      tester "comm scripts, function pingPassive, the result empty, tPage = " & tPage
      
      # contents of line 1 of ping.txt must be "online"
      if line 1 of tPage is "online" then 
         put "online" into tResult
      end if
   else
      tester "comm scripts, function pingPassive, the result = " & LF & the result
   end if
   return tResult
end pingPassive

# -------------------------------

on phoneHome
     
   put gHomeURLDefault & "/rl_updater.livecode" into tHomeURL
   loadGoStart tHomeURL
   
end phoneHome

# -------------------------------

# handlers below are from MetaCard 2.4 download stack in mctools.rev
# edited and names changed by R. Herz

# -------------------------------

on loadGoStart href
   
   -- separate this from loadGoStartContinue and set counter
   -- so can repeat if trouble below
   set the cConnectCounter of me to 0
   tester "comm scripts, loadGoStart, just before send loadGoStartContinue"
   send "loadGoStartContinue" && quote & href & quote to me in 10 milliseconds
   
end loadGoStart

# -------------------------------

on loadGoStartContinue href
   
   tester "comm scripts, enter loadGoStartContinue, href = " & LF & href
   
   put false into lCancelled
   put gPathToEngineFolder into lDownloadProgressStack
   
   put "/program_folder/scripts/download_progress.livecode" after lDownloadProgressStack
   
   tester "comm scripts, loadGoStartContinue, lDownloadProgressStack = " & LF & lDownloadProgressStack
   
   if there is a stack "comm scripts" then # won't be if running from "default comm scripts"
      
      tester "comm scripts, loadGoStartContinue, there is a stack comm scripts"
      
      # zzz think now I want to always show download progress stack - really need on dialup!
      set the cShowDownloadProgress of stack "comm scripts" to "show"  # zzz
      
      if the cShowDownloadProgress of stack "comm scripts" is not "hide" then
         if there is a stack lDownloadProgressStack then
            # apparently can't open this "as modal" without also
            # changing the "send ... to me" below to specify "comm scripts" not "me"
            go stack lDownloadProgressStack
            get fDisplayDownloadTitle("Check for network connection may take up to 20 seconds...")
            if the short name of the topstack is "Directory" then
               set the loc of stack lDownloadProgressStack to the loc of stack "Directory"
            end if
         end if  
         put the ticks into lStartTicks
         set the itemDelimiter to "/"
         put the last item of href into tref
         set the itemDelimiter to "."
         put item 1 of tref into tref
         replace "_" with space in tref
         
         if the cGetLocalLab of stack "Directory" is true then
            get fDisplayDownloadTitle("Check for updates:" && tref)
         else
            get fDisplayDownloadTitle("Downloading: " && tref)
         end if
         
         displayStatus empty
         put "contacting" into field "status" of stack lDownloadProgressStack
         set the thumbPos of sb 1  of stack lDownloadProgressStack to 0
      end if
   end if
   tester "comm scripts, loadGoStartContinue, just before load href, href = " & LF & href
   load href
   displayStatus "contacting"
   
   tester "comm scripts, loadGoStartContinue, displayStatus > contacting"
   
   tester "comm scripts, loadGoStartContinue, just after load href, href = " & LF & href
   
   -- set counter so can repeat in case trouble below in finish
   put the cConnectCounter of me into tCount
   add 1 to tCount
   set the cConnectCounter of me to tCount
   
   tester "comm scripts, loadGoStartContinue, just before send loadGoFinish"
   send "loadGoFinish" && quote & href & quote to me in 1000 milliseconds
   put the long seconds into lStime
   
end loadGoStartContinue

# -------------------------------

on loadGoFinish href
   
   local stat, nk
   
   tester "comm scripts, enter loadGoFinish, href = " & LF & href
   
   if lCancelled then
      tester "comm scripts, loadGoFinish, lCancelled is true"
      unload url href
      if there is a stack lDownloadProgressStack then
         close stack lDownloadProgressStack
      end if
      exit loadGoFinish
   end if
   
   put urlStatus(href) into stat
   displayStatus stat
   
   if stat contains "error" or stat contains "not found" \
         or stat contains "time out" or stat contains "timeout" then
      
      tester "comm scripts, loadGoFinish, stat contains error, not found, time out, or timeout"
      
      if there is a stack lDownloadProgressStack then
         close stack lDownloadProgressStack
      end if
      
      ## zzz get stat = error about every 10th time if are off line
      ## zzz pingPassive() returns online when trouble happens
      ## zzz and then click lab and say connect    
      ## zzz when this happened, manually clicking the divs and the labs again worked
      ## zzz so automate that process and try it in one repeat
      
      tester "comm scripts, loadGoFinish, just before unload href, href = " & href
      
      unload url href
      displayStatus empty
      put the cConnectCounter of me into tCount
      
      if tCount < 2 and the cClickSPECIAL of field "the labs" of card "dir" of stack "Directory" is not "true" then
         
         send "getLabListFromServer" to field "the divs" of card "dir" of stack "Directory"
         set the cClickSPECIAL of field "the labs" of card "dir" of stack "Directory" to "true"
         send mouseUpSPECIAL to field "the labs" of card "dir" of stack "Directory" in 1 second
         
      else
         
         answer "Trouble connecting.  Try:" & LF &\
         "1) Click on line button again." & LF &\
         "2) Click this division and lab again." & LF &\
         "3) Can you reach" && gMainLabWebSiteUrlShort && "with web browser?" -- new for merge
      end if
      
      exit loadGoFinish
   end if
   
   if stat contains "cached" then
      
      tester "comm scripts, loadGoFinish, stat contains cached, handle the downloaded file"
      
      if there is a stack lDownloadProgressStack then
         if the cShowDownloadProgress of stack "comm scripts" is empty then
            put the ticks - lStartTicks into temp
            if temp > 360 then
               set the cShowDownloadProgress of stack "comm scripts" to "show"
            else
               set the cShowDownloadProgress of stack "comm scripts" to "hide"
            end if
         end if
         put "Done" into field "status" of stack lDownloadProgressStack
         set the thumbpos of sb 1 of stack lDownloadProgressStack to the endValue of sb 1 of stack lDownloadProgressStack
         wait 500 milliseconds
         close stack lDownloadProgressStack
      end if
      
      set the itemDelimiter to "."
      if the last item of href is "gz" then
         -- gzipped file
         tester "comm scripts, loadGoFinish, decompressing gzipped file"
         displayStatus "decompressing"
         put decompress(url href) into temp
      else
         -- not gzipped file
         put url href into temp
      end if
      
      tester "comm scripts, loadGoFinish, before deciding how to handle downloaded file"
      
      if offset("REVO",word 1 of temp) = 1 AND the version < 2.7 then
         answer "This module requires a newer version of the Lab distribution." & LF & "Please get it at" && gMainLabWebSiteUrlShort
         tester "comm scripts, loadGoFinish, this lab module requires a newer version of app"
         unload url href
         put empty into temp
         displayStatus empty
         exit loadGoFinish
      end if
      
      if word 1 of temp is "#!/bin/sh" OR offset("REVO",word 1 of temp) = 1 then
         displayStatus empty
         tester "comm scripts, loadGoFinish, good stack, go to stack and exit loadGoFinish"
         go temp
         unload url href
         put empty into temp
         exit loadGoFinish
      else
         tester "comm scripts, loadGoFinish, bad file, unload and exit loadGoFinish"
         answer "URL" && href  && "is not a valid" && gMainLabWebSiteUrlShort && "module."
         unload url href
         put empty into temp
         displayStatus empty
         exit loadGoFinish
      end if
      
   end if
   
   if item 1 of stat is "loading" then
      
      tester "comm scripts, loadGoFinish, item 1 of stat is loading"
      
      put item 2 of stat div 1024 into nk
      put nk & "K/" & item 3 of stat div 1024 & "K  "\
            & nk * 10 div (the long seconds - lStime) / 10 & "K/sec" into tprog
      displayStatus tprog
      
      if there is a stack lDownloadProgressStack then
         put tprog into field "status" of stack lDownloadProgressStack
         set the endValue of sb 1 of stack lDownloadProgressStack to item 3 of stat
         set the thumbpos of sb 1 of stack lDownloadProgressStack to item 2 of stat
      end if
      
   end if
   
   if stat is empty then
      tester "comm scripts, loadGoFinish, stat is empty"
      displayStatus empty
      if there is a stack lDownloadProgressStack then
         -- answer "close stack 02"
         close stack lDownloadProgressStack
      end if
      exit loadGoFinish
   end if
   
   if stat is "requested" then
      tester "comm scripts, loadGoFinish, stat is requested, sending loadGoFinish to me"
      displayStatus "requested"
      send "loadGoFinish" && quote & href & quote to me in 500 milliseconds
   else
      send "loadGoFinish" && quote & href & quote to me in 500 milliseconds
   end if
   
end loadGoFinish

# -------------------------------

on loadGoStartPing href
   
   -- this is for first check of network connection when starting the Lab
   
   tester "comm scripts, start of loadGoStartPing, href = " & LF & href
   
   put false into lCancelled
   put gPathToEngineFolder into lDownloadProgressStack
   
   put "/program_folder/scripts/download_progress.livecode" after lDownloadProgressStack
   
   if there is a stack "comm scripts" then # won't be if running from "default comm scripts"
      
      set the cShowDownloadProgress of stack "comm scripts" to "show" 
      
      if the cShowDownloadProgress of stack "comm scripts" is not "hide" then
         if there is a stack lDownloadProgressStack then
            # apparently can't open this "as modal" without also
            # changing the "send ... to me" below to specify "comm scripts" not "me"
            go stack lDownloadProgressStack
            get fDisplayDownloadTitle("Check for network connection may take up to 20 seconds...")
            if the short name of the topstack is "Directory" then
               set the loc of stack lDownloadProgressStack to the loc of stack "Directory"
            end if
         end if  
         put the ticks into lStartTicks
         set the itemDelimiter to "/"
         put the last item of href into tref
         set the itemDelimiter to "."
         put item 1 of tref into tref
         replace "_" with space in tref
         displayStatusPing empty
         put "contacting" into field "status" of stack lDownloadProgressStack
         set the thumbPos of sb 1  of stack lDownloadProgressStack to 0
      end if
   end if
   
   load href -- non-blocking load, check status in loadGoFinishPing
   
   displayStatusPing "contacting"
   send "loadGoFinishPing" && quote & href & quote to me in 500 milliseconds
   put the long seconds into lStime
   
   tester "comm scripts, at end of loadGoStartPing,  displayStatusPing > contacting"
   
end loadGoStartPing

# -------------------------------

on loadGoFinishPing href
   
   local stat, nk
   
   tester "comm scripts, start of loadGoFinishPing, href = " & LF & href
   
   if lCancelled then
      
      tester "comm scripts, loadGoFinishPing, lCancelled is true"
      
      unload url href
      
      if there is a stack lDownloadProgressStack then
         close stack lDownloadProgressStack
      end if
      
      startUpOffline
      exit loadGoFinishPing
      
   end if
   
   put urlStatus(href) into stat
   displayStatusPing stat
   
   tester "comm scripts, loadGoFinishPing, displayStatusPing stat = " & stat
   
   if stat contains "error" or stat contains "not found" \
         or stat contains "time out" or stat contains "timeout" then
      
      if there is a stack lDownloadProgressStack then
         close stack lDownloadProgressStack
      end if
      
      startUpOffline
      unload url href
      displayStatusPing empty
      tester "comm scripts, loadGoFinishPing, just after unload url and before exit due to stat"
      exit loadGoFinishPing
   end if
   
   if stat contains "cached" then
      
      tester "comm scripts, loadGoFinishPing, stat is cached"
      if there is a stack lDownloadProgressStack then
         if the cShowDownloadProgress of stack "comm scripts" is empty then
            put the ticks - lStartTicks into temp
            if temp > 360 then
               set the cShowDownloadProgress of stack "comm scripts" to "show"
            else
               set the cShowDownloadProgress of stack "comm scripts" to "hide"
            end if
         end if
         put "Done" into field "status" of stack lDownloadProgressStack
         set the thumbpos of sb 1 of stack lDownloadProgressStack to the endValue of sb 1 of stack lDownloadProgressStack    
      end if
      
      put url href into tresult
      put fLineEndingFix(tresult) into tresult
      tester "comm scripts, loadGoFinishPing, after put url href into tresult, tresult = " & LF & tresult
      
      # contents of line 1 of ping.txt must be "online"
      if line 1 of tresult is "online" then
         tester "comm scripts, loadGoFinishPing, ping is onlne, just before startUpOnline"
         startUpOnline
      else
         tester "comm scripts, loadGoFinishPing, ping NOT online, just before startUpOffline"
         startUpOffline
      end if
      displayStatusPing empty
      unload url href
      tester "comm scripts, just before exit loadGoFinishPing after unload url href"
      exit loadGoFinishPing
      
   end if
   
   if item 1 of stat is "loading" then
      
      tester "comm scripts, loadGoFinishPing, item 1 of stat is loading"
      put item 2 of stat div 1024 into nk
      put nk & "K/" & item 3 of stat div 1024 & "K  "\
            & nk * 10 div (the long seconds - lStime) / 10 & "K/sec" into tprog
      displayStatusPing tprog
      
      if there is a stack lDownloadProgressStack then
         put tprog into field "status" of stack lDownloadProgressStack
         set the endValue of sb 1 of stack lDownloadProgressStack to item 3 of stat
         set the thumbpos of sb 1 of stack lDownloadProgressStack to item 2 of stat
      end if
      
      tester "comm scripts, loadGoFinishPing, just before send loadGoFinishPing to me"
      send "loadGoFinishPing" && quote & href & quote to me in 500 milliseconds
      exit loadGoFinishPing
      
   end if
   
   if stat is empty then
      
      tester "comm scripts, loadGoFinishPing, stat is empty"
      displayStatusPing empty
      
      tester "comm scripts, loadGoFinishPing, stat is empty, just before send loadGoFinishPing to me"
      send "loadGoFinishPing" && quote & href & quote to me in 500 milliseconds
      exit loadGoFinishPing
      
   end if
   
   if stat contains "contacted" then
      
      tester "comm scripts, loadGoFinishPing, stat contains contacted"
      displayStatusPing stat
      tester "comm scripts, loadGoFinishPing, stat contains contacted, just before send loadGoFinishPing to me"
      send "loadGoFinishPing" && quote & href & quote to me in 500 milliseconds
      exit loadGoFinishPing
   end if
   
   if stat is "requested" then
      tester "comm scripts, loadGoFinishPing, stat is requested"
      displayStatusPing "requested"
      tester "comm scripts, loadGoFinishPing, stat is requested, just before send loadGoFinishPing to me"
      send "loadGoFinishPing" && quote & href & quote to me in 500 milliseconds
      exit loadGoFinishPing
   end if
   
   tester "comm scripts, at end loadGoFinishPing"
   
end loadGoFinishPing

# -------------------------------

on startUpOnline
   tester "comm scripts, enter startUpOnline"
   setInfo empty
   put the long time & ", on go card 2, ping result = online" & LF after gHistory
   set the cPingResult of card "dir" of stack "Directory" to "online"
   if the cGetLab of card "dir" of stack "Directory" is true then
      send getLabOnServerFinish to field "the labs" of card "dir" of stack "Directory"
   else
      send goOnLine to button "on line" of card "dir" of stack "Directory"
   end if
end startUpOnline

# ------------------------------

on startUpOffline
   tester "comm scripts, enter startUpOffline, can't connect to" && gMainLabWebSiteUrlShort
   setInfo empty
   put the long time & ", on go cd 2, ping result = offline" & LF after gHistory
   send goOffLine to button "on line" of card "dir" of stack "Directory"
   answer "Can't connect to" && gMainLabWebSiteUrlShort & LF &\
   "Your Internet connection or the Lab server may be down temporarily."
end startUpOffline

# ------------------------------

on displayStatus tStatus
  if there is a field "status" of the topStack then
    put tStatus into field "status" of the topStack
  else if there is a field "status" of me then
    put tStatus into field "status" of me
  else if there is a field "info box" of the topStack then
    put tStatus into field "info box" of the topStack
  else if there is a field "info box" of me then
    put tStatus into field "info box" of me
  end if
end displayStatus

on displayStatusPing tStatus
   
   if there is a stack lDownloadProgressStack then
      if there is a field "status" of stack lDownloadProgressStack then
         put tStatus into field "status" of stack lDownloadProgressStack
      end if
   end if
   
end displayStatusPing

# -------------------------------

on unloadAll
  
  repeat for each line i in the cachedURLs
    unload url i
  end repeat
  
end unloadAll

# -------------------------------

function stripper tVar
  
  # strips spaces before and after, and returns after string
  
  # on one server (Win NT server) I am getting an ASCII 13
  # which isn't recognized as return or cr
  # this doesn't happen on other servers (Sun Unix server)
  
  repeat while charTOnum(the last char of tVar) is 13
    #    answer "delete an ASCII 13 (return)"
    delete the last character of tVar
  end repeat
  
  repeat while the last character of tVar is return
    delete the last character of tVar
  end repeat
  
  repeat while the last character of tVaris is space
    delete the last character of tVar
  end repeat
  
  repeat while the first character of tVar is space
    delete the first character of tVar
  end repeat
  
  return tVar
  
end stripper

# ------------------------------

# from Runtime Revolution 2.0.1
# from button revCommon of stack revLibrary

on revGoURL pWhich
  global gREVWebBrowser
  revSetWindowsShellCommand
  put revRunningWindowsNT() into tNT
  if "file://" is not in pWhich then replace "file:/" with "file:///" in pWhich--so that local URLs as used in Transcript can be used
  if the platform is "Win32" then
    if char 1 to 7 of pWhich is "mailto:" then
      put queryRegistry("HKEY_CLASSES_ROOT\mailto\shell\open\command\") into tMailApp
      replace quote & "%1" & quote with pWhich in tMailApp
      replace "%1" with pWhich in tMailApp
      
      --older versions use %l ("pecent L")
      replace quote & "%l" & quote with pWhich in tMailApp
      replace "%l" with pWhich in tMailApp
      
      -- for the new and wonderful XP
      replace "%ProgramFiles%" with $ProgramFiles in tMailApp
      
      open process tMailApp for neither # original
      
      # launch tMailApp
      # if the result is not empty then
      # answer "Sorry, can't open mail application." & LF & "Please do it manually."
      # end if
      
    else
      put word 1 of queryRegistry("hkey_local_machine\software\classes\http\shell\open\command\") into tWebBrowserPath
      if not tNT then
        get shell(tWebBrowserPath && quote & pWhich & quote)
      else
        set the hideconsolewindows to false
        open process (tWebBrowserPath && quote & pWhich & quote) for neither
      end if
    end if
  else if the platform is "MacOS" then
    if "appleScript" is not in the alternateLanguages then
      return "Error: AppleScript not installed"
    end if
    do ("open location" && quote & pWhich & quote) as appleScript
  else
    if gREVWebBrowser is empty
    then launch "mozilla" && quote & pWhich & quote
    else launch gREVWebBrowser && quote & pWhich & quote
  end if
end revGoURL

on revMail pTo, pCC, pSubject, pBody
  local tURL
  put empty into tURL
  if the paramcount is 1 then
    put "mailto:" & pTo into tURL
  else
    if pCC is not empty then put true into tCC
    if pSubject is not empty then put true into tSubject
    if pBody is not empty then put true into tBody
    
    put "mailto:" & pTo into tURL
    if tCC then
      if (tURL contains "?Subject=") or (tURL contains "?Body=") then
        put "&" & "CC=" & pCC after tURL
      else
        put "?" & "CC=" & pCC after tURL
      end if
    end if
    if tSubject then
      if (tURL contains "?CC=") or (tURL contains "?Body=") then
        put "&" & "Subject=" & pSubject after tURL
      else
        put "?" & "Subject=" & pSubject after tURL
      end if
    end if
    if tBody then
      if (tURL contains "?CC=") or (tURL contains "?Subject=") then
        put "&" & "Body=" & pBody after tURL
      else
        put "?" & "Body=" & pBody after tURL
      end if
    end if
  end if
  revGoURL tURL
end revMail

function revRunningWindowsNT
  if the platform is not "Win32" then return false
  if word 1 of the systemVersion is "Windows"
  then return false
  else return true
end revRunningWindowsNT

on revSetWindowsShellCommand
  if the platform is not "Win32" then exit revSetWindowsShellCommand
  set the hideConsoleWindows to true
  if $COMSPEC is not empty then set the shellCommand to $COMSPEC
  else
    --just in case some windows versions don't use $COMSPEC
    if revRunningWindowsNT() then set the shellCommand to "cmd.exe"
    else set the shellCommand to "command.com"
  end if
end revSetWindowsShellCommand
