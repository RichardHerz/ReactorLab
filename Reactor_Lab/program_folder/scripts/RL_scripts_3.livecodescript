script "RL scripts 3"
# The Reactor Lab stack designs and all scripts copyright 1996-2005
# PureWaterLab stack designs and scripts copyright 2005
# by Richard K. Herz, all rights reserved.

# ----------------------

on plotRectInfo
  
  global runCount
  global specialPoints
  global labType
  
  if runCount > 0 then
    if "S" is in labType then
      if specialPoints is not empty then
        setInfo "Solid dots are stationary states; open circles are oscillatory states; the last run's point is larger and colored."
      else
        if runCount > 1 then
          setInfo "The point for the most recent run is colored and larger than points for previous runs."
        end if
      end if
    end if
  else
    setInfo empty
  end if
  
end plotRectInfo

# ----------------------

on plotRefresh
  global labTitle, runCount, varCount, dataArray, dataHeaders, xVarNum, yVarNum, OLDxVarNum, OLDyVarNum
  global yVar, xVar, xMax, yMax, plotPaint, yLegend, xLegend, xOrigin, yOrigin, dataMinMax, labType
  global xZero, yZero, xSpan, ySpan
  if "D" is in labType or "R" is in labType then exit plotRefresh  # Dynamic or RTD (in/out)
  if item yVarNum of dataHeaders = "n" then put OLDyVarNum into yVarNum
  if item xVarNum of dataHeaders = "n" then put OLDxVarNum into xVarNum
  setInfo "Plotting..."
  put "true" into plotPaint
  put item xVarNum of line runCount of dataArray into xVar
  put item yVarNum of line runCount of dataArray into yVar
  if xVarNum <> OLDxVarNum then
    put "true" into wantNewPlot
  else if yVarNum <> OLDyVarNum then
    put "true" into wantNewPlot
  else if (xVar > xMax) AND (xVar > 0.0000000000000000001) then
    put "true" into wantNewPlot
  else if (yVar > yMax) AND (yVar > 0.0000000000000000001) then
    put "true" into wantNewPlot
  else if (xVar <= xOrigin) AND (xVar > 0.0000000000000000001) then
    put "true" into wantNewPlot
  else if (yVar <= yOrigin) AND (yVar > 0.0000000000000000001) then
    put "true" into wantNewPlot
  else if runCount = 1 then
    put "true" into wantNewPlot
  else if "P" is in labType or "R" is in labType then
    put "true" into wantNewPlot
  end if
  if wantNewPlot = "true" then
    plotAllPoints
  else
    plotOnePoint
  end if
end plotRefresh

# ----------------------

on plot_X_button
  global labType, varCount, outputCount
  global runCount, xVarNum, replot, dataHeaders, dataArray
  global OLDxVarNum
  if OLDxVarNum is empty then put xVarNum into OLDxVarNum
  put the selectedLine of button "plot x button" into temp
  delete char 1 to 5 of temp
  put char 1 to 2 of temp into temp
  put stripSpace(temp) into temp
  put line temp of button "plot x button" into varName
  if varName = "n" then
    set the label of button "plot x button" to item OLDxVarNum of dataHeaders
    answer "Sorry.  The reaction order can't be plotted. "
    exit plot_X_button
  end if
  repeat with i = 1 to the number of items in dataHeaders
    if varName = item i of dataHeaders then
      put i into varNum
      exit repeat
    end if
  end repeat
  if item varNum of line 1 of dataArray contains "?" then
    set the label of button "plot x button" to item OLDxVarNum of dataHeaders
    answer "Sorry.  This variable can't be plotted."
    exit plot_X_button
  end if
  if "P" is in labType or "R" is in labType then
    put (varCount - outputCount + temp) into temp
  end if
  if (runCount < 1) then
    answer "No data to plot.  Please make a run first."
    exit plot_X_button
  else if (temp = xVarNum) then
    exit plot_X_button
  else
    setInfo "Plotting..."
    set the label of button "plot x button" to the selectedText of button "plot x button"
    put temp into xVarNum
    plotAllPoints
    put "true" into replot -- for plot stack refresh
  end if
end plot_X_button

