script "RL scripts 2"
# The Reactor Lab stack designs and all scripts copyright 1996-2010
# PureWaterLab stack designs and scripts copyright 2005-2010
# by Richard K. Herz, all rights reserved.

# -------------

global gConnectStatus

constant kLabTextBrowserStack = "Module Text" -- also set in RL scripts 1, 2, 4

# -------------

on resizeStack
   checkMainGroupScrollbars
   pass resizeStack
end resizeStack

# -------------

on checkMainGroupScrollBars
   -- called by resizeStack and enterlab, both in RL scripts 2
   -- for scrollbars that handle when running on a small screen (or projector)
   -- and card is too small to show everything on card
   -- action of scrollbars is handled by scrollbarDrag in in RL scripts 2
   
   if there is a group "main" and there is a scrollbar "scroll main W" then
      -- assume there is also a scrollbar "scroll main V"
      if the width of group "main" <= the width of this card then
         hide scrollbar "scroll main W"
         -- want to set group main to line up at left if scrolled right when hide scrollbar
         put the rect of group "main" into tRect
         put 0 into item 1 of tRect
         put the width of group "main" into item 3 of tRect
         set the rect of group "main" to tRect
      else
         show scrollbar "scroll main W"
      end if
      if the height of group "main" <= the height of this card then
         hide scrollbar "scroll main V"
         -- want to set group main to line up at top if scrolled down when hide scrollbar
         put the rect of group "main" into tRect
         put 0 into item 2 of tRect
         put the height of group "main" into item 4 of tRect
         set the rect of group "main" to tRect
      else
         show scrollbar "scroll main V"
      end if
   end if
   -- need send in time at least when start LC by double-clicking on this stack in Finder
   -- probably because the geometry group in LC hadn't started up yet
   -- may not need when have LC already open and then later open stack
   send revUpdateGeometry to this stack -- in 100 milliseconds
   
end checkMainGroupScrollBars

# -------------

on scrollbarDrag pPos
   -- handles scrollbars in some labs to scroll card contents in group "main"
   -- when opening card on a small screen or projector and card size is too small to show everything
   -- scrollbars need to be named "scroll main V" (vertical) and "scroll main W" (width)
   
   put the target into tTarget
   if "scroll main" is not in tTarget then
      pass scrollbarDrag
   else
      
      put the width of group "main" into tGroupW
      put the height of group "main" into tGroupV
      put tGroupW/2 into tGroupMidW
      put tGroupV/2 into tGroupMidV
      
      put the endValue of the target into tMyEnd
      put pPos/tMyEnd into tFrac
      
      put the loc of group "main" into tLoc
      
      delete the last character of tTarget -- delete quote
      if the last character of tTarget is "V" then
         put (1 - tFrac)*tGroupMidV into item 2 of tLoc -- scrollbar V only
      else
         put (1 - tFrac)*tGroupMidW into item 1 of tLoc -- scrollbar W only
      end if
      
      set the loc of group "main" to tLoc
      
      --      put tGroupMidW & "," & tGroupMidV & LF into msg
      --      put the loc of group "main" after msg
      --      put LF & the target after msg
      
   end if -- end: if "scroll main" is not in tTarget then
   
end scrollbarDrag

# --------------

on goodEnd
   
   global runCount, replot, runBeep, tableFlag, tableOpen
   global labType
   global flagDataToSave
   global labNumber, labCardName
   global budgetReportImage
   global budgetBalance
   global quizLabel
   global quizName
   global quizFirstRun
   global expCount
   
   global pathTOlab  # xxx pathTOlab added in test below xxx
   
   switch
      
      case labType is in "S, SQ"
         
         displayRuns runCount
         if tableFlag <  0 then put 2 into tableFlag
         dataStamper
         tableDataSave
         
         break
         
      case labType is in "P, PQ", "DP"
         
         put zero into tableFlag
         
         break
         
      case default
         
         break
         
   end switch
   
   if there is a field "OLD PLOT" then
      put empty into field "OLD PLOT"
   end if
   
   if "D" is not in labType then
      plotRefresh
      put "true" into replot
      put "true" into flagDataToSave
   end if
   
   # xxx this block doesn't work with screen locked because lines don't add to open Table xxx
   # if tableOpen is "yes" then
   # set the lockScreen to "true"
   # go stack "Table"   # to add new run to open Table
   # go stack pathTOlab  # xxx old push and pop cd was closing Table after returning to lab
   # set the lockScreen to "false"
   # end if
   
   if "Q" is in labType then
      add one to expCount
      put budgetBalance - 100 into budgetBalance
      if quizFirstRun is not "yes" then
         put stripOuterSpace(labNumber && labCardName) into quizName
         put "Enter quiz " & numTOchar(quizLabel+64) & ", " & quizName & return after budgetReportImage
         put "yes" into quizFirstRun
      end if
   end if
   
   saveSetBtn "show"
   
   if runBeep is "on" then
      beep
   end if
   
   setInfo "Run completed."
   
end goodEnd

# ---------------

on saveSetBtn showit
   if showit is "show" then
      if there is a button "Clear/Save Set" then
         show button "Clear/Save Set"
      end if
      if there is a button "Save Set" then
         show button "Save Set"
      end if
      if there is a group "clear copy save" then
         set the enabled of group "clear copy save" to "true"
      end if
   else if showit is "hide" then
      if there is a button "Clear/Save Set" then
         hide button "Clear/Save Set"
      end if
      if there is a button "Save Set" then
         hide button "Save Set"
      end if
      if there is a group "clear copy save" then
         set the enabled of group "clear copy save" to "false"
      end if
   end if
end saveSetBtn

# ---------------

on emptyRightFlds
   global labType, plotPaint
   if "R" is not in labType then  # RTD (in/out)
      if there is a field "outputs" then
         put empty into field "outputs"
      end if
      if there is a field "OLD PLOT" then
         if plotPaint is "true" then
            put "OLD PLOT" into field "OLD PLOT"
         else
            put empty into field "OLD PLOT"
         end if
      end if
   end if
end emptyRightFlds

# ---------------

function paramChange lineNum, noswitch
   global dataHeaders, dataMinMax, dataPrompts, preCount
   put (lineNum + preCount) into varNum
   put line lineNum of field "inputs" into orig
   put orig into old
   put stripSpace(old) into old
   put item varNum of line 1 of dataMinMax into pmin
   put item varNum of line 2 of dataMinMax into pmax
   put sciConv(pmin) into cmin
   put sciConv(pmax) into cmax
   put sciNote(cmin,"yes") into pmin
   put sciNote(cmax,"yes") into pmax
   put stripSpace(pmin) into pmin
   put stripSpace(pmax) into pmax
   repeat
      ask line varNum of dataPrompts & return & "(" & pmin & " to " & pmax & "):" with old
      if the result is "Cancel" then
         return "false"
         exit paramChange
      end if
      put it into theEntry
      if theEntry is empty then exit repeat
      put sciConv(theEntry) into theEntry
      if (theEntry >= cmin) and (theEntry <= cmax) then exit repeat
   end repeat
   put sciNote(theEntry,"yes","yes") into scIt  # yes to remove trialing zeros, yes to have no spaces
   if (theEntry is empty) or (scIt is orig) then
      put "false" into theEntry
   else
      if noswitch is not "no" then
         dataSwitchER varNum, scIt
      end if
      put scIt into line lineNum of field "inputs"
   end if
   return theEntry
end paramChange

# ---------------

on dataSwitchER z, temp
   global dataSwitch, OLDdataSwitch, varCount, runCount, dataArray, warnSetSave, tableCount
   if runCount = 0 then exit dataSwitchER
   if item z of dataSwitch = 1 then
      if temp = sciNote(item z of line runCount of dataArray) then
         put zero into item z of dataSwitch
      end if
   else if item z of dataSwitch = 0 then
      put 1 into item z of dataSwitch
      if tableCount >= 18 then
         put "The table pages are full (limit 18 columns) and this variable will" into temp
         put space & "not appear in a table column but will appear in saved data sets and can be plotted." after temp
         put return & "Consider saving and clearing this set before another run." after temp
         answer temp
      end if
   end if
   if warnSetSave is "true" then
      put zero into counter
      if dataSwitch is not OLDdataSwitch then
         repeat with i = 1 to varCount
            if (item i of dataSwitch = 1) or (item i of dataSwitch = 2) then
               put counter + 1 into counter
            end if
         end repeat
      end if
      if counter > 1 then
         put "done" into warnSetSave
         put "You have changed more than one variable.  Consider saving" into temp
         put space & "and clearing this data set before making a new run." after temp
         answer temp
      end if
   end if
end dataSwitchER

# ---------------

on dataSwitchReset
   global varCount, dataSwitch, OLDdataSwitch, SAVEDdataSwitch
   global tableCount, OLDtableCount, tableSwitch
   put dataSwitch into SAVEDdataSwitch
   repeat with i = 1 to varCount
      if item i of dataSwitch < 9 then put zero into item i of dataSwitch
   end repeat
   put dataSwitch into OLDdataSwitch
   put empty into tableSwitch
   put zero into tableCount
   repeat with i = 1 to varCount
      if item i of dataSwitch > 0 then
         put tableCount + 1 into tableCount
         put tableCount into item i of tableSwitch
      else
         put zero into item i of tableSwitch
      end if
   end repeat
   put tableCount into OLDtableCount
end dataSwitchReset

# ---------------

