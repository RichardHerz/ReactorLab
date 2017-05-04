script "confer scripts"
# by Richard K. Herz <rherz@ucsd.edu>  May 2001
# revised October 2002
# revised February 2003
# revised May-August 2003 engine startUp in "engine" stack
# revised March-April 2004 changed from many cgi posts to socket communications
-- December 16, 2016 - move logHistory command to stack comm_scripts.livecode

global gPathToEngine
global gPathToEngineFolder

global gHistory
global gConnectStatus # set by on/off line buttons in Directory
global gSelfHeal
global gCheckOnStartup

# used below, originally from MetaCard download stack
local stime
local cancelled 
local localGUIname

# new for net
local lStartTicks
local lChatPortNumber # set at top of openChatSocketRequest

local lReservedNickName

# ------------- new version of chat socket -------------------

global gChatSocket
global gChatFlag
global gChatFlagCount
global gChatMessages
global gConferStackPath
global gPostNotice

local lStartSeconds

# -----------------------------------

on openChatConnection
   
   if the environment is "development" then
      put "enter openChatConnection in confer scripts" & LF after msg
   end if
   
   # xxx exit openChatConnection # zzz disables chat
   if gChatSocket is not empty then
      # should have an active connection already
      
      if the environment is "development" then
         put "just before exit openChatConnection with if gChatSocket is not empty is true in confer scripts" & LF after msg
      end if
      
      exit openChatConnection
   end if
   put empty into gChatSocket
   put "false" into gChatFlag
   put 0 into gChatFlagCount
   
   # assume server stack already open and try to connect
   # with chatserver stack on eMac - the chatserver stack on eMac has to be running or can't chat
   
   put the ticks into lStartTicks
   
   if the environment is "development" then
      put "just before openChatSocketRequest in openChatConnection in confer scripts" & LF after msg
   end if
   
   openChatSocketRequest
   
   if the environment is "development" then
      put "just after openChatSocketRequest in openChatConnection in confer scripts" & LF after msg
   end if
   
   put "Opening conference connection. This should take about 20 seconds..." & LF into field "log" of stack gConferStackPath
   put "(if nothing new appears here after that time and you have a good" & LF after field "log" of stack gConferStackPath
   put "connection, try clicking off line button then on line button again)" & LF & LF after field "log" of stack gConferStackPath
   #  if the environment is "development" then
   #    put the ticks - lStartTicks into tTicksElapsed
   #    put tTicksElapsed && "in openChatConnection, openChatSocketRequest sent" & LF & LF after field "log" of stack gConferStackPath
   #  end if
   
   if the environment is "development" then
      put "in openChatConnection in confer scripts JUST BEFORE send openChatConnection01 to me in 2000 milliseconds" & LF after msg
   end if
   
   # need to wait to so that gChatFlag can be set if connection made
   send openChatConnection01 to me in 2000 milliseconds # was 1500
   
   if the environment is "development" then
      put "at end openChatConnection in confer scripts and after send openChatConnection01 to me " & LF after msg
   end if
   
end openChatConnection