# ----------------------

on plot_Y_button
  global labType, varCount, outputCount
  global runCount, yVarNum, dataHeaders, replot, dataArray
  global OLDyVarNum
  if OLDyVarNum is empty then put yVarNum into OLDyVarNum
  put the selectedLine of button "plot y button" into temp
  delete char 1 to 5 of temp
  put char 1 to 2 of temp into temp
  put stripSpace(temp) into temp
  put line temp of button "plot y button" into varName
  if varName = "n" then
    set the label of button "plot y button" to item OLDyVarNum of dataHeaders
    answer "Sorry.  The reaction order can't be plotted. "
    exit plot_Y_button
  end if
  repeat with i = 1 to the number of items in dataHeaders
    if varName = item i of dataHeaders then
      put i into varNum
      exit repeat
    end if
  end repeat
  if item varNum of line 1 of dataArray contains "?" then
    set the label of button "plot y button" to item OLDyVarNum of dataHeaders
    answer "Sorry.  This variable can't be plotted."
    exit plot_Y_button
  end if
  if "P" is in labType or "R" is in labType then
    put (varCount - outputCount + temp) into temp
  end if
  if (runCount < 1) then
    answer "No data to plot.  Please make a run first."
    exit plot_Y_button
  else if (temp = yVarNum) then
    exit plot_Y_button
  else
    setInfo "Plotting..."
    set the label of button "plot y button" to the selectedText of button "plot y button"
    put temp into yVarNum
    plotAllPoints
    put "true" into replot -- for plot cd refresh
  end if
end plot_Y_button

# ----------------------

on plotOnePoint
  global runCount, dataHeaders, xVarNum, yVarNum, OLDxVarNum, OLDyVarNum
  global yVar, xVar, xMax, yMax, xOrigin, yOrigin
  global xZero, yZero, xSpan, ySpan, plotGraphicCount
  global labType
  if (xMax < 0.0000000000000000001)  or (yMax < 0.0000000000000000001) then
    # xxx need to catch and handle this like I do in plotAllPoints
    # xxx for now, just call plotAllPoints
    plotAllPoints
    exit plotOnePoint
  end if
  if (xMax - xOrigin) > 0 then
    put xZero + round((xVar - xOrigin)*xSpan/(xMax - xOrigin)) into xVar
  else
    put xZero  into xVar
  end if
  if (yMax - yOrigin) > 0 then
    put yZero - round((yVar - yOrigin)*ySpan/(yMax - yOrigin)) into yVar
  else
    put yZero into yVar
  end if
  set the cantAbort of this stack to "true"
  set the lockScreen to true
  set the style of the templateGraphic to "rectangle"
  if labType contains "S" then
    # make previous point standard symbol, make new point special
    put "plotPoint" & plotGraphicCount into thisPoint
    if there is a graphic thisPoint then
      set the foregroundColor of graphic thisPoint to "black"
      set the filled of graphic thisPoint to "false"
      put the loc of graphic thisPoint into temp # make sure loc doesn't shift!
      set the height of graphic thisPoint to 2
      set the width of graphic thisPoint to 2
      set the loc of graphic thisPoint to temp
    end if
    set the height of the templateGraphic to 3
    set the width of the templateGraphic to  3
    set the foregroundColor of the templateGraphic to "255, 51, 51"
    set the backgroundColor of the templateGraphic to "255, 51, 51"
    set the filled of the templateGraphic to "true"
  else
    set the height of the templateGraphic to 2
    set the width of the templateGraphic to  2
  end if
  put "plotPoint" & runcount into thisPoint
  create graphic thisPoint
  add one to plotGraphicCount
  if (yVar <= yZero-1) AND (yVar >= (yZero - ySpan)) AND (xVar >= xZero+1) AND (xVar <= (xZero + xSpan)) then
    set the location of graphic thisPoint to xVar, yVar
  else
    # need to create and place a graphic for all runCount numbers
    set the location of graphic thisPoint to -2, -2  # put it off window top left corner
  end if
  reset the templateGraphic
  choose browse tool
  set the lockScreen to false
  set the cantAbort of this stack to "false"
  setInfo empty
end plotOnePoint

