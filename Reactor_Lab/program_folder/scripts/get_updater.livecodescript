script "get updater"
-- by Richard K. Herz <herz@ucsd.edu>  May 2001
-- revised October 2002
-- revised February 2003
-- revised May-August 2003 engine startUp in "engine" stack
-- revised March-April 2004 changed from many cgi posts to socket communications

-- revised October 2006, make a separate stack only used to get updater stack from server
-- this stack is put in use in Directory stack script
-- this stack is referenced in Directory card "dir",  "on line" button script

-- revised July 2010, replace tDownloadProgressStack with local lDownloadProgressStack

global gPathToEngineFolder
local lStime
local lCancelled 
local lStartTicks
local lDownloadProgressStack

# ------------------

on updateDisplayStatus tStatus
  if there is a field "status" of the topStack then
    put tStatus into field "status" of the topStack
  else if there is a field "status" of me then
    put tStatus into field "status" of me
  else if there is a field "info box" of the topStack then
    put tStatus into field "info box" of the topStack
  else if there is a field "info box" of me then
    put tStatus into field "info box" of me
  end if
end updateDisplayStatus

# ------------------

# handlers below are from MetaCard 2.4 download stack in mctools.rev
# edited and names changed by R. Herz

# ----------------

on updateLoadGoStart href
   
   tester "get updater, updateLoadGoStart, enter updateLoadGoStart, href = " & href
   
   ## zzz separate this from updateLoadGoStartContinue and set counter
   ## zzz so can repeat if trouble below
   set the cConnectCounter of me to 0
   send "updateLoadGoStartContinue" && quote & href & quote to me in 10 milliseconds
   
end updateLoadGoStart

on updateLoadGoStartContinue href
   
   tester "get updater, enter updateLoadGoStartContinue, href = " & href
   
   put false into lCancelled
   
   put gPathToEngineFolder into lDownloadProgressStack
   put "/program_folder/scripts/download_progress.livecode" after lDownloadProgressStack
   
   if there is a stack "comm scripts" then # won't be if running from "default comm scripts"
      
      # zzz think now I want to always show download progress stack - really need on dialup!
      set the cShowDownloadProgress of stack "comm scripts" to "show"  # zzz
      
      if the cShowDownloadProgress of stack "comm scripts" is not "hide" then
         if there is a stack lDownloadProgressStack then
            # apparently can't open this "as modal" without also
            # changing the "send ... to me" below to specify "comm scripts" not "me"
            go stack lDownloadProgressStack
            put the cTitle["download"] of stack lDownloadProgressStack into field "title" of stack lDownloadProgressStack
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
         put "Downloading: " && tref into field "title" of stack lDownloadProgressStack
         updateDisplayStatus empty
         put "contacting" into field "status" of stack lDownloadProgressStack
         set the thumbPos of sb 1  of stack lDownloadProgressStack to 0
      end if
   end if
   
   tester "get updater, updateLoadGoStartContinue, just before load href, href = " & href
   
   load href
   updateDisplayStatus "contacting"
   
   ## zzz set counter so can repeat in case trouble below in finish
   put the cConnectCounter of me into tCount
   add 1 to tCount
   set the cConnectCounter of me to tCount
   
   send "updateLoadGoFinish" && quote & href & quote to me in 1000 milliseconds
   put the long seconds into lStime
end updateLoadGoStartContinue

# ----------------

