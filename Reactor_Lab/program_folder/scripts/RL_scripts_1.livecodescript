script "RL scripts 1"

# The Reactor Lab stack designs and all scripts copyright 1996-2010
# PureWaterLab stack designs and scripts copyright 2005-2010
#  by Richard K. Herz, all rights reserved.

# ----------------

constant kLabTextBrowserStack = "Module Text" -- also set in RL scripts 1, 2, 4

-- new for merge
global gHomeStackShortName -- set in home stack
global gHomeStackFileName -- set in home stack
-- below set in comm scripts
global gSupportEmail
global gPingURL
global gMainLabWebSiteUrlShort

# ----------------

on closeCard -- default handler
  setInfo empty
end closeCard

# ----------------

on lockedVolumeAction
  
  put "false" into tMacOSXPlayer
  if the environment is not "development" then
    if the platform is "MacOS" then
      set the itemdelimiter to "."
      if item 1 of the systemversion > 9 then
        put "true" into tMacOSXPlayer
      end if
      set the itemdelimiter to ","
    end if
  end if
  
  if tMacOSXPlayer is "true" then
    put "You are trying to run this program on a locked disk, disk image, or server! " into temp
    put LF & "Copy the" && gHomeStackShortName && "folder to your local computer before running the program! " after temp -- new for merge
    put LF & "If you have opened a disk image file (.dmg), drag the" && gHomeStackShortName && "folder" after temp -- new for merge
    put LF & "and its contents to your hard disk, then open that copy of the Lab." after temp
    put LF & "This copy will quit now!" after temp
  else
    put "You are trying to run this program on a locked server or disk! " into temp
    put LF & "Copy the" && gHomeStackShortName && "folder to your local computer before running the program! " after temp -- new for merge
    put LF & "This copy will quit now!" after temp
  end if
   
  answer temp
  put "true" into quitFast
  quit
   
end lockedVolumeAction

# ----------------

on initInit
  
  # xxx get rid of globals that aren't necessary here 
  
  global budgetBalance, budgetRunCost, budgetPrintBal, budgetReportImage
  global runCount, oldRunCount, oldRuns
  global fileCount, preCount, setPlotted, xVarNum, yVarNum, preCount
  global tableFlag, setCount, err, dynTloaded, exportFileName
  global dataArray, dataHeaders, dataUnits, dataMinMax, dataPrompts
  global replot, replotLab, labInitialize, userName, tableLastRun
  global plotChecks, theFiles, runBeep, autoNote, decoOn
  global firstSetSaved, flagDataToSave, gCurrentCard
  global quitFast
  global doFolderMaintenanceDONE, backDropColor
  
  # new for net version
  global gChatSocket
  global gConferStackPath
  global gPathToEngineFolder
  global gLabURL
  global gLabUpdateStatus
  
  set the cShowDownloadProgress of stack "comm scripts" to empty
  
  set the navigationarrows to false
  set the textarrows to true
  
  # QuickTime can cause problems in some systems
  set the dontuseqt to true
  set the dontuseqteffects to true
  
  put gPathToEngineFolder into gConferStackPath
  put "/program_folder/scripts/Confer.livecode" after gConferStackPath
  
  put 1 into err  # random error level, value is std dev percent
  
  put zero into budgetBalance
  put zero into budgetRunCost
  put zero into budgetPrintBal
  put zero into runCount
  put zero into oldRunCount
  put zero into oldRuns  # xxx where is this used????
  put zero into fileCount
  put zero into preCount
  put zero into setPlotted
  put zero into xVarNum
  put zero into yVarNum
  put zero into preCount
  put zero into tableFlag
  put zero into tableLastRun
  put 1 into setCount
  put empty into budgetReportImage
  put empty into dataArray
  put empty into dataHeaders
  put empty into dataUnits
  put empty into dataMinMax
  put empty into dataPrompts
  put empty into userName
  put empty into theFiles
  put empty into gCurrentCard
  put "ooooooo" into plotChecks  # l.c. letter "oh"
  put "no" into firstSetSaved
  put "false" into flagDataToSave
  put "no" into dynTloaded
  put "none" into exportFileName
  put "false" into replot
  put "false" into replotLab
  put "true" into labInitialize
  put "true" into decoOn -- was an option in Options stack but convert to true with no option
  put "true" into quitFast  # set "false" when user clicks on a lab in directory
  put "no" into doFolderMaintenanceDONE
  
  get the customSettings of stack "Options" # was placed in use in openStack
  put line 1 of it into runBeep
  put line 2 of it into autoNote
  put line 3 of it into backDropColor
  set the backdrop to backDropColor
  put empty into gChatSocket
  put empty into gLabURL
  put empty into gLabUpdateStatus -- see the labs field script of Directory
  
  tableDataClear
  plotReset
  
end initInit

# -------------

on closeStackRequest
   
   global dataArray
   global flagDataToSave
   
   # new for net version: change "is one" to "is two" because
   # Directory is not the standalone anymore, the hidden "engine" stack is
   
   put 2 into tMinLines -- 1 for hidden "engine" stack, 1 for stack being closed
   
   --  answer "closeStackRequest: num lines, stacks = " & the number of lines in the stacks & LF & \
         --      the stacks
   
   -- xxx trouble with checking dataArray is that profile labs don't empty it on save
   -- xxx so check flagDataToSave
   -- xxx if the number of lines in the stacks is tMinLines and dataArray is not empty then
   
   if the number of lines in the stacks is tMinLines and flagDataToSave is "true" then
      
      put "At least one window must remain open when" && gHomeStackShortName && "is active." into temp -- new for merge
      put return & "You have unsaved data which will be lost if you quit now." after temp
      put return & "Would you like to Quit or Stay?" after temp
      answer temp with "Quit" or "Stay"
      if it is "Quit" then
         put "false" into flagDataToSave -- since may get checked again in shutdown and/or shutdownrequest
         quit
      end if
      
   else if the number of lines in the stacks is tMinLines then
      
      put "At least one window must remain open when" && gHomeStackShortName && "is active." into temp -- new for merge
      put return & "Would you like to Quit or Stay?" after temp
      answer temp with "Quit" or "Stay"
      if it is "Quit" then
         put "false" into flagDataToSave -- just in case
         quit
      end if
      
   else
      
      -- for stacks that use altBrowser external -- uuu
      if the altBrowserID of this stack is not empty then
         put the altBrowserID of this stack into tID
         revBrowserClose tID
         set the altBrowserID of this stack to empty
      end if
      
      pass closeStackRequest
   end if
   
end closeStackRequest

# -----------------

-- April 2017, RKH, info stacks not reliably getting
-- check to see if the info stack is open but main lab
-- stack is closed in order to get the return to lab button to
-- show in info stack 
-- so add windowChecker in focus in and out
-- close stack doesn't work because windowChecker gets
-- sent before lab stack is actually closed

on focusOut
   windowChecker 
   pass focusOut
end focusOut

on focusIn
   windowChecker
   pass focusIn
end focusIn

on windowChecker
   global windowMain
   put "no" into foundIt
   repeat with i = 1 to the number of lines in the windows
      if windowMain is line i of the windows OR word 2 of line i of the windows is "sims" OR \
            "Module Text" is line i of the windows then
         -- WHEN first download a PWL lab, windowMain will be name of lab rather than Module Text
         -- so check for Module Text
         -- THIS REQUIRES PWL SIMULATION STACK to have word 2 of its name = "sims"
         -- when main part of module is stack "Module Text" with revBrowser display
         -- and then go to simulations and close the module text stack
         -- and then click info button or conference room (or other stack)
         -- and then close simulations stack, then don't want the return notice to show
         put "yes" into foundIt
         if there is a button "return to windowMain" then
            hide button "return to windowMain"
         end if
         if there is a field "return notice" then
            hide field "return notice"
         end if
         exit repeat
      end if
   end repeat
   if foundIt is "no" then
      if there is a button "return to windowMain" then
         show button "return to windowMain"
      end if
      if there is a field "return notice" then
         show field "return notice"
      end if
   end if
end windowChecker

# -----------------