on dataStamper
   global varCount, runCount, dataArray, dataSwitch, OLDdataSwitch
   global xVarNum, tableCount, OLDtableCount, tableSwitch
   if runCount > 1 then
      repeat with i = 1 to varCount
         if item i of dataSwitch = 0 and item i of line runCount of dataArray is not "?" then  #? in quizzes
            if sciNote(item i of line (runCount-1) of dataArray) is not sciNote(item i of line runCount of dataArray) then
               put 9 into item i of dataSwitch
               if tableCount < 18 then
                  put tableCount + 1 into tableCount
                  put tableCount into item i of tableSwitch
               end if
            end if
         end if
      end repeat
   end if
   repeat with i = 1 to varCount
      if item i of dataSwitch = 1 then
         put 2 into item i of dataSwitch
         if tableCount < 18 then
            put tableCount + 1 into tableCount
            put tableCount into item i of tableSwitch
         end if
      end if
   end repeat
   if dataSwitch is not OLDdataSwitch then
      setInfo "Adding changed variables to table..."
      tableDataUpdate
      repeat with i = 1 to varCount
         if (item i of dataSwitch = 2) AND (item i of OLDdataSwitch < 2) then
            # xxx xVarNum is the x variable for the plots
            # xxx this sets it to an input var only the first time in a set it is changed
            # xxx e.g., change cin, then T, then cin again, but plot x stays T
            # xxx may want to remember last input var changed then set xVarNum
            # xxx to it after next run is made
            put i into xVarNum
            exit repeat
         end if
      end repeat
   end if
   put dataSwitch into OLDdataSwitch
   put tableCount into OLDtableCount
end dataStamper

# ---------------

on labSaveOrClear
   -- this is for use with button "Clear/Save Set" or button "Save Set"
   -- also see commands for group "clear copy save": labSaveStartStart, labClearStart, labCopyToClipboard
   global autoNote, labType, firstSetSaved, flagDataToSave
   answer "Clear these data from memory or save this set to disk and start a new set?" with "Clear" or "Cancel" or "Save"
   if it is Clear then
      if "Q" is in labType then
         # runs "cost $" in quizzes so they may want to keep last run
         answer "Do you want to keep the last run?" with "No" or "Yes"
         if it is "Yes" then
            put "true" into keeper
         else
            put "false" into keeper
         end if
      else
         put "false" into keeper
      end if
      labClear keeper
      put "false" into flagDataToSave  # checked on quitting application
   end if
   if it is "Save" then
      labSaveStart
      if firstSetSaved is not "yes" then
         # user canceled labSaveStart so cancel labSaveOrClear
         exit labSaveOrClear
      end if
      put "false" into flagDataToSave  # checked on quit
      answer "A new data set has been created. Clear these data from memory or keep them in the new data set?" with "Clear" or "Keep"
      if it is "Clear" then
         if "Q" is in labType then
            # runs "cost $" in quizzes so they may want to keep last run
            answer "Do you want to keep the last run as part of the new data set?" with "No" or "Yes"
            if it is "Yes" then
               put "true" into keeper
            else
               put "false" into keeper
            end if
         else
            put "false" into keeper
         end if
         labClear keeper
         put "true" into cleared
      else
         put "false" into cleared
      end if
      setInfo empty
      if autoNote is "on" then
         toNotePad cleared
      end if
   end if
end labSaveOrClear

# ---------------

on labClearStart
   -- this is being developed in May 2010 to replace old clear/save button
   -- with new clear, copy, save buttons
   global autoNote, labType, firstSetSaved, flagDataToSave, setCount
   if "Q" is in labType then
      # runs "cost $" in quizzes so they may want to keep last run
      answer "Do you want to keep the last run?" with "No" or "Yes"
      if it is "Yes" then
         put "true" into keeper
      else
         put "false" into keeper
      end if
   else
      put "false" into keeper
   end if
   
   labClear keeper
   put "false" into flagDataToSave  # checked on quitting application
   
   setCountIncrement
   
end labClearStart

# ---------------

on labSaveStartSTART -- this calls labSaveStart
   -- this is being developed in May 2010 to replace old clear/save button
   -- with new clear, copy, save buttons
   -- see below: exit labSaveStartStart
   global autoNote, labType, firstSetSaved, flagDataToSave
   labSaveStart
   if firstSetSaved is not "yes" then
      # user canceled labSaveStart so cancel labSaveOrClear
      exit labSaveStartSTART
   end if
   put "false" into flagDataToSave  # checked on commandKeyDown "Q" to quit
   
   if character 1 of labType is "P" or character 1 of labType is "R" then
      -- no reason to clear labType "P" or "PQ" or "R" profile labs
      -- since new run replaces all data
      put "false" into cleared
      put "false" into keeper
   else
      answer "A new data set has been created. Clear these data from memory or keep them in the new data set?" with "Clear" or "Keep"
      if it is "Clear" then
         if "Q" is in labType then
            # runs "cost $" in quizzes so they may want to keep last run
            answer "Do you want to keep the last run as part of the new data set?" with "No" or "Yes"
            if it is "Yes" then
               put "true" into keeper
            else
               put "false" into keeper
            end if
         else
            put "false" into keeper
         end if
         labClear keeper
         put "true" into cleared
      else
         put "false" into cleared
      end if
   end if
   
   setInfo empty
   if autoNote is "on" then
      toNotePad cleared
   end if
end labSaveStartSTART

# ---------------

on labClear  keeper
   global runCount, dataArray, replot
   setInfo empty
   if keeper is "true" then
      put runCount into oldruns
      put 1 into runCount
      displayRuns runCount
      put the last line of dataArray into dataArray
      if oldruns > 1 then
         plotRefresh
         setInfo "Clearing data set and opening a new one..."
         put "true" into replot
      end if
      dataSwitchReset
      tableDataClear
      dataStamper
      tableDataSave
   else
      put zero into runCount
      displayRuns runCount
      saveSetBtn "hide"
      put empty into dataArray
      plotClear
      setInfo "Clearing data set and opening a new one..."
      put "false" into replot
      dataSwitchReset
      tableDataClear
   end if
   setInfo empty
end labClear

# ---------------

on enterLab
   global runCount, labType
   global labCardName, gCurrentCard
   global replotLab
   
   checkForConferenceRoom -- in RL scripts 1
   
   -----------------------------------------------------------
   -- for scrollbars that handle when running on a small screen (or projector)
   -- and card is too small to show everything on card
   -- action of scrollbars is handled by scrollbarDrag in this script
   checkMainGroupScrollBars
   -----------------------------------------------------------
   
   put the number of this cd into gCurrentCard
   -- set the customEnabled of button "go help" to "true"
   checkForInfoStack -- in RL scripts 1 - only enabled "go help" if the stack is there
   set the customEnabled of button "go table" to "true"
   set the customEnabled of button "go plot" to "true"
   if there is a button "go lab" then -- new in PWL
      if "Q" is in labType then
         set the customEnabled of button "go lab" to "true"
      else
         set the customEnabled of button "go lab" to "false"
      end if
   end if
   put stripOuterSpace(labCardName && "Quiz") into labQuizName
   if there is a button "go lab quiz" then -- new in PWL
      if "Q" is in labType then
         set the customEnabled of button "go lab quiz" to "false"
      else if there is a cd labQuizName then
         set the customEnabled of button "go lab quiz" to "true"
      else
         set the customEnabled of button "go lab quiz" to "false"
      end if
   end if
   if runCount > 0 then
      saveSetBtn "show"
   else
      saveSetBtn "hide"
   end if
   if (replotLab is "true") then  # set to true in plot cd x,y btns
      setInfo "Plotting..."
      plotAllPoints
      setInfo empty
      put "false" into replotLab
   end if
   
   # Starting with version Rev 2.1.2 am getting spurious ink
   # on far left of plot button labels when lab first opens
   # "go this card" this fixes it
   go this card
   
end enterLab

# -------------------

on preOpenCard
   
   # xxx
   # in Rev 2.5, lines in preOpenCard and fontSetter which set properties of fields
   # interferes with visual effect on card transitions, especially "wipe"
   # of a field; no problem if were to move to openCard
   # Since only have wipe in Directory and Stoichiometry, for now, just skip these stacks
   # don't have courier font in these stacks so OK to skip
   
   -- if the short name of this stack is not in "Directory, Stoichiometry" then
   
   fontSetter
   
   -- April 2017, RKH, Conference Room is not active so do not do this
   --    # set connects and conferees in openStack of Stoichiometry
   --    # never do this in Directory anyway
   --    if there is a field "current connects" then
   --       put field "current connects" of card "dir" of stack "Directory" into field "current connects"
   --    end if
   --    if there is a field "conferees" then
   --       put field "conferees" of card "dir" stack "Directory" into field "conferees"
   --    end if
   
   -- end if
   
   -- April 2017, RKH, Conference Room is not active so do this
   if there is a button "go conference" then hide button "go conference"
   if there is a field "online users label" then hide field "online users label"
   if there is a field "current connects" then hide field "current connects"
   if there is a field "conferee label" then hide field "conferee label"
   if there is a field "conferees" then hide field "conferees" 
   
   pass preOpenCard
end preOpenCard

# -------------------

on preOpenStack
   locateStackWindow
end preOpenStack

# -------------------

