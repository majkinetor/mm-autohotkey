/* Title:		RTF
				Rich Text Format Generator.
 */


/*
 Function:	Table
			Creates table.
 
 Parameters:
			Rows, Cols	- Number of rows and columns of the table.
			ColWidths	- Widths of each column in the table.
 */
RTF_Table(Rows, Cols, ColWidths) {
	
	sTable	:= "{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\froman\fprq2\fcharset0 Times New Roman;}{\f1\fswiss\fcharset0 Arial;}}{\*\generator Msftedit 5.41.15.1503;}\viewkind4\uc1"
	row		:= "\trowd\trgaph108\trleft8\trbrdrl\brdrs\brdrw10 \trbrdrt\brdrs\brdrw10 \trbrdrr\brdrs\brdrw10 \trbrdrb\brdrs\brdrw10 \trpaddl108\trpaddr108\trpaddfl3\trpaddfr3"
	col		:= "\clbrdrl\brdrw10\brdrs\clbrdrt\brdrw10\brdrs\clbrdrr\brdrw10\brdrs\clbrdrb\brdrw10\brdrs\cellx"
	endcell := "\cell"
	endrow	:= "\row"

	width   := ColWidth*20	;in twips
	loop, %rows%
	{
		sTable .= row, 	j := 0
		loop, parse, ColWidths, %A_Space%%A_Tab%
			sTable .= col ( j += A_LoopField*12 )

		sTable .= "\pard\intbl"
		loop, %cols%
			sTable .= endcell

		sTable .= endrow
	}
	sTable .= "\par}"
	return sTable
}