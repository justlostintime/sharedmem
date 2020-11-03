#!/usr/bin/gsh
'Defaults to be loaded into an empty system
'Script for Shell Version 1.2
'Functions in this file are loaded as plugins each time the gsh starts
' The comment lines starting with double ' will be printed by the help
' function.
' so 
'' this is help
' will be printed when detailed help is required
' may contain as many lines as required after the Sub declaration
' Extern, Include and Use may be declared in the body of any function
' each is treated as a stand alone Program 
' see Sub clearhist for an example of extern
' Dont use public that is assumed.
' if you call a function from this file during loading then
' it should be defined before you call it

'sharedmem["$trace"] = true

sharedmem.free("sub.vardel")
sub vardel(varname as string, optional noerrorreport as boolean = false) as boolean
''VarDel $globalvar - Delete a global variable 
''          as function vardel("varname")
''          as command vardel "varname"
''          global functions have format "sub.sub"
''          global classes have format "class.classname"
''          returns true if found, false otherwise
''          $result contains the error text or "OK"
with sharedmem
   .Free("$result")
   'print "Deleting ";varname;", Result on check=";.exist(varname)
   if .exist(varname) Then
     .free(varname)
     .["$result"] = "OK"
     return true
   else
     .["$result"] = "Error : \""&varname&"\" not found"
     if not noerrorreport then
         print #file.err, .["$result"]
     endif
     return false
   endif
   
 end with
end

vardel("sub.clear",true)
Sub clear()  as boolean
''clear     clear the screen
''          returns true if cleared, false otherwise
''          $result contains the error text or "OK"
exec [ "clear"] wait
sharedmem["$result"] = "OK"
return true
end

vardel("sub.hist",true)
Sub hist() As boolean
''Hist      print a list input lines to the stdout
''          as function hist()
''          as command hist
''          uses the global collection $history
''          returns true if read, false otherwise
''          $result contains the error text or "OK"
''
with sharedmem
dim cH as collection = .["$history"]
for each s as string in cH
   print "[";format(ch.key,"###0");"]";s
next
end with
  return true
end

vardel("sub.lenv",true)
Sub lenv() as boolean
''lEnv      prints the current environment for exec
''          as function env()
''          as command  env
''          uses the global $env string[] variable
''          returns true if found, false otherwise
''          $result contains the error text or "OK"
''
with sharedmem
   for each sI as string in .["$env"]
     print sI
   next
end with
End