on locateStackWindow
   
   -- don't want this to execute during editing of this script
   if the short name of this stack is "RL scripts 2" then
      exit locateStackWindow
   end if
   
   put the loc of stack "Directory" into tDloc
   
   -- new for PWL sims stacks
   if the short name of this stack contains " sims" then
      if kLabTextBrowserStack is in the windows then
         put the topLeft of stack kLabTextBrowserStack into tSimsLoc
         add 10 to item 1 of tSimsLoc
         add 30 to item 2 of tSimsLoc
         set the topLeft of this stack to tSimsLoc
      else
         -- should not get here since only entry point as of May 2007
         -- is via the text browser stack
         put tDloc into tSimsLoc
         add 0 to item 1 of tSimsLoc
         add 0 to item 2 of tSimsLoc
         set the loc of this stack to tSimsLoc
      end if
      exit locateStackWindow -- EXIT THIS COMMAND
   end if
   
   -- -- xxx earlier I had this not work on browser stack but why not?
   -- -- xxx see farther below: if the short name of this stack is kLabTextBrowserStack
   --   if the short name of this stack is not in "Confer, Note Pad" \
         --          AND the short name of this stack is not kLabTextBrowserStack then
   
   if the short name of this stack is not in "Confer, Note Pad"  then
      
      -- position other stacks
      -- Confer and Note Pad position themselves at edge of screen
      -- let user position the module text browser stack - it saves itself when not in development mode
      
      -- set up different locations
      
      put tDloc into tLoc[0]
      
      put tDloc into tLoc[1]
      add 60 to item 1 of tLoc[1]
      add 50 to item 2 of tLoc[1]
      
      put tDloc into tLoc[2]
      subtract 60 from item 1 of tLoc[2]
      add 50 to item 2 of tLoc[2]
      
      put tDloc into tLoc[3]
      add 34 to item 1 of tLoc[3]
      add 90 to item 2 of tLoc[3]
      
      # initialize flag to hold number of locations
      
      put 0 into tLocNum # default - stack will be put at Directory loc
      
      # set number of location for different types of stacks
      if the short name of this stack contains "info" then put 1 into tLocNum
      if the short name of this stack contains "Plot" then put 2 into tLocNum
      if the short name of this stack contains "Table" then put 1 into tLocNum
      if the short name of this stack contains "Budget" then put 2 into tLocNum
      if the short name of this stack contains "Options" then put 1 into tLocNum
      # About now is How to use the Lab
      if the short name of this stack contains "About" then put 3 into tLocNum 
      
      -- August 2009
      -- now making labs with much larger card sizes
      -- want to locate so that users with smaller screens don't have problems moving or closing stack
      -- many of the new netbooks have 1024x600 screens and some of new lab cards
      -- bigger than this - but usually cutting off some of lab isn't fatal
      -- just need to make sure user can drag stack and get to window close button
      -- centering stacks on Directory only good if Directory not near screen edge
      -- and lab card not too big
      -- on opening a lab, need to check
      --   screen rect
      --   card rect
      -- need to make sure that for Mac, top left of stack not within about 40 left x (leave room for left Dock) and 44 top y
      -- need to make sure for Win, top right of stack not more than top right of screen
      
      put 44 into tMacMargin
      put 26 into tWinMargin
      
      if the short name of this stack is kLabTextBrowserStack then
         put the loc of this stack into tNewLoc
         -- keep loc saved when stack was last closed
         -- except below make sure it stays on screen
         -- by why wouldn't it if user saved it last?
         -- maybe if saved in development on another machine...
      else
         put  tLoc[tLocNum] into tNewLoc
      end if
      
      put the height of this stack into tYhigh
      put the width of this stack into tXwide
      
      put item 1 of tNewLoc - round(tXwide/2) into tXleft
      put item 1 of tNewLoc + round(tXwide/2) into tXright
      put item 2 of tNewLoc - round(tYhigh/2) into tYtop
      
      put the screenRect into tScreen -- also used below
      put item 3 of tScreen into tScreenXright
      subtract 3 from tScreenXright -- adjust for Win XP
      
      switch the platform
         case "MacOS"
            -- window has close button on left
            if tXleft < tMacMargin then
               add (tMacMargin - tXleft) to item 1 of tNewLoc
            end if
            if tYtop < tMacMargin then
               add (tMacMargin - tYtop) to item 2 of tNewLoc
            end if
            break
         default
            -- assume window with close button on right
            if tXright > tScreenXright then
               subtract (tXright - tScreenXright) from item 1 of tNewLoc
            end if
            if tYtop < tWinMargin then
               add (tWinMargin - tYtop) to item 2 of tNewLoc
            end if
            break
      end switch
      
      -- now another problem with trying to center stack on Directory is that,
      --  if Directory is shifted to lower left, then
      -- stack can be shifted off lower left even if stack could fit in screen
      
      put item 3 of tScreen into tScreenWidth -- first two items are 0,0
      put item 4 of tScreen into tScreenHeight
      
      put item 1 of tNewLoc - round(tXwide/2) into tXleft
      put item 1 of tNewLoc + round(tXwide/2) into tXright
      put item 2 of tNewLoc - round(tYhigh/2) into tYtop
      put item 2 of tNewLoc + round(tYhigh/2) into tYbtm
      
      -- check platform and set margins
      if the platform is "MacOSX" then
         put 2*tMacMargin into tMarginTotal
         put 2*tMacMargin into tMarginBtm -- user might have dock at screen bottom
      else
         add 6 to tWinMargin
         put 2*tWinMargin into tMarginTotal
         put tWinMargin into tMarginBtm
      end if
      
      if tYhigh < (tScreenHeight-tMarginTotal) then
         if tXwide < (tScreenWidth-6) then
            -- stack can fit completely on screen
            -- now check if its bottom y > bottom y of screen
            -- and check if its left x < left x of screen
            if tYbtm > (item 4 of tScreen - tMarginBtm) then
               subtract (tMarginBtm + tYbtm - item 4 of tScreen) from item 2 of tNewLoc
            end if
            if tXleft < 0 then
               subtract tXleft from item 1 of tNewLoc
            else if tXright > item 3 of tScreen then
               subtract (tXright - item 3 of tScreen) from item 1 of tNewLoc
            end if
         end if
      end if
      
      set the loc of this stack to tNewLoc
      
   end if
   
end locateStackWindow

# -------------------

on fontSetter   
   
   -- xxx WARNING: SETTING htmlText DESTROYS SUPERSCRIPTS in LC 8, 9 and ...?
   -- April, 2017, RKH, original fontSetter sets htmlText which destroys superscripts
   -- in at least LC 8 and 9, so deactivate all parts that affect htmlText but
   -- continue to change fields whose textFont is courier/courier new
   -- which usually are input value fields so to line up numbers with
   -- input labels and input units
   
   -- called in preOpenCard above
   -- uses functions fontSetter_NonWin, fontSetter_Win
   -- change "courier" to "courier new" in all fields on Win
   -- change "courier new" to "courier" in all fields on Mac and other OS
   
   # xxx
   # fontSetter in preOpenCard in Rev 2.5 interferes with visual effect on card
   # transitions, especially "wipe" because of lines in fontSetter setting
   # properties (htmlText here) of a field; no problem if were to move to openCard
   
   if (the platform is "Win32") then
      # change all to "courier new"
      repeat with i = 1 to the number of fields
         if the textFont of field i is "courier" then
            set the textFont of field i to "courier new"
         end if
         -- deactivate next two lines, setting htmlText destroys superscripts in LC 8, 9 and ...?
         --       put the htmlText of field i into tText
         --       set the htmlText of field i to fontSetter_Win(tText)
      end repeat
   else
      # change all to "courier" (for non-win standalones)
      repeat with i = 1 to the number of fields
         if the textFont of field i is "courier new" then
            set the textFont of field i to "courier"
         end if
         -- deactivate next two lines, setting htmlText destroys superscripts in LC 8, 9 and ...?
         --       put the htmlText of field i into tText
         --       set the htmlText of field i to fontSetter_NonWin(tText)
      end repeat
   end if
   # end if
end fontSetter

# -------------------

function fontSetter_Win tText 
   repeat
      put wordOffset(quote & "courier" & quote, tText) into tOffset
      if tOffset = 0 then
         exit repeat
      else
         put quote & "courier new" & quote into word tOffset of tText
      end if
   end repeat
   return tText
end fontSetter_Win

# -------------------

function fontSetter_NonWin tText
   repeat
      put offset("courier new", tText) into tOffset
      if tOffset = 0 then
         exit repeat
      else
         delete char (tOffset+7) to (tOffset+10) of tText
      end if
   end repeat
   return tText
end fontSetter_NonWin

# -------------------

on toNotePad cleared
   global labType, pathTOstacks, dataHeaders, runBeep
   global noteFileName, varCount, dataSwitch, SAVEDdataSwitch
   setInfo empty
   go stack pathTOstacks & "/Note_Pad.livecode" in new window
   repeat until the last char in field "notes" is not cr
      delete the last char in field "notes"
   end repeat
   if field "notes" is not empty then put LF & LF after field "notes"
   put empty into temp
   if "Q" is in labType then
      put "QUIZ " after temp
   end if
   put noteFileName && "saved to disk" & ".  " after temp
   if ("S" is in labType) or ("D" is in labType) then  # Single pt.
      put "Variables changed were: " after temp
      put "none" into found
      if cleared is "true" then
         repeat with i = 1 to varCount
            if item i of SAVEDdataSwitch = 2 then
               put temp && (item i of dataHeaders) & ";" into temp
               put "found" into found
            end if
         end repeat
      else
         repeat with i = 1 to varCount
            if item i of dataSwitch = 2 then
               put temp && (item i of dataHeaders) & ";" into temp
               put "found" into found
            end if
         end repeat
      end if
      if found is "none" then put temp & "(none) " into temp
      delete the last char in temp  # get rid of last ";"
      put temp & ".  " into temp
   end if
   put temp & "OBSERVATIONS:  " into temp
   put temp after field "notes"
   select after text of field "notes"
   if runBeep = "on" then
      beep
   end if
end toNotePad

# ---------------