# ----------------------

# NOTE THAT plotAllPoints is very similar to plotPoints in Plot stack
# so consider making same changes in both places

on plotAllPoints
  global runCount, dataArray, dataHeaders, labType
  global xVarNum, yVarNum, OLDxVarNum, OLDyVarNum, yVar, xVar
  global yLegend, xLegend, xOrigin, yOrigin, xMax, yMax
  global xZero, yZero, xSpan, ySpan, plotGraphicCount
  set the label of button "plot y button" to item yVarNum of dataHeaders
  set the label of button "plot x button" to item xVarNum of dataHeaders
  put item xVarNum of dataHeaders into xLegend
  put item yVarNum of dataHeaders into yLegend
  put empty into yVar
  put empty into xVar
  repeat with j = 1 to runCount
    # 7-Mar-2005, modify to allow "INF" for fuel cell external resistance
    if (item xVarNum of line j of dataArray is a number) and\
    (item yVarNum of line j of dataArray is a number) then
      put item xVarNum of line j of dataArray into item j of xVar
      put item yVarNum of line j of dataArray into item j of yVar
    else
      put -1 into item j of xVar
      put -1 into item j of yVar
    end if
  end repeat
  put max(yVar) into yMax
  put max(xVar) into xMax
  # var names starting with x and "cvn" and "conv" reserved for fractional conversion
  put "no" into flag
  if char 1 of item yVarNum of dataHeaders is "x" then put "yes" into flag
  put item yVarNum of dataHeaders into temp
  if temp is "cvn" or temp is "conv" then put "yes" into flag
  if (flag is "yes") AND (yMax > 0.5) then
    put 1.0 into yMax
  else
    put yMax into yMax
  end if
  put "no" into flag
  if char 1 of item xVarNum of dataHeaders is "x" then put "yes" into flag
  put item xVarNum of dataHeaders into temp
  if temp is "cvn" or temp is "conv" then put "yes" into flag
  if (flag is "yes") AND (xMax > 0.5) then
    put 1.0 into xMax
  else
    put xMax into xMax
  end if
  # variable name starting with capital T are reserved for temperature
  if charToNum(char 1 of item xVarNum of dataHeaders) is charToNum("T") then
    put minTset(min(xVar)) into xOrigin
    put maxTset(max(xVar)) into xMax
    if xOrigin is xMax then
      add 5 to xMax
      subtract 5 from xOrigin
    end if
  else
    put zero into xOrigin
  end if
  if charToNum(char 1 of item yVarNum of dataHeaders) is charToNum("T") then
    put minTset(min(yVar)) into yOrigin
    put maxTset(max(yVar)) into yMax
    if yOrigin is yMax then
      add 5 to yMax
      subtract 5 from yOrigin
    end if
  else
    put zero into yOrigin
  end if
  set the cantAbort of this stack to "true"
  set the lockScreen to true
  # clear plot of all points
  repeat with i = 1 to plotGraphicCount
    put "plotPoint" & i into thisPoint
    # do a repeat to delete any duplicates, though shouldn't be any
    repeat 10 times # put arbitrary limit so don't get stuck
      if there is a graphic thisPoint then
        delete graphic thisPoint
      else
        exit repeat
      end if
    end repeat
  end repeat
  put zero into plotGraphicCount
  if (xMax < 0.0000000000000000001) then
    put zero into field "xMin Legend"
    put empty into field "xMax Legend"
    set the lockscreen to "false"
    setInfo "The maximum x value is zero or negative.  Zero and negative values are not plotted here."
    wait 2 seconds
    set the lockscreen to "true"
    put "true" into negFlag
  else
    put sciNote(xOrigin,"yes","yes") into field "xMin Legend"
    put sciNote(xMax,"yes","yes") into field "xMax Legend"
  end if
  if (yMax < 0.0000000000000000001) then
    put zero into field "yMin Legend"
    put empty into field "yMax Legend"
    if negFlag is not "true" then  # don't repeat warning if xMax was also negative
      set the lockscreen to "false"
      setInfo "The maximum y value is zero or negative.  Zero and negative values are not plotted here."
      wait 2 seconds
      set the lockscreen to "true"
    end if
    put "true" into negFlag
  else
    put sciNote(yOrigin,"yes","yes") into field "yMin Legend"
    put sciNote(yMax,"yes","yes") into field "yMax Legend"
  end if
  #  if you need to redraw axes, use the handler "plotAxes"
  set the style of the templateGraphic to "rectangle"
  set the height of the templateGraphic to 2
  set the width of the templateGraphic to 2
  if negFlag is "true" then
    # set all points off window
    repeat with j = 1 to runCount
      # need to create and place a graphic for all runCount numbers
      put "plotPoint" & j into thisPoint
      create graphic thisPoint
      add one to plotGraphicCount
      set the location of graphic thisPoint to -2, -2  # put it off window top left corner
    end repeat
  else
    repeat with j = 1 to runCount
      put item j of xVar into temp
      if (xMax - xOrigin) > 0 then
        put xZero + round((temp - xOrigin)*xSpan/(xMax - xOrigin)) into xPt
      else
        put xZero  into xPt
      end if
      put item j of yVar into temp
      if (yMax - yOrigin) > 0 then
        put yZero - round((temp- yOrigin)*ySpan/(yMax - yOrigin)) into yPt
      else
        put yZero into yPt
      end if
      put "plotPoint" & j into thisPoint
      create graphic thisPoint
      add one to plotGraphicCount
      if (yPt <= yZero-1) AND (yPt >= (yZero - ySpan)) AND (xPt >= xZero+1) AND (xPt <= (xZero + xSpan)) then
        set the location of graphic thisPoint to xPt, yPt
      else
        # need to create and place a graphic for all runCount numbers
        set the location of graphic thisPoint to -2, -2  # put it off window top left corner
      end if
    end repeat
  end if
  if labType contains "S" then
    # mark last point special
    put the loc of graphic thisPoint into temp  # make sure loc doesn't shift!
    set the height of graphic thisPoint to 3
    set the width of graphic thisPoint to 3
    set the foregroundColor of graphic thisPoint to "255, 51, 51"
    set the backgroundColor of graphic thisPoint to "255, 51, 51"
    set the filled of graphic thisPoint to "true"
    set the loc of graphic thisPoint to temp
  else  end if
  reset templateGraphic
  put yVarNum into OLDyVarNum
  put xVarNum into OLDxVarNum
  choose browse tool
  set the lockScreen to false
  set the cantAbort of this stack to "false"
  if negFlag is not "true" then
    setInfo empty
  end if