on openChatConnection01
   
   if the environment is "development" then
      put "enter openChatConnection01 in confer scripts" & LF after msg
   end if
   
   # check to see if chat connection has been made
   # if not, send openChatConnection02 after some wait interval at bottom
   
   # xxx actually, assuming chatserver on eMac is active but there is
   # xxx something preventing chat socket to be opened on first try
   # xxx do I need to KILL any previous openChatSocketRequest messages which may be pending
   # xxx so that don't get multiple sockets opened or someother screwup??????
   
   #  if the environment is "development" then
   #    put the ticks - lStartTicks into tTicksElapsed
   #    put tTicksElapsed && "in openChatConnection01, gChatFlag = " & gChatFlag & LF & LF after field "log" of stack gConferStackPath
   #  end if
   if gChatFlag is "true" then
      
      if the environment is "development" then
         put "just before exit  openChatConnection01 in confer scripts because gChatFlag is true" & LF after msg
      end if
      
      # server stack already open
      #    if the environment is "development" then
      #      put the ticks - lStartTicks into tTicksElapsed
      #      put tTicksElapsed && "exit openChatConnection01" & LF & LF after field "log" of stack gConferStackPath
      #    end if
      exit openChatConnection01
   end if
   
   ## --------------------------------------------
   ## below commented-out from older version where had all on RL ISP web host
   ## and used post to cgi to wake up Rev chat server stack
   
   #  # zzz
   #  put gPathToEngineFolder into tSplashStackPath
   #  put "/program_folder/scripts/message_connect.rev" after tSplashStackPath
   #  go stack tSplashStackPath # splash to notify user
   #  setInfo "Please wait while the message connection is established."
   #  
   #  # server stack apparently not already open
   #  # send post to CGI script to open server stack
   #  # APPARENTLY NOW NEED TEXT/HTML - TEXT/PLAIN DOESNT WORK NOW APPARENTLY
   #  set the httpHeaders to "Content-type: text/html" & LF & LF
   #  set cursor to watch
   #  put "posting" into gPostNotice # post here interferes with getting div and lab lists in Directory
   #  
   #  try
   #    
   #    # post urlEncode("startChat") to url "http://reactorlab.net/cgi-bin/chatCGI.mt"
   #    # now change to chat server at my office eMac
   #    post urlEncode("startChat") to url "http://132.239.191.51/cgi-bin/chatCGI.mt"
   #    
   #  catch errNum
   #  end try
   #  close stack tSplashStackPath
   #  put empty into gPostNotice
   #  setInfo empty
   
   #  if the environment is "development" then
   #  put the ticks - lStartTicks into tTicksElapsed
   #  put tTicksElapsed && "in openChatConnection01, post to CGI sent" & LF & LF after field "log" of stack gConferStackPath
   #  end if
   ## --------------------------------------------
   
   # make more attempts to open chat connection
   send openChatConnection02 to me in 2000 milliseconds # was 1500
   
   if the environment is "development" then
      put "at end openChatConnection01 in confer scripts" & LF after msg
   end if
   
end openChatConnection01

on openChatConnection02
   
   if the environment is "development" then
      put "at start openChatConnection02 in confer scripts" & LF after msg
   end if
   
   if gChatFlag is "true" then
      exit openChatConnection02
      #    if the environment is "development" then
      #      put the ticks - lStartTicks into tTicksElapsed
      #      put tTicksElapsed && "in openChatConnection02, gChatFlag is true" & LF & LF after field "log" of stack gConferStackPath
      #    end if
   else
      add 1 to gChatFlagCount
      openChatSocketRequest
      #    if the environment is "development" then
      #      put the ticks - lStartTicks into tTicksElapsed
      #      put tTicksElapsed && "in openChatConnection02, openChatSocketRequest sent, gChatFlagCount = "\
             #          & gChatFlagCount & LF & LF after field "log" of stack gConferStackPath
      #    end if
   end if
   if gChatFlagCount > 5 then
      #    if the environment is "development" then
      #      put the ticks - lStartTicks into tTicksElapsed
      #      put tTicksElapsed && "in openChatConnection02, can't seem to connect, chatCount > 5"\
          #          & LF & LF after field "log" of stack gConferStackPath
      #    end if
      # notify user
      put "Sorry, can't connect to conference room server!" & LF & LF after field "log" of stack gConferStackPath
   else
      send openChatConnection02 to me in 2000 milliseconds # was 1500
   end if
   
   if the environment is "development" then
      put "at end openChatConnection02 in confer scripts" & LF after msg
   end if
   
end openChatConnection02

on openChatSocketRequest
  
  put "1948" into lChatPortNumber
  
  # IP address is that of server, :1987 is port number
  # PORT NUMBER USED BY CLIENT STACKS MUST AGREE WITH PORT NUMBER USED BY SERVER STACK
  # IP address of reactorlab.net on 27-Mar-2004 was 69.73.151.143
  # open socket "69.73.151.143:1987" with message "openChatSocketConfirmed"
  # xxx may have problem of url lookup in libURL hanging if no net connection
  # xxx if use domain name instead of IP address
  
  # open socket "reactorlab.net:1985" with message "openChatSocketConfirmed"
  
  -- put "132.239.191.51:" & lChatPortNumber into tSocketToOpen -- NOTE COLON AT END! - MAE
  put "137.110.112.103:" & lChatPortNumber into tSocketToOpen -- NOTE COLON AT END! - NE in Atkinson
  open socket tSocketToOpen with message "openChatSocketConfirmed"
  
