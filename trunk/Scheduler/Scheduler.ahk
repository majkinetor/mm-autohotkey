/* 
	Function: Create	
			 Creates new scheduled task

	Parameters:
		TaskName -	Specifies a name for the task
		TaskRun	 -	Specifies the program or command that the task runs. 
		Arguments-  Arguments of the program that the task runs.
		Type	 -	MINUTE, HOURLY, DAILY, WEEKLY, MONTHLY,     ONCE, ONSTART, ONLOGON, ONIDLE.  By default, ONCE.
		Modifier -  Number, Specifies how often the task runs within its schedule type (defaults to 1)
					Additionally, the words FIRST, SECOND, THIRD, FOURTH, LAST, LASTDAY can be used.
		Day		 -  Specifies a day of the week or a day of a month. Valid only with a WEEKLY or MONTHLY schedule.
					For WEEKLY type, valid values are MON - SUN and * (every day). MON is the default.
					A value of MON - SUN is required when the FIRST, SECOND, THIRD, FOURTH, or LAST modifier is used. 
					A value of 1 - 31 is optional and is valid only with no modifier or a modifier of the 1 - 12 type.
		Month	 -  Specifies a month of the year. Valid values are JAN - DEC and *  The parameter is valid only with a MONTHLY schedule. 
					It is required when the LASTDAY modifier is used. Otherwise, it is optional and the default value is * (every month).
		IdleTime -  A whole number from 1 to 999. Specifies how many minutes the computer is idle before the task starts. This parameter is valid only with an ONIDLE schedule, and then it is required.
		StartTime - Specifies the time of day that the task starts in HH:MM:SS 24-hour format. The default value is the current local time when the command completes. \
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
	static Time="Start Time", Run="Task To Run", User="Run As User", Type="Schedule Type", StartDate="Start Date", EndDate="End Date", Day="Days", Month="Months", Computer="HostName", Status="Status", LastResult="Last Result"
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
	
	return res
}

Scheduler_Exists(Name) {
	return Scheduler_Query(Name) != ""
}


Scheduler_run(CMDin, WorkingDir=0)
{
  Global cmdretPID
  tcWrk := WorkingDir=0 ? "Int" : "Str"
  idltm := A_TickCount + 20
  CMsize = 1
  VarSetCapacity(CMDout, 1, 32)
  VarSetCapacity(sui,68, 0)
  VarSetCapacity(pi, 16, 0)
  VarSetCapacity(pa, 12, 0)
  Loop, 4 {
    DllCall("RtlFillMemory", UInt,&pa+A_Index-1, UInt,1, UChar,12 >> 8*A_Index-8)
    DllCall("RtlFillMemory", UInt,&pa+8+A_Index-1, UInt,1, UChar,1 >> 8*A_Index-8)
  }
  IF (DllCall("CreatePipe", "UInt*",hRead, "UInt*",hWrite, "UInt",&pa, "Int",0) <> 0) {
    Loop, 4
      DllCall("RtlFillMemory", UInt,&sui+A_Index-1, UInt,1, UChar,68 >> 8*A_Index-8)
    DllCall("GetStartupInfo", "UInt", &sui)
    Loop, 4 {
      DllCall("RtlFillMemory", UInt,&sui+44+A_Index-1, UInt,1, UChar,257 >> 8*A_Index-8)
      DllCall("RtlFillMemory", UInt,&sui+60+A_Index-1, UInt,1, UChar,hWrite >> 8*A_Index-8)
      DllCall("RtlFillMemory", UInt,&sui+64+A_Index-1, UInt,1, UChar,hWrite >> 8*A_Index-8)
      DllCall("RtlFillMemory", UInt,&sui+48+A_Index-1, UInt,1, UChar,0 >> 8*A_Index-8)
    }
    IF (DllCall("CreateProcess", Int,0, Str,CMDin, Int,0, Int,0, Int,1, "UInt",0, Int,0, tcWrk, WorkingDir, UInt,&sui, UInt,&pi) <> 0) {
      Loop, 4
        cmdretPID += *(&pi+8+A_Index-1) << 8*A_Index-8
      Loop {
        idltm2 := A_TickCount - idltm
        If (idltm2 < 10) {
          DllCall("Sleep", Int, 10)
          Continue
        }
        IF (DllCall("PeekNamedPipe", "uint", hRead, "uint", 0, "uint", 0, "uint", 0, "uint*", bSize, "uint", 0 ) <> 0 ) {
          Process, Exist, %cmdretPID%
          IF (ErrorLevel OR bSize > 0) {
            IF (bSize > 0) {
              VarSetCapacity(lpBuffer, bSize+1)
              IF (DllCall("ReadFile", "UInt",hRead, "Str", lpBuffer, "Int",bSize, "UInt*",bRead, "Int",0) > 0) {
                IF (bRead > 0) {
                  TRead += bRead
                  VarSetCapacity(CMcpy, (bRead+CMsize+1), 0)
                  CMcpy = a
                  DllCall("RtlMoveMemory", "UInt", &CMcpy, "UInt", &CMDout, "Int", CMsize)
                  DllCall("RtlMoveMemory", "UInt", &CMcpy+CMsize, "UInt", &lpBuffer, "Int", bRead)
                  CMsize += bRead
                  VarSetCapacity(CMDout, (CMsize + 1), 0)
                  CMDout=a   
                  DllCall("RtlMoveMemory", "UInt", &CMDout, "UInt", &CMcpy, "Int", CMsize)
                  VarSetCapacity(CMDout, -1)   ; fix required by change in autohotkey v1.0.44.14
                }
              }
            }
          }
          ELSE
            break
        }
        ELSE
          break
        idltm := A_TickCount
      }
      cmdretPID=
      DllCall("CloseHandle", UInt, hWrite)
      DllCall("CloseHandle", UInt, hRead)
    }
  }
  IF (StrLen(CMDout) < TRead) {
    VarSetCapacity(CMcpy, TRead, 32)
    TRead2 = %TRead%
    Loop {
      DllCall("RtlZeroMemory", "UInt", &CMcpy, Int, TRead)
      NULLptr := StrLen(CMDout)
      cpsize := Tread - NULLptr
      DllCall("RtlMoveMemory", "UInt", &CMcpy, "UInt", (&CMDout + NULLptr + 2), "Int", (cpsize - 1))
      DllCall("RtlZeroMemory", "UInt", (&CMDout + NULLptr), Int, cpsize)
      DllCall("RtlMoveMemory", "UInt", (&CMDout + NULLptr), "UInt", &CMcpy, "Int", cpsize)
      TRead2 --
      IF (StrLen(CMDout) > TRead2)
        break
    }
  }
  StringTrimLeft, CMDout, CMDout, 1
  Return, CMDout
}