end plotAllPoints

# ----------------------

function minTset theT
  put the trunc of theT into minT
  put the last char of minT into temp
  if temp is in "1234" then
    put 0 into the last char of minT
  else if temp is in "6789" then
    put 5 into the last char of minT
  else if temp is "0" then
    subtract 5 from minT
  else if temp is "5" then
    subtract 5 from minT
  end if
  return minT
end minTset

# ----------------------

function maxTset theT
  if theT is an integer and the last char of theT is 5 then
    return theT
  end if
  put theT + 0.5 into maxT
  put round (maxT) into maxT
  put the last char of maxT into temp
  if temp is zero then
    -- do nothing
  else if temp is in "12345" then
    put 5 into the last char of maxT
  else if temp is in "6789" then
    put zero into the last char of maxT
    add 10 to maxT
  end if
  return maxT
end maxTset

# ----------------------

on plotAxes
  
  global xZero, yZero, xSpan, ySpan
  
  if there is a button "plot rect" then
    
    put the rect of button "plot rect" into thisRect
    put item 1 of thisRect into xZero  # top left x
    put item 2 of thisRect into yMin  # top left y
    put item 3 of thisRect into xMax  # btm right x
    put item 4 of thisRect into yZero # btm right y
    put xMax - xZero into xSpan
    put yZero - yMin into ySpan
    
    set the style of the templateGraphic to "polygon"
    
    if there is not a graphic "y axis" then
      create graphic "y axis"
    end if
    set the points of graphic "y axis" to xZero &","& yZero &return& xZero &","& yMin
    
    if there is not a graphic "x axis" then
      create graphic "x axis"
    end if
    set the points of graphic "x axis" to xZero &","& yZero &return& xMax &","& yZero
    
    if there is not a graphic "y origin tick" then
      create graphic "y origin tick"
    end if
    set the points of graphic "y origin tick" to xZero &","& yZero &return& xZero-4 &","& yZero
    
    if there is not a graphic "y top tick" then
      create graphic "y top tick"
    end if
    set the points of graphic "y top tick" to xZero &","& yMin &return& xZero-4 &","& yMin
    
    if there is not a graphic "x origin tick" then
      create graphic "x origin tick"
    end if
    set the points of graphic "x origin tick" to xZero &","& yZero &return& xZero &","& yZero+4
    
    if there is not a graphic "x max tick" then
      create graphic "x max tick"
    end if
    set the points of graphic "x max tick" to xMax &","& yZero &return& xMax &","& yZero+4
    
    choose browse tool
    
    reset templateGraphic
    
  else
    answer "no button 'plot rect', exiting plotAxes "
    exit plotAxes
  end if
  