on returnBtnHandler topen
  global directoryOpen
  if there is a field "return notice" then
    hide field "return notice"
  end if
  if there is a button "return to windowMain" then
    hide button "return to windowMain"
  end if
  if topen is "open" then
    # leave this stack open
  else
    close the name of this stack
  end if
  if directoryOpen is "yes" then
    showDirectory
  else
    showLab
  end if
end returnBtnHandler

# -----------------

on showAbout
  global pathTOstacks
  put pathTOstacks & "/About_The_Lab.livecode"  into temp
  if there is a stack temp then
    go stack temp as toplevel
  else
    answer "About file is missing - get a fresh distribution of The Lab"
  end if
end showAbout

# -----------------

on showOptions
  global pathTOstacks
  put pathTOstacks & "/Options.livecode" into temp
  if there is a stack temp then
    go stack temp as toplevel
  else
    answer "Option file is missing - get a fresh distribution of The Lab"
  end if
end showOptions

# -----------------

on showInfoStack
  global pathTOlabFolder, labNumber
  put the short name of this cd into infoCard
  if offset("card id", infoCard) > 0 then
    put empty into infoCard  # cd name is blank so got id back
  end if
  put pathTOlabFolder & "/" & labNumber & "_info.livecode" into labInfo
  if there is a stack labInfo then
    go stack labInfo as toplevel
    if infoCard is not empty then
      go cd infoCard
    end if
  else
    answer "Sorry.  No more information is available."
  end if
end showInfoStack

# -----------------

on checkForConferenceRoom
   -- in 2014 don't have chat server running
    if there is a button "go conference" then set the icon of button "go conference" to 0 -- was using icon 999031 
   if there is a button "go conference" then set the enabled of button "go conference" to false
   if there is a field "online users label" then set the enabled of field "online users label" to false
   if there is a field "current connects" then set the enabled of field "current connects" to false
   if there is a field "conferee label" then set the enabled of field "conferee label" to false
   if there is a field "conferees" then set the enabled of field "conferees" to false
end checkForConferenceRoom

# -----------------

-- new for PWL but also can be used in RL
on checkForInfoStack
  global pathTOlabFolder, labNumber
  put the short name of this cd into infoCard
  if offset("card id", infoCard) > 0 then
    put empty into infoCard  # cd name is blank so got id back
  end if
  put pathTOlabFolder & "/" & labNumber & "_info.livecode" into labInfo
  if there is a button "go help" then
    if there is a stack labInfo then
      set the customEnabled of button "go help" to true
    else
      set the customEnabled of button "go help" to false
    end if
  end if
end checkForInfoStack

# -----------------

on showLab
  # script for Show menu in menubar
  global pathTOlab, gCurrentCard
  go stack pathTOlab as toplevel
  go cd gCurrentCard of stack pathTOlab
end showLab

#-----------------

on showLabButton
  # script for button "go lab"
  global labCardName
  global labType
  global runCount
  
  if "Q" is in labType then
    if runCount > 0 then
      answer "Going to the lab will clear your data from memory" with "Leave" or "Stay"
      if it is "Stay" then
        exit showLabButton
      end if
    end if
    leaveLab "no"  # assumes lab and quiz in same stack
  end if
  
  visual effect dissolve fast
  go to cd labCardName
  
end showLabButton

# -----------

on showQuiz
  
  global labCardName
  global labType
  global runCount
  
  if "Q" is not in labType and runCount > 0 then
    answer "Going to the quiz will clear your data from memory" with "Leave" or "Stay"
    if it is "Stay" then exit showQuiz
  end if
  
  if "Q" is not in labType then
    leaveLab "no"  # assumes lab and quiz in same stack
  end if
  
  put stripOuterSpace(labCardName && "Quiz") into labQuizName
  if there is a cd labQuizName then
    visual effect dissolve fast
    go cd labQuizName
  else
    answer "Quiz not available."
  end if
  
  set the enabled of button "go budget"to true
  
end showQuiz

# -----------------

on showTable
  global pathTOstacks
  put pathTOstacks & "/Table.livecode" into temp
  if there is a stack temp then
    go stack temp as toplevel
  else
    answer "Table file is missing - get a fresh distribution of The Lab"
  end if
end showTable

# -----------------

on showNotePad
  global pathTOstacks
  put pathTOstacks & "/Note_Pad.livecode" into temp
  if there is a stack temp then
    go stack temp as toplevel
  else
    answer "Note Pad file is missing - get a fresh distribution of The Lab"
  end if
  select after text of field 1 of cd 1
end showNotePad

# ------------

on showPlot
  global pathTOstacks
  put pathTOstacks & "/Plot.livecode" into temp
  if there is a stack temp then
    go stack temp as toplevel
  else
    answer "Plot file is missing - get a fresh distribution of The Lab"
  end if
end showPlot

# ---------------

on showBudget
  global pathTOstacks
  put pathTOstacks & "/Budget_Report.livecode" into temp
  if there is a stack temp then
    go stack temp as toplevel
  else
    answer "Budget file is missing - get a fresh distribution of The Lab"
  end if
end showBudget

# ---------------

on showDirectory
  
  global labType, labNumber
  global dataArray, pathTOstacks, pathTOdirectory
  global record, tableOpen, plotOpen, directoryOpen
  
  if the number of lines in dataArray > 0 then
    answer "Leaving the lab will clear your data from memory!" with "Leave" or "Stay"
    if it is "Stay" then
      exit showDirectory
    end if
  end if
  
  if ("D" is in labType) and (record is "on") then -- Dynamic
    answer "Please stop saving data to disk before leaving." with "OK"
    exit showDirectory
  end if
  
  put the stacks into sList
  repeat with i = 1 to the number of lines in sList
    if "Table" is in line i of sList then
      put line i of sList into sClose
      if there is a stack sClose then
        close stack sClose
      end if
    end if
    if "Plot" is in line i of sList then
      put line i of sList into sClose
      if there is a stack sClose then
        close stack sClose
      end if
    end if
    if "info" is in line i of sList then
      if "Directory_Info" is in line i of sList then
        # do nothing
      else
        put line i of sList into sClose
        if there is a stack sClose then
          close stack sClose
        end if
      end if
    end if
  end repeat
  
  leaveLab
  
end showDirectory

# -----------------

on showHomeCard
   visual effect wipe right
   go card "home" of stack "Directory"
end showHomeCard

# -----------------

on showConferenceRoom
  global pathTOstacks
  
  put pathTOstacks & "/Confer.livecode" into tConfer
  go stack tConfer
  
  # zzz to deactivate
  # put "The Conference Room is temporarily unavailable." into temp # zzz
  # put LF & "Go 'on line' to check for updates." after temp # zzz
  # answer temp # zzz
  
end showConferenceRoom

# -----------------

-- new in PWL
on showLabText
  global pathTOstacks
  -- "this stack" should be lab sims stack
  put the long name of this stack into tStack
  set the itemdelimiter to "_"
  delete the last item of tStack -- delete _sims.livecode"
  put ".livecode" & quote after tStack
  if there is a field "text" of stack tStack then
    -- this module doesn't use browser
    toplevel stack tStack
  else
    -- this module uses browser stack
    put kLabTextBrowserStack into tStack -- kLabTextBrowserStack is short name of stack
    replace space with "_" in tStack
    put pathTOstacks & "/" before tStack
    put ".livecode" after tStack
    -- put pathTOstacks & "/Module_Text.livecode" into tStack
    if there is a stack tStack then
      toplevel stack tStack
    else
      answer "Module Text file is missing - get a fresh distribution of The Lab"
    end if
  end if
end showLabText

# -----------------

-- new in PWL
on showLabSims
  global pathTOlab
  put pathTOlab into tStack
  set the itemdelimiter to "."
  delete the last item of tStack -- delete .livecode"
  put "_sims.livecode" after tStack
  if there is a stack tStack then
    -- check if need to set revxml externals before opening first time
    put pathTOlab into tFolder
    set the itemdelimiter to "/"
    delete the last item of tFolder
    if the platform is "Win32" then
      put tFolder & "/revxml.dll" into tExternal
      if there is a file tExternal then
        set the externals of stack tStack to tExternal
      end if
    else if the platform is "MacOS" then
      put tFolder & "/revxml.bundle" into tExternal
      if there is a folder tExternal then
        -- answer "in rl scripts in showLabSims, there is folder"
        set the externals of stack tStack to tExternal
      end if
    else
      -- xxx don't have xml parser for Linux
    end if -- end of: if the platform is "Win32", else if
    toplevel stack tStack
  end if -- end of: if there is a stack tStack
  -- answer "in rl scripts 1 in showLabSims, the externals = " & LF & the externals of stack tStack
