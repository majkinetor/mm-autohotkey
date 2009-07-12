/* Title: Scheduler
 */

/* 
	Function: Create	
			 Creates new scheduled task

	Parameters:
		Name	 -	Specifies a name for the task
		Run		 -	Specifies the program or command that the task runs. 
		Arguments-  Arguments of the program that the task runs.
		Type	 -	MINUTE, HOURLY, DAILY, WEEKLY, MONTHLY,     ONCE, ONSTART, ONLOGON, ONIDLE.  By default, ONCE.
		Modifier -  Number, Specifies how often the task runs within its schedule type (defaults to 1)
					Additionally, the words FIRST, SECOND, THIRD, FOURTH, LAST, LASTDAY can be used.
		Day		 -  Specifies a day of the week or a day of a month. Valid only with a WEEKLY or MONTHLY schedule.
					For WEEKLY type, valid values are MON-SUN and * (every day). MON is the default.
					A value of MON-SUN is required when the FIRST, SECOND, THIRD, FOURTH, or LAST modifier is used. 
					A value of 1-31 is optional and is valid only with no modifier or a modifier of the 1-12 type.
		Month	 -  Specifies a month of the year. Valid values are JAN - DEC and *  The parameter is valid only with a MONTHLY schedule. 
					It is required when the LASTDAY modifier is used. Otherwise, it is optional and the default value is * (every month).
		IdleTime -  A whole number from 1 to 999. Specifies how many minutes the computer is idle before the task starts. This parameter is valid only with an ONIDLE schedule, and then it is required.
		Time	  - Specifies the time of day that the task starts in HH:MM:SS 24-hour format. The default value is the current local time when the command completes. \
					Valid with MINUTE, HOURLY, DAILY, WEEKLY, MONTHLY, and ONCE schedules. It is required with a ONCE schedule.
		StartDate - Specifies the date that the task starts in MM/DD/YYYY format. The default value is the current date. Valid with all schedules, and is required for a ONCE schedule.
		EndDate	  - Specifies the last date that the task is scheduled to run. This parameter is optional. It is not valid in a ONCE, ONSTART, ONLOGON, or ONIDLE schedule. By default, schedules have no ending date.
		Computer  - Specifies the name or IP address of a remote computer (with or without backslashes). The default is the local computer.
		User	  - Runs the command with the permissions of the specified user account. By default, the command runs with the permissions of the user logged on to the computer running SchTasks.
		Password  - Specifies the password of the user account specified in the _User_ parameter (required with it)

 */