end plotAxes

# ----------------------

on plotClear
  global labNumber, labCardName, labType, labInitialize, plotPaint
  global xZero, yZero, xSpan, ySpan, plotGraphicCount
  if "S" is in labType or "P" is in labType then
    put "false" into plotPaint
    setInfo "Clearing old plot..."
    set the lockScreen to true
    set the cantAbort of this stack to true
    put labInitialize into OLDinitialize
    put "false" into labInitialize -- so won't add bpc ending to setCount when going to lab
    push this card
    if labType is "S" then -- Single pt
      -- xxx this needs work, maybe use showLabButton and showQuiz
      if labCardName is empty then
        go cd 1
      else
        go cd labCardName
      end if
    else if "Q" is in labType then
      go cd labCardName && "Quiz"
    end if
    repeat with i = 1 to plotGraphicCount
      put "plotPoint" & i into thisPoint
      # do a repeat to delete any duplicates, though shouldn't be any
      repeat 10 times # put arbitrary limit so don't get stuck
        if there is a graphic thisPoint then
          delete graphic thisPoint
        else
          exit repeat
        end if
      end repeat
    end repeat
    put zero into plotGraphicCount
    if there is a field "OLD PLOT" then put empty into field "OLD PLOT" -- labType "P" Profile
    set the lockScreen to false
    set the cantAbort of this stack to "false"
    pop cd
    put OLDinitialize into labInitialize
    setInfo empty
  end if
end plotClear

# ----------------------

on plotReset
  
  -- xxx NOTE:  should all this be done in stack script of plot stack
  -- where plotReset is called, maybe just set plotResetFlag and
  -- get rid of this handler?  BUT ITS CALLED IN LEAVELAB HANDLER TOO!!!!
  -- BUT CURRENTLY THIS IS CALLED IN INITINIT OF OPENING OF MAIN STACK!!!!!!!!
  -- Remember stuff in plot stack only done when that stack opened.
  
  global setPlotted
  global lastVar, oldLastVar
  global plotList, listFile
  global plotResetFlag
  global plotGraphicCount
  
  put zero into setPlotted
  put zero into lastVar
  put zero into oldLastVar
  put empty into plotList -- xxx check stack script of plot stack
  put empty into listFile -- xxx check stack script of plot stack
  
  put "clear" into plotResetFlag
  
  repeat with i = 1 to plotGraphicCount
    put "plotPoint" & i into thisPoint
    # do a repeat to delete any duplicates, though shouldn't be any
    repeat 10 times # put arbitrary limit so don't get stuck
      if there is a graphic thisPoint then
        delete graphic thisPoint
      else
        exit repeat
      end if
    end repeat
  end repeat
  put zero into plotGraphicCount
  if there is a field "OLD PLOT" then
    put empty into field "OLD PLOT"
  end if
  
end plotReset

# ----------------------