end showLabSims

# -----------------

on infoForLabButton
  global labCardName
  if the enabled of button "go lab" is "true" then
    setInfo "Click here to return to the lab."
  else
    put the short name of this cd into thisTempName
    if offset("card id", thisTempName) > 0 then
      put empty into thisTempName
    end if
    if thisTempName is labCardName then
      setInfo "You're already here."
    else
      setInfo "Not available."
    end if
  end if
end infoForLabButton

on infoForLabButtonDisabled
  setInfo "Not available.  In a lab quiz, click this to return to the regular lab."
end infoForLabButtonDisabled

# ----------------

on infoForQuizButton
  global labCardName
  put stripOuterSpace(labCardName && "Quiz") into labQuizName
  if the enabled of button "go lab quiz" is "true" then
    setInfo "Click here to go to the quiz for this lab."
  else
    if the short name of this cd is labQuizName then
      setInfo "You're already here."
    else
      setInfo "Not available."
    end if
  end if
end infoForQuizButton

on infoForQuizButtonDisabled
  setInfo "Not available.  In a lab with a quiz, click this to go to the quiz."
end infoForQuizButtonDisabled

# -----------------

on infoForTableButton
  if the enabled of button "go table" is "true" then
    setInfo "Click here to open the data table and view the current data set."
  else
    setInfo "Table not available now."
  end if
end infoForTableButton

on infoForTableButtonDisabled
  setInfo "Not available.  In a lab module, click this to see the current data."
end infoForTableButtonDisabled

# -----------------

on infoForHelpButton
  if the enabled of button "go help" is "true" then
    if the short name of the topstack is "Directory" then
      setInfo "Click here for more information."
    else
      setInfo "Click here for more information."
    end if
  else
    if the name of this cd contains "Help" then
      setInfo "You're already here."
    else
      setInfo "Additional information not available."
    end if
  end if
end infoForHelpButton

on infoForHelpButtonDisabled
  setInfo "Not available."
end infoForHelpButtonDisabled

# -----------------

on infoForHomeButton
   setInfo "Click here to go to SimzLab home to change courses."
end infoForHomeButton

on infoForHomeButtonDisabled
   setInfo empty
end infoForHomeButtonDisabled

# -----------------

on infoForNotePadButton
  if the enabled of button "go note pad" is "true" then
    setInfo "Click here to open the note pad to record your observations."
  else
    setInfo "Note pad not available now."
  end if
end infoForNotePadButton

# -----------------

on infoForPlotButton
  if the enabled of button "go plot" is "true" then
    setInfo "Click here to print the plot and to add previous data sets to the plot."
  else
    setInfo "Plot not available."
  end if
end infoForPlotButton

on infoForPlotButtonDisabled
  setInfo "Not available.  In a lab module, click this to see plots of the current data."
end infoForPlotButtonDisabled

# -----------------

on infoForBudgetButton
  if the enabled of button "go budget" is "true" then
    setInfo "Click here to see  your budget report."
  else
    if the id of this cd is "card id 13991" then
      setInfo "You're at the budget report."
    else
      setInfo "Budget report not available now."
    end if
  end if
end infoForBudgetButton

# -----------------

on infoForDirectoryButton
  if the enabled of button "go directory" is "true" then
    setInfo "Click here to go to the Directory to change labs."
  else
    setInfo "Not available now."
  end if
end infoForDirectoryButton

on infoForDirectoryButtonDisabled
  setInfo "You're already in the Directory.  In a lab module, click this button to return here."
end infoForDirectoryButtonDisabled

# -----------------

on infoForAboutButton
  setInfo "Click here for instructions on how to use the Lab."
end infoForAboutButton

# -----------------

on infoForOptionsButton
  setInfo "Click here to choose your options."
end infoForOptionsButton

# -----------------

on infoForReturnButton
  global directoryOpen
  if directoryOpen is "yes" then
    setInfo "Click here to return to the Directory."
  else
    setInfo "Click here to return to the lab."
  end if
end infoForReturnButton

# -----------------

on infoStackTextPrinter
  if there is not a field "info" then exit infoStackTextPrinter
  put the htmltext of field "info" into bodyText
  myPrintField bodyText,"helvetica",12
end infoStackTextPrinter

# -----------------

on infoForConferenceRoom
  
  setInfo "Click to enter the Conference Room. Send email and messages, read messages."
  
  # setInfo "The Conference Room is temporarily unavailable. Go 'on line' to check for updates." # zzz
  
end infoForConferenceRoom

# -----------------

on infoForConnectDisplay
  
  global gConnectStatus
  if field "current connects" is "-" then
    if gConnectStatus is "true" then
      put "Message connection closed.  Click 'on line' button again to connect." into tInfo
    else
      put "Shows number of people working on line when you are on line." into tInfo
    end if
  else
    put "Number of people working in the Lab and connected to" && gMainLabWebSiteUrlShort into tInfo -- new for merge
  end if
  setInfo tInfo
  
  # setInfo "Display of people on line is temporarily unavailable." # zzz 
  
end infoForConnectDisplay

# -----------------

on infoForConferDisplay
  
  global gConnectStatus
  if field "conferees" is "-" then
    if gConnectStatus is "true" then
      put "Message connection closed.  Click 'on line' button again to connect." into tInfo
    else
      put "Shows new messages received in Conference Room when you are on line." into tInfo
    end if
  else
    put "New messages received in Conference Room." into tInfo
  end if
  setInfo tInfo
  
  # setInfo "Conference Room is temporarily unavailable." # zzz
  
end infoForConferDisplay

# -----------------

-- new in PWL
on infoForSectionListField
  setInfo "Click a section name to display its text."
end infoForSectionListField

# -----------------

-- new in PWL
on infoForSimulationButton
  setInfo "Click to open the simulations for this lab. This window will remain open."
end infoForSimulationButton

# -----------------

-- new in PWL
on infoForTextButton
  setInfo "Click to open text explanation for lab. This window will remain open."
end infoForTextButton

# -----------------

-- new in PWL
on infoForSimulationListField
  setInfo "Click on a simulation name to go to the simulation."
end infoForSimulationListField

# -----------------

on mouseUp
    -- default mouseUp handler
    -- handles email and url links clicked in fields
    put the clicktext into thisLink
    handleLinkInTextField thisLink
end mouseUp

on handleLinkInTextField thisLink
    replace space with empty in thisLink
    if thisLink contains "@" then
        revMail thisLink,,"Lab support request"
    else if the version >= "2.9" then
        handleLinkInTextField_New thisLink
    else
        handleLinkInTextField_Old thisLink
    end if
end handleLinkInTextField

on handleLinkInTextField_New thisLink
    -- for Rev engine versions 2.9.0 and later
    -- uses "launch url" instroduced with Rev engine version 2.9.0
    -- uses offset rather than "begins with" which stalls entire script when run under Rev engines before 2.9
    if offset("www.",thisLink) = 1 then put "http://" before thisLink 
    if offset("http://",thisLink) = 1 then launch url thisLink
    -- xxx can launch url handle ftp? 
end handleLinkInTextField_New

on handleLinkInTextField_Old thisLink
    -- for Rev engine versions before 2.9.0
    if offset("www.",thisLink) = 1 then put "http://" before thisLink 
    if offset("http://",thisLink) = 1 then revGoUrl thisLink
end handleLinkInTextField_Old

# -----------------

# deactivate this and set navigation arrows to false in initInit
#on arrowKey
#  # do nothing
#end arrowKey

# -----------------

# iconifyStack is meant for Windows (need to check Unix/Linux)
# On Win, if have backdrop showing and hiding system task bar and only one RL stack,
# then iconify (minimize) that stack, then task bar is covered and only backdrop shows
# on screen (control-alt-escape will show task bar).  These clear backdrop when iconify
# a single RL stack
# at least on MacOS, iconifyStack gets sent whenever mouse enters or starts a move
#  within window "icon" which is window title bar on MacOS
# unIconifyStack msg available but not used because of crash problem on Win, see below