on labSaveStart
   
   global setCount, firstSetSaved
   global labNumber, noteFileName
   global pathTOapp, pathTOtemps
   global pathTOdata, pathTOcurrent, currentDataFolderName
   global doFolderMaintenanceDONE
   if doFolderMaintenanceDONE is not "yes" then
      send doFolderMaintenance  # do folder maintenance, updates currentDataFolderName
   end if
   setInfo "Saving data set to disk file..."
   
   -- May 3, 2010: I only have used exportOne recently. Don't need exportMATLAB since
   -- can just paste into Matlab, comment header, put all data in one array, then pull out the
   -- columns you need, and not likely going to have more than one set being processed at a time.
   -- exportTWO was for plotting programs like KaleidaGraph.
   -- Just using exportONE gets rid of a dialog
   -- COMMENTED-OUT COPIES OF exportMATLAB and exportTWO are at bottom of this script
   
   exportPLOT
   exportONE
   
   --  put "Select format ONE for header and data in ONE file for import into a spreadsheet or plotting" into temp
   --  put return & "program.  Select MATLAB for data file and m-file that loads data file.  Select TWO for" after temp
   --  put return & "header and data in TWO separate files.  Data set in memory is not erased by save." after temp
   --  put return & "Select option..." after temp
   --  answer temp with "TWO" or "MATLAB" or "ONE"
   --  put it into exportOption
   --  lock screen
   --  exportPLOT
   --  if exportOption = "TWO" then
   --    exportTWO
   --  else if exportOption = "ONE" then
   --    exportONE
   --  else
   --    exportMATLAB
   --  end if
   
   put labNumber & "_"  & setCount into shortFileName
   # this next file doesn't have a setCount, it holds the names of sets for this lab module
   # that have been saved to disk but are not in the global theFiles xxx check this! xxx
   put pathTOtemps & "/" & labNumber & ".temp" into tempFile
   put "false" into alreadyThere
   if there is a file tempFile then
      open file tempFile
      read from file tempFile until end
      put it into tempList
      close file tempFile
      if offset(shortFileName,tempList) > 0 then
         # check further so don't find D1L1 in D1L11, e.g.
         repeat with j = 1 to the number of lines in tempList
            put line j of tempList into temp
            if shortFileName = temp then put "true" into alreadyThere
         end repeat
      end if
   else
      # Windows OS needs file to be created now
      open file tempFile
      write empty to file tempFile
      close file tempFile
   end if
   if alreadyThere is "false" then  # add new file to list
      open file tempFile for append
      write shortFileName & return to file tempFile
      close file tempFile
   end if
   unlock screen
   go this cd
   # save for note pad
   -- put labNumber & "_" & setCount && "(format " & exportOption & ")" into noteFileName
   put labNumber & "_" & setCount into noteFileName
   setCountIncrement
   setInfo empty
   put "yes" into firstSetSaved
end labSaveStart

# ---------------

on setCountIncrement
   global setCount, replot
   put the last char of setCount into savedChar
   repeat while the last char of setCount is not a number
      delete the last char of setCount
   end repeat
   put setCount + 1 into setCount
   if (savedChar = "b") or (savedChar = "c") or (savedChar = "p") then
      put setCount & savedChar into setCount
   end if
   setSet setCount
   put "true" into replot
end setCountIncrement

# ---------------

function getNextSetCount
   global setCount
   put setCount into nextSetCount
   put the last char of nextSetCount into savedChar
   repeat while the last char of nextSetCount is not a number
      delete the last char of nextSetCount
   end repeat
   put nextSetCount + 1 into nextSetCount
   if (savedChar = "b") or (savedChar = "c") or (savedChar = "p") then
      put nextSetCount & savedChar into nextSetCount
   end if
   return nextSetCount
end getNextSetCount

# ---------------

on doFolderMaintenance
   global doFolderMaintenanceDONE
   global quitFast
   global pathTOapp, pathTOtemps  # values set elsewhere
   global pathTOdata, pathTOcurrent, currentDataFolderName  # values set here
   set cursor to watch
   setInfo "Setting up folder to hold new notes and data..."
   if there is not a directory pathTOtemps then
      create directory pathTOtemps
   end if
   set the directory to pathTOtemps
   put the files into tempFiles
   repeat with i = 1 to the number of lines in tempFiles
      put line i of tempFiles into thisFile
      put pathTOtemps & "/" & thisFile into thisFile
      delete file thisFile
   end repeat
   put pathTOapp & "/data_folder" into pathTOdata
   if there is not a directory pathTOdata then
      create directory pathTOdata
   end if
   put the date into thisDate
   set the itemDelimiter to "/"
   put item 1 of thisDate into thisMonth
   put item 2 of thisDate into thisDay
   put item 3 of thisDate into thisYear
   if the number of characters in thisMonth is 1 then put "0" before thisMonth
   if the number of characters in thisDay is 1 then put "0" before thisDay
   set the itemDelimiter to ","  # back to default
   # if change order of year, mo, day, then need to change dialog on quitting lab in "quitMC"
   put "session_" & thisMonth & thisDay & "_1" into currentDataFolderName
   # xxx  put "session_" & thisYear & thisMonth & thisDay & "_1" into currentDataFolderName
   set the directory to pathTOdata
   put the directories into directoryList
   repeat
      if currentDataFolderName is in directoryList then
         add one to the last char of currentDataFolderName
      else
         exit repeat
      end if
   end repeat
   put pathTOdata & "/" & currentDataFolderName into pathTOcurrent
   create directory pathTOcurrent
   put "yes" into doFolderMaintenanceDONE
   put "false" into quitFast
end doFolderMaintenance

# ---------------

on exportONE
   
   global labCardName, labType, setCount, varCount, dataHeaders
   global dataUnits, dataArray, labNumber
   global dataSwitch
   global pathTOapp, pathTOtemps
   global pathTOdata, pathTOcurrent, currentDataFolderName
   global quizLabel
   
   put return into recordDelim
   put tab into fieldDelim
   
   put labNumber && labCardName into thisTempName
   put stripOuterSpace(thisTempName) into thisTempName
   if "Q" is in labType then
      put stripOuterSpace(thisTempName && "Quiz") into thisTempName
   end if
   
   put thisTempName & ", Data Set" && setCount & return into tTempText -- first line in tTempText
   
   if "Q" is in labType then
      put "Current Quiz Letter:  "  & numTOchar(quizLabel+64) & return into temp
      put "The code for a quiz changes each time you supply a correct answer." & return after temp
      put "Always re-enter an unfinished quiz with the code recorded in the" & return after temp
      put "Budget Report when you LAST LEFT the quiz in your last session." & return after temp
      put temp after tTempText
   end if
   put return after tTempText
   repeat with i = 1 to varCount
      if item i of dataSwitch = 0 then
         put item i of dataHeaders & "_" & setCount after tTempText
         put " remained constant at " after tTempText
         if item i of line 1 of dataArray is a number then
            put sciNote(item i of line 1 of dataArray) & space after tTempText
         else
            put item i of line 1 of dataArray & space after tTempText
         end if
         put line i of dataUnits & return after tTempText
      end if
   end repeat
   repeat with i = 1 to varCount
      if item i of dataSwitch > 1 then
         put item i of dataHeaders & "_" & setCount after tTempText
         put " has units of " after tTempText
         put line i of dataUnits & return after tTempText
      end if
   end repeat
   put return after tTempText
   repeat with i = 1 to (varCount - 1)
      if item i of dataSwitch > 1 then
         put item i of dataHeaders & "_" & setCount & tab after tTempText
      end if
   end repeat
   if item varCount of dataSwitch > 1 then
      put item varCount of dataHeaders & "_" & setCount after tTempText
   end if
   put return after tTempText
   put the number of lines in dataArray into lineCount
   repeat with j = 1 to lineCount
      set cursor to busy
      repeat with i = 1 to (varCount - 1)
         if item i of dataSwitch > 1 then
            put sciNote(item i of line j of dataArray,"no","yes") & fieldDelim after tTempText
         end if
      end repeat
      if item varCount of dataSwitch > 1 then
         put sciNote(item varCount of line j of dataArray,"no","yes") after tTempText
      end if
      put recordDelim after tTempText
   end repeat
   
   -- May 3, 2010: don't need _one anymore since only using exportONE
   -- put pathTOcurrent & "/" & labNumber & "_" & setCount & "_one.txt" into thisFileName
   -- also see below in this command when annouce save to user
   put pathTOcurrent & "/" & labNumber & "_" & setCount & ".txt" into thisFileName
   open file thisFileName
   write tTempText to file thisFileName
   close file thisFileName
   
   -- May 3, 2010: don't need _one anymore since only using exportONE
   -- put pathTOcurrent & "/" & labNumber & "_" & setCount & "_one.txt" into thisFileName
   -- also see above in this command when set filename
   --    put labNumber & "_" & setCount & "_one.txt" into thisFileName
   put labNumber & "_" & setCount & ".txt" into thisFileName -- doesn't have pathTOcurrent/
   
   put getNextSetCount() into nextSetCount
   put "Export of Data Set " & setCount & " is complete." into temp
   put return & return & "Experimental conditions and tab-delimited data were saved to the file '" & thisFileName & "'" after temp
   put space & "in the folder  '" & currentDataFolderName & "' in the 'data_folder'." after temp
   put return & return & "The Data Set number will be incremented to " & nextSetCount & "." after temp
   answer temp
   setInfo empty
end exportONE

# ---------------

on exportPLOT
  global labNumber, dataArray, dataHeaders, setCount, pathTOtemps
  put pathTOtemps & "/" & labNumber & "_" & setCount & ".temp" into thisFileName
  open file thisFileName
  write dataHeaders to file thisFileName
  write return to file thisFileName
  write dataArray to file thisFileName
  close file thisFileName
end exportPLOT

# -----------------