#  if the environment is "development" then
#    put the ticks - lStartTicks into tTicksElapsed
#    put tTicksElapsed && "in openChatSocketRequest" & LF & LF after field "log" of stack gConferStackPath
#  end if
end openChatSocketRequest

on openChatSocketConfirmed s
  # set the label of button "connect" to "disconnect"
  put s into gChatSocket
  # s should be the IP address and port of the server
  # and should be same as that supplied in chatConnect handler
  # and its open socket command
  put "true" into gChatFlag
  if the environment is "development" then
    #    put the ticks - lStartTicks into tTicksElapsed
    #    put tTicksElapsed && "in openChatSocketConfirmed, s = " & s & LF & LF after field "log" of stack gConferStackPath
  else
    put empty into field "log" of stack gConferStackPath
  end if
  
  # for now don't worry about timing, assume they get queued
  send sendChatJoinRequest to me in 20 ticks
  put the long time & ", confirm socket opened with server " & s & LF after gHistory
  send logHistory to me in 40 ticks
  
  # assume stack "Directory" is in the windows
  put 0 into gChatMessages
  put gChatMessages into field "conferees" of card "dir" of stack "Directory"
  put gChatMessages into field "conferees" of stack gConferStackPath
  put the windows into tWindows
  repeat with i = 1 to the number of lines in tWindows
    put line i of tWindows into tWin
    if there is a field "conferees" of stack tWin then
      put gChatMessages into field "conferees" of stack tWin
    end if
  end repeat
  
  send updateConnectDisplay to me in 20 ticks
  # get ready to receive messages from server
  read from socket s with message "receiveChatAtClient"
end openChatSocketConfirmed

on receiveChatAtClient s, theMsg
  # first line of theMsg received
  # tell this handler what to do
  # things to do:  message to broadcast, history to log, request for stats
  put line 1 of theMsg into theRequest
  delete line 1 of theMsg
  switch theRequest
  case "message"
    handleNewChatMessage theMsg
    break
  case "stats"
    updateConnectDisplayFinish theMsg
    break
  case "join"
    handleJoinMessage theMsg
    break
  end switch
  # get ready to receive next message from server
  read from socket s with message "receiveChatAtClient"
end receiveChatAtClient

on handleNewChatMessage theMsg
  # answer "enter handleNewChatMessage: " & theMsg
  if the environment is "development" then
    # let everything show
  else
    if theMsg contains "server stack" then
      exit handleNewChatMessage # assume development message
    end if
  end if
  put theMsg & LF & LF after field "log" of stack gConferStackPath
  scrollToEnd
  chatBeep
  # update count of new messages
  # assume stack "Directory" is in the windows
  if "server stack" is not in theMsg then
    # don't count development messages from the server stack
    add 1 to gChatMessages
    put gChatMessages into field "conferees" of card "dir" of stack "Directory"
    put gChatMessages into field "conferees" of stack gConferStackPath
    put the windows into tWindows
    repeat with i = 1 to the number of lines in tWindows
      put line i of tWindows into tWin
      if there is a field "conferees" of stack tWin then
        put gChatMessages into field "conferees" of stack tWin
      end if
    end repeat
  end if
end handleNewChatMessage

