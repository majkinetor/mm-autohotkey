List of some of the methods used in the code.

  * "Add" function arguments should not have initializers other then "". Default values should be handled inside the function. This is to solve the problem with add2Form in Forms framework which always sends all available parameters of the controls Add function. If user didn't set the parameter Parse will set it to "" (thats why "" must specify default value)

  * Any constant used is referenced as static on the start of the function. If there is a need to repeat the same statics in several functions, helper function is created which is then the only one to keep static definitions.

  * Module does not use globals for its inner working. If module needs globals, it uses its own copy of **storage** function (big storage, lil' storage or mini storage, depending on what storage options it needs).

  * Module is independent as much as possible. If there is only few function dependencies to other modules in places not mandatory for the module use, they are called using dynamic function calls so that script doesn't fail if dependency isn't included. If this can not be done or is not practical, module states its dependencies as first thing in documentation after specifying Title.

  * If there is already a module implementing some set of functions using the same or similar terminology as module being implemented, their API's are the same or similar to provide unified experience as much as possible.

  * DllCalls that return handles have "Uint" output type set. Handles are often used as variable names and negative handles will make the script fail. DllCalls that are used in the loop or extensively are pre-loaded.

  * Any message handler for message that is expected to be used in other scenarios is chained. The chain method must be the same in all modules. Messages that are generally not expected to be used by the user don't need this.

  * Each function returns error with A\_ThisFunc "> ... " or using ErrorLevel. Function shouldn't use MsgBox for such purpose (generally).

  * Control classes use MODULEID as ID. ID must be unique among controls (date when the control is created with 6 numbers - DDMMYY, it must be bigger then 10 000). MODULEID is generally used in Add function and onNotify function to uniquely identify control class in question. Each module having those **must** use the same initialization scheme which is required for message chains to work.