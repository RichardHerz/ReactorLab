script "RL scripts 5"
# The Reactor Lab stack designs and all scripts copyright 1996-1999
# by Richard K. Herz, all rights reserved.

# --------------

on regCheck
  
  # check to see if program has been registered
  
  get the script of stack "RL icons"
  put it into thisScript
  put the last line of thisScript into regLine
  if the last character of regLine is return then
    delete the last character of regLine
  end if
  delete char 1 to 2 of regLine  # delete "# "
  
  if regLine is encryptor("golf&bowling") then    # string appears in three places in this script
    # OK to proceed, do nothing
  else
    regNotice
  end if
  
end regCheck

# --------------

on regNotice
  
  global quitFast
  
  put "This copy of the Lab is not registered with the author, Richard K. Herz." into temp
  put return & "The Lab is provided at no charge but must be registered. " after temp
  put return & "Send email to rherz@ucsd.edu to obtain a free unlock code." after temp
  put return & "After you obtain it, please click Enter Code below.  Thank you." after temp
  
  answer temp with "Quit" or "Enter Code"
  
  if it is "Quit" then
    put "true" into quitFast
    quit
  end if
  
  ask "Please enter the code..."
  put it into theCode
  
  if it is "golf&bowling" then   # string appears in three places in this script
    
    put return & "# -----------------------------------" & return into temp
    put "# Don't bother trying to get around the registration procedure." & return after temp
    put "# The Reactor Lab is available at no charge." & return after temp
    put "# All I ask is that you let me know that you are interested in the Lab." & return after temp
    put "# Please register by sending an email message to" & return & return after temp
    put "#          rherz@ucsd.edu" & return & return after temp
    put "# Copyright, 1999, by Richard K. Herz." & return & return after temp
    put "# " & encryptor("golf&bowling") into theCode  # string appears in three places in this script
    put theCode  after temp
    
    # xxx 12 lines added by temp
    # xxx if change the number of lines added by temp then
    # xxx change clear code handler in my Home stack
    
    get the script of stack "RL icons"
    put temp after it
    set the script of stack "RL icons" to it
    save stack "RL icons"
    
  else
    
    put "The code is incorrect." & return & "Please send email to rherz@ucsd.edu" into temp
    put return & "to obtain a free code."
    answer temp
    put "true" into quitFast
    quit
    
  end if
  
end regNotice

# --------------

function encryptor theCode
  
  put "abcdefghijklmnopqrstuvwxyz!@#$%&*" into alist
  put "pzo&avw!$gmjcx%nekbhfdlri*qu#yt@s" into clist
  
  put empty into outList
  repeat with i = 1 to the number of characters in theCode
    put character i of theCode into thisOne
    put offset(thisOne,alist) into na
    put character na of clist after outlist
  end repeat
  
  return outlist
  
end encryptor

# --------------

function encoder input
  
  # Monaco letters I and O are ambigous with symbol | and number 0 so don't use these four
  
  put the number of chars in input into inLen
  
  if inLen < 9 then
    # too short, cracking attempt, randomly scramble valid input chars
    repeat with i = 1 to inLen
      put any char of "0123456789Lbcp,.E+-" into char i of input
    end repeat
  end if
  
  put empty into semiList   # see for delimiter (comma, was semicolon) below
  
  repeat with i = 1 to inLen
    
    put char i of input into theChar
    
    if theChar is in "1234567890" then
      
      if random(2) < 2 then
        put char (theChar+1) of "ABCD>FGHIJ" into char i of output
      else
        put char (theChar+1) of "ZYXWV[TSRQ" into char i of output
      end if
      
    else if theChar is "L" then
      put any char of "K!]~<E" into char i of output
      
    else if theChar is "b" then
      put any char of "M#" into char i of output
      
    else if theChar is "c" then
      put any char of "N$" into char i of output
      
    else if theChar is "p" then
      put any char of "O*" into char i of output
      
    else if theChar is "," then
      # lots of delimiters in codes so don't repeat any until all used
      # must initialize semiList to empty before repeat starts
      if semiList is empty then
        put "P%-+_U" into semiList
      end if
      repeat
        put any char of semiList into theOne
        if theOne is not theLastOne then
          exit repeat
        end if
      end repeat
      put empty into theLastOne
      delete char offset(theOne,semiList) of semiList
      if semiList is empty then put theOne into theLastOne
      put theOne into char i of output
      
    else if theChar is "." then
      put any char of "L&" into char i of output
      
    else if theChar is "E" then
      put any char of "/@" into char i of output
      
    else if theChar is "+" then
      put any char of ";=" into char i of output
      
    else if theChar is "-" then
      put any char of ":\" into char i of output
      
    end if
    
  end repeat
  
  return output
  
end encoder

# -----------