Scheduler_Create( v, bForce=false ) {
	static arguments="Type Modifier Day Month IdleTime Time StartDate EndDate Computer User Password"
	static Type="/sc", Modifier="/mo", Day="/d", Month="/m", IdleTime="/i", Time="/st", EndDate="/ed", Computer="/s", User="/u", Password="/p"

	Name := %v%_Name,  Run := %v%_Run,  Args := %v%_Args

   ;errors
	if (Name = "") 
		return "ERROR: No value specified for 'Name' option."
	if (Run = "")
		return "ERROR: No value specified for 'Run' option."

   ;defaults 
	if ( %v%_Type = "" )
		%v%_Type := "ONCE"
	
   ;generate cmd line
	cmd = /create /tn "%Name%" /tr "\"%Run%\" %Args%"
	loop, parse, arguments, %A_Space%
	{
		c := %A_LoopField%,   
		val := %v%_%A_LoopField%
		StringReplace, val, val, `",, A
		if val !=					
			cmd = %cmd% %c% %val%
	}

	if Scheduler_Exists(Name)
	{
		if !bForce
		{
			Msgbox, 36, %A_ThisFunc%, Scheduled task '%Name%' already exists.`n`nDo you want to overwrite ?
			IfMsgBox No
				return "Operation canceled."
		}
		Scheduler_Delete( %v%_Name, true)
	}
	res := Scheduler_run("Schtasks " cmd)
	StringReplace, res, res, `r`nType "SCHTASKS /CREATE /?" for usage.`r`n
	return res
}

/* Function: ClearVar
			 Clears the global array.
 */
Scheduler_ClearVar(v){
	static arguments="Type Modifier Day Month IdleTime Time StartDate EndDate Computer User Password"
	loop, parse, arguments, %A_Space%
		%v%_%A_LoopField% := ""
}

/* 
	Function: Delete	
			  Delete specified scheduled task

	Parameters:
		Name   - Specifies the name of task to be deleted. Use "*" to delete all tasks.
		bForce - Surpess confimration message, false by default.		

 */
Scheduler_Delete( Name, bForce=false, User="", Password="", Computer="")
{
	StringReplace, Name, Name, `", ,A
	if (!bForce) {
		Msgbox, 36, %A_ThisFunc%, Are you sure you want to delete task "%Name%" ? 
		IfMsgBox No, return
	}
	
	cmd = /delete /f /tn "%Name%" %A_Space%
	cmd .= User != "" ? "/u" User : ""
	cmd .= Password != "" ? "/p" Password : ""
	cmd .= Computer != "" ? "/s" Computer : ""

	res := Scheduler_run("Schtasks " cmd)
	return res
}
/* 
	Function: Query
			  Query specified scheduled task or all tasks

	Parameters:
		Name   - Specifies the name of task. Use empty string to return all tasks.
		var	   - If non empty, variable prefix for task parameters extraction

 */
Scheduler_Query(Name="", var=""){
	global
	static args="Run Type Modifier Day Month IdleTime Time StartDate EndDate Computer User Password"
	static Time="Start Time", Run="Task To Run", User="Run As User", Type="Schedule Type", StartDate="Start Date", EndDate="End Date", Day="Days", Month="Months", Computer="HostName", Status="Status", LastResult="Last Result", Modifier="Repeat: Every"
	local cmd, res, p, out, out1

	StringReplace, Name, Name, `", ,A
	cmd := "/query " (Name != "" ? "/fo List /v /tn """ Name """"  : "")
	res := Scheduler_run("Schtasks " cmd)
	if InStr(res, "ERROR: The system cannot find the file specified")
		res := ""

	if (var != "")
	{
		%var% := ""
		loop, parse, args, %A_Space%
		{
			p := %A_LoopField%
			if (p = "") {
				%var%_%A_LoopField% := ""
				continue
			}
			RegExMatch(res, "im)^" p ":\s*(.+)$", out)
			%var%_%A_LoopField% := (out1 != "N/A") ? out1 : ""
		}
		%var% := res
	}
	Scheduler_fixData(var)
	return res
}

/* Function: Exists
			 Check if task exists.
	
   Parameter: 
			 Name	- Name of the task.
 */
Scheduler_Exists(Name) {
	return Scheduler_Query(Name) != ""
}

/* Function: Open
			 Opens Task Scheduler
 */
Scheduler_Open() {
	Run, %A_WinDir%\system32\taskschd.msc
}

;fix garbadge data reported by schtasks app.
Scheduler_fixData( var ) {
	
	if RegExMatch( %var%_Modifier, "S)(\d+)\D+(\d+)", m)		;1 Hour(s), 10 Minute(s)
		%var%_Modifier := m1*60 + m2
}

Scheduler_run(Cmd, Dir = "", Input = "", Stream = "")
{
	DllCall("CreatePipe", "UintP", hStdInRd , "UintP", hStdInWr , "Uint", 0, "Uint", 0)
	DllCall("CreatePipe", "UintP", hStdOutRd, "UintP", hStdOutWr, "Uint", 0, "Uint", 0)
	DllCall("SetHandleInformation", "Uint", hStdInRd , "Uint", 1, "Uint", 1)
	DllCall("SetHandleInformation", "Uint", hStdOutWr, "Uint", 1, "Uint", 1)
	VarSetCapacity(pi, 16, 0)
	NumPut(VarSetCapacity(si, 68, 0), si)	; size of si
	NumPut(0x100	, si, 44)		; STARTF_USESTDHANDLES
	NumPut(hStdInRd	, si, 56)		; hStdInput
	NumPut(hStdOutWr, si, 60)		; hStdOutput
	NumPut(hStdOutWr, si, 64)		; hStdError
	If !DllCall("CreateProcess", "Uint", 0, "Uint", &Cmd, "Uint", 0, "Uint", 0, "int", True, "Uint", 0x08000000, "Uint", 0, "Uint", Dir ? &Dir : 0, "Uint", &si, "Uint", &pi)	; bInheritHandles and CREATE_NO_WINDOW
		return A_ThisFunc "> Can't create process:`n" Cmd 
	
	hProcess := NumGet(pi,0)
    DllCall("CloseHandle", "Uint", NumGet(pi,4)),  DllCall("CloseHandle", "Uint", hStdOutWr),  DllCall("CloseHandle", "Uint", hStdInRd)

	If Input !=
		DllCall("WriteFile", "Uint", hStdInWr, "Uint", &Input, "Uint", StrLen(Input), "UintP", nSize, "Uint", 0)

	DllCall("CloseHandle", "Uint", hStdInWr)
	Stream+0 ? (bAlloc:=DllCall("AllocConsole"),hCon:=DllCall("CreateFile","str","CON","Uint",0x40000000,"Uint",bAlloc ? 0 : 3,"Uint",0,"Uint",3,"Uint",0,"Uint",0)) : ""
	VarSetCapacity(sTemp, nTemp:=Stream ? 64-nTrim:=1 : 4095)
	Loop
		If	DllCall("ReadFile", "Uint", hStdOutRd, "Uint", &sTemp, "Uint", nTemp, "UintP", nSize:=0, "Uint", 0) && nSize
		{
			NumPut(0,sTemp,nSize,"Uchar"), VarSetCapacity(sTemp,-1), sOutput.=sTemp
			If	Stream
				Loop
					If	RegExMatch(sOutput, "S)[^\n]*\n", sTrim, nTrim)
						Stream+0 ? DllCall("WriteFile", "Uint", hCon, "Uint", &sTrim, "Uint", StrLen(sTrim), "UintP", 0, "Uint", 0) : %Stream%(sTrim), nTrim+=StrLen(sTrim)
					Else	Break
		}
		Else	Break	
	DllCall("CloseHandle", "Uint", hStdOutRd)
	Stream+0 ? (DllCall("Sleep","Uint",1000),hCon+1 ? DllCall("CloseHandle","Uint",hCon) : "",bAlloc ? DllCall("FreeConsole") : "") : ""
	DllCall("GetExitCodeProcess", "uint", hProcess, "intP", ExitCode)
	DllCall("CloseHandle", "Uint", hProcess)
	ErrorLevel := ExitCode
	return	sOutput
}

/* 
 Group: About 
 	o v0.9 by majkinetor.
	o Schtasks at MSDN: http://www.microsoft.com/resources/documentation/windows/xp/all/proddocs/en-us/schtasks.mspx?mfr=true
	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>
 */