on labCopyToClipboard
   
   -- based on exportONE
   -- this is being developed in May 2010 to replace old clear/save button
   -- with new clear, copy, save buttons
   
   global labCardName, labType, setCount, varCount, dataHeaders
   global dataUnits, dataArray, labNumber
   global dataSwitch
   global pathTOapp, pathTOtemps
   global pathTOdata, pathTOcurrent, currentDataFolderName
   global quizLabel
   
   put return into recordDelim
   put tab into fieldDelim
   
   put labNumber && labCardName into thisTempName
   put stripOuterSpace(thisTempName) into thisTempName
   if "Q" is in labType then
      put stripOuterSpace(thisTempName && "Quiz") into thisTempName
   end if
   
   put thisTempName & ", Data Set" && setCount & return into tTempText -- first line in tTempText
   
   if "Q" is in labType then
      put "Current Quiz Letter:  "  & numTOchar(quizLabel+64) & return into temp
      put "The code for a quiz changes each time you supply a correct answer." & return after temp
      put "Always re-enter an unfinished quiz with the code recorded in the" & return after temp
      put "Budget Report when you LAST LEFT the quiz in your last session." & return after temp
      put temp after tTempText
   end if
   put return after tTempText
   repeat with i = 1 to varCount
      if item i of dataSwitch = 0 then
         put item i of dataHeaders & "_" & setCount after tTempText
         put " remained constant at " after tTempText
         if item i of line 1 of dataArray is a number then
            put sciNote(item i of line 1 of dataArray) & space after tTempText
         else
            put item i of line 1 of dataArray & space after tTempText
         end if
         put line i of dataUnits & return after tTempText
      end if
   end repeat
   repeat with i = 1 to varCount
      if item i of dataSwitch > 1 then
         put item i of dataHeaders & "_" & setCount after tTempText
         put " has units of " after tTempText
         put line i of dataUnits & return after tTempText
      end if
   end repeat
   put return after tTempText
   repeat with i = 1 to (varCount - 1)
      if item i of dataSwitch > 1 then
         put item i of dataHeaders & "_" & setCount & tab after tTempText
      end if
   end repeat
   if item varCount of dataSwitch > 1 then
      put item varCount of dataHeaders & "_" & setCount after tTempText
   end if
   put return after tTempText
   put the number of lines in dataArray into lineCount
   repeat with j = 1 to lineCount
      set cursor to busy
      repeat with i = 1 to (varCount - 1)
         if item i of dataSwitch > 1 then
            put sciNote(item i of line j of dataArray,"no","yes") & fieldDelim after tTempText
         end if
      end repeat
      if item varCount of dataSwitch > 1 then
         put sciNote(item varCount of line j of dataArray,"no","yes") after tTempText
      end if
      put recordDelim after tTempText
   end repeat
   
   -- now put the text into clipboard
   
   set the clipboardData["text"] to tTempText
   
   setInfo "Data has been copied to the computer's clipboard"
   
end labCopyToClipboard

# ---------------

on quizExit
   
   global pathTOscripts
   global labCardName
   global labNumber
   global runCount
   global quizUnknowns  # need to initialize this in initThisLab
   global quizAnswers
   global quizFirstRun
   global quizIsSolved
   global quizLabel
   global quizName
   global quizCode
   global quizCodeRefresh
   global expCount
   global budgetReportImage
   global budgetBalance
   global budgetPrintBal
   global gHistory
   
   put the long time & ", leave quiz" && labNumber & ", balance =" && budgetBalance & LF after gHistory
   
   # do NOT clear things like quizIsSolved here so don't clear flds in Budget Report
   # do NOT change quizSpecify Order here
   
   if quizFirstRun is "yes" then
      
      if (runCount > 0) OR (quizCodeRefresh is "yes") then
         
         # update quizAnswers, expCount & budgetBalance in code
         
         put empty into savedOrderCode
         if offset("(",quizCode) > 0 then
            put offset("(",quizCode) into firstChar
            put the number of chars in quizCode into lastChar
            put char firstChar to lastChar of quizCode into savedOrderCode
            delete char firstChar to lastChar of quizCode
         end if
         
         put decoder(quizCode) into temp
         
         put quizAnswers into item 2 of temp  # fix quizAnswers as item 2 of code structure
         
         put random(9) into theOffset
         put expCount + theOffset into ecode
         put (10 - theOffset) before ecode
         put ecode into item 3 of temp  # fix ecode as item 3 of code structure
         
         put random(9) into theOffset
         put budgetBalance/100 + theOffset into bcode  # balances always multiples of 100
         put (10 - theOffset) before bcode
         put bcode into item 4 of temp  # fix bcode as item 4 of code structure
         
         put encoder(temp) & savedOrderCode into quizCode
         
      end if
      
      put "no" into quizFirstRun
      put -1 into budgetPrintBal  # to trigger warning to print if they quit now
      put stripOuterSpace(labNumber && labCardName) into quizName
      
      if expCount = 1 then
         put " experiment, balance = $" into temp
      else
         put " experiments, balance = $" into temp
      end if
      
      if quizIsSolved = "yes" then
         put "Leave solved quiz " & numTOchar(quizLabel+64) & ", " & quizName & ", " & expCount & temp & budgetBalance & return after budgetReportImage
         put "    code: " & quizCode & return after budgetReportImage
      else
         put "Leave unfinished quiz " & numTOchar(quizLabel+64) & ", " & quizName & ", " & expCount & temp & budgetBalance & return after budgetReportImage
         put "    code: " & quizCode & return after budgetReportImage
         answer "The code number has been recorded in the Budget Report if you want to continue this quiz later."
      end if
      
      quizLabelIncrement
      
   end if
   
   -- added May 2010 to ensure report gets saved
   -- need to have stack "Budget Report" in use
   -- but global pathTOscripts not set in older Directory
   -- so check to make sure budget report is in use
   -- so that don't hang here and prevent leaving lab if user still has older Directory in use
   put pathTOscripts & "/Budget_Report.livecode" into tStack
   if there is a stack tStack then
      start using stack tStack
      send updateMe to stack tStack
      send mouseUp to button "Save" of cd "Budget" of stack tStack
   end if
   
   repeat with i = 1 to the number of items in quizUnknowns
      put "lvq" & item i of quizUnknowns into temp
      if there is a button temp then
         show button temp
      end if
   end repeat
   
   if labNumber is "D1L1" then
      quizOrderBox "off"  # special for Isothermal Nth Order numbered as D1L1
   end if
   
end quizExit

# --------------

on quizOrderBox thisSwitch   # special for Isothermal Nth Order numbered as D1L1
  global labNumber
  if labNumber is not  "D1L1" then
    exit quizOrderBox
  end if
  if thisSwitch is "on" then
    # need to expand top of cd graphic "input frame bottom" to enclose order
    put the rect of button "lv3" into lvRect
    put the rect of cd graphic "input frame bottom" into thisRect
    put item 2 of lvRect into item 2 of thisRect
    set the rect of cd graphic "input frame bottom" to thisRect
    set the textColor of line 3 of field "inputs" to "blue"
  else
    put the rect of button "lv4" into lvRect
    put the rect of cd graphic "input frame bottom" into thisRect
    put item 2 of lvRect into item 2 of thisRect
    set the rect of cd graphic "input frame bottom" to thisRect
    set the textColor of line 3 of field "inputs" to "black"
  end if
end quizOrderBox

# --------------