# get MC crash on Win if try to change backdrop and any stacks are minimized (iconic)!!!!
# see control/command key B handlers below

on iconifyStack
  global backDropColor
  if the platform is not "MacOS" then
    set the backdrop to "none"
  end if
  pass iconifyStack
end iconifyStack

# -----------------

on controlKeyDown theKey
   # this is only sent on Macs; sent on Mac when control key pressed
   # also see commandKeyDown handler in this script
   global dataArray
   global backDropColor
   switch theKey
      case "B"
         put "false" into tFlag
         if the platform is not "MacOS" then
            repeat for each line tStack in the stacks
               if the iconic of stack tStack is true then
                  put "true" into tFlag
               end if
            end repeat
         end if
         if tFlag is "false" then
            # only change backdrop if Mac or no stacks minimized on Win
            if the backdrop is "none" then
               set the backdrop to backDropColor
            else
               set the backdrop to "none"
            end if
         else
            answer "You can't change the backdrop if any Lab windows are minimized."
         end if
         break
      case "C"
         if the environment is "development" then
            pass controlKeyDown
         else
            copy the selectedtext
         end if
         # see case V below
         break
         --  case "F"
         --    if (the altBrowserState of stack kLabTextBrowserStack is true) AND \
                --        (the long name of stack kLabTextBrowserStack is the topStack) then
         --      pwlFindBrowserText -- in RL scripts 4
         --    else
         --      pass controlKeyDown
         --    end if
         --    break
         --  case "G"
         --    if (the altBrowserState of stack kLabTextBrowserStack is true) AND \
                --        (the long name of stack kLabTextBrowserStack is the topStack) then
         --      pwlFindAGAINBrowserText -- in RL scripts 4
         --    else
         --      pass controlKeyDown
         --    end if
         --    break
      case "P"
         lock screen
         myPrintCard the short name of this stack
         unlock screen
         break
         -- case "Q"
         --    -- MAC CMD-Q DOES NOT GET CAUGHT HERE
         --    -- USE THE REV COMMAND SHUTDOWNREQUEST INSTEAD
         --    # make sure this is consistent with on menuPick handler in File button of
         --    # Directory stack's menubar group, where typing Q with commandKey doesn't work consistently
         --    if dataArray is not empty then
         --      put "You have unsaved data which will be lost if you quit now." into temp
         --      put return & "Would you like to Quit or Stay?" after temp
         --      answer temp with "Quit" or "Stay"
         --      if it is "Quit" then
         --        quit  # this sends shutDown message before quitting
         --      end if
         --    else
         --      if the environment is "development" then
         --        # check to avoid quitting during development by mistake
         --        answer "Are you sure you want to quit?" with "Stay" or "Quit"
         --        if it is "Quit" then
         --          quit  # this sends shutDown message before quitting
         --        end if
         --      else
         --        # in standalone (player) and no current data, just quit without another check
         --        quit  # this sends shutDown message before quitting
         --      end if
         --    end if
         --    break
      case "R"
         if there is a button "Run" then
            send mouseUp to button "Run"
         else if there is a button "Run Reaction" then
            send mouseUp to button "Run Reaction"
         end if
         break
      case "V"
         if the environment is "development" then
            pass controlKeyDown
         else
            if the clipboard is "text" then
               paste
            end if
         end if
         # see case C above
         break
      default
         pass controlKeyDown
   end switch
end controlKeyDown

# -----------------

on commandKeyDown theKey
   # commandKey on Mac is Apple/Cloverleaf key, on Windows and Unix it's the Control key
   # see also controlKeyDown handler in this script which is for Mac control key only
   global dataArray
   global backDropColor
   switch theKey
      case "B"
         put "false" into tFlag
         if the platform is not "MacOS" then
            repeat for each line tStack in the stacks
               if the iconic of stack tStack is true then
                  put "true" into tFlag
               end if
            end repeat
         end if
         if tFlag is "false" then
            # only change backdrop if Mac or no stacks minimized on Win
            if the backdrop is "none" then
               set the backdrop to backDropColor
            else
               set the backdrop to "none"
            end if
         else
            answer "You can't change the backdrop if any Lab windows are minimized."
         end if
         break
      case "C"
         if the environment is "development" then
            pass commandKeyDown
         else
            copy the selectedtext
         end if
         # see case V below
         break
         --  case "F"
         --    if (the altBrowserState of stack kLabTextBrowserStack is true) AND \
                --        (the long name of stack kLabTextBrowserStack is the topStack) then
         --      pwlFindBrowserText -- in RL scripts 4
         --    else
         --      pass commandKeyDown
         --    end if
         --    break
         --  case "G"
         --    if (the altBrowserState of stack kLabTextBrowserStack is true) AND \
                --        (the long name of stack kLabTextBrowserStack is the topStack) then
         --      pwlFindAGAINBrowserText -- in RL scripts 4
         --    else
         --      pass commandKeyDown
         --    end if
         --    break
      case "P"
         lock screen
         myPrintCard the short name of this stack
         unlock screen
         break
         --      case "Q"
         --         -- MAC CMD-Q DOES NOT GET CAUGHT HERE
         --         -- USE THE REV COMMAND SHUTDOWNREQUEST INSTEAD
         --         # make sure this is consistent with on menuPick handler in File button of
         --         # Directory stack's menubar group, where typing Q with commandKey doesn't work consistently
         --         if dataArray is not empty then
         --            put "You have unsaved data which will be lost if you quit now." into temp
         --            put return & "Would you like to Quit or Stay?" after temp
         --            answer temp with "Quit" or "Stay"
         --            if it is "Quit" then
         --               quit  # this sends shutDown message before quitting
         --            end if
         --         else
         --            if the environment is "development" then
         --               # check to avoid quitting during development by mistake
         --               answer "Are you sure you want to quit?" with "Stay" or "Quit"
         --               if it is "Quit" then
         --                  quit  # this sends shutDown message before quitting
         --               end if
         --            else
         --               # in standalone (player) and no current data, just quit without another check
         --               quit  # this sends shutDown message before quitting
         --            end if
         --         end if
         --         break
      case "R"
         if there is a button "Run" then
            send mouseUp to button "Run"
         else if there is a button "Run Reaction" then
            send mouseUp to button "Run Reaction"
         end if
         break
      case "V"
         if the environment is "development" then
            pass commandKeyDown
         else
            if the clipboard is "text" then
               paste
            end if
         end if
         # see case C above
         break
      default
         pass commandKeyDown
   end switch
end commandKeyDown

# -----------------

function switchReactorCheck runCount
  # used in change reactor buttons in labs with different reactor options
  put "ignore" into tFlag
  if runCount > 0 then
    answer "Switching reactors will clear your data from memory." with "Switch" or "Cancel"
    if it is "Cancel" then put "Stay" into tFlag # calling units look for "Stay"
  end if
  return tFlag
end switchReactorCheck

# -----------------

on shutDownRequest
   
   global dataArray
   global flagDataToSave
   
   -- NEED THIS IF WANT TO HANDLE MAC CMD-Q SINCE THAT
   -- IS NOT INTERCEPTED BY commandKeyDown NOR controlKeyDown
   -- don't have this send shutdown or may get inifinite recursion
   
   -- next block was from case "Q" in commandKeyDown but doesn't fire
   -- there when type cmd-Q on Mac
   
   -- xxx trouble with checking dataArray is that it is not emptied after
   -- xxx saving profile labs so check flagDataToSave
   -- xxx if dataArray is not empty then
   
   put "END SESSION (in shutDownRequest, Cmd-Q) at" && the long time & LF after gHistory 
   put the cSessionStartSeconds of stack "Directory" into tStart
   put the seconds - tStart into tElapsed
   put round(tElapsed/60, 1) into tElapsed
   put the long time & "," && tElapsed && "MINUTES TOTAL SESSION DURATION" & LF after gHistory
   logHistory
   
   if flagDataToSave is "true" then
      
      put "You have unsaved data which will be lost if you quit now." into temp
      put return & "Would you like to Quit or Stay?" after temp
      answer temp with "Quit" or "Stay"
      if it is "Stay" then
         exit shutDownRequest 
      end if
      if it is "Quit" then
         put "false" into flagDataToSave
      end if
   end if
   
   pass shutDownRequest
   