on updateLoadGoFinish href
   
   local stat, nk
   
   tester "get updater, enter updateLoadGoFinish, href = " & href
   
   tester "get updater, enter updateLoadGoFinish, stat = " & stat
   
   if lCancelled then
      unload url href
      if there is a stack lDownloadProgressStack then
         close stack lDownloadProgressStack
      end if
      exit updateLoadGoFinish
   end if
   put urlStatus(href) into stat
   updateDisplayStatus stat
   
   if stat contains "error" or stat contains "not found" \
         or stat contains "time out" or stat contains "timeout" then
      
      if there is a stack lDownloadProgressStack then
         close stack lDownloadProgressStack
      end if
      
      ## zzz ----------------------------------------------------
      
      ## zzz get stat = error about every 10th time if are off line
      ## zzz pingPassive() returns online when trouble happens
      ## zzz and then click lab and say connect    
      ## zzz when this happened, manually clicking the divs and the labs again worked
      ## zzz so automate that process and try it in one repeat
      
      unload url href
      updateDisplayStatus empty
      put the cConnectCounter of me into tCount
      
      -- xxx change from card 2 to card "dir"
      if tCount < 2 and the cClickSPECIAL of field "the labs" of card "dir" of stack "Directory" is not "true" then
         
         send "getLabListFromServer" to field "the divs" of card "dir" of stack "Directory"
         set the cClickSPECIAL of field "the labs" of card "dir" of stack "Directory" to "true"
         send mouseUpSPECIAL to field "the labs" of card "dir" of stack "Directory" in 1 second
         
         ## zzz ----------------------------------------------------
         
      else
         
         answer "Trouble connecting.  Try:" & LF &\
         "1) Click on line button again." & LF &\
         "2) Click this division and lab again." & LF &\
         "3) Can you reach ReactorLab.net with web browser?"
         
      end if
      
      exit updateLoadGoFinish
   end if
   
   if stat contains "cached" then
      
      tester "get updater, updateLoadGoFinish, stat cached: stat = " & stat
      
      tester "get updater, updateLoadGoFinish, stat cached: href = " & href
      
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
         #gzipped stack
         updateDisplayStatus "decompressing"
         put decompress(url href) into temp
         
         tester "get updater, updateLoadGoFinish, stat cached: gz file temp (1) = " & temp
         
         if offset("REVO",word 1 of temp) = 1 AND the version < 2.7 then
            answer "You have an old version of the Reactor Lab which cannot be updated automatically." & LF & \
                  "Please download the new version at www.ReactorLab.net"
            unload url href
            put empty into temp
            updateDisplayStatus empty
            exit updateLoadGoFinish
         end if
         
         if word 1 of temp is "#!/bin/sh" OR offset("REVO",word 1 of temp) = 1 then
            updateDisplayStatus empty
            go temp
            unload url href
            put empty into temp
            exit updateLoadGoFinish
         else
            answer "URL" && href  && "is not a valid ReactorLab.net module."
            unload url href
            put empty into temp
            updateDisplayStatus empty
            exit updateLoadGoFinish
         end if
         
      else
         
         if there is a stack lDownloadProgressStack then
            put "Done" into field "status" of stack lDownloadProgressStack
            set the thumbpos of sb 1 of stack lDownloadProgressStack to the endValue of sb 1 of stack lDownloadProgressStack
            wait 500 milliseconds
            close stack lDownloadProgressStack
         end if
         
         put line 1 of url href into temp -- XXX CRITICAL NEW LINE XXX
         
         tester "get updater, updateLoadGoFinish, word 1 of not gz file temp (2) = " & word 1 of temp
         
         if offset("REVO",word 1 of temp) = 1 AND the version < 2.7 then
            answer "You have an old version of the Reactor Lab which cannot be updated automatically." & LF & \
                  "Please download the new version at www.ReactorLab.net"
            updateDisplayStatus empty
            unload url href
            exit updateLoadGoFinish
         end if
         
         if word 1 of temp is "#!/bin/sh" OR offset("REVO",word 1 of temp) = 1 then
            updateDisplayStatus empty
            go url href
            unload url href
            exit updateLoadGoFinish
         else
            answer "URL" && href  && "is not a valid ReactorLab.net module."
            updateDisplayStatus empty
            unload url href
            exit updateLoadGoFinish
         end if
         
      end if
   end if
   
   if item 1 of stat is "loading" then
      
      tester "get updater, updateLoadGoFinish, item 1 of stat is loading, stat = " & stat
      
      put item 2 of stat div 1024 into nk
      put nk & "K/" & item 3 of stat div 1024 & "K  "\
            & nk * 10 div (the long seconds - lStime) / 10 & "K/sec" into tprog
      updateDisplayStatus tprog
      
      if there is a stack lDownloadProgressStack then
         put tprog into field "status" of stack lDownloadProgressStack
         set the endValue of sb 1 of stack lDownloadProgressStack to item 3 of stat
         set the thumbpos of sb 1 of stack lDownloadProgressStack to item 2 of stat
      end if
      
   end if
   
   if stat is empty then
      
      tester "get updater, updateLoadGoFinish, if stat is empty, stat = " & stat
      
      updateDisplayStatus empty
      if there is a stack lDownloadProgressStack then
         close stack lDownloadProgressStack
      end if
      exit updateLoadGoFinish
   end if
   
   if stat is "requested" then
      
      tester "get updater, updateLoadGoFinish, if stat is requested, stat = " & stat
      
      updateDisplayStatus "requested"
      send "updateLoadGoFinish" && quote & href & quote to me in 500 milliseconds
   else
      
      tester "get updater, updateLoadGoFinish, if stat is requested NOT TRUE, before send updateLoadGoFinish, stat = " & stat
      
      send "updateLoadGoFinish" && quote & href & quote to me in 500 milliseconds
   end if
   
end updateLoadGoFinish
