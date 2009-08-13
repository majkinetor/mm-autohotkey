	cmd := "schtasks s /query"

	s := Run(cmd, "", .2)
	m(s)


#include Run.ahk