end shutDownRequest

# -----------------

on shutDown
   
   global labNumber, labCardName, labType
   global plotPaint, dataArray, gCurrentCard, currentDataFolderName
   global pathTOstacks, pathTOdirectory, pathTOsessionNotes, pathTOlab
   global budgetBalance, budgetPrintBal, budgetReportImage
   global firstSetSaved, quizFirstRun
   global doFolderMaintenanceDONE
   global quitFast # quit fast if user has never gone to a lab
   global quitFlag # set to "true" here, checked when saving Budget Report and Note Pad files
   
   global gConnectStatus
   global gHistory
   
   closeChatSocket
   
   if quitFast is "true" then 
      -- -- quitFast is set to false when user clicks on lab in Directory
      -- -- exit shutDown here skips rest of shutdown handLer AND LAB WILL THEN QUIT
      -- exit shutDown 
   end if
   
   put "true" into quitFlag # used in Note Pad and Budget stacks when writing final disk files
   
   if there is a stack pathTOdirectory then
      # operating as stack, not standalone
      # "the stacks" gets cleared before entering shutDown
      # so need to refer to stacks by file path
      put pathTOdirectory into pathTOdirectory
   else
      # operating as standalone, not stack
      # "the stacks" gets cleared before entering shutDown
      # but, for some reason, file path doesn't work but stack name does!
      put "Directory" into pathTOdirectory # xxx new for net
   end if
   
   hide button 1 of card 1 of stack pathTOdirectory
   go card 1 of stack pathTOdirectory
   -- set htmltext after going to card because card has an opencard that sets text to welcome
   set the htmltext of field "title" of card 1 of stack pathTOdirectory to field "htmltext for goodbye" of card 1 of stack pathTOdirectory -- hidden field
   put "Quitting..." & LF & LF into temp
   put "   Please email comments to:" & LF & LF after temp
   put "      " & gSupportEmail after temp -- new for merge
   put temp into field "welcome" of card 1 of stack pathTOdirectory
   
   put the ticks into tStartQuitTicks -- so quit messages stay up min amt time
   
   put "END SESSION (in shutDown) at" && the long time & LF after gHistory 
   put the cSessionStartSeconds of stack "Directory" into tStart
   put the seconds - tStart into tElapsed
   put round(tElapsed/60, 1) into tElapsed
   put the long time & "," && tElapsed && "MINUTES TOTAL SESSION DURATION" & LF after gHistory
   logHistory
   
   if plotPaint is "true" and dataArray is not empty then
      # lab is active so go and clear its thumbnail plot
      # no need to clear other params on quitting, though
      go cd gCurrentCard of stack pathTOlab in new window
      plotClear
      close this stack
   end if
   
   # this if needs to be above "if budgetBalance..." below!
   if "Q" is in labType and quizFirstRun is "yes" then
      # they are quitting from inside an active quiz
      go cd gCurrentCard of stack pathTOlab in new window
      -- answer "in shutDown, just before quizExit" -- bbb
      quizExit
      -- answer "in shutDown, just after quizExit" -- bbb
      close this stack
   end if
   
   -- answer "in shutDown, budgetBalance, budgetPrintBal = " & LF & budgetBalance & LF & budgetPrintBal -- bbb
   
   if budgetBalance is not budgetPrintBal then
      
      -- answer "inside if budgetBalance is not budgetPrintBal"
      
      go stack pathTOstacks & "/Budget_Report.livecode" in new window
      -- don't need this since will be sent on resumeStack: send updateMe to stack "Budget Report"
      send mouseUp to button "Save" of cd "Budget" of stack "Budget Report"
      
      -- answer "mouseUp was sent to button save of cd budget of budget report" -- bbb
      
      if budgetPrintBal = "FINAL" then # set to "FINAL" in Budget Report Stack's Save button on quitting
         put "Your Budget Report was saved to the file 'FINAL_budget_report.txt'." into temp
      else
         put "Your Budget Report was saved to the file 'budget_report.txt'." into temp
      end if
      put return & "To return to an unfinished quiz in a new session," after temp
      put space & "copy the last version of the code from the Budget Report disk file," after temp
      put space & "click the Reset button in the quiz, then paste the old code." after temp
      
      # xxx get strange error referring to field "developer credits" of bg "Regular Background"
      # xxx and creation of a new blank stack if click Print here!
      # xxx    put return & "You can always print the disk file version of the Report." after temp
      # xxx    put return & "Would you like to print a paper copy of the Report now or just Quit?" after temp
      # xxx     beep
      
      answer temp # xxx with "Print" or "Quit"
      
      # xxx     if it is "Print" then
      # xxx    send mouseUp to button "Print" of cd "Budget"
      # xxx    end if
      
      wait 0.5 seconds
      send clearBudgetFields
      wait 0.5 seconds
      close this stack
      
   end if
   
   if there is a file pathTOsessionNotes then
      put pathTOstacks & "/Note_Pad.livecode"  into pathTOnotes
      go stack pathTOnotes in new window
      if field "notes" is not empty then
         open file pathTOsessionNotes for write
         
         if the result is not empty then
            # file probably open in another application
            set the itemdelimiter to "/"
            put "FINAL_" before the last item of pathTOsessionNotes
            set the itemdelimiter to comma
            open file pathTOsessionNotes for write
            put "This file with FINAL prefix was written because the regular file" into temp
            put return & "was open in another program and couldn't be accessed by the Lab." & return & return after temp
            write temp to file pathTOsessionNotes
         end if
         
         write field "notes" to file pathTOsessionNotes
         close file pathTOsessionNotes
         
         set the itemdelimiter to "/"
         put the last item of pathTOsessionNotes into shortFileName
         set the itemdelimiter to comma
         put "Your notes have been saved to the disk file" into temp
         put return & "'" & shortFileName & "'." after temp
         put return & "The Note Pad will be cleared for the next user." after temp
         answer temp
         wait 0.5 seconds
         put empty into field "notes"
         wait 0.5 seconds
      end if
      close stack pathTOnotes
   end if
   
   if doFolderMaintenanceDONE is "yes" then
      go stack pathTOdirectory
      go card 1 of stack pathTOdirectory
      -- set htmltext after going to card because card has an opencard that sets text to welcome
      set the htmltext of field "title" of card 1 of stack pathTOdirectory to field "htmltext for goodbye" of card 1 of stack pathTOdirectory -- hidden field
      set cursor to watch
      wait 1 second
      beep
      put "Your files from this session are in the folder '" & currentDataFolderName & "'" into temp
      put return & " (session_mon-day_#) in the folder 'data_folder'." after temp
      # order of yr, mon, day set in doFolderMaintenance
      put return & return & "If you are working in a computer lab, copy these files" after temp
      put space & "to your own disk to save them." after temp
      answer temp
      wait 1 second
   end if
   
   -- want to have goodbye notice up a minimum time
   put the ticks - tStartQuitTicks into tTicks
   if tTicks < 90 then
      put 90 - tTicks into tTicks
      wait tTicks
   end if
   
   # engine quits automatically after shutDown ends
   
end shutDown

# -----------------