on handleJoinMessage theMsg
   go stack gConferStackPath
   
   # try to get complete log file from web server
   -- put "http://132.239.191.51/rl_net_confer.html" into tURL -- MAE
   put "http://137.110.112.103/rl_net_confer.html" into tURL -- NE in Atkinson
   
   -- repeat get url because doesn't always work first time or two
   put 10 into tRepeatAttempts
   put 0 into tRepeats
   put empty into it
   repeat until it is not empty
      add 1 to tRepeats
      get url tURL
      if tRepeats = tRepeatAttempts then
         exit repeat
      end if
   end repeat
   if the result is empty then
      # got entire log file from web server
      put it into theMsg
      set the htmlText of field "log" of stack gConferStackPath to theMsg
      put cr after field "log" of stack gConferStackPath
   else
      # getting entire log file failed
      put theMsg after field "log" of stack gConferStackPath # theMsg for old chat log has blank lines at end
   end if
   
   scrollToEnd
   if "Directory" is in the windows then
      send mouseUp to button "go conference" of card "dir" of stack "Directory"
   end if
   chatBeep
   # update count of new messages
   # assume stack "Directory" is in the windows
   add 1 to gChatMessages
   put gChatMessages into field "conferees" of card "dir" of stack "Directory"
   put gChatMessages into field "conferees" of stack gConferStackPath
   put the windows into tWindows
   repeat with i = 1 to the number of lines in tWindows
      put line i of tWindows into tWin
      if there is a field "conferees" of stack tWin then
         put gChatMessages into field "conferees" of stack tWin
      end if
   end repeat
end handleJoinMessage

on scrollToEnd
  put the formattedHeight of field "log" of stack gConferStackPath into tHt
  add 100 to tHt # add more to get it to go to end
  set the scroll of field "log" of stack gConferStackPath to tHt
end scrollToEnd

on chatBeep
  if "Confer" is in the windows then
    if there is a button "beep" of stack gConferStackPath then
      if the label of button "beep" of stack gConferStackPath is "beep is on" then
        beep
      end if
    end if
  end if
end chatBeep

# ----------------

function setReservedNickName
  -- use a local to store, not a global or custom prop to help hide
  put "false" into lReservedNickName
  if the commandKey is down and the shiftKey is down then
    ask question "yes?"
    if it is "revdev rich" then
      ask question "who?"
      put it into field "nickname" of stack "Confer"
      put "true" into lReservedNickName
    end if
  end if
  if lReservedNickName is "true" then
    return "true"
  else
    return "false"
  end if
end setReservedNickName

function passNickName
   
   -- uses function stripPunc
   -- checks for names that appear to be from RL or PWL or me
   -- called by sendChatMessage and by closeField of field "nickname" of stack "Confer"
   
   -- SEE script of "What's this" button in Confer stack for how 
   -- developer can enter reserved nickname
   
   put field "nickname" of stack "Confer" into tName
   put line 1 of tName into tName
   put tName into field "nickname" of stack "Confer"
   put stripOuterSpace(tName) into tName
   
   if tName is empty then
      return "true"
      exit passNickName
   end if
   
   if lReservedNickName is "true" then
      -- lReservedNickName set by function setReservedNickName
      return "true"
      exit passNickName
   end if
   
   put stripPunc(tName) into tName
   
   -- put empty into msg
   -- beep
   -- wait 30 ticks
   -- put tName into msg
   
   put false into tBadNameFlag -- switch to true if unacceptable name
   -- put the number of words of tName into tNum
   --  repeat with i = 1 to tNum
   --    if word i of tName is "rich" then put true into tBadNameFlag
   --  end repeat
   if tName contains "rich" then put true into tBadNameFlag
   if tName contains "herz" then put true into tBadNameFlag
   if tName contains "Reactor Lab" then put true into tBadNameFlag
   if tName contains "ReactorLab" then put true into tBadNameFlag
   if tName is "RL" then put true into tBadNameFlag
   if tName contains "RL.net" then put true into tBadNameFlag
   if tName contains "RL.org" then put true into tBadNameFlag
   if tName contains "RL.com" then put true into tBadNameFlag
   if tName contains "PureWaterLab" then put true into tBadNameFlag
   if tName contains "Pure Water Lab" then put true into tBadNameFlag
   if tName contains "PWL" then put true into tBadNameFlag
   if tName contains "dick" then put true into tBadNameFlag
   if tName contains "hurts" then put true into tBadNameFlag
   if tName contains "hertz" then put true into tBadNameFlag
   if tName contains "hurtz" then put true into tBadNameFlag
   if tName contains "fuck" then put true into tBadNameFlag
   if tName contains "shit" then put true into tBadNameFlag
   if tName contains "cock" then put true into tBadNameFlag
   if tName contains "cunt" then put true into tBadNameFlag
   if tName contains "dong" then put true into tBadNameFlag
   if tName contains "pussy" then put true into tBadNameFlag
   if tName contains "pusy" then put true into tBadNameFlag
   if tName contains "suck" then put true into tBadNameFlag
   if tName contains "crap" then put true into tBadNameFlag
   
   if tBadNameFlag is not "false" then
      answer information "That pseudonym is not available." & LF & "Please use another one."
      put empty into field "nickname" of stack "Confer"
   end if
   
   if tBadNameFlag is "false" then
      return "true" -- no bad name so nickname passes
   else
      return "false"
   end if