function decoder input
  
  put the number of chars in input into inLen
  
  if inLen < 9 then
    # too short, cracking attempt, randomly scramble valid input chars
    repeat with i = 1 to inLen
      put any character of "!@#$%&*=/\,:-+[]<>~ABCDEFGHIJKLMNOPQRSTUVWXYZ" into char i of input
    end repeat
  end if
  
  repeat with i = 1 to inLen
    
    put char i of input into theChar
    
    if theChar is in "ABCD>FGHIJ" then
      put offset(theChar,"ABCD>FGHIJ") - 1 into char i of output
      
    else if theChar is in "ZYXWV[TSRQ" then
      put offset(theChar,"ZYXWV[TSRQ") - 1 into char i of output
      
    else if theChar is in "K!]~<E" then
      put "L" into char i of output
      
    else if theChar is in "M#" then
      put "b" into char i of output
      
    else if theChar is in "N$" then
      put "c" into char i of output
      
    else if theChar is in "O*" then
      put "p" into char i of output
      
    else if theChar is in "P%-+_U" then
      put "," into char i of output
      
    else if theChar is in "&L" then
      put "." into char i of output
      
    else if theChar is in "/@" then
      put "E" into char i of output
      
    else if theChar is in ";=" then
      put "+" into char i of output
      
    else if theChar is in ":\" then
      put "-" into char i of output
      
    end if
    
  end repeat
  
  return output
  
end decoder

# -----------

function printCode
  
  put field "budget balance" & ";" & the long time into input
  
  put stripSpace(input) into input
  
  repeat
    if ":" is not in input then exit repeat
    put offset(":",input) into tc
    put ";" into char tc of input
  end repeat
  
  put the number of chars in input into inLen
  
  put empty into semiList  # see for semicolon below
  
  repeat with i = 1 to inLen
    
    put char i of input into theChar
    
    if theChar is in "1234567890" then
      
      if random(2) < 2 then
        put char (theChar+1) of "HJKABFGCDE" into char i of output
      else
        put char (theChar+1) of "SRQZYXUTWV" into char i of output
      end if
      
      # the spare output letters: LMNP
      
    else if theChar is "A" then
      put any char of "K!M#" into char i of output
      
    else if theChar is "P" then
      put any char of "N$L&" into char i of output
      
    else if theChar is ";" then
      # lots of ; in codes so don't repeat any until all used
      # must initialize semiList to empty before repeat starts
      if semiList is empty then
        put "P%/@" into semiList
      end if
      repeat
        put any char of semiList into theOne
        if theOne is not theLastOne then
          exit repeat
        end if
      end repeat
      put empty into theLastOne
      delete char offset(theOne,semiList) of semiList
      if semiList is empty then put theOne into theLastOne
      put theOne into char i of output
      
    else if theChar is "-" then
      put any char of ":\;=" into char i of output
      
    end if
    
  end repeat
  
  return output
  
end printCode

# --------------------

function authenticate_budget thisInput
   
   # Monaco letters I and O are ambigous with symbol | and number 0 so don't use these four
   
   put the number of chars in thisInput into inLen
   
   if inLen < 10 then   # 10 is current min from printCode()
      # too short, cracking attempt, randomly scramble valid input chars
      repeat with i = 1 to inLen
         put any character of "!#$&%/@:\;=ABCDEFGHJKLMNPQRSTUVWXYZ" into char i of thisInput
      end repeat
   end if
   
   repeat with i = 1 to inLen
      
      put char i of thisInput into theChar
      
      if theChar is in "HJKABFGCDE" then
         put offset(theChar,"HJKABFGCDE") - 1 into char i of thisOutput
         
      else if theChar is in "SRQZYXUTWV" then
         put offset(theChar,"SRQZYXUTWV") - 1 into char i of thisOutput
         
      else if theChar is in "K!M#" then
         put "A" into char i of thisOutput
         
      else if theChar is in "N$L&" then
         put "P" into char i of thisOutput
         
      else if theChar is in "P%/@" then
         put ";" into char i of thisOutput
         
      else if theChar is in ":\;=" then
         put "-" into char i of thisOutput
         
      end if
      
   end repeat
   
   # now make this output look different that actual input to printCode()
   
   put "$" before thisOutput
   put offset(";",thisOutput) into tc
   put char 1 to tc of thisOutput into sc
   delete char 1 to tc of thisOutput
   delete the last char of sc
   put ", printed/saved at " after sc
   repeat
      if ";" is not in thisOutput then exit repeat
      put offset(";",thisOutput) into tc
      put ":" into char tc of thisOutput
   end repeat
   put sc & thisOutput into thisOutput
   put the last char of thisOutput into sc
   delete the last char of thisOutput
   put space after thisOutput
   put sc after thisOutput
   put "M" after thisOutput
   
   return thisOutput
   
end authenticate_budget
