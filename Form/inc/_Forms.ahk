/*
	Title:	_Forms
			*Forms framework*

 Group: Overview
 :
		Forms framework is group of modules used together to create AHK graphical user interfaces in very simple manner. 
		Even the very complex GUIs can be created with just several lines of code.
 :
		Forms framework is the list of optional module includes with each of them designed to work with or without framework.
		It includes <Form> module which capabilities are backbone of the framework and number of custom controls, extensions and useful libraries.
 :
		The framework can be used to quickly create Windows utilities of any kind.

 Group: Features
 :
		All modules are developed so they fulfill specific goals :

		o Standalone. All modules are independent of each other. You can copy any module to your script and use it without other modules.
		  They generally don't depend on your script settings. 
		o Standardized. Generally, modules use the same or similar APIs whenever possible. Functions with big number of parameters use
		  named arguments to avoid long list of empty parameters. Functions doing similar things are declared the same and arguments
		  having similar purpose are named equaly cross-module.
		o Clean. They don't create any globals and try not to influence the hosting script in any way unless specified differently.
		o Documented. All scripts contain documentation in the source code. You can use mkdoc script to create HTML documentation out of it by simply
		  running it in the folder with scripts. You can use comment remover to reduce the size of the modules. Finally, you can merge them into
		  single include using ScriptMerge, which gives the you option to create unite documentation in one big HTML file and simpler way to include framework.
		o Free. All modules are open source and free.

 Group: Modules
		o <Form>		- Alternative way of creating AHK GUIs.
		o <Panel>		- Panel custom control, container for other controls.
		o <Toolbar>		- Toolbar custom control.
		o <Rebar>		- Rebar custom control.
		o <HLink>		- HyperLink custom control.
		o <Splitter>	- Splitter custom control.
		o <HiEdit>		- HiEdit custom control.
		o <QHTM>		- Qhtm custom control.
		o <Win>			- Set of window functions.
		o <Dlg>			- Common dialogs.

 Group: Extensions
		o <Align>		- Aligns controls inside the parent.
		o <Attach>		- Determines how a control is resized with its parent.
		o <Cursor>		- Set cursor shape for control or window.
		o <Tooltip>		- Adds tooltips to GUI controls.
		o <Image>		- Adds image to the Button control.
 */
#include *i Form.ahk

;extensions
#include *i Align.ahk
#include *i Attach.ahk
#include *i Tooltip.ahk
#include *i Cursor.ahk
#include *i Image.ahk

;controls
#include *i Panel.ahk
#include *i Toolbar.ahk
#include *i Rebar.ahk
#include *i HLink.ahk
#include *i Splitter.ahk

#include *i HiEdit.ahk
#include *i Qhtm.ahk


;dependencies and utils
#include Win.ahk  ; required by Align atm too.
#include Dlg.ahk

/* 
 Group: About
	o v0.1 by majkinetor.
	o Licenced under BSD <http://creativecommons.org/licenses/BSD/> .
 */