on leaveLab goDirectory
  
  global pathTOlab
  global labCardName, labNumber
  global labType, gCurrentCard
  global runCount, setCount
  global dataArray, dataHeaders, dataUnits, dataMinMax, dataPrompts
  global labInitialize, setPlotted, xVarNum, tableLastRun
  global yVarNum, preCount, replot, replotLab, plotPaint
  global pathTOapp, pathTOtemps, pathTOlab, pathTOdirectory
  global plotFlag, flagDataToSave
  global quizSpecifyOrder, quizInputs
  global specialPoints  # for Steady State CSTR
  global gHistory
  global gLabURL
  
  if "Q" is in labType then
    put labCardName && "Quiz" into qName
    if there is a stack pathTOlab then
      go cd qName of stack pathTOlab
      quizExit
    end if
  end if
  
  -- new in PWL
  put pathTOlab into tSims
  set the itemdelimiter to "."
  delete the last item of tSims
  put "_sims.livecode" after tSims
  if there is a stack tSims then
    close stack tSims
  end if
  
  -- new for browser in PWL -- uuu
  if there is a stack kLabTextBrowserStack then
    if the altBrowserID of stack kLabTextBrowserStack is not empty then
      put the altBrowserID of stack kLabTextBrowserStack into tID
      revBrowserClose tID
      set the altBrowserID of stack kLabTextBrowserStack to empty
    end if
    delete stack kLabTextBrowserStack
  end if
  
  put the long time & ", leave" && the short name of this stack && labCardName & LF after gHistory
  
  set cursor to watch
  put zero into plotFlag
  put zero into setPlotted
  put zero into xVarNum
  put zero into yVarNum
  put zero into preCount
  put zero into tableLastRun
  put "false" into replot
  put "false" into replotLab
  put "false" into flagDataToSave
  put "no" into quizSpecifyOrder
  put empty into dataArray
  put empty into dataHeaders
  put empty into dataUnits
  put empty into dataMinMax
  put empty into dataPrompts
  put empty into quizInputs
  put empty into specialPoints   # for Steady State CSTR
  put empty into gLabURL
  tableDataClear  # also sets tableFlag to zero
  plotReset
  
  if goDirectory is "no" then
    -- leaving one part of lab to go to another part in same stack
    -- do nothing
  else
    
    -- is this block for info necessary?
    put labnumber & " info" into tInfoStack
    if there is a stack tInfoStack then
      close stack tInfoStack
    end if
    try
      delete stack tInfoStack
    end try
    
    -- why do this?
    -- maybe if on a reactor internals card of a lab stack?
    if the topstack is pathTOlab then 
      go cd gCurrentCard of stack pathTOlab
    end if
     
  end if
  
  put empty into gCurrentCard
  put "true" into labInitialize  # needs to be after the "if goDirectory" structure  above
  if plotPaint is "true" then plotClear
  -- next if-then needs to be after if-then...plotClear
  if goDirectory is "no" then
    -- leaving one part of lab to go to another part in same stack
    -- do nothing
  else
    put empty into labCardName
    put empty into labNumber
    put empty into labType
  end if
  repeat while the last char of setCount is not a number
    delete the last char of setCount
  end repeat
  if runCount > zero then put setCount + 1 into setCount
  put zero into runCount  # see the line above, don't move this line
  
  put the stacks into sList
  repeat with i = 1 to the number of lines in sList
    if "Table" is in line i of sList then
      put line i of sList into sClose
      if there is a stack sClose then
        close stack sClose
      end if
    end if
    if "Plot" is in line i of sList then
      put line i of sList into sClose
      if there is a stack sClose then
        close stack sClose
      end if
    end if
    
    if "info" is in line i of sList then
      if "Directory_Info" is in line i of sList then
        # do nothing
      else
        put line i of sList into sClose
        if there is a stack sClose then
          close stack sClose
          delete stack sClose # xxx new for net
        end if
      end if
    end if
    
  end repeat
  
  if goDirectory is not "no" then
    go card "dir" of stack "Directory"  as toplevel
    if there is a stack pathTOlab then
      close stack pathTOlab
      -- lab stack will be purged from RAM in Directory
      -- when downloading a new version from server
    end if
  end if
  
end leaveLab

# -------------

function effFactor modulus
  # Eff. factor for 1st order rxn
  # in spherical pellet of uniform activity.
  # Charac length in the modulus must be
  # the pellet radius, not 1/3 the radius.
  
  if modulus < 0.2 then
    put 1.0 into eff
  else if modulus >= 3 then
    # coth approx = 1
    put (3/modulus^2)*(modulus - 1) into eff
  else
    put 1 into coth
    repeat with n = 1 to 50
      put 2 * (the exp of (-2*n*modulus)) into cothmore
      put coth + cothmore into coth
      if the abs of (cothmore/coth) < 0.00001 then
        exit repeat
      end if
    end repeat
    put (3/modulus^2)*(modulus*coth - 1) into eff
  end if
  return eff
end effFactor

# -----------------

on displayRuns runCount
  if there is a field "Run Count" then
    if runCount is 1 then
      put runCount && "run" into field "Run Count"
    else
      put runCount && "runs" into field "Run Count"
    end if
  end if
end displayRuns

-----------------

function ReactPFRnthSS order, Cin, k, tau, cBreak
  
  # this also works for ideal batch reactors!
  
  # have orders 0 and -1 change to 1st order below conc = cBreak
  if cBreak is a number and cBreak > 0 then
    if order is 0 then
      put k/cBreak into kBreak
      if Cin <= cBreak then
        put 1 into order
        put kBreak into k
      end if
    else if order is -1 then
      put k/cBreak^2 into kBreak
      if Cin <= cBreak then
        put 1 into order
        put kBreak into k
      end if
    end if
  end if
  
  if order is 2 then
    
    put Cin/(1 + Cin*k*tau) into Cout
    
  else if order is 1 then
    
    put Cin*exp(-k*tau) into Cout
    
  else if order is 0 then
    
    if cBreak is a number and cBreak > 0 then
      put (Cin - cBreak)/k into tauBreak
      if tau <= tauBreak then
        put (Cin - k*tau) into Cout
      else
        # conc drops into 1st order regime
        put cBreak*exp(-kBreak*(tau-tauBreak)) into Cout
      end if
    else
      if k*tau < Cin then
        put (Cin - k*tau) into Cout
      end if
    end if
    
  else if order is -1 then
    
    if cBreak is a number and cBreak > 0 then
      put (Cin^2/2 - cBreak^2/2)/k into tauBreak
      if tau <= tauBreak then
        put sqrt(Cin^2 - 2*k*tau) into Cout
      else
        # conc drops into 1st order regime
        put cBreak*exp(-kBreak*(tau-tauBreak)) into Cout
      end if
    else
      if 2*k*tau < Cin^2 then
        put sqrt(Cin^2 - 2*k*tau) into Cout
      end if
    end if
    
  else
    answer "bug:  order supplied to ReactPFRnthSS() must be -1, 0, 1, or 2"
  end if
  
  if Cout < 0 then put 0 into Cout # just in case
  
  return Cout
  
end ReactPFRnthSS

# -----------------

function ReactCSTRnthSS order, Cin, k, tau, CoutOLD, cMax, cBreak
  
  # xxx note cMax not used here but have to check everywhere before removing!!
  
  # have orders 0 and -1 change to 1st order below conc = cBreak
  if cBreak is a number and cBreak > 0 then
    if order is 0 then
      put k/cBreak into kBreak
      if Cin <= cBreak then
        put 1 into order
        put kBreak into k
      end if
    else if order is -1 then
      put k/cBreak^2 into kBreak
      if Cin <= cBreak then
        put 1 into order
        put kBreak into k
      end if
    end if
  else
    put 0 into cBreak
  end if
  
  if order is 1 then
    
    put Cin/(1 + k*tau) into Cout
    
  else if order is 0 then
    
    put (Cin - k*tau) into Cout -- Cout may go negative but will get caught next
    if Cout < cBreak then
      put Cin/(1 + kBreak*tau) into Cout
    end if
    if Cout < 0 then
      put 0 into Cout -- in case user didn't supply cBreak, etc.
    end if
    
  else if order is -1 then
    
    # see if there is a high C SS (low conversion)
    # assume that other quadratic solution (Cin - (Cin^2 - 4*k*tau)^0.5)/2 is unstable
    
    if Cin >= (4*k*tau)^0.5 then
      put (Cin + (Cin^2 - 4*k*tau)^0.5)/2 into cHighSS
    else
      put 0 into cHighSS
    end if
    
    # calc low C SS
    
    if kBreak is a number then
      put Cin/(1 + kBreak*tau) into cLowSS
    else
      put 0 into cLowSS
    end if
    
    # decide which SS to go to based on where we came from
    
    if CoutOLD > cBreak then
      put cHighSS into Cout
    else
      put cLowSS into Cout
    end if
    
  else if order is 2 then
    
    put (-1 + (1 + 4*k*tau*Cin)^0.5)/(2*k*tau) into Cout
    
  else
    answer "bug: order supplied to ReactCSTRnthSS() must be -1, 0, 1, or 2"
  end if
  
  if Cout < 0 then put 0 into Cout # just in case
  
  return Cout
  