end passNickName

function stripPunc tString
    repeat
        if char 1 of tString is in "~`!@#$%^&*-_+=;,.?/\|{}[]<>()'" then
            delete char 1 of tString
        else if char 1 of tString is quote then
            delete char 1 of tString
        else if char 1 of tString is space then
            delete char 1 of tString
        else
            -- answer "exit repeat, char 1 = " & char 1 of tString
            exit repeat
        end if
    end repeat
    repeat
        if the last char of tString is in "~`!@#$%^&*-_+=;,.?/\|{}[]<>()'" then
            delete the last char  of tString
        else if the last char of tString is quote then
            delete the last char of tString
         else if the last char of tString is space then
            delete the last char of tString
       else
            -- answer "exit repeat, last char = " & the last char of tString
            exit repeat
        end if
    end repeat
    return tString
end stripPunc

# ----------------

on sendChatMessage
   # uses function stripAndMark()
   # do some checking first  
   
   -- answer "will exit sendChatMessage in confer scripts"
   -- exit sendChatMessage
   
   # xxx comment out a few lines temporarily
   #  if the cFirstOpen of stack gConferStackPath is not "true" then exit sendChatMessage
   
   if passNickName() is not "true" then exit sendChatMessage
   
   if gConnectStatus is not "true" then
      answer "Click 'work on line' button first."
      exit sendChatMessage
   end if
   
   if gChatSocket is empty then
      answer "Click 'work on line' button first."
      exit sendChatMessage
   end if
   
   put field "message" of stack gConferStackPath into tempMsg
   if stripOuterLines(tempMsg) is empty then
      exit sendChatMessage
   end if
   if (the number of chars of tempMsg) > 1000 then
      put "stop" into tflag
   else if (the number of lines of tempMsg) > 25 then
      put "stop" into tflag
   end if
   if tflag is "stop" then
      answer "Message is too long!" & LF & "  (max 1000 characters, 25 lines)"
      exit sendChatMessage
   end if
   put empty into tflag
   put field "nickname" of stack gConferStackPath into tname
   if (the number of chars of tname) > 50 then
      put "stop" into tflag
   else if (the number of lines of tname) > 1 then
      put "stop" into tflag
   end if
   if tflag is "stop" then
      answer "Your name is too long!" & LF & "  (max 50 characters)"
      exit sendChatMessage
   end if
   put "message" into theMsg
   put LF & the internet date after theMsg
   put LF & tname after theMsg
   put " >> " & stripAndMark(tempMsg) after theMsg
   write theMsg to socket gChatSocket
   put empty into field "message" of stack gConferStackPath
   # answer "just sent chat message: " & LF & gChatSocket & LF & theMsg # xxx
end sendChatMessage

on closeChatSocket
  # sent when going off line by "off line" button script in Directory
  # and by shutdown in RL scripts 1
  if gChatSocket is empty then exit closeChatSocket
  logHistory
  close socket gChatSocket
  #  if the environment is "development" then
  #    put the ticks - lStartTicks into tTicksElapsed
  #    put tTicksElapsed && "in closeChatSocket:" & gChatSocket & LF & LF after field "log" of stack gConferStackPath
  #  end if
  put empty into gChatSocket
  
  clearConnectDisplay
  
end closeChatSocket

on sendChatJoinRequest
  put "join" into theMsg
  write theMsg to socket gChatSocket
  # put "in sendChatJoinRequest, join, the result: " & the result into msg # xxx
  # server stack will return some previous messages
  # in a "join" message
  # apparently can only send/receive 4 K chars through sockets
  # alternatively, could use "get url" to get the entire log file
  # and trim at client, or have server stack keep log file size down by
  # periodically moving older messages into another file...