on quizReset
   
   global labNumber
   global setCount
   global runCount
   global dataMinMax
   global dataHeaders
   global plotFlag
   global quizUnknowns
   global quizAnswers
   global quizAnswerCounts
   global quizIsSolved
   global quizCode
   global quizFirstRun
   global quizSpecifyOrder
   global quizInputs
   global expCount
   global budgetBalance
   
   put zero into plotFlag
   
   repeat with i = 1 to the number of items in quizUnknowns
      put "lvq" & item i of quizUnknowns into temp
      if there is a button temp then
         show button temp
      end if
   end repeat
   
   put "no" into quizFirstRun
   put "no" into quizIsSolved
   if runCount > 0 then
      labClear "no"
   end if
   put empty into quizAnswerCounts
   repeat with i = 1 to the number of items in quizUnknowns
      put zero into item i of quizAnswerCounts
   end repeat
   
   put empty into quizAnswers
   repeat with i = 1 to the number of items in quizUnknowns
      put any char of "13579" into char i of quizAnswers  # odd = not answered
   end repeat
   
   if labNumber is in "D1L2,D1L3,D1L4" then   # special for "variable" labs with stoich coeffs (modify for D1L20, etc)
      put any char of "02468" into char 4 of quizAnswers  # stoich coeff a set by quiz but known to user
      put any char of "02468" into char 5 of quizAnswers  # stoich coeff b
   end if
   
   if labNumber is "D1L1" then  # special for Isothermal Nth Order numbered as D1L1
      if quizSpecifyOrder is "yes" then
         put any char of "02468" into char 3 of quizAnswers  # so can detect when quiz is solved in quizAnswerHandler
         hide button "lvq3"
         quizOrderBox "on"
      else if quizSpecifyOrder is "no" then
         quizOrderBox "off"
         show button "lvq3"
      end if
   end if
   
   repeat with i =  1 to the number of items in quizUnknowns
      
      put item i of quizUnknowns into varNum
      put item varNum of dataHeaders into varName
      
      # in if-else structure, first check for special labs with special variables
      
      if (varName is "n") AND ( labNumber is in "D1L1,D1L2,D1L3,D1L4") then
         
         if quizSpecifyOrder is "yes" then
            # user has specified n
            put sciConv(line 3 of field "inputs") into n
            if n is 0 then
               put "(Z)" into orderSaver
            else
               put "(" & n & ")" into orderSaver
            end if
         else
            # pick integer order value and put into field
            put sciConv(line 3 of quizInputs) into n
            put n into old
            repeat while n = old
               -- put any item of "1,2,0,-1" into n
               -- NEGATIVE ORDER CAN BE TOO TOUGH
               -- SO DON'T USE -1
               put any item of "1,2,0" into n
            end repeat
            put "?" into line 3 of field "inputs"
            put sciNote(n,"yes","yes") into line 3 of quizInputs
            put empty into orderSaver  # need this since orderSaver added after quizCode below
         end if
         
      else if (varName is "a") AND ( labNumber is in "D1L2,D1L3,D1L4") then
         
         put sciConv(line 4 of quizInputs) into olda
         put olda into sca
         repeat while sca = olda
            put random(3) into sca
         end repeat
         put sca into line 4 of field "inputs"  # need to display this
         put sca into line 4 of quizInputs
         
      else if (varName is "b") AND ( labNumber is in "D1L2,D1L3,D1L4") then
         
         put sciConv(line 4 of quizInputs) into sca
         put sca into scb
         repeat while scb = sca
            put random(3) into scb
         end repeat
         put scb into line 5 of field "inputs"  # need to display this
         put scb into line 5 of quizInputs
         
      else if char 1 of varName = "k" then
         
         # pick random value evenly distributed over ln of range
         put sciConv(line varNum of quizInputs) into old
         put old into new
         repeat while new = old
            put item varNum of line 1 of dataMinMax into varMin
            put item varNum of line 2 of dataMinMax into varMax
            put sciConv(varMin) into varMin
            put sciConv(varMax) into varMax
            if varMin = 0 then  # can't take ln of 0
               put 0.000001 into varMin
            end if
            put ln(varMin) into varMin
            put ln(varMax) into varMax
            put random(101) into temp
            put (temp-1)/100 into temp
            put (varMax - varMin)*temp + varMin into temp
            put exp(temp) into new
         end repeat
         put "?" into line varNum of field "inputs"
         put sciNote(new, "yes", "yes") into line varNum of quizInputs
      else
         
         # pick random value evenly spaced over range
         put sciConv(line varNum of quizInputs) into old
         put old into new
         repeat while new = old
            put item varNum of line 1 of dataMinMax into varMin
            put item varNum of line 2 of dataMinMax into varMax
            put sciConv(varMin) into varMin
            put sciConv(varMax) into varMax
            put random(101) into temp
            put (temp-1)/100 into temp
            put (varMax - varMin)*temp + varMin into new
         end repeat
         put "?" into line varNum of field "inputs"
         put sciNote(new, "yes", "yes") into line varNum of quizInputs
         
      end if
      
   end repeat
   
   put zero into expCount
   put zero into budgetBalance
   
   # do a slight encoding so don't always record 0 0 for new quiz
   
   put random(9) into theOffset
   put expCount + theOffset into ecode
   put (10 - theOffset) before ecode
   
   put random(9) into theOffset
   put budgetBalance/100 + theOffset into bcode  # balances always multiples of 100
   put (10 - theOffset) before bcode
   
   put labNumber into temp
   delete char 1 of temp
   if the last char of setCount is not a number then
      put the last char of setCount after temp  # type of reactor: b,c or p
   end if
   
   # build code structure
   # lab desig is item 1, quizAnswers is 2, ecode is 3, bcode is 4, then unknowns
   put temp into quizCode
   put quizAnswers into item 2 of quizCode
   put ecode into item 3 of quizCode
   put bcode into item 4 of quizCode
   repeat with i =  1 to the number of items in quizUnknowns
      put item i of quizUnknowns into varNum
      put line varNum of quizInputs into item (i+4) of quizCode
   end repeat
   put encoder(quizCode) into quizCode
   put quizCode & orderSaver into quizCode
   
   put quizLabelDisplay() into field "code"
   
   emptyRightFlds
   
end quizReset

# -------------

on quizLabelIncrement
  
  global quizLabel  # an integer
  
  if quizLabel is empty then
    put 1 into quizLabel
  else
    add one to quizLabel
  end if
  if quizLabel > 26 then
    put 1 into quizLabel
  end if
  
end quizLabelIncrement

# -------------

function quizLabelDisplay
  
  # returns "Quiz A", where A is letter corresponding to number of alphabet spec by quizLabel
  
  global quizLabel  # an integer
  
  if (quizLabel is empty) OR (quizLabel is not a number) then
    # this avoids having to initialize quizLabel on lab startup
    put 1 into quizLabel
  end if
  
  put 64 + quizLabel into temp
  put numTOchar(temp) into temp
  put "Quiz" && temp into temp
  return temp
  
end quizLabelDisplay

# --------------

on quizResetHandler
  
  global runCount
  global setCount
  global labCardName
  global labNumber
  global dataHeaders
  global quizAnswers
  global quizUnknowns
  global quizIsSolved
  global quizCode
  global quizLabel
  global quizFirstRun
  global quizSpecifyOrder
  global quizInputs
  global expCount
  global budgetReportImage
  global budgetBalance
  
  put "Do you want to clear this set and get new randomized values, " into temp
  put temp & "or do you want to clear this set and enter an old code?" into temp
  answer temp with "Old" or "New" or "Cancel"
  
  if it = "Cancel" then exit quizResetHandler
  
  set cursor to watch
  
  quizExit
  
  if it = "New" then
    quizReset
  end if
  
  if it = "Old" then
    
    ask "Enter the old code from this quiz please...                                         "
    
    if the result is "Cancel" then
      exit quizResetHandler
    end if
    
    if it is empty then exit quizResetHandler
    
    put stripOuterSpace(it) into oldCode
    
    if word 1 of oldCode is "code:" then
      delete word 1 of oldCode
    end if
    
    put stripSpace(oldCode) into oldCode
    
    repeat with i = 1 to the number of items in quizUnknowns
      put item i of quizUnknowns into varNum
      put "lvq" & varNum into temp
      if there is a button temp then
        show button temp
      end if
    end repeat
    
    labClear "no"
    
    put oldCode into temp
    
    if labNumber is "D1L1" then  # special for Isothermal Nth Order numbered as D1L1
      
      if the last char of temp is ")" then
        
        put "yes" into quizSpecifyOrder
        put empty into line 3 of field "inputs"
        put empty into line 3 of quizInputs
        hide button "lvq3"
        quizOrderBox "on"  # in stack script
        
        delete the last char of temp
        put offset("(",temp) into parenLoc
        delete char 1 to parenLoc of temp
        
        if temp is "Z" then
          put zero into order  # xxx I don't do anything with "order", might check against a varName of "n"
        else
          if temp is a number then
            put temp into order
          else
            answer "This is not a valid code! (0)"
            exit quizResetHandler
          end if
        end if
        
        put the number of chars of oldCode into lastChar
        put offset("(",oldCode) into firstChar
        put char firstChar to lastChar of oldCode into savedOrderCode
        delete char firstChar to lastChar of oldCode
        
      else
        
        put "no" into quizSpecifyOrder
        quizOrderBox "off"
        show button "lvq3"
        
        # end of if the last char of temp is ")"
      end if
      
      # end of  if labNumber is "D1L1"
    end if
    
    put oldCode into savedOldCode
    put decoder(oldCode) into oldCode
    
    put the number of items of quizUnknowns into numVar
    
    if the number of items of oldCode = (4 + numVar) then  # 4 + for lab desig, quizAnswers, ecode, bcode
      # this has the right number of items
    else
      answer "This is not a valid code! (1)"
      exit quizResetHandler
    end if
    
    # item 1 of code structure is lab designation
    
    put item 1 of oldCode into temp
    put labNumber into temp2
    if the last char of setCount is not a number then
      # last char of setCount is type of reactor: b, c or p
      put the last char of setCount after temp2
    end if
    delete char 1 of temp2
    if temp is not temp2 then
      answer "This is not a code from this lab quiz! (2)"
      exit quizResetHandler
    end if
    
    # item 2 of code structure is quizAnswers
    
    put item 2 of oldCode into quizAnswers
    
    if quizAnswers is not a number then
      answer "This is not a valid code! (3)"
      
      # xxx A global value, quizAnswers, has been changed even though this is
      # xxx a bad code.  I shouldn't change any globals until after all validity checks
      # xxx have been made.  For now, I will do a quizReset here and below,
      # xxx even though that's not what user requested.
      
      quizReset
      exit quizResetHandler
    end if
    
    if the number of chars in quizAnswers is not numVar then
      answer "This is not a valid code! (4)"
      quizReset
      exit quizResetHandler
    end if
    
    # move handling of quizAnswers below after after quizInputs updated
    # so any answered values will show correctly after lvq btn hide
    
    # item 3 of code structure is ecode for expCount
    
    put item 3 of oldCode into ecode
    
    if ecode is not a number then
      answer "This is not a valid code! (5)"
      quizReset
      exit quizResetHandler
    end if
    
    # ---  from quizReset ---
    # put random(9) into theOffset
    # put expCount + theOffset into ecode
    # put (10 - theOffset) before ecode
    
    put 10 - char 1 of ecode into theOffset
    delete char 1 of ecode
    put ecode - theOffset into expCount
    
    # item 4 of code structure is bcode for budget balance
    
    put item 4 of oldCode into bcode
    
    # *** do NOT check if bcode is a number! ***
    # *** e.g., for theOffset = 3, bal = $-600, bcode is "7-3", which is not a number! ***
    # *** this problem does not occur with ecode
    
    # ---  from quizReset ---
    # put random(9) into theOffset
    # put budgetBalance/100 + theOffset into bcode
    # put (10 - theOffset) before bcode
    
    put 10 - char 1 of bcode into theOffset
    delete char 1 of bcode
    put bcode - theOffset into bcode
    put 100*bcode into budgetBalance  # balances always multiples of 100
    
    # repeat to the end of the code structure to get the unknowns
    
    repeat with i = 1 to numVar
      
      put item i of quizUnknowns into varNum
      put item varNum of dataHeaders into varName
      
      put item (i+4) of oldCode into thisValue
      put sciConv(thisValue) into thisValue
      
      if thisValue is a number then
        
        put sciNote(thisValue,"yes","yes") into line varNum of quizInputs
        
        # put value into field "inputs" only for specific cases
        
        if (labNumber is "D1L1") then
          if (varName is "n") AND (quizSpecifyOrder is "yes") then
            put sciNote(thisValue,"yes","yes") into line varNum of field "inputs"
          end if
        end if
        
        if labNumber is in "D1L2,D1L3,D1L4" then
          if (varName is "a") OR (varName is "b") then
            put sciNote(thisValue,"yes","yes") into line varNum of field "inputs"
          end if
        end if
        
      else
        answer "This is not a valid code! (7)"
        quizReset
        exit quizResetHandler
      end if
      
    end repeat
    
    put "yes" into quizIsSolved
    repeat with i = 1 to the number of chars in quizAnswers
      if char i of quizAnswers is in "02468" then
        put item i of quizUnknowns into varNum
        put "lvq" & varNum into temp
        if there is a button temp then
          put line varNum of quizInputs into line varNum of field "inputs"
          hide button temp
        end if
      else
        put "no" into quizIsSolved
      end if
    end repeat
    
    put quizLabelDisplay() into field "code"
    put savedOldCode & savedOrderCode into quizCode
    
    put "Re-enter old quiz, " & labNumber && labCardName & ", " & expCount & " experiments, balance = $" & budgetBalance & return after budgetReportImage
    put "    code: " & quizCode & return after budgetReportImage
    put "    old quiz assigned current quiz letter " & numTOchar(quizLabel+64) & return after budgetReportImage
    put "yes" into quizFirstRun  # want yes even if no runs made
    
  end if
  