end ReactCSTRnthSS

# -----------------

function sciConv x
  
  # must call with x as text, e.g., sciConv("1E-4")
  
  # strip all blank space
  repeat while tempOff > 0
    put offset(space,x) into tempOff
    if tempOff > 0 then delete char tempOff of x
  end repeat
  
  repeat with i = 1 to the length of x
    # note E (case insensitive), ., + and - are missing from the following list
    if char i of x is in "ABCDFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_/?><~`'}{][\|=" then
      put "Sorry, this isn't a number in correct scientific notation.  " into temp
      put temp & "Use notation similar to:  101, 1.01E2, -1.01e+02, 0.101, +1.01E-1, etc." into temp
      answer temp
      return x
      exit sciConv
    end if
  end repeat
  
  put offset("E",x) into eLoc  -- case insensitive
  
  if eLoc > 0 then
    
    put offset("-",x) into minusLoc
    put offset("+",x) into plusLoc
    
    if minusLoc = 1 then
      put "true" into negNum
      delete the first char of x
    else
      put "false" into negNum
    end if
    if plusLoc = 1 then
      delete the first char of x
    end if
    
    put offset("E",x) into eLoc -- may have stripped leading ±
    put offset("-",x) into minusLoc -- may have stripped leading -
    put offset("+",x) into plusLoc -- may have stripped leading +
    
    if minusLoc > eLoc then
      put "true" into negExp
      put empty into expNum
      put minusLoc + 1 into i
      repeat with i = (minusLoc + 1) to the length of x
        put expNum & char i of x into expNum
      end repeat
    else if plusLoc > eLoc then
      put "false" into negExp
      put empty into expNum
      repeat with i = (plusLoc + 1) to the length of x
        put expNum & char i of x into expNum
      end repeat
    else
      put "false" into negExp
      put empty into expNum
      repeat with i = (eLoc + 1) to the length of x
        put expNum & char i of x into expNum
      end repeat
    end if
    
    repeat with i = eLoc to the length of x
      delete the last char in x
    end repeat
    
    # x is the number before e
    # expNum is the exponent number
    # negExp is "true" if a negative exponent
    # negNum is "true" if entire number is negative
    
    if negExp is "true" then
      put x / 10^expNum into x
    else
      put x * 10^expNum into x
    end if
    
    if negNum is "true" then put -1 * x into x
    
  end if
  
  return x
  
end sciConv

# -----------------

function sciNote x, strip, bare
  # strip = "yes" to remove trailing zeros
  # bare = "yes" to have no spaces
  
  if x is not a number then
    return x
    exit sciNote
  end if
  
  if x is empty then
    return empty
    exit sciNote
  end if
  
  # NEED "x + 0" below to put new numberFormat into effect
  # result returned is TEXT not numeric (forced by the space added at end)
  
  put zero into negFlag
  if x < 0.00000000000000000000 then
    put 0.00000000000000000000 - x into x
    put 1 into negFlag
  end if
  # x should be positive at this point
  if x < 0.0000000000000000001 then -- less than 1E-19 (number format is 1E-20)
    put "0" & space into output
  else if x = 0 then
    put "0" & space into output # new, needed in MC 2.4
  else
    if x >= 0.100 and x < 1.00000 then
      # this is special because plain 1 comes here
      set the numberformat to "0.###"
      put x + 0 & space into x -- to force to formatted string
      delete the last char in x
      if x = "1" then
        put "1.00" & space into output
      else
        if strip <> "yes" then
          put "#" & x into x
          repeat while the number of chars in x < 6
            put x & "0" into x
          end repeat
          delete char 1 of x
        end if
        put x & space into output
      end if
    else if x >= 1.00000 and x < 10.000 then
      set the numberformat to "0.##"
      put "#" & x + 0 into x -- to formatted string
      if strip <> "yes" then
        if offset (".",x) = 0 then
          put x & "." into x
        end if
        repeat while the number of chars in x < 5
          put x & "0" into x
        end repeat
      end if
      delete char 1 of x
      put x & space into output
    else if x >= 10.000 and x < 100.000 then
      set the numberformat to "0.#"
      put "#" & x + 0 into x -- to formatted string
      if strip <> "yes" then
        if offset (".",x) = 0 then put x & "." into x
        repeat while the number of chars in x < 5
          put x & "0" into x
        end repeat
      end if
      if x is "#100." then
        put "#100.0" into x
      end if
      delete char 1 of x
      put x & space into output
    else if x >= 100.000 and x < 500.000 then
      # keep going out to 1 decimal place because of T's up to 500
      set the numberformat to "0.#"
      put "#" & x + 0 into x -- to formatted string
      if strip <> "yes" then
        if offset (".",x) = 0 then put x & "." into x
        repeat while the number of chars in x < 6
          put x & "0" into x
        end repeat
      end if
      if x is "#500.0" then put "#500" into x
      delete char 1 of x
      put x & space into output
    else if x >= 500.000 and x < 2000.000 then -- max set by max T in labs
      set the numberformat to "0."
      put x + 0 & space into output
    else
      
      put log10(x) into x
      
      if x > 0 then
        
        put the trunc of x into power
        put x - power into x
        
        # do the following to avoid things like 10.0E3 output for 9999.9999995
        if x > 0.99978279844979068 then
          put 0 into x
          add one to power
        end if
        
        put 10^x into x
        if x = 9.999 then
          put 1 into x
          put power + 1 into power
        end if
        set the numberformat to "0.##"
        put "#" & x + 0 into x -- to formatted string
        if strip <> "yes" then
          if offset (".",x) = 0 then put x & "." into x
          repeat while the number of chars in x < 5
            put x & "0" into x
          end repeat
        end if
        delete char 1 of x
        put x & "E" & power & space into output
      else
        
        put the round of (x - 0.500) into power
        put x - power into x
        
        # do the following to avoid things like 10.0E-2 output for 0.09995
        if x > 0.99978279844979068 then
          put 0 into x
          add one to power
        end if
        
        put 10^x into x
        if x > 9.999 then
          put 1 into x
          put power + 1 into power
        end if
        set the numberformat to "0.##"
        put "#" & x + 0 into x  #  to formatted string
        if strip <> "yes" then
          if offset (".",x) = 0 then put x & "." into x
          repeat while the number of chars in x < 5
            put x & "0" into x
          end repeat
        end if
        delete char 1 of x
        put x & "E" & power & space into output
      end if
    end if
  end if
  if negFlag = 1 then put "-" & output into output
  
  if bare is "yes" then
    if the last char of output is space then
      delete the last char of output
    end if
  else
    # add leading spaces to get constant number of char
    put char 1 to (11 - the length of output) of "            " before output
  end if
  
  return output
  
end sciNote

# ------------------

function log x
  # returns the log (base 10) of x, needed handler for old HC scripts
  # now use std MC function, keep custom log() in case old calls remain
  return log10(x)
end log

# -----------------

function stripSpace thing
  repeat while offset(space,thing) > 0
    delete char offset(space,thing) of thing
  end repeat
  return thing
end stripSpace

# -----------------

function stripLeadSpace thing
  repeat while offset(space,thing) = 1
    delete char 1 of thing
  end repeat
  return thing
end stripLeadSpace

# -----------------

function stripTrailingSpace thing
  repeat
    if the last char of thing is space then
      delete the last char of thing
    else
      exit repeat
    end if
  end repeat
  return thing
end stripTrailingSpace

# -----------------

function stripOuterSpace thing
  repeat while offset(space,thing) = 1
    delete char 1 of thing
  end repeat
  repeat
    if the last char of thing is space then
      delete the last char of thing
    else
      exit repeat
    end if
  end repeat
  return thing
end stripOuterSpace

# -----------------

--function stripOuterWhiteSpace thing
--  repeat while (offset(cr,thing) = 1) OR (offset(tab,thing) = 1) or (offset(space,thing) = 1)
--    delete char 1 of thing
--  end repeat
--  repeat
--    if (the last char of thing is cr) OR (the last char of thing is tab) OR (the last char of thing is space) then
--      delete the last char of thing
--    else
--      exit repeat
--    end if
--  end repeat
--  return thing
--end stripOuterWhiteSpace