end sendChatJoinRequest

on sendChatStatRequest
  # want to send message with identifier that tells server stack
  # to reply only to this client the number of people on line and
  if gChatSocket is not empty then
    # put "sending stats message to gChatSocket: " & gChatSocket into msg # xxx
    write "stats" to socket gChatSocket
  end if
end sendChatStatRequest

on socketClosed s  # this is a Rev system message name
  
  # when trying to get all this to work on eMac
  # I'm getting a socketClosed from reactorlab.net's IP address
  # apparently it's associated with other aspects of going on line
  if lChatPortNumber is not in s then exit socketClosed
  
  # zzz need to make sure connect displays get updated
  #  if the environment is "development" then
  #    put the ticks - lStartTicks into tTicksElapsed
  #    put tTicksElapsed && "in socketClosed, socket: " & s & LF & LF after field "log" of stack gConferStackPath
  #  end if
  if gConnectStatus is "true" then
    put "Message connection lost, click 'on line' button again." & LF & LF after field "log" of stack gConferStackPath
    scrollToEnd
    chatBeep
  end if
  put empty into gChatSocket
  
  clearConnectDisplay
  
end socketClosed

on socketError s, data # this is a Rev system message name
  # zzz need to make sure connect displays get updated
  #  if the environment is "development" then
  #    put the ticks - lStartTicks into tTicksElapsed
  #    put tTicksElapsed && "in socketError, socket; data: " & s & LF & "   " & data & LF after field "log" of stack gConferStackPath
  #    put "   gChatFlag = " & gChatFlag & LF & LF after field "log" of stack gConferStackPath
  #  end if
  put "false" into gChatFlag
  put empty into gChatSocket # zzz do I really want to do this?  Does error mean socket is closed?
  
  clearConnectDisplay
  
end socketError

on clearConnectDisplay
  if "Directory" is in the windows then
    put "-" into field "current connects" of card "dir" of stack "Directory"
    put "-" into field "conferees" of card "dir" of stack "Directory"
  end if
  put "-" into field "current connects" of stack gConferStackPath
  put "-" into field "conferees" of stack gConferStackPath
  put the windows into tWindows
  repeat with i = 1 to the number of lines in tWindows
    put line i of tWindows into tWin
    if there is a field "current connects" of stack tWin then
      put "-" into field "current connects" of stack tWin
      put "-" into field "conferees" of stack tWin
    end if
  end repeat
end clearConnectDisplay

function stripAndMark ttext # uses function stripOuterLines
  put stripOuterLines(ttext) into ttext
  # "mark" empty lines so only empty lines are between messages
  # first record the empty line numbers in line list
  # don't mark them during search or hard to get sequential empty lines
  put 0 into tskip
  put empty into tElines # line list of empty lines
  put 0 into tMaxCount # counter to prevent endless loop
  put 0 into tHitCount # number of lines to be marked
  put the number of lines of ttext into tnum # to prevent endless loop
  repeat
    add 1 to tMaxCount
    if tMaxCount > tnum then exit repeat # to be safe
    # find line before a blank line
    put lineOffset(LF & LF, ttext, tskip) into tline
    if tline = 0 then exit repeat
    add 1 to tHitCount
    put tskip + tline + 1 into tline # tline now line num of empty line
    put tline into line tHitCount of tElines # just record for now
    put tline - 1 into tskip # so next lineOffset from where we are now
  end repeat
  # now go back and "mark" the empty lines
  repeat with i = 1 to the number of lines in tElines
    put "." into line (line i of tElines) of ttext
  end repeat
  return ttext
end stripAndMark

function stripOuterLines ttext
  # used by function stripAndMark()
  repeat
    if char 1 of ttext is space or char 1 of ttext is cr then
      delete char 1 of ttext
    else
      exit repeat
    end if
  end repeat
  repeat
    if the last char of ttext is space or the last char of ttext is cr then
      delete the last char of ttext
    else
      exit repeat
    end if
  end repeat
  return ttext
end stripOuterLines

# ------------- end new version of chat socket --------------