vardel("sub.varread",true)
sub varread(varname as string, optional FileName as string = "") as boolean
''VarRead  $GlobalVarName <"filename"> - read a global variable value from a file, default = ~/var/varname
''          as function - varread("varname <, "filename">)
''          as command  - varread "varname" <"filename
''          returns true if read, false otherwise
''          $result contains the error text or "OK"
''
with sharedmem
   .Free("$result")
   if not .exist(varname) Then
     .[varname] = ""
   endif
   try .readvarfrom(varname,FileName)
   if error Then
      .["$result"] = error.text
      print #file.err, error.text
      return false
   endif
   return true
end with
end

vardel("sub.varwrite",true)
sub varwrite(varname as string, optional FileName as string = "") as boolean
''VarWrite  $GlobalVarName <"filename"> - write a global variable value to a file, default = ~/var/varname
''          as function - varwrite("varname <, "filename">)
''          as command  - varwrite "varname" <"filename>
''          returns true if write, false otherwise
''          $result contains the error text or "OK"
''
with sharedmem
   .Free("$result")
   if not .exist(varname) Then
     .["$result"] = "Error : \""&varname&"\" not found"
     print #file.err, .["$result"]
     return false
   endif
   try .writevarto(varname,FileName)
   if error Then
      .["$result"] = error.text
      print #file.err, error.text
      return false
   endif
   return true
end with
end

vardel("sub.lvars",true)
Sub lvars(optional varname as string = "") as boolean
''lVars  <$GlobalVarName> - list all varables or specific variable with content
''          function lvars(<varname>) 
''          command lvars <varname> 
''          list all if no parameter, other wise varname passed
''          returns true if found, false otherwise
''          $result contains the error text or "OK"
with sharedmem
    if varname <> "" then
       if .exist(varname) then
        print varname;"=";.[varname]
       else
        .["$result"] = "Error : Global variable Not found ["&varname&"]"
        print #file.err, .["$result"]
        return false
       endif
    else
				For Each s As SharedMemSymbol In .SymbolTable
		   		 if not (s.symname like "sub.*" or s.symname like "class.*") then
		   		      if s.SymType = gb.string then
		   		        if .[s.symname].len < 50 then
		   		          Print .SymbolTable.key; "="; quote(.[s.symname])
		   		        else 
		   		      	   Print .SymbolTable.key;"="; quote(left(.[s.symname],50));"..."
		   		      	endif
		   		      else
        					Print .SymbolTable.key; "=";.[s.symname]
        				endif
        		endif
    		Next
    endif
    .["$result"] = "OK"
end with
return true
End

vardel("sub.lsubs",true)
Sub lsubs(optional varname as string = "") as boolean
''lSubs <GlobalSubName> - prints a list of global functions, Subs, Procs
''          prints the content of functuon if name is provided
''          function lsub(<subname>)
''          Command lsub <subname>
''          returns true if found, false otherwise
''          $result contains the error text or "OK"
with sharedmem
    if varname <> "" then
       if .exist("sub."&varname) then
        print .["sub."&varname]
       else
        .["$result"] = "Error : Global Function Not found ["&varname&"]"
        print #file.err, .["$result"]
        return false
       endif
    else
       	For Each s As SharedMemSymbol In .SymbolTable
         If s.symname Like "sub.*" Then 
             Print split(.[s.symname],"\n","",true)[0]
         endif
    		Next
    endif
.["$result"] = "OK"
end with
return true
End

vardel("sub.lclass",true)
sub lclass(optional varname as string = "") as boolean
''lClass    <GlobalClassname> - prints a list of global classes
''          prints the content of classif name is provided
''          function lsub(<subname>)
''          Command lsub <subname>
''          returns true if found, false otherwise
''          $result contains the error text or "OK"
''          returns true if found, false otherwise
''          $result contains the error text or "OK"
with sharedmem
    if varname <> "" then
       if .exist("class."&varname) then
        print .["class."&varname]
       else
        .["$result"] = "Error : Global Class Not found ["&varname&"]"
        print #file.err, .["$result"]
        return false
       endif
    else
   			For Each s As SharedMemSymbol In SharedMem.SymbolTable
     			If s.symname Like "class.*" Then 
     			  Print split(.[s.symname],"\n","",true)[0]
     			endif
   			Next
   	endif
   	
.["$result"] = "OK"
end with
return true
End

vardel("sub.save",true)
Sub save(Optional FileName As String = ".") As Boolean
''Save <"ImageFileName"> - Save the current image to a file
''          Images may be saved to a file and loaded as needed
''          Images may contain any application environment
''          function save(<"filename">)
''          Command  save <"filename">
''          returns true if found, false otherwise
''          $result contains the error text or "OK"
With sharedmem
   .Free("$result")
    Try .Sync(".", FileName)
    If Error Then
         .["$result"] = error.text
         Return False
    Endif
    
    .["$result"] = "OK"
End With
Return True
End

vardel("sub.load",true)
Sub load(Optional FileName As String = ".") As Boolean
''load <"ImageFileName"> - load an image from a file and make it current
''          Images may be saved to a file and loaded as needed
''          Images may contain any application environment
''          Function load(<"filename">)
''          Command  load <"filename">
''          the default path is ~/vars/filename
''          The default filename is gsh.image
''          returns true if found, false otherwise
''          $result contains the error text or "OK"
With sharedmem
   .Free("$result")
   .clearmem()
   Try .merge(filename)
   If Error Then
       .["$result"] = error.text
       Print #file.err, error.text
       Return False
   Endif
   .["$result"] = "OK"
End With
Return True
End

vardel("sub.clearhist",true)
Sub clearhist() As Boolean
''ClearHist Clears the history of entered commands
''          Function clearhist()
''          Command clearhist()
''          returns true if found, false otherwise
''          $result contains the error text or "OK"
extern clear_history() In "libreadline:5"
With sharedmem

.["$history"] = New Collection
.["$historycurrent"] = 1
clear_history()
.["$result"] = "OK"
End With
Return True
End

vardel("sub.lprint",true)
Sub lprint(...) As Boolean
''lPrint    print the content of arrays or collections
''          or objects/classes with the special _print function
''          function lprint(...) print the valiables
''          command  lprint .....  prints the variables
''          returns true if found, false otherwise
''          $result contains the error text or "OK"
Dim vParms As Variant[]
vParms = param.all
With sharedmem
   For Each v As Variant In vParms
        Select Case TypeOf(v)
        	Case gb.object
        	    Select Case object.class(v).name
        	      Case "String[]"
        	         For Each s as string In v 
        	            Print s
        	         Next
        	         
        	      Case "Byte[]"
        	            print v.ToString()
        	            
        	      Case "Collection"
        	         For Each vs As Variant In v
        	            Print v.key; "="; vs
        	         next
        	         
        	      Case "Class"
        	            print "Class :"; v.name;; "Refs=";v.count
        	     				print "  Symbols :";
				        	    for each s as string in v.symbols
        	        				print s;;
        	     				next
        	     				print
         
        	      Default
        	           If object.class(v).exist("_print") Then
        	              v._print()
        	           Else
        	              Print v
        	           Endif
        	    End Select
        	    
        	case gb.class
        	     print "Class :"; v.name;; "Refs=";v.count
        	     print "  Symbols :";
        	     for each s as string in v.symbols
        	        print s;;
        	     next
        	     print
        	     
        	Default
        	   Print v
        End Select
   Next
.["$result"] = "OK"
End With
Return True
End

vardel("sub.fprint", true)
Sub fprint(filename as variant ,...) As Boolean
''fPrint    print to a file the content of arrays or collections
''          or objects/classes with the special _print function
''          function fprint(filename,...) print the valiables
''          command  lprint filename .....  prints the variables
''          returns true if found, false otherwise
''          $result contains the error text or "OK"
Dim vParms As Variant[]
Dim mFile as variant
With sharedmem

if typeof(filename) = gb.string then 
		if file.dir(filename) = "" then
   		filename = user.home &/ "vars"&/ filename
		endif

		try mFile = open filename for write create
		if error then
       .["$result"] = error.text
       print #file.err, "fprint :";error.text
       return false
		endif
else
		mFile = filename
endif

vParms = param.all

  For Each v As Variant In vParms
    	Select Case TypeOf(v)
        	Case gb.object
        	    Select Case object.class(v).name
        	      Case "String[]"
        	         For Each s as string In v 
        	            Print #mFile, s
        	         Next
        	         
        	      Case "Byte[]"
        	         v.write(mfile)
        	         
        	      Case "Collection"
        	         For Each vs As Variant In v
        	            Print #mFile, v.key; "="; vs
        	         next
        	         
        	      Case "Class"
        	            print #mFile, "Class :"; v.name;; "Refs=";v.count
        	     				print "  Symbols :";
				        	    for each s as string in v.symbols
        	        				print  #mFile,s;;
        	     				next
        	     				print #mFile
         
        	      Default
        	           If object.class(v).exist("_print") Then
        	              v._print(mFile)
        	           Else
        	              if object.class(v).exist("_write") Then
        	                 v._write(mfile)
        	              else
        	              		Print  #mFile,v
        	              endif
        	           Endif
        	    End Select
        	    
        	case gb.class
        	     print  #mFile,"Class :"; v.name;; "Refs=";v.count
        	     print  #mFile,"  Symbols :";
        	     for each s as string in v.symbols
        	        print  #mFile,s;;
        	     next
        	     print #mFile
        	     
        	Default
        	   Print  #mFile,v
      End Select
  Next
.["$result"] = "OK"
End With
if typeof(filename) = gb.string then close mfile
Return True
End

vardel("sub.getfile",true)
sub getfile(filename as string, symbol as string) as boolean 
''getfile  loads a binary copy of the file into a global variable
''         Defaults to ~/vars/filename
''         loaded file may be dumped using fprint
''         used a byte[] as the medium edit will hex edit this type

with sharedmem
if not exist(filename) then
  if file.dir(filename) = "" then
      filename = user.home &/ "vars" &/ filename
      if not exist(filename) then
        print #file.err, "File not found"
        .["$result"] = "File Not Found"
        return false
      endif
  else
        print #file.err, "File not found"
        .["$result"] = "File Not Found"
        return false
  endif
endif
dim mfile as file
try mfile = open filename for read
dim x as new byte[lof(mfile)]
x.read(mfile)
.[symbol] = x
.["$result"] = "OK"
end with
return true
end


vardel("sub.resetdefaults",true)
sub resetdefaults() as boolean
''resetdefaults  resets the system variables to thier default value
''          this is no destructive and will change all needed variables to
''          thier default valiables
with sharedmem
		.["$execprog"] = "print \"Gambas Shell \""
		.["$blockindent"] = "  "                          ' used to indent code as you enter a block of code
		.["$prompt"] = "Sharedmem[\"$pwd\"]&\"->\"&gsh.blockindent"
		.["$result"] = "OK"
		.["$maxhistory"] = 300    ' define the max history length
		.["$historycurrent"] = 0  ' defines the current history level
		.["$pwd"] = user.home
		.["$history"] = new collection
		.["$editor"] = "/bin/nano"
		.["$home"] = user.home
		.["$hosttype"] = system.Architecture
		.["$hostname"] = system.host
		.["$term"] = "xterm-256color"
		.["$path"] = user.home &/ ".local/bin:"&user.home &/ "bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
		.["$env"] = ["PWD="&.["$pwd"], "PATH="&.["$path"],"HOME="&.["$home"],"TERM="&.["$term"],"HOSTTYPE="&.["$hosttype"],"HOSTHAME="&.["$hostname"],"LASTPLACEONEARTH=EndOfTheEarth"]
		if not .exist("$trace") then 
		    .["$trace"] = False
		endif
end with
return true
end

vardel("sub.resetenv",true)
Sub resetenv() As Boolean
''ResetEnv  Reset the current image to default 
''          You must call save or quit to save this image to disk
''          function resetenv()
''          command resetenv
''          returns true if found, false otherwise
''          $result contains the error text or "OK"
With sharedmem

    .["$execprog"] = "print \"Gambas Shell \""
		.["$blockindent"] = ""                          ' used to indent code as you enter a block of code
		.["$prompt"] = "Sharedmem[\"$pwd\"]&\"->\"&sharedmem[\"$blockindent\"]"
		.["$result"] = "OK"
		.["$maxhistory"] = 300    ' define the max history length
		.["$historycurrent"] = 0  ' defines the current history level
		.["$pwd"] = user.home
		.["$history"] = new collection
		.["$editor"] = "/bin/nano"
		.["$home"] = user.home
		.["$hosttype"] = system.Architecture
		.["$hostname"] = system.host
		.["$term"] = "xterm-256color"
		.["$path"] = user.home &/ ".local/bin:"&user.home &/ "bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
		.["$env"] = ["PWD="&.["$pwd"], "PATH="&.["$path"],"HOME="&.["$home"],"TERM="&.["$term"],"HOSTTYPE="&.["$hosttype"],"HOSTHAME="&.["$hostname"],"LASTPLACEONEARTH=EndOfTheEarth"]
		if not .exist("$trace") then 
		    .["$trace"] = False
		endif
		
		Try shell user.home &/ "vars/profile.gsh" Wait
		If Error Then 
		    .["$result"] = error.text
		    Print #file.err,"resetenv : profile.gsh - "; error.text
		    Return False
		Endif

    .["$result"] = "OK"
End With
Return True
End

vardel("sub.traceon",true)
sub traceon() as boolean
''TraceOn   Turns on shell command tracing 
''          Will cause the prining of each input line with time stamp and required terminator
''          terminator is the current block termination string
''          command traceon
''          returns true if found, false otherwise
''          $result contains the error text or "OK"
with sharedmem

    .["$trace"] = true
    .["$result"] = "OK"
    
end with
return true
end

vardel("sub.traceoff",true)
sub traceoff() as boolean
''TraceOff  Turns off shell command tracing 
''          Will cause the prining of each input line with time stamp and required terminator
''          terminator is the current block termination string
''          command traceoff
''          returns true if found, false otherwise
''          $result contains the error text or "OK"
with sharedmem

    .["$trace"] = false
    .["$result"] = "OK"
    
end with
return true
end


vardel("sub.cd",true)
sub cd(optional newdir as string = ".") as boolean
''cd   directorypath - change the current working directory
''          uses the global $pwd variable
''          updates the global $env variable PWD entry
''          Function cd("directory")
''          Command  cd "directory"
''          returns true if found, false otherwise
''          $result contains the error text or "OK"
with sharedmem
  .Free("$result")
   Dim senv As String[] = .["$env"]
   Dim sPath As String = Trim(newdir)
   
   Dim sPathSplit As String[] = Split(.["$pwd"], "/", "" , True)
   for each Sdir as string in sPathSplit
     Select Case sPath
      Case "."
       
                           
     Case ".."
        
        If sPathSplit.count > 0 Then 
            sPathSplit.Remove(sPathSplit.max)
        endif
        
        sPath = "/" & sPathSplit.join("/")
                        
   End Select
   
   next
   
   sdir = file.dir(spath)
   
   if sdir = "" or sdir = "." then 
       sPath = .["$pwd"] &/ sPath
   endif
    
   If Exist(sPath) Then
   		.["$pwd"] = sPath
   		For ijm As Integer = 0 To senv.Max
       If Left(senv[ijm], 3) = "PWD" Then
          senv[ijm] = "PWD=" & .["$pwd"]
          Break
       Endif
   		Next
   		.["$env"] = senv
   		.["$result"] = "OK"
   Else
      Print #file.err, "Directory Not Found :"; sPath
      .["$result"] = "Error : Directory Not Found :" & sPath
   Endif

end with
end

vardel("sub.onstart",true)
sub onstart() as boolean
''onstart()  - Executed at startup of interactive session
shell "fortune" wait
print

return true

end

vardel("sub.lsclasses" , true)
Sub lsclasses(optional classname as string = "")
''lsclasses  List all the classes in the current environment
dim s as class
if classname = "" then
    print "Class Name ";classname
    for each s in classes
  		print s.name, "Ref=";s.count;" Symbols [";
  		dim jj as integer = 0
  		for each m as string in s.symbols
    		if jj > 10 then break
    		print m;",";
    		flush
    		inc jj
  		next
 			print "]..."
 		next
 		print "End Of List"
 	else
 	  s = classes[classname]
 	  if s = null then
 	     print "Class ";classname; " not found"
 	  else
 	     print "Public sysmbols for";; classname
 	     for each m as string in s.symbols
    		  print classname&"."&m
  		 next
 	  endif
 	endif
End

vardel("sub.readto",true)
sub readto(GlobalVar as string)
''readto(GlocalVar as string) For next command redirect output to variable
  dim c as class
  dim o as object
  c = classes["gsh"]
  o = c.instance()
  o.ReturnOutputTo = GlobalVar
end


' reset this value to false at anytime to reload the profile upon restart 
'   $profile=false
'   quit
'now restart gsh and profile.gsh will run and reset everything to fresh state
$profile = true  ' sets this to true on the first load of the profile. only done upon first init








