on initLabStart
  global setCount, runCount, labType, warnSetSave, firstQuizRun
  
  global gHistory, labNumber, labCardName # new for net version
  if labType contains "Q" then
    put "quiz" into temp
  else
    put empty into temp
  end if
  put the long time & ", enter" && the short name of this stack && labCardName && temp & LF after gHistory
  
  set cursor to watch
  setInfo "Initializing this lab..."
  setSet setCount
  displayRuns runCount
  saveSetBtn "hide"
  emptyRightFlds
  if "D" is in labType or "R" is in labType then
    -- Dynamic or RTD (in/out)
    -- do nothing
  else
    plotAxes
    if there is a field "xMax Legend" then
      put empty into field "xMax Legend"
      put empty into field "xMin Legend"
      put empty into field "yMax Legend"
      put empty into field "yMin Legend"
    end if
  end if
  if "P" is in labType or "R" is in labType or "D" is in labType then
    -- Profile, RTD (in/out), Dynamic
    put "false" into warnSetSave
  else
    put "true" into warnSetSave
  end if
  if "Q" is in labType then
    put "no" into firstQuizRun
  end if
end initLabStart

# ----------------------

on initLabFinish varNum, inputCount, xVarNum, yVarNum
   
   -- add lock screen 20140802 LC v7.0dp8, plot axis button labels showed all being loaded on enter lab
   -- also add unlock screen at end this handler
   lock screen 
   
   #  total number variables, number input variables, first x and y variables to plot
   global varCount, outputCount, dataSwitch
   global labType, dataHeaders, labInitialize
   put varNum into varCount -- total number of input and output variables
   put (varCount - inputCount) into outputCount
   if (outputCount > 6) and ("P" is in labType) then -- Profile
      answer "More than 6 output variables.  Not all can be displayed in the Table."
   end if
   put empty into dataSwitch
   repeat with i = 1 to varCount
      put zero into item i of dataSwitch
   end repeat
   if outputCount > zero then
      # switch output variables on
      repeat with i = (varCount + 1 - outputCount) to varCount
         put 9 into item i of dataSwitch -- 9 is a flag number, don't change
      end repeat
   end if
   dataSwitchReset
   if "D" is in labType or "R" is in labType then
      # do nothing, Dynamic or RTD (in/out)
   else
      set the label of button "plot y button" to empty
      set the label of button "plot x button" to empty
      put empty into button "plot y button"
      put empty into button "plot x button"
      if "P" is in labType then
         -- Profile
         put (varCount - outputCount + 1) into b
      else
         put 1 into b
      end if
      put zero into temp
      repeat with j = b to varCount
         add one to temp
         put item j of dataHeaders into line temp of button "plot y button"
         put item j of dataHeaders into line temp of button "plot x button"
      end repeat
      
      # xxx starting with MC 2.5 betas, having problem with labels of plot buttons
      # if set to 1 char label, get button name displayed instead of label
      # problem may have to do because these stacks were originally HyperCard stacks
      # problem persists even with hcAddressing set to false and all refs to "card" and "bg" removed
      # from refs to buttons and fields and delete and create new buttons
      # fix for now by first setting the labels to empty
      set the label of button "plot y button" to empty
      set the label of button "plot x button" to empty
      set the label of button "plot y button" to item yVarNum of dataHeaders
      set the label of button "plot x button" to item xVarNum of dataHeaders
      
      # set the menuLines so most or all items show in Win without scrolling list
      if number of lines of button "plot y button" <= 10 then
         set the menuLines of button "plot y button" to the number of lines of button "plot y button"
         set the menuLines of button "plot x button" to the number of lines of button "plot x button"
      else
         set the menuLines of button "plot y button" to 10
         set the menuLines of button "plot x button" to 10
      end if
   end if
   put "false" into labInitialize
   
   # xxx new for net version
   # In original version, stacks kept in RAM so announceText about
   # clicking info button only appeared first time a lab was entered in a session
   # Now with net version, stack is purged from RAM on close, so announceText
   # will appear on every entry into every lab
   # So change the custom property setting so annouceText only appears once in entire session
   if the cFirstLabEntry of stack "Directory" is not "true" then
      # don't interfere with lab module announceText
      set the cFirstLabEntry of stack "Directory" to "true"
   else
      # change "customFirstEntry" setting in lab module stack
      # so don't show announceText
      set the customFirstEntry of this stack to "true"
   end if
   
   unlock screen
   
end initLabFinish