on updateConnectDisplay
   
   if the environment is "development" then
      put "enter updateConnectDisplay in confer scripts" & LF after msg
   end if
   
   # put "enter updateConnectDisplay" into msg # xxx
   
   # ping here only refreshes number of socket
   # server sends out notice when any changes made, only need to ping
   # here at shorter time interval that server kills after last message
   
   put 30*60 into tPingRepeatSec
   
   if gConnectStatus is not "true" then
      if "Directory" is in the windows then
         put "-" into field "current connects" of card "dir" of stack "Directory"
         put "-" into field "conferees" of card "dir" of stack "Directory"
         set the hilite of button "on line" of card "home" of stack "Directory" to false
         set the hilite of button "off line" of card "home" of stack "Directory" to true
         set the hilite of button "on line" of card "dir" of stack "Directory" to false
         set the hilite of button "off line" of card "dir" of stack "Directory" to true
      end if
      put "-" into field "current connects" of stack gConferStackPath
      put "-" into field "conferees" of stack gConferStackPath
      set the hilite of button "on line" of stack gConferStackPath to false
      set the hilite of button "off line" of stack gConferStackPath to true
      put the windows into tWindows
      repeat with i = 1 to the number of lines in tWindows
         put line i of tWindows into tWin
         if there is a field "current connects" of stack tWin then
            put "-" into field "current connects" of stack tWin
            put "-" into field "conferees" of stack tWin
         end if
      end repeat
      cancelUpdateConnectDisplay
      exit updateConnectDisplay
   end if
   
   if the environment is "development" then
      put "just before sendChatStatRequest in updateConnectDisplay in confer scripts" & LF after msg
   end if
   
   sendChatStatRequest
   
   if the environment is "development" then
      put "just after sendChatStatRequest in updateConnectDisplay in confer scripts" & LF after msg
   end if
   
   # response from cgi script through chat socket on server will be handled by receiveChatAtClient
   # and then passed to updateConnectDisplayFinish
   # put "just before send updateConnectDisplay" into msg # xxx
   
   send "updateConnectDisplay" to me in tPingRepeatSec seconds
   
   if the environment is "development" then
      put "at end updateConnectDisplay in confer scripts" & LF after msg
   end if
   
end updateConnectDisplay

on updateConnectDisplayFinish theMsg
   if the number of items of theMsg is 1 then # now just returning number of open sockets at server stack
      # put "enter updateConnectDisplayFinish, theMsg = " & LF & theMsg into msg # xxx
      # good result
      if "Directory" is in the windows then
         put item 1 of theMsg into field "current connects" of card "dir" of stack "Directory"
         set the hilite of button "on line" of card "home" of stack "Directory" to true
         set the hilite of button "off line" of card "home" of stack "Directory" to false
         set the hilite of button "on line" of card "dir" of stack "Directory" to true
         set the hilite of button "off line" of card "dir" of stack "Directory" to false
      end if
      put item 1 of theMsg into field "current connects" of stack gConferStackPath
      
      #    if the environment is "development" then
      #      put "update stats received" & LF & LF after field "log" of stack gConferStackPath
      #      beep
      #      scrollToEnd
      #    end if
      
      set the hilite of button "on line" of stack gConferStackPath to true
      set the hilite of button "off line" of stack gConferStackPath to false
      put the windows into tWindows
      repeat with i = 1 to the number of lines in tWindows
         put line i of tWindows into tWin
         if there is a field "current connects" of stack tWin then
            put item 1 of theMsg into field "current connects" of stack tWin
         end if
      end repeat
   end if
end updateConnectDisplayFinish

on cancelUpdateConnectDisplay
  # clear the pendingMessages of updateConnectDisplay
  put the pendingMessages into tmess
  put 0 into tcounter # counter of message id's to cancel
  put empty into tcanner # list of message id's to cancel
  repeat with i = 1 to the number of lines of tmess
    if item 3 of line i of tmess is "updateConnectDisplay" then
      add 1 to tcounter
      put item 1 of line i of tmess into line tcounter of tcanner
    end if
  end repeat
  repeat with i = 1 to tcounter
    cancel line i of tcanner
  end repeat
  
  # put "at end of cancelUpdateConnectDisplay, pending = " & LF & the pendingMessages into msg # xxx
  
end cancelUpdateConnectDisplay