end quizResetHandler

# --------------

on quizAnswerHandler theVar
   
   global expCount
   global dataHeaders
   global quizUnknowns
   global quizAnswers
   global quizAnswerCounts
   global quizSpecifyOrder
   global quizInputs
   global quizCodeRefresh
   global budgetBalance
   global budgetReportImage
   
   if expCount = 0 then
      answer "Please don't guess!"
      exit quizAnswerHandler
   end if
   
   put item theVar of dataHeaders into varName
   
   # theVar is the line number in field "inputs" of the unknown
   # need to find which item of quizUnknowns it is
   
   repeat with i = 1 to the number of items in quizUnknowns
      if theVar = item i of quizUnknowns then
         put i into theOne
         exit repeat
      end if
   end repeat
   
   if char theOne of quizAnswers is in "02468" then
      answer "You have already entered the correct value!" with "OK"
      exit quizAnswerHandler
   end if
   
   ask "Enter the value of " & varName & ":"
   if the result is "Cancel" then
      exit quizAnswerHandler
   end if
   if it is empty then exit quizAnswerHandler
   
   put sciConv(it) into theResponse
   put sciConv(line theVar of quizInputs) into theAnswer
   
   # xxx the +/- 20% is OK for rate constants (char  1 of varname is "k")
   # xxx but not so good for other variables such as Ea, maybe do something
   # xxx with fraction of those variables ranges???
   
   put "no" into theFlag
   
   if (theAnswer > 0) AND (theResponse > 0) then
      if  (theResponse >= theAnswer*0.8) AND (theResponse <= theAnswer *1.2) then
         put "yes" into theFlag
      end if
   end if
   
   if (theAnswer < 0) AND (theResponse < 0) then
      put abs(theResponse) into absResponse
      put abs(theAnswer) into absAnswer
      if (absResponse >= absAnswer*0.8) AND (absResponse <= absAnswer *1.2) then
         put "yes" into theFlag
      end if
   end if
   
   if (char 1 of varName is not "k") AND (theAnswer = 0) then
      if theResponse = theAnswer then
         put "yes" into theFlag
      end if
   end if
   
   # if true Ea = 0, then accept from 0 to 1 kJ/mol (Ea's are positive)
   if char 1 of varName is "E" then
      if (theAnswer = 0) AND (theResponse >= 0) AND (theResponse <= 1) then
         put "yes" into theFlag
      end if
   end if
   
   -- in May 2010 got string "5.37x10^-10" pasted in by mistake accepted
   -- as correct for 44.7 so make sure theResponse is really a number
   if theResponse is not a number then
      put "no" into theFlag
   end if
   
   if theFlag is "yes" then
      
      put item theOne of quizAnswerCounts into temp
      put 1000 - 100*temp into newPts
      if newPts < 200 then put 200 into newPts
      put budgetBalance + newPts into budgetBalance
      
      put any char of "02468" into char theOne of quizAnswers
      put "yes" into quizCodeRefresh  # so refresh code on quizExit even if no new runs
      
      put sciNote(theAnswer,"yes","yes") into theAnswer
      put sciNote(theResponse,"yes","yes") into theResponse
      
      put "Yes, the value of " & varName & " is " & theAnswer & "." into temp
      put return & "You have just earned $" & newPts && "and have $" & budgetBalance && "in your budget." after temp
      answer temp with "OK"
      
      put "lvq" & theVar into temp
      if there is a button temp then
         put theAnswer into line theVar of field "inputs"
         hide button temp
      end if
      
      put "    " & "correct answer, " & varName & " = " & theAnswer & "(" & theResponse & "), earned $" & newPts & return after budgetReportImage
      
   else
      answer "No, try again." with "OK"
      add one to item theOne of quizAnswerCounts
      exit quizAnswerHandler
   end if
   
   # for lab with quizSpecifyOrder, if quizSpecifyOrder is "yes", the corresponding char of quizAnswers should already be even
   put "yes" into temp
   repeat with i = 1 to the number of chars in quizAnswers
      if char i of quizAnswers is in "13579" then
         put "no" into temp
      end if
   end repeat
   if temp is "yes" then quizSolvedHandler
   
end quizAnswerHandler

# -------------

on quizSolvedHandler
  
  global setCount
  global quizSpecifyOrder
  global budgetBalance
  global quizIsSolved
  global budgetReportImage
  
  # set value of bonus $ earn
  if the last char of setCount is "c" then  # xxx need to generalize this
    # CSTR easier to solve than batch and PFR
    if quizSpecifyOrder is "yes" then
      put 200 into bonus
    else
      put 400 into bonus
    end if
  else
    if quizSpecifyOrder is "yes" then
      put 250 into bonus
    else
      put 500 into bonus
    end if
  end if
  
  put budgetBalance + bonus into budgetBalance
  
  put "Click 'Reset' button for a new quiz." into field "code"
  put "yes" into quizIsSolved
  
  put  "    " & "solved quiz, bonus = $" & bonus & ", balance = $" & budgetBalance & return after budgetReportImage
  
  beep
  put "For completing the entire quiz, you have earned an additional $" & bonus into temp
  put temp && "and have $" & budgetBalance && "in your budget for this quiz.  " into temp
  put temp & "Click the 'Reset' button to repeat with new unknown values." into temp
  answer temp with "OK!"
  
end quizSolvedHandler

# ---------------

on quizOptionsHandler  # specific to D1L1 Isothermal Nth Order Labs
  
  global runCount
  global quizSpecifyOrder
  global quizInputs
  
  put "You can choose the option of finding the order or specifying the order.  " & return into temp
  put "Changing your option will reset the quiz with new unknown values of k and Ea.  " & return after temp
  put "Your current option is " after temp
  if quizSpecifyOrder is "yes" then
    put "'Specify'." after temp
  else
    put "'Find'." after temp
  end if
  
  answer temp with "Specify" or "Find" or "Cancel"
  put it into theChoice
  
  if theChoice is "Cancel" then
    exit quizOptionsHandler
  end if
  
  if theChoice is "Specify" then
    put "yes" into theChoice
  else
    put "no" into theChoice
  end if
  
  if theChoice is quizSpecifyOrder then
    # user's choice is current option
    exit quizOptionsHandler
  else
    # user wants to switch option
    if theChoice is "yes" then
      put 1 into line 3 of field "inputs"  # replace "?"
      put 1 into line 3 of quizInputs  # to agree with previous line
    else
      put "?" into line 3 of field "inputs"
    end if
    put theChoice into quizSpecifyOrder
    quizExit
    quizReset
  end if
  
end quizOptionsHandler

# --------------

on hlvq
  global quizUnknowns
  repeat with i = 1 to the number of items in quizUnknowns
    put item i of quizUnknowns into theLine
    put "lvq" & theLine into temp
    if there is a button temp then
      hide button temp
    end if
  end repeat
end hlvq

# --------------

on slvq
  global quizUnknowns
  repeat with i = 1 to the number of items in quizUnknowns
    put item i of quizUnknowns into theLine
    put "lvq" & theLine into temp
    if there is a button temp then
      show button temp
    end if
  end repeat
end slvq

---------------

-- -- KEEP THIS COMMENTED COPY FOR POSSIBLE USE LATER
on exportMATLAB
--  global labType, labCardName, labNumber, setCount, varCount, dataHeaders
--  global dataUnits, dataArray, dataSwitch
--  global pathTOapp, pathTOtemps
--  global pathTOdata, pathTOcurrent, currentDataFolderName
--  global quizLabel
--  put return into recordDelim
--  put tab into fieldDelim

--  # need short and long file names for two files:  m-file and data file
--  put labNumber & "_" & setCount into shortFileName
--  put shortFileName into shortDataFileName  # have separate name in case want to add prefix or suffix later
--  put shortDataFileName & ".txt" into shortDataFileNameTXT
--  put pathTOcurrent & "/" & shortDataFileNameTXT into longDataFileName
--  put shortFileName & ".m" into shortMFileName
--  put pathTOcurrent & "/" & shortMFileName into longMFileName