# -----------------

on setTitle
  global labNumber
  put "Div " into labNumberLong
  put labNumber into thisTempName
  delete char 1 of thisTempName  # delete "D"
  put char 1 to (offset("L",thisTempName) - 1) of thisTempName after labNumberLong
  put " Lab " after labNumberLong
  delete char 1 to offset("L",thisTempName) of thisTempName  # delete "L"
  put thisTempName after labNumberLong
  if there is a field "Title" then
    put labNumberLong into field "Title"
  end if
end setTitle

# -----------------

on setSet theSet
  if there is not a field "Set" then exit setSet
  if theSet is not empty then
    put "Data Set" && theSet into field "Set"
  else
    put empty into field "Set"
  end if
end setSet

# -----------------

on setInfo theInfo
  -- sets htmlText so can use tags such as <b></b>
  -- have to form attributes requiring " with quote char
  if there is a field "info box" then
    set the htmltext of field "info box" to theInfo
  end if
end setInfo

# -----------------

# in doDecoOn, decoOnList and doDecoCleanup are to clear button decorations
# that persist when mouse over a button and user activates Run Reaction button
# with traversalOn and enter key in Win or control-R, then button doesn't get mouseLeave
# when user moves mouse (a) to another button (so cleared by "if decoOnList is not empty")
# or (b) when user moves mouse off to anywhere else on card (so "send doDecoCleanup...")

on doDecoOn thisLongName
  global decoOn, decoOnList
  # if decoOn is "true" then
  if decoOn is "true" then # zzz had checked if "confer" is in thisLongName
    if decoOnList is not empty then
      doDecoOff decoOnList
    end if
    set the showborder of thisLongName to "true"
    put thisLongName into decoOnList
    send doDecoCleanup to me in 1 second
  end if
end doDecoOn

on doDecoCleanup
  global decoOnList
  # cancel any other pendingMessages to this handler
  doDecoMsgCancel
  if decoOnList is not empty then
    set the itemdelimiter to quote
    put the last item of decoOnList into temp
    set the itemdelimiter to comma
    put "stack " & quote before temp
    put quote after temp
    # mouseLoc relative to defaultStack, would be script stack if don't set it
    try
      set the defaultstack to temp
      if the mouseloc is within the rect of decoOnList then
        # check back later
        send doDecoCleanup to me in 1 second
      else
        # mouse has left this button so turn deco off
        doDecoOff decoOnList
      end if
    end try
  end if
end doDecoCleanup

# -----------------

on doDecoMsgCancel
  repeat with i = 1 to the number of lines in the pendingmessages
    if line i of the pendingmessages contains "doDecoCleanup" then
      cancel item 1 of line i of the pendingmessages
    end if
  end repeat
end doDecoMsgCancel

# -----------------

on doDecoOff thisLongName
  global decoOnList
  if there is a thisLongName then
    set the showborder of thisLongName to "false"
    put empty into decoOnList
  end if
  if there is a field "info box" then
    put empty into field "info box"
  end if
end doDecoOff

# -----------------


on mouseLeave
  if there is a field "info box" then
    put empty into field "info box"
  end if
end mouseLeave

# ----------------

function error
  put 0 into summer  #  initialize
  #10 into factor and 4 into repeater gives ± 2.8% std dev.
  # 15 into factor and 4 into repeater gives ± 4.3% std dev.
  put 4.3 into percent
  put percent*3.53 into factor
  put 4 into repeater
  repeat repeater
    put summer + random(100) into summer
  end repeat
  put summer/(repeater*100) into summer  # now 0 <= summer <= 1
  put factor*(1 - 2*summer) into err  # summer ave. 0.5, so err ave. 0
  put (100 + err)/100 into err  # 1-(factor/100) <= err <= 1+(factor/100)
  return err
end error

# -----------------------

function errorVar percent
  put 0 into summer -- initialize
  # 10 into factor and 4 into repeater gives ± 2.8% std dev.
  # 15 into factor and 4 into repeater gives ± 4.3% std dev.
  put percent*3.53 into factor
  put 4 into repeater
  repeat repeater
    put summer + random(100) into summer
  end repeat
  put summer/(repeater*100) into summer  # now 0 <= summer <= 1
  put factor*(1 - 2*summer) into err  # summer ave. 0.5, so err ave. 0
  put (100 + err)/100 into err  # 1-(factor/100) <= err <= 1+(factor/100)
  return err
end errorVar

# -------------------

function R_J_molK
  # ideal gas constant R(J/ mol K), SI units
  return 8.3143
end R_J_molK

function R_kJ_molK # used in nth-order isothermal labs, at least
  # ideal gas constant R(kJ/ mol K)
  return 0.0083143
end R_kJ_molK

function R_cal_molK
  # ideal gas constant R(cal/ mol K)
  return 1.9872
end R_cal_molK

#----------------

function R_Pam3_molK
  # ideal gas constant R(Pa m3/ mol K), SI units
  # from PV = nRT, P = 101.325 kPa, V/n = 22.4136 liter/mol, and T = 273.15 K, or
  # from PV = nRT, P = 101325 Pa, V/n = 0.0224136 m3/mol, and T = 273.15 K
  return 8.3143
end R_Pam3_molK

function R_Pam3_kmolK
  #  ideal gas constant R(Pa m3 / kmol K)
  #  from PV = nRT, P = 101325 Pa, V/n = 22.4136 m3/kmol, and T = 273.15 K
  return 8314.3
end R_Pam3_kmolK

function R_kPaL_molK
  # ideal gas constant R(kPa L / mol K)
  # from PV = nRT, P = 101.325 kPa, V/n = 22.4136 liter/mol, and T = 273.15 K
  return 8.3143
end R_kPaL_molK

function R_kPam3_molK
  # ideal gas constant R(kPa m3 / mol K)
  # from PV = nRT, P = 101.325 kPa, V/n = 0.0224136 m3/mol, and T = 273.15 K
  return 0.0083143
end R_kPam3_molK

function R_atmm3_molK
  # ideal gas constant R(atm m3/ mol K)
  # from PV = nRT, P = 1 atm, V/n = 0.0224136 m3/mol, and T = 273.15 K
  return 0.000082056
end R_atmm3_molK

function R_atmm3_kmolK
  # ideal gas constant R(atm m3 / kmol K)
  # from PV = nRT, P = 1 atm, V/n = 22.4136 m3/kmol, and T = 273.15 K
  return 0.082056
end R_atmm3_kmolK

function R_atmL_molK
  # ideal gas constant R(atm Liter / mol K)
  # from PV = nRT, P = 1 atm, V/n = 22.4136 liter/mol, and T = 273.15 K
  return 0.082056
end R_atmL_molK

function R_atmcm3_molK
  # ideal gas constant R(atm cm3 / mol K)
  # from PV = nRT, P = 1 atm, V/n = 22413.6 cm3/mol, and T = 273.15 K
  return 82.056
end R_atmcm3_molK

# xxx the two R functions below don't follow naming convention (press unit, then vol), so
# xxx be sure all references are deleted before deleting these definitions!
# xxx there are equivalents above with correct naming convention

function R_m3atm_molK
  # ideal gas constant R(m3 atm / mol K)
  # from PV = nRT, P = 1 atm, V/n = 0.0224136 m3/mol, and T = 273.15 K
  return 0.000082056
end R_m3atm_molK

function R_m3Pa_molK
  # ideal gas constant R(m3 Pa / mol K), SI units
  # from PV = nRT, P = 101.325 kPa, V/n = 22.4136 liter/mol, and T = 273.15 K, or
  # from PV = nRT, P = 101325 Pa,V/n = 0.0224136 m3/mol, and T = 273.15 K
  return 8.3143
end R_m3Pa_molK

function JPERcal
  return 4.184
end JPERcal

function torrPERpascal
  return 760/101325
end torrPERpascal

function pascalPERtorr
  return 101325/760
end pascalPERtorr

function cmPERm
  return 100
end cmPERm

function mPERcm
  return 0.01
end mPERcm

function gPERkg
  return 1000
end gPERkg

function kgPERg
  return .001
end kgPERg