--  open file longDataFileName
--  put the number of lines in dataArray into lineCount
--  repeat with j = 1 to lineCount
--    set cursor to busy
--    repeat with i = 1 to varCount-1
--      if item i of dataSwitch > 1 then
--        write sciNote(item i of line j of dataArray,"no","yes") & fieldDelim to file longDataFileName
--      end if
--    end repeat
--    if item varCount of dataSwitch > 1 then
--      write sciNote(item varCount of line j of dataArray,"no","yes") to file longDataFileName
--    end if
--    write recordDelim to file longDataFileName
--  end repeat
--  close file longDataFileName

--  # now write the m file with commands to load data and header info
--  open file longMFileName
--  put labNumber && labCardName into thisTempName
--  put stripOuterSpace(thisTempName) into thisTempName
--  if "Q" is in labType then
--    put stripOuterSpace(thisTempName && "Quiz") into thisTempName
--  end if
--  write "%" && thisTempName & ", Data Set" && setCount & return to file MfileName
--  if "Q" is in labType then
--    put "% Current Quiz Letter:  "  & numTOchar(quizLabel+64) & return into temp
--    put "% The code for a quiz changes each time you supply a correct answer." & return after temp
--    put "% Always re-enter an unfinished quiz with the code recorded in the" & return after temp
--    put "% Budget Report when you LAST LEFT the quiz in your last session." & return after temp
--    write temp to file longMFileName
--  end if
--  write return to file longMFileName
--  put false into tFlag
--  repeat with i = 1 to varCount
--    if item i of dataSwitch = 0 then
--      put item i of dataHeaders into tempVar
--      if "~`!@#$%^&*+='?/\|<>" contains the last char of tempVar then
--        delete the last char of tempVar  # MATLAB can't handle special chars in var names
--        put true into tFlag
--      end if
--      write "%" && tempVar & "_" & setCount to file longMFileName
--      write " remained constant at " to file longMFileName
--      if item i of line 1 of dataArray is a number then
--        write sciNote(item i of line 1 of dataArray) & space to file longMFileName
--      else
--        write item i of line 1 of dataArray & space to file longMFileName
--      end if
--      write line i of dataUnits & return to file longMFileName
--    end if
--  end repeat
--  if tFlag is true then
--    write "% Special characters denoting values at reference" & return to file longMFileName
--    write "% conditions (e.g., STP) have been deleted from variable names above." & return to file longMFileName
--  end if
--  put false into tFlag
--  write return to file longMFileName
--  repeat with i = 1 to varCount
--    if item i of dataSwitch > 1 then
--      put item i of dataHeaders into tempVar
--      if "~`!@#$%^&*+='?/\|<>" contains the last char of tempVar then
--        delete the last char of tempVar  # MATLAB can't handle special chars in var names
--        put true into tFlag
--      end if
--      write "%" && tempVar & "_" & setCount to file longMFileName
--      write " has units of " to file longMFileName
--      write line i of dataUnits & return to file longMFileName
--    end if
--  end repeat
--  write return to file longMFileName
--  write "load" && shortDataFileNameTXT & return to file longMFileName
--  # now separately extract variables from matrix
--  # an alternate way would be to use "load filename var1 var2..." version of Matlab load syntax
--  put zero into colNum
--  repeat with i = 1 to varCount
--    if item i of dataSwitch > 1 then
--      put item i of dataHeaders into tempVar
--      if "~`!@#$%^&*+='?/\|<>" contains the last char of tempVar then
--        delete the last char of tempVar  # MATLAB can't handle special chars in var names
--        put true into tFlag
--      end if
--      put colNum+1 into colNum
--      write tempVar & "_" & setcount && "=" && shortDataFileName & "(:," & colNum & ");" & return to file longMFileName
--    end if
--  end repeat
--  write "clear " & shortDataFileName & return to file longMFileName  # save RAM & allow user to edit and re-run m-file with same name
--  put labNumber && labCardName into temp
--  put stripOuterSpace(temp) into temp
--  write "fprintf('\nthe data loaded are from" && temp & ", Data Set" && setCount & " \n')" & return to file longMFileName
--  repeat with i = 1 to varCount
--    if item i of dataSwitch > 1 then
--      put item i of dataHeaders into tempVar
--      if "~`!@#$%^&*+='?/\|<>" contains the last char of tempVar then
--        delete the last char of tempVar  # MATLAB can't handle special chars in var names
--        put true into tFlag
--      end if
--      write "fprintf('data in array: " && tempVar & "_" & setcount & " \n')" & return to file longMFileName
--    end if
--  end repeat
--  if tFlag is false then
--    write "fprintf('See m-file comments for units and values remaining constant. \n\n')" & return to file longMFileName
--  else
--    write "fprintf('See m-file comments for units and values remaining constant. \n')" & return to file longMFileName
--    write "fprintf('Special characters denoting values at reference \n')" & return to file longMFileName
--    write "fprintf('conditions (e.g., STP) have been deleted from variable names. \n\n')" & return to file longMFileName
--  end if
--  close file longMFileName
--  put getNextSetCount() into nextSetCount
--  put "Export of Data Set " & setCount & " is complete.  Two files were saved." into temp
--  put LF & LF & "The data are in file '" after temp
--  put shortDataFileNameTXT  & "' in the folder '" & currentDataFolderName & "' in the 'data_folder'." after temp
--  put LF & LF & "The MATLAB m-file to load and label the data is '" & shortMFileName & "'." after temp
--  put LF & LF & "The Data Set number will be incremented to " & nextSetCount & "." after temp
--  setInfo empty
--  answer temp
end exportMATLAB

# ---------------

-- -- KEEP THIS COMMENTED COPY FOR POSSIBLE USE LATER
on exportTWO
--  global labType, setCount, varCount, dataHeaders
--  global dataUnits, dataSwitch, dataArray, labCardName, labNumber
--  global pathTOapp, pathTOtemps
--  global pathTOdata, pathTOcurrent, currentDataFolderName
--  global quizLabel
--  put return into recordDelim
--  put tab into fieldDelim
--  # first write the data file
--  # naming format here should match that in start recording/saving data in Dynamic Labs
--  put pathTOcurrent & "/" & labNumber & "_" & setCount & "_two.txt" into thisFileName
--  open file thisFileName
--  repeat with i = 1 to (varCount - 1)
--    if item i of dataSwitch > 1 then
--      write item i of dataHeaders & "_" & setCount & tab to file thisFileName
--    end if
--  end repeat
--  if item varCount of dataSwitch > 1 then
--    write item varCount of dataHeaders & "_" & setCount to file thisFileName
--  end if
--  write return to file thisFileName
--  put the number of lines in dataArray into lineCount
--  repeat with j = 1 to lineCount
--    set cursor to busy
--    repeat with i = 1 to (varCount - 1)
--      if item i of dataSwitch > 1 then
--        write sciNote(item i of line j of dataArray,"no","yes") & fieldDelim to file thisFileName
--      end if
--    end repeat
--    if item varCount of dataSwitch > 1 then
--      write sciNote(item varCount of line j of dataArray,"no","yes") to file thisFileName
--    end if
--    write recordDelim to file thisFileName
--  end repeat
--  close file thisFileName
--  # now write the header file
--  # naming format here should match that in start recording/saving data in Dynamic Labs
--  put pathTOcurrent & "/" & labNumber & "_" & setCount & "_two_head.txt" into HfileName
--  open file HfileName
--  put labNumber && labCardName into thisTempName
--  put stripOuterSpace(thisTempName) into thisTempName
--  if "Q" is in labType then
--    put stripOuterSpace(thisTempName && "Quiz") into thisTempName
--  end if
--  write thisTempName & ", Data Set" && setCount & return to file HfileName
--  if "Q" is in labType then
--    put "Current Quiz Letter:  "  & numTOchar(quizLabel+64) & return into temp
--    put "The code for a quiz changes each time you supply a correct answer." & return after temp
--    put "Always re-enter an unfinished quiz with the code recorded in the" & return after temp
--    put "Budget Report when you LAST LEFT the quiz in your last session." & return after temp
--    write temp to file HfileName
--  end if
--  write return to file HfileName
--  repeat with i = 1 to varCount
--    if item i of dataSwitch = 0 then
--      write item i of dataHeaders & "_" & setCount to file HfileName
--      write " remained constant at " to file HfileName
--      if item i of line 1 of dataArray is a number then
--        write sciNote(item i of line 1 of dataArray) & space to file HfileName
--      else
--        write item i of line 1 of dataArray & space to file HfileName
--      end if
--      write line i of dataUnits & return to file HfileName
--    end if
--  end repeat
--  repeat with i = 1 to varCount
--    if item i of dataSwitch > 1 then
--      write item i of dataHeaders & "_" & setCount to file HfileName
--      write " has units of " to file HfileName
--      write line i of dataUnits & return to file HfileName
--    end if
--  end repeat
--  write return to file HfileName
--  close file HfileName
--  put labNumber & "_" & setCount & "_two.txt" into thisFileName
--  put labNumber & "_" & setCount & "_two_head.txt" into HfileName
--  put getNextSetCount() into nextSetCount
--  put "Export of Data Set " & setCount & " is complete." into temp
--  put return & return & "Two files were saved.  The tab-delimited data are in the file '" after temp
--  put thisFileName & "'" & LF & "in the folder '" & currentDataFolderName & "' in the 'data_folder'." after temp
--  put LF & LF &  "The experimental conditions are in the file '" & HfileName &   "'." after temp
--  put return & return & "The Data Set number will be incremented to " & nextSetCount & "." after temp
--  setInfo empty
--  answer temp
end exportTWO

# ---------------
