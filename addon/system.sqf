/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedFunctionViewer

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xFuncViewer_fnc_system

Description:
	Handles all tasks related to the extended function viewer UI
---------------------------------------------------------------------------- */

#define THIS_FUNC CAU_xFuncViewer_fnc_system
#define DISPLAY_NAME CAU_displayExtendedFunctionViewer

#include "\a3\3den\ui\dikcodes.inc"
#include "\a3\3den\ui\macros.inc"
#include "_defines.inc"

#define VAR_THEME QUOTE(FUNC_SUBVAR(setting_theme))
#define VAR_LOAD QUOTE(FUNC_SUBVAR(setting_load))
#define VAR_HIGHLIGHT QUOTE(FUNC_SUBVAR(setting_highlight))
#define VAR_LINE_INTERPRET QUOTE(FUNC_SUBVAR(setting_line_interpret))
#define VAR_EXT_PARSING QUOTE(FUNC_SUBVAR(setting_extension_parsing))
#define VAR_FONT_SIZE QUOTE(FUNC_SUBVAR(setting_font_size))
#define VAR_TREE_MODE QUOTE(FUNC_SUBVAR(setting_tree_mode))

#define VAR_INIT_COMPLETE QUOTE(FUNC_SUBVAR(init_complete))

#define VAR_EXT_LOADED QUOTE(FUNC_SUBVAR(extension_loaded))
#define VAR_EXT_EVH_ID QUOTE(FUNC_SUBVAR(extension_callback_handle))
#define VAR_EXT_TASK_ID QUOTE(FUNC_SUBVAR(extension_task_id))
#define VAR_EXT_TASK_DATA(id) format["%1_%2",QUOTE(FUNC_SUBVAR(extension_task_data)),id]

#define VAR_SELECTED_FUNC QUOTE(FUNC_SUBVAR(selected_func))
#define VAR_SELECTED_FUNC_HISTORY QUOTE(FUNC_SUBVAR(selected_func_history))

#define VAR_SAVED_FUNCS QUOTE(FUNC_SUBVAR(saved_func_vars))
#define VAL_SAVED_FUNC_VAR(f) format["%1_%2",QUOTE(THIS_FUNC),f]

#define VAL_LETTERS_LOWER ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
#define VAL_LETTERS_UPPER ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
#define VAL_DIGITS ["1","2","3","4","5","6","7","8","9","0"]

#define VAL_BRACKETS ["[","]","{","}","(",")"]
#define VAL_QUOTES ["'",""""]

#define VAL_LETTERS VAL_LETTERS_LOWER + VAL_LETTERS_UPPER
#define VAL_VAR_CHARS ["_"] + VAL_LETTERS + VAL_DIGITS
#define VAL_DIGIT_CHARS ["."] + VAL_DIGITS

#define VAL_PREPROCESSOR ["include","define","undef","ifdef","ifndef","else","endif","line"]
#define VAL_KEYWORDS ["case","catch","default","do","else","exit","exitwith","for","foreach","from","if","private","switch","then","throw","to","try","waituntil","while","with"]
#define VAL_LITERALS ["blufor","civilian","confignull","controlnull","displaynull","diaryrecordnull","east","endl","false","grpnull","independent","linebreak","locationnull","nil","objnull","opfor","pi","resistance","scriptnull","sideambientlife","sideempty","sidelogic","sideunknown","tasknull","teammembernull","true","west"]
#define VAL_MAGIC_VARS ["_this","_x","_foreachindex","_exception","_thisscript","_thisfsm","_thiseventhandler"]
#define VAL_NULLS ["nil","controlnull","displaynull","diaryrecordnull","grpnull","locationnull","netobjnull","objnull","scriptnull","tasknull","teammembernull","confignull"]

#define VAL_SYNTAX_ON  "\cau\extendedfunctionviewer\a_on_alt.paa"
#define VAL_SYNTAX_OFF "\cau\extendedfunctionviewer\a_off.paa"
#define VAL_LINE_INTERPRET_ON  "\cau\extendedfunctionviewer\hash_on.paa"
#define VAL_LINE_INTERPRET_OFF "\cau\extendedfunctionviewer\hash_off.paa"
#define VAL_EXT_PARSING_ON  "\cau\extendedfunctionviewer\vs_on.paa"
#define VAL_EXT_PARSING_OFF "\cau\extendedfunctionviewer\vs_off.paa"


params[["_mode","",[""]],["_params",[]]];
//private _dev_map = if (isNil "_dev_map") then {[_mode]} else {_dev_map + [_mode]};
//diag_log _dev_map;
scopeName _mode;

switch _mode do {
	case "init":{
		ctrlParent(_params#0) createDisplay QUOTE(DISPLAY_NAME);
		USE_DISPLAY(THIS_DISPLAY);
		USE_CTRL(_ctrlTitle,IDC_STATIC_TITLE);
		USE_CTRL(_ctrlEditSearch,IDC_EDIT_SEARCH);
		USE_CTRL(_ctrlButtonSearch,IDC_BUTTON_SEARCH);
		USE_CTRL(_ctrlComboTheme,IDC_COMBO_THEME);
		USE_CTRL(_ctrlComboLoad,IDC_COMBO_LOAD);
		USE_CTRL(_ctrlButtonSizeUp,IDC_BUTTON_SIZEUP);
		USE_CTRL(_ctrlButtonSizeDown,IDC_BUTTON_SIZEDOWN);
		USE_CTRL(_ctrlButtonHighlight,IDC_BUTTON_HIGHLIGHT);
		USE_CTRL(_ctrlButtonLineInterpret,IDC_BUTTON_LINE_INTERPRET);
		USE_CTRL(_ctrlButtonExtParsing,IDC_BUTTON_EXT_PARSING);
		USE_CTRL(_ctrlComboTree,IDC_COMBO_TREE_MODE);
		USE_CTRL(_ctrlButtonCollapse,IDC_BUTTON_TREE_COLLAPSE);
		USE_CTRL(_ctrlButtonExpand,IDC_BUTTON_TREE_EXPAND);
		USE_CTRL(_ctrlTree,IDC_TREE_VIEW);
		USE_CTRL(_ctrlViewerLoadbar,IDC_STATIC_VIEWER_LOADBAR);
		USE_CTRL(_ctrlButtonCopy,IDC_BUTTON_COPY);
		USE_CTRL(_ctrlButtonExecute,IDC_BUTTON_EXECUTE);
		USE_CTRL(_ctrlButtonRecompile,IDC_BUTTON_RECOMPILE);
		USE_CTRL(_ctrlButtonRecompileAll,IDC_BUTTON_RECOMPILE_ALL);
		USE_CTRL(_ctrlButtonClose,IDC_BUTTON_CLOSE);

		_ctrlViewerLoadbar setVariable ["width",ctrlPosition _ctrlViewerLoadbar # 2];

		["initSettings"] call THIS_FUNC;

		_ctrlTitle ctrlSetText "Extended Function Viewer";

		_ctrlEditSearch ctrlAddEventHandler ["KeyUp",{["searchKeyUp",_this] call THIS_FUNC}];
		_ctrlButtonSearch ctrlAddEventHandler ["ButtonClick",{["searchButtonClick",_this] call THIS_FUNC}];

		{_ctrlComboTheme lbAdd _x} forEach [
			"Dark+ (Visual Studio Code)",
			"Light+ (Visual Studio Code)",
			"One Dark (Atom)",
			"One Light (Atom)"
		];
		_ctrlComboTheme ctrlSetTooltip "Function viewer theme";
		_ctrlComboTheme ctrlAddEventHandler ["LBSelChanged",{["themeLBSelChanged",_this] call THIS_FUNC}];
		_ctrlComboTheme lbSetCurSel (profileNamespace getVariable [VAR_THEME,0]);


		{_ctrlComboLoad lbAdd _x} forEach [
			"loadFile",
			"preprocessFile",
			"preprocessFileLineNumbers",
			"Compiled Function"
		];
		_ctrlComboLoad ctrlSetTooltip "Function viewer file loading method";
		_ctrlComboLoad ctrlAddEventHandler ["LBSelChanged",{["loadLBSelChanged",_this] call THIS_FUNC}];
		_ctrlComboLoad lbSetCurSel (profileNamespace getVariable [VAR_LOAD,0]);

		_ctrlButtonSizeUp ctrlSetText "\cau\extendedfunctionviewer\a_up.paa";
		_ctrlButtonSizeUp ctrlSetTooltip "Increase font size";
		_ctrlButtonSizeUp ctrlAddEventHandler ["ButtonClick",{["sizeButtonClick",_this] call THIS_FUNC}];

		_ctrlButtonSizeDown ctrlSetText "\cau\extendedfunctionviewer\a_down.paa";
		_ctrlButtonSizeDown ctrlSetTooltip "Decrease font size";
		_ctrlButtonSizeDown ctrlAddEventHandler ["ButtonClick",{["sizeButtonClick",_this] call THIS_FUNC}];

		_ctrlButtonHighlight ctrlSetText ([VAL_SYNTAX_OFF,VAL_SYNTAX_ON] select (profilenamespace getVariable [VAR_HIGHLIGHT,true]));
		_ctrlButtonHighlight ctrlSetTooltip "Toggle Syntax Highlighting";
		_ctrlButtonHighlight ctrlAddEventHandler ["ButtonClick",{["highlightButtonClick",_this] call THIS_FUNC}];

		_ctrlButtonLineInterpret ctrlSetText ([VAL_LINE_INTERPRET_OFF,VAL_LINE_INTERPRET_ON] select (profilenamespace getVariable [VAR_LINE_INTERPRET,false]));
		_ctrlButtonLineInterpret ctrlSetTooltip "Toggle #line interpeting (preprocessFileLineNumbers and Compiled Function modes only)";
		_ctrlButtonLineInterpret ctrlAddEventHandler ["ButtonClick",{["lineInterpretButtonClick",_this] call THIS_FUNC}];

		_ctrlButtonExtParsing ctrlSetText ([VAL_EXT_PARSING_OFF,VAL_EXT_PARSING_ON] select (profilenamespace getVariable [VAR_EXT_PARSING,true]));
		_ctrlButtonExtParsing ctrlSetTooltip "Toggle extension parsing. Extension parsing is considerably faster than sqf parsing, but is not supported in all scenarios.";
		_ctrlButtonExtParsing ctrlAddEventHandler ["ButtonClick",{["extensionParsingButtonClick",_this] call THIS_FUNC}];

		{_ctrlComboTree lbAdd _x} forEach [
			"CfgFunctions - Hierarchy",
			"CfgFunctions - Parent Groups",
			"CfgFunctions - Function Tags",
			"CfgScriptPaths - UI Functions",
			"Viewed Function History"
		];
		_ctrlComboTree ctrlSetTooltip "Sorting options";
		_ctrlComboTree lbSetCurSel (profileNamespace getVariable [VAR_TREE_MODE,0]);
		_ctrlComboTree ctrlAddEventHandler ["LBSelChanged",{["treeLBSelChanged",_this] call THIS_FUNC}];

		_ctrlButtonCollapse ctrlSetText "\a3\3den\data\displays\display3den\tree_collapse_ca.paa";
		_ctrlButtonCollapse ctrlSetTooltip "Collapse All";
		_ctrlButtonCollapse ctrlAddEventHandler ["ButtonClick",{["collapseButtonClick",_this] call THIS_FUNC}];

		_ctrlButtonExpand ctrlSetText "\a3\3den\data\displays\display3den\tree_expand_ca.paa";
		_ctrlButtonExpand ctrlSetTooltip "Expand All";
		_ctrlButtonExpand ctrlAddEventHandler ["ButtonClick",{["expandButtonClick",_this] call THIS_FUNC}];

		_ctrlTree ctrlAddEventHandler ["TreeSelChanged",{["treeTVSelChanged",_this] call THIS_FUNC}];

		_ctrlButtonExecute setVariable ["text",ctrlText _ctrlButtonExecute];
		_ctrlButtonExecute ctrlAddEventHandler ["ButtonClick",{["executeButtonClick",_this] call THIS_FUNC}];

		_ctrlButtonCopy ctrlAddEventHandler ["ButtonClick",{["copyButtonClick",_this] call THIS_FUNC}];
		_ctrlButtonClose ctrlAddEventHandler ["ButtonClick",{(ctrlParent(_this#0)) closeDisplay 2}];

		private _disableRecompileButtons = getNumber(getMissionConfig "allowFunctionsRecompile") == 0 && !cheatsEnabled;
		if _disableRecompileButtons then {
			_ctrlButtonRecompile ctrlEnable false;
			_ctrlButtonRecompileAll ctrlEnable false;
		} else {
			_ctrlButtonRecompile ctrlAddEventHandler ["ButtonClick",{["recompileButtonClick",_this] call THIS_FUNC}];
			_ctrlButtonRecompileAll ctrlAddEventHandler ["ButtonClick",{["recompileAllButtonClick",_this] call THIS_FUNC}];
		};

		private _supportedOperators = [];
		private _supportedCommands = [];
		private _varChars = VAL_VAR_CHARS;
		{
			if ((_x select [0,1]) != "t") then {
				private _string = _x splitString ": ";
				_string = switch (_string#0) do {
					case "n";
					case "u":{_string#1};
					case "b":{_string#2};
					default {""};
				};

				if (_string != "") then {
					private _stringA = _string splitString "";
					if ((_stringA-_varChars) isEqualTo []) then {
						_supportedCommands pushBackUnique tolower _string;
					} else {
						_supportedOperators pushBackUnique tolower _string;
					};
				};
			};
			false
		} count (supportInfo "");

		_display setVariable ["supportedOperators",_supportedOperators];
		_display setVariable ["supportedCommands",_supportedCommands];

		private _extReturn = ["callExtension",["init",[_supportedCommands]]] call THIS_FUNC;
		if (_extReturn == 0) then {
			_display setVariable [VAR_EXT_LOADED,true];
			private _handle = addMissionEventHandler ["ExtensionCallback",{["extensionCallback",_this] call THIS_FUNC}];
			_display setVariable [VAR_EXT_EVH_ID,_handle];
		} else {
			_ctrlButtonExtParsing ctrlEnable false;
			_ctrlButtonExtParsing ctrlRemoveAllEventHandlers "ButtonClick";
			_ctrlButtonExtParsing ctrlSetTooltip "Extension parsing is not available.";
		};

		_display setVariable [VAR_INIT_COMPLETE,true];

		["populateTree"] call THIS_FUNC;
	};
	case "onLoad":{
		uiNamespace setVariable [QUOTE(DISPLAY_NAME),_params#0];
	};
	case "onUnload":{
		_params params ["_display"];
		private _handle = _display getVariable [VAR_EXT_EVH_ID,-1];
		if (_handle > -1) then {
			removeMissionEventHandler ["ExtensionCallback",_handle];
		};
		saveProfileNamespace;
	};


	case "populateTree":{
		USE_DISPLAY(THIS_DISPLAY);
		USE_CTRL(_ctrlTree,IDC_TREE_VIEW);
		USE_CTRL(_ctrlEditSearch,IDC_EDIT_SEARCH);
		USE_CTRL(_ctrlComboTree,IDC_COMBO_TREE);

		private _searchTerm = ctrlText _ctrlEditSearch;
		private _noSearch = _searchTerm == "";
		private _mode = profileNamespace getVariable [VAR_TREE_MODE,lbCurSel _ctrlComboTree];

		private _finalizePath = {
			if ((_ctrlTree tvCount _this) > 0) then {
				_ctrlTree tvSort [_this,false];
			} else {
				if !_noSearch then {
					_ctrlTree tvDelete _this;
				};
			};
		};

		tvClear _ctrlTree;
		// bug fix: "tvCollapseAll" hides new entries
		tvExpandAll _ctrlTree;

		if (_mode != 3) then {
			// Standard load from CfgFunctions
			private _buildTreeData = {
				params ["_config","_name"];
				private _isMissionConfig = _config isEqualTo missionConfigFile;
				private _treeData = [_name,[]];
				{
					private _rootTag = if (isText(_x >> "tag")) then {getText(_x >> "tag")} else {configName _x};
					private _rootData = [configName _x,_rootTag,[]];
					{
						private _subFile = if (isText(_x >> "file")) then {getText(_x >> "file")} else {
							if _isMissionConfig then {"functions\"+configName _x} else {""};
						};
						private _subData = [configName _x,[]];
						{
							private _fileFile = getText(_x >> "file");
							private _finalVar = format["%1_fnc_%2",_rootTag,configName _x];
							private _finalFile = if (_fileFile != "") then {_fileFile} else {
								format[
									"%1fn_%2%3",
									format[
										"%1%2",_subFile,
										["\",""] select (["stringEndsWith",[_subFile,"\"]] call THIS_FUNC)
									],
									configName _x,
									if (isText(_x >> "ext")) then {getText(_x >> "ext")} else {".sqf"}
								]
							};
							if (_noSearch || {
								([_searchTerm,_finalVar] call BIS_fnc_inString) ||
								([_searchTerm,_finalFile] call BIS_fnc_inString)
							}) then {
								(_subData#1) pushback [configname _x,_finalVar,_finalFile];
							};
						} forEach ("true" configClasses _x);
						(_rootData#2) pushback _subData;
					} foreach ("true" configClasses _x);
					(_treeData#1) pushback _rootData;
				} foreach ("true" configClasses (_config >> "cfgfunctions"));
				_treeData
			};

			{
				_x params ["_configName","_configData"];

				switch _mode do {
					case 0:{
						private _configFileIndex = _ctrlTree tvAdd [[],_configName];
						{
							_x params ["_rootName","","_rootData"];
							private _rootIndex = _ctrlTree tvAdd [[_configFileIndex],_rootName];
							{
								_x params ["_subName","_subData"];
								private _subIndex = _ctrlTree tvAdd [[_configFileIndex,_rootIndex],_subName];
								{
									_x params ["_fileName","_fileVar","_filePath"];
									private _fileIndex = _ctrlTree tvAdd [[_configFileIndex,_rootIndex,_subIndex],_fileName];
									_ctrlTree tvSetData [[_configFileIndex,_rootIndex,_subIndex,_fileIndex],str[_fileVar,_filePath]];
								} forEach _subData;
								[_configFileIndex,_rootIndex,_subIndex] call _finalizePath;
							} foreach _rootData;
							[_configFileIndex,_rootIndex] call _finalizePath;
						} foreach _configData;
						[_configFileIndex] call _finalizePath;
					};
					case 1:{
						private _parents = [];

						{
							_x params ["","_rootTag","_rootData"];
							{
								_x params ["_parentName","_parentData"];
								private _parentIndex = if (tolower _parentName in _parents) then {
									_parents find tolower _parentName
								} else {
									private _index = _ctrlTree tvAdd [[],_parentName];
									_parents set [_index,tolower _parentName];
									_index
								};
								{
									_x params ["_fileName","_fileVar","_filePath"];
									private _fileIndex = _ctrlTree tvAdd [[_parentIndex],_fileVar];//format["%1 (%2)",_fileName,_rootTag]
									_ctrlTree tvSetData [[_parentIndex,_fileIndex],str[_fileVar,_filePath]];
								} forEach _parentData;
								[_parentIndex] call _finalizePath;
							} foreach _rootData;
						} foreach _configData;
						[] call _finalizePath;
					};
					case 2:{
						private _tags = [];

						{
							_x params ["","_rootTag","_rootData"];
							private _rootIndex = if (tolower _rootTag in _tags) then {
								_tags find tolower _rootTag
							} else {
								private _index = _ctrlTree tvAdd [[],_rootTag];
								_tags set [_index,tolower _rootTag];
								_index
							};
							{
								_x params ["","_subData"];
								{
									_x params ["_fileName","_fileVar","_filePath"];
									private _fileIndex = _ctrlTree tvAdd [[_rootIndex],_fileName];
									_ctrlTree tvSetData [[_rootIndex,_fileIndex],str[_fileVar,_filePath]];
								} forEach _subData;
							} foreach _rootData;
							[_rootIndex] call _finalizePath;
						} foreach _configData;
						[] call _finalizePath;
					};
					case 4:{
						private _history = profileNamespace getVariable [VAR_SELECTED_FUNC_HISTORY,[]];
						if (count _history > 0) then {
							// Identify functions that exist so we don't list fuctions from mods that are no longer loaded
							{
								_x params ["_fileVar","_filePath"];

								private _funcExists = !isNil {
									if (
										isNil {missionNameSpace getVariable _fileVar} &&
										{isNil {uiNamespace getVariable _fileVar}}
									) exitWith {};0
								};

								if _funcExists then {
									private _fileIndex = _ctrlTree tvAdd [[],_fileVar];
									_ctrlTree tvSetData [[_fileIndex],str[_fileVar,_filePath]];
								};
							} forEach _history;
						};
					};
				};
			} forEach [
				[configFile,"configFile"] call _buildTreeData,
				[campaignConfigFile,"campaignConfigFile"] call _buildTreeData,
				[missionConfigFile,"missionConfigFile"] call _buildTreeData
			];
		} else {
			// Unique load from display classes indirectly using CfgScriptPaths
			private _configData = call {
				private _treeData = [];

				{
					{
						if (getNumber (_x >> "scriptIsInternal") isEqualTo 0) then {
							private _scriptName = getText (_x >> "scriptName");
							private _scriptPath = getText (_x >> "scriptPath");

							if !("" in [_scriptName,_scriptPath]) then {
								private _index = _treeData findIf {_x#0 == _scriptPath};
								if (_index == -1) then {_index = _treeData pushBack [_scriptPath,[]]};
								private _subData = _treeData#_index;

								private _func = _scriptName + "_script";
								private _file = format ["%1%2.sqf", getText (configFile >> "CfgScriptPaths" >> _scriptPath), _scriptName];

								if (_noSearch || {
									([_searchTerm,_func] call BIS_fnc_inString) ||
									([_searchTerm,_file] call BIS_fnc_inString)
								}) then {
									//(_subData#1) pushback [["stringReplace",[str _x,"bin\config.bin","configFile"]] call THIS_FUNC,_func,_file];
									(_subData#1) pushbackunique [_func,_func,_file];
									_treeData set [_index,_subData];
								};
							};
						};
					} forEach ("isText (_x >> 'scriptPath')" configClasses _x);
				} forEach [
					configFile,
					configFile >> "RscTitles",
					configFile >> "RscInGameUI",
					configFile >> "Cfg3DEN" >> "Attributes"
				];

				_treeData
			};

			private _paths = [];
			{
				_x params ["_path","_data"];
				private _rootIndex = if (tolower _path in _paths) then {
					_paths find tolower _path
				} else {
					private _index = _ctrlTree tvAdd [[],_path];
					_paths set [_index,tolower _path];
					_index
				};
				{
					_x params ["_config","_func","_path"];
					private _fileIndex = _ctrlTree tvAdd [[_rootIndex],_config];
					_ctrlTree tvSetData [[_rootIndex,_fileIndex],str[_func,_path]];
				} foreach _data;
				[_rootIndex] call _finalizePath;
			} foreach _configData;
			[] call _finalizePath;
		};

		if !_noSearch then {
			tvExpandAll _ctrlTree;
		};

		private _data = profileNamespace getVariable [VAR_SELECTED_FUNC,[]];
		if (_data isEqualTypeParams ["",""]) then {
			_data = str _data;
			private _searchPath = {
				for "_i" from 0 to (_ctrlTree tvCount _this) do {
					private _path = _this + [_i];
					if (_data isEqualTo (_ctrlTree tvData _path)) then {
						_ctrlTree tvExpand _this;
						_ctrlTree tvSetCurSel _path;
						breakTo "selectLastFunction";
					};
					_path call _searchPath;
				};
			};
			scopeName "selectLastFunction";
			[] call _searchPath;
		};
	};
	case "treeTVSelChanged":{
		_params params ["_ctrlTree","_selectionPath"];
		private _data = _ctrlTree tvData _selectionPath;
		if (_data != "") then {
			USE_DISPLAY(ctrlParent _ctrlTree);

			_data = parseSimpleArray _data;
			profileNamespace setVariable [VAR_SELECTED_FUNC,_data];

			// Add function to history if not already viewing history
			private _mode = profileNamespace getVariable [VAR_TREE_MODE,-1];
			if (_mode != 4) then {
				private _history = profileNamespace getVariable [VAR_SELECTED_FUNC_HISTORY,[]];
				_history = ([_data] + (_history - [_data])) select [0,100]; // save last 100 viewed functions
				profileNamespace setVariable [VAR_SELECTED_FUNC_HISTORY,_history];
			};

			["loadFunction"] call THIS_FUNC;
		};
	};


	case "collapseButtonClick";
	case "expandButtonClick":{
		_params params ["_ctrlButton"];
		USE_DISPLAY(ctrlParent _ctrlButton);
		USE_CTRL(_ctrlTree,IDC_TREE_VIEW);

		if (_mode == "expandButtonClick") then {
			tvExpandAll _ctrlTree;
		} else {
			tvCollapseAll _ctrlTree;
		};
	};


	case "searchKeyUp":{
		_params params ["_ctrlEditSearch","_key"];

		private _thread = _ctrlEditSearch getVariable ["thread",scriptNull];
		terminate _thread;

		if (_key in [DIK_RETURN,DIK_NUMPADENTER]) then {
			["populateTree"] call THIS_FUNC;
		} else {
			_thread = [_ctrlEditSearch] spawn {
				scriptName format["%1: %2",QUOTE(THIS_FUNC),"Search Delay"];
				uiSleep 0.5;
				isNil {
					["populateTree"] call THIS_FUNC;
				};
			};
			_ctrlEditSearch setVariable ["thread",_thread];
		};
	};
	case "searchButtonClick":{
		_params params ["_ctrl"];
		USE_DISPLAY(ctrlParent _ctrl);
		USE_CTRL(_ctrlEditSearch,IDC_EDIT_SEARCH);
		["populateTree"] call THIS_FUNC;
	};


	case "initSettings":{
		{
			if !((profileNamespace getVariable _x) isEqualType (_x#1)) then {
				profilenamespace setVariable [_x#0,nil];
			};
		} foreach [
			[VAR_THEME,0],
			[VAR_LOAD,0],
			[VAR_HIGHLIGHT,true],
			[VAR_LINE_INTERPRET,false],
			[VAR_EXT_PARSING,true],
			[VAR_TREE_MODE,0]
		]
	};
	case "themeLBSelChanged";
	case "loadLBSelChanged";
	case "treeLBSelChanged":{
		_params params ["","_index"];

		private _variable = switch _mode do {
			case "themeLBSelChanged":{VAR_THEME};
			case "loadLBSelChanged":{VAR_LOAD};
			case "treeLBSelChanged":{VAR_TREE_MODE};
		};
		profileNamespace setVariable [_variable,_index];
		switch _mode do {
			case "themeLBSelChanged":{["loadTheme"] call THIS_FUNC};
			case "loadLBSelChanged":{["loadFunction"] call THIS_FUNC};
			case "treeLBSelChanged":{["populateTree"] call THIS_FUNC};
		};
	};
	case "sizeButtonClick":{
		_params params ["_ctrl"];

		private _size = profileNamespace getVariable [VAR_FONT_SIZE,1];

		_size = if (ctrlIDC _ctrl == IDC_BUTTON_SIZEDOWN) then {
			(_size - 0.1) max 0.1;
		} else {
			(_size + 0.1) min 3;
		};

		profileNamespace setVariable [VAR_FONT_SIZE,_size];

		["loadFunction"] call THIS_FUNC;
	};
	case "highlightButtonClick":{
		_params params ["_ctrl"];

		private _state = !(profilenamespace getVariable [VAR_HIGHLIGHT,true]);
		_ctrl ctrlSetText ([VAL_SYNTAX_OFF,VAL_SYNTAX_ON] select _state);
		profilenamespace setVariable [VAR_HIGHLIGHT,_state];

		["loadFunction"] call THIS_FUNC;
	};
	case "lineInterpretButtonClick":{
		_params params ["_ctrl"];

		private _state = !(profilenamespace getVariable [VAR_LINE_INTERPRET,false]);
		_ctrl ctrlSetText ([VAL_LINE_INTERPRET_OFF,VAL_LINE_INTERPRET_ON] select _state);
		profilenamespace setVariable [VAR_LINE_INTERPRET,_state];

		["loadFunction"] call THIS_FUNC;
	};
	case "extensionParsingButtonClick":{
		_params params ["_ctrl"];

		private _state = !(profilenamespace getVariable [VAR_EXT_PARSING,true]);
		_ctrl ctrlSetText ([VAL_EXT_PARSING_OFF,VAL_EXT_PARSING_ON] select _state);
		profilenamespace setVariable [VAR_EXT_PARSING,_state];

		(ctrlParent _ctrl) setVariable [VAR_EXT_LOADED,_state];

		["loadFunction"] call THIS_FUNC;
	};


	case "clearSavedFuncs":{
		USE_DISPLAY(THIS_DISPLAY);
		USE_CTRL(_ctrlViewerContent,IDC_STRUCTURED_VIEWER_CONTENT);

		{
			_ctrlViewerContent setVariable [_x,nil];
			false
		} count (_ctrlViewerContent getVariable [VAR_SAVED_FUNCS,[]]);
		_ctrlViewerContent setVariable [VAR_SAVED_FUNCS,[]];
	};


	case "loadTheme":{
		USE_DISPLAY(THIS_DISPLAY);
		USE_CTRL(_ctrlViewerBG,IDC_STATIC_VIEWER_BG);
		USE_CTRL(_ctrlViewerFunc,IDC_STATIC_VIEWER_FUNC);
		USE_CTRL(_ctrlViewerPath,IDC_STATIC_VIEWER_PATH);

		private _theme = profileNamespace getVariable [VAR_THEME,0];

		private _colourBG = ["themeColour","background"] call THIS_FUNC;
		_ctrlViewerBG ctrlSetBackgroundColor (["htmlToRGBA1",_colourBG] call THIS_FUNC);

		private _colourFunc = ["themeColour","func"] call THIS_FUNC;
		_ctrlViewerFunc ctrlSetTextColor (["htmlToRGBA1",_colourFunc] call THIS_FUNC);

		private _colourPath = ["themeColour","path"] call THIS_FUNC;
		_ctrlViewerPath ctrlSetTextColor (["htmlToRGBA1",_colourPath] call THIS_FUNC);

		["loadFunction"] call THIS_FUNC;
	};


	case "loadFunction":{
		USE_DISPLAY(THIS_DISPLAY);
		USE_CTRL(_ctrlComboLoad,IDC_COMBO_LOAD);
		USE_CTRL(_ctrlViewerLoadbar,IDC_STATIC_VIEWER_LOADBAR);
		USE_CTRL(_ctrlViewerFunc,IDC_STATIC_VIEWER_FUNC);
		USE_CTRL(_ctrlViewerPath,IDC_STATIC_VIEWER_PATH);
		USE_CTRL(_ctrlViewerLines,IDC_STRUCTURED_VIEWER_LINES);
		USE_CTRL(_ctrlViewerContent,IDC_STRUCTURED_VIEWER_CONTENT);

		if !(_display getVariable [VAR_INIT_COMPLETE,false]) exitWith {};

		private _data = profileNamespace getVariable [VAR_SELECTED_FUNC,[]];
		if (_data isEqualTo []) exitWith {};

		private _thread = _ctrlViewerLoadbar getVariable ["thread",scriptNull];
		terminate _thread;

		_data params ["_func","_file"];
		private _fileLoadMode = lbCurSel _ctrlComboLoad;
		private _content = switch _fileLoadMode do {
			case 1:{preprocessFile _file};
			case 2:{preprocessFileLineNumbers _file};
			case 3:{
				private _var = str(switch true do {
					case !(isNil{missionNamespace getVariable _func}):{missionNamespace getVariable _func};
					case !(isNil{uiNamespace getVariable _func}):{uiNamespace getVariable _func};
					default {{}};
				});
				_var select [1,count _var - 2];
			};
			default {loadFile _file};
		};

		_ctrlViewerFunc ctrlSetText _func;
		_ctrlViewerPath ctrlSetText _file;

		private _fontSize = profileNamespace getVariable [VAR_FONT_SIZE,1];

		private _lineInterpretState = profilenamespace getVariable [VAR_LINE_INTERPRET,false];
		private _lineInterpretStateInt = [0,1] select _lineInterpretState;

		private _savedVar = VAL_SAVED_FUNC_VAR(_func);
		private _savedFunc = _ctrlViewerContent getVariable [_savedVar,[]];

		private _savedLineCounts = _savedFunc param [0,[]];
		private _loadModes = _savedLineCounts param [_fileLoadMode,[]];
		private _lineCount = _loadModes param [_lineInterpretStateInt,[]];

		private _extLoaded = _display getVariable [VAR_EXT_LOADED,false];
		private _text = _content;
		private _replaceChars = {
			_text = ["replaceStructuredCharacters",_text] call THIS_FUNC;
			// some files dont use [13,10] new lines :(
			_text = ["stringReplace",[_text,tostring[13],""]] call THIS_FUNC;
			// blank lines dont maintain original line height on modified sizes
			_text = ["stringReplace",[_text,tostring[10],"─<br/>"]] call THIS_FUNC;
			_text = ["stringReplace",[_text,toString[9],"&#32;&#32;&#32;&#32;"]] call THIS_FUNC;
			_text = ["stringReplace",[_text,"    ","&#32;&#32;&#32;&#32;"]] call THIS_FUNC;
		};

		if (_lineCount isEqualTo []) then {
			if _extLoaded then {
				// Call extension to count lines, wait for line breaks
				private _taskID = ["callExtension",["countlines",[text _text,_lineInterpretState && _fileLoadMode in [2,3]]]] call THIS_FUNC;
				if (_taskID == -2) then {_this call THIS_FUNC} else {
					_display setVariable [VAR_EXT_TASK_DATA(_taskID),[_savedVar,_fileLoadMode,_lineInterpretStateInt]];
				};
				breakOut _mode;
			} else {
				call _replaceChars;

				if (_lineInterpretState && _fileLoadMode in [2,3]) then {
					/*
						There are a few things to explain here:
						1. It splits the script string by line so each line is its own string snippet
						2. It splits each line snippet with a space delimeter to seperate the line number value into its own string
						3. It searches for #line at the end of each snippet because sometimes '#line N "script\path"' is appended to the end of a line with existing script commands
						4. It ensures the snippet after #line is a number, otherwise it is most likely #line written into a string, like this mod does a few lines down
					*/
					private _displayI = 1;
					private _textTMP = ["stringSplitString",[_text,"<br/>"]] call THIS_FUNC;
					for "_i" from 0 to count _textTMP - 1 do {
						private _line = _textTMP#_i;
						if ("#line " in _line) then {
							private _lineSplit = _line splitString " ";
							private _lineNumber = parseNumber(_lineSplit#((_lineSplit findIf {["stringEndsWith",[_x,"#line"]] call THIS_FUNC})+1));
							if (_lineNumber > 0) then {
								_displayI = (_lineNumber - 1) max 0;
								_lineCount pushBack "─";
							} else {
								_lineCount pushBack str _displayI;
							};
						} else {
							_lineCount pushBack str _displayI;
						};
						_displayI = _displayI + 1;
					};
				} else {
					for "_i" from 1 to (["stringCount",[_text,"<br/>"]] call THIS_FUNC)+1 do {
						_lineCount pushBack str _i;
					};
				};

				private _savedFuncs = _ctrlViewerContent getVariable [VAR_SAVED_FUNCS,[]];
				_savedFuncs pushBackUnique _savedVar;
				_ctrlViewerContent setVariable [VAR_SAVED_FUNCS,_savedFuncs];

				_loadModes set [_lineInterpretStateInt,_lineCount];
				_savedLineCounts set [_fileLoadMode,_loadModes];
				_savedFunc set [0,_savedLineCounts];
				_ctrlViewerContent setVariable [_savedVar,_savedFunc];
			};
		} else {call _replaceChars};

		_text = format["<t color='%1' size='%2'>",["themeColour",""] call THIS_FUNC,_fontSize]+_text+"</t>";
		_lineCount = format["<t color='%1' size='%2'>",["themeColour","lineNumber"] call THIS_FUNC,_fontSize]+(_lineCount joinString "<br/>")+"</t>";

		_ctrlViewerLines ctrlSetStructuredText parseText _lineCount;
		_ctrlViewerContent ctrlSetStructuredText parseText _text;

		private _ctrlViewerGroup = ctrlParentControlsGroup _ctrlViewerLines;
		private _ctrlViewerGroupP = ctrlPosition _ctrlViewerGroup;

		private _ctrlViewerLinesP = ctrlPosition _ctrlViewerLines;
		_ctrlViewerLinesP set [2,10];
		_ctrlViewerLinesP set [3,10];
		_ctrlViewerLines ctrlSetPosition _ctrlViewerLinesP;
		_ctrlViewerLines ctrlCommit 0;
		_ctrlViewerLinesP set [2,ctrlTextWidth _ctrlViewerLines + PX_WA(2)];
		_ctrlViewerLinesP set [3,(ctrlTextHeight _ctrlViewerLines + PX_HA(2)) max (_ctrlViewerGroupP#3)];
		_ctrlViewerLines ctrlSetPosition _ctrlViewerLinesP;
		_ctrlViewerLines ctrlCommit 0;

		private _ctrlViewerContentP = ctrlPosition _ctrlViewerContent;
		_ctrlViewerContentP set [2,10];
		_ctrlViewerContentP set [3,10];
		_ctrlViewerContent ctrlSetPosition _ctrlViewerContentP;
		_ctrlViewerContent ctrlCommit 0;
		_ctrlViewerContentP set [0,_ctrlViewerLinesP#2];
		_ctrlViewerContentP set [2,ctrlTextWidth _ctrlViewerContent + PX_WA(10)];
		_ctrlViewerContentP set [3,_ctrlViewerLinesP#3];
		_ctrlViewerContent ctrlSetPosition _ctrlViewerContentP;
		_ctrlViewerContent ctrlCommit 0;

		private _ctrlViewerLoadbarP = ctrlPosition _ctrlViewerLoadbar;
		private _ctrlViewerLoadbarW = _ctrlViewerLoadbar getVariable ["width",0];
		_ctrlViewerLoadbarP set [2,_ctrlViewerLoadbarW];
		_ctrlViewerLoadbar ctrlSetPosition _ctrlViewerLoadbarP;
		_ctrlViewerLoadbar ctrlCommit 0;
		if (profileNamespace getVariable [VAR_HIGHLIGHT,true]) then {
			_thread = ["highlightContent",[_func,_content]] spawn THIS_FUNC;
			_ctrlViewerLoadbar setVariable ["thread",_thread];
		};
	};
	case "highlightContent":{
		_params params ["_func","_text"];

		USE_DISPLAY(THIS_DISPLAY);
		USE_CTRL(_ctrlComboLoad,IDC_COMBO_LOAD);
		USE_CTRL(_ctrlViewerLoadbar,IDC_STATIC_VIEWER_LOADBAR);
		USE_CTRL(_ctrlViewerContent,IDC_STRUCTURED_VIEWER_CONTENT);

		private _savedVar = VAL_SAVED_FUNC_VAR(_func);
		private _savedFunc = _ctrlViewerContent getVariable [_savedVar,[]];

		private _theme = profileNamespace getVariable [VAR_THEME,0];
		private _fileLoadMode = lbCurSel _ctrlComboLoad;

		private _savedContents = _savedFunc param [1,[]];
		private _themeFunc = _savedContents param [_theme,[]];
		private _output = _themeFunc param [_fileLoadMode,""];

		private _ctrlViewerLoadbarP = ctrlPosition _ctrlViewerLoadbar;
		private _ctrlViewerLoadbarW = _ctrlViewerLoadbar getVariable ["width",0];

		if (_output == "") then {
			private _extLoaded = _display getVariable [VAR_EXT_LOADED,false];
			if _extLoaded then {
				// Execute in unscheduled to ensure the script exits before the callback event fires
				isNil {
					private _themeColours = [
						"comment",
						"string",
						"number",
						"magicVar",
						"localVar",
						"function",
						"preprocessor",
						"keyword",
						"literal",
						"null",
						"command",
						"globalVar"
					] apply {["themeColour",_x] call THIS_FUNC};

					private _taskID = ["callExtension",["highlight",[text _text,_themeColours]]] call THIS_FUNC;
					if (_taskID == -2) then {_this call THIS_FUNC} else {
						_display setVariable [VAR_EXT_TASK_DATA(_taskID),[_savedVar,_fileLoadMode,_theme,_params]];
					};

					breakOut _mode;
				};
			} else {
				_output = [];
				private _textArray = _text splitString "";
				private _segment = "";

				private _letters = VAL_LETTERS;
				private _varChars = VAL_VAR_CHARS;
				private _digitChars = VAL_DIGIT_CHARS;
				private _spaceTab = [tostring[32],tostring[9]];
				private _supportedOperators = _display getVariable ["supportedOperators",[]];
				private _supportedCommands = _display getVariable ["supportedCommands",[]];

				private _push = {
					if (_segment != "") then {
						_output pushBack _segment;
						_segment = "";
					};
				};

				private _textLen = count _text;

				for "_i" from 0 to (_textLen - 1) do {
					if (isNull _ctrlViewerLoadbar) then {terminate _thisScript};
					_ctrlViewerLoadbarP set [2,linearConversion[0,_textLen,_i,0,0.75*_ctrlViewerLoadbarW,true]];
					_ctrlViewerLoadbar ctrlSetPosition _ctrlViewerLoadbarP;
					_ctrlViewerLoadbar ctrlCommit 0;

					private _thisChar = _textArray param [_i,""];
					private _prevChar = _textArray param [_i - 1,""];
					private _nextChar = _textArray param [_i + 1,""];

					switch true do {
						case (_thisChar == "/" && _nextChar == "*"):{
							call _push;
							_segment = _text select [_i,_textLen];
							_index = 4 + ((_segment select [2,count _segment]) find ("*/"));
							if (_index == -1) then {_index = count _segment};
							_segment = _segment select [0,_index];
							call _push;
							_i = _i + _index - 1;
						};
						case (_thisChar == "/" && _nextChar == "/"):{
							call _push;
							_segment = _text select [_i,_textLen];
							_index = _segment find tostring[10];
							if (_index == -1) then {_index = count _segment};
							_segment = _segment select [0,_index];
							call _push;
							_i = _i + _index - 1;
						};
						case (_thisChar in VAL_QUOTES):{
							call _push;
							_segment = _text select [_i,_textLen];
							_index = 2 + ((_segment select [1,count _segment]) find _thisChar);
							if (_index == -1) then {_index = count _segment};
							_segment = _segment select [0,_index];
							call _push;
							_i = _i + _index - 1;
						};
						case (_thisChar in _digitChars):{
							call _push;
							private _tmp_segment = _textArray select [_i,_textLen];
							_tmp_segment = _tmp_segment select [0,count _tmp_segment];
							_index = _tmp_segment findIf {!(_x in _digitChars)};
							if (_index == -1) then {_index = count _tmp_segment};
							// TODO: simplify double select
							_segment = (_text select [_i,_textLen]) select [0,_index];
							call _push;
							_i = _i + _index - 1;
						};
						case (_thisChar in _varChars):{
							call _push;
							private _tmp_segment = _textArray select [_i,_textLen];
							_tmp_segment = _tmp_segment select [0,count _tmp_segment];
							_index = _tmp_segment findIf {!(_x in _varChars)};
							if (_index == -1) then {_index = count _tmp_segment};
							// TODO: simplify double select
							_segment = (_text select [_i,_textLen]) select [0,_index];
							call _push;
							_i = _i + _index - 1;
						};
						case (_thisChar in VAL_BRACKETS);
						case (_thisChar in [",","#",toString[10]]):{
							call _push;
							_segment = _thisChar;
							call _push;
						};
						default {
							if (
								(_thisChar in _spaceTab && !(_prevChar in _spaceTab)) ||
								{_prevChar in _spaceTab && !(_thisChar in _spaceTab)}
							) then {
								call _push;
							};
							_segment = _segment + _thisChar;
						};
					};
				};

				call _push;

				private _outputLen = count _output - 1;
				{
					if (isNull _ctrlViewerLoadbar) then {terminate _thisScript};
					_ctrlViewerLoadbarP set [2,linearConversion[0,_outputLen,_forEachIndex,0.75*_ctrlViewerLoadbarW,0.99*_ctrlViewerLoadbarW,true]];
					_ctrlViewerLoadbar ctrlSetPosition _ctrlViewerLoadbarP;
					_ctrlViewerLoadbar ctrlCommit 0;

					private _type = switch true do {
						case ((_x select [0,2]) in ["/*","//"]):{"comment"};
						case ((_x select [0,1]) in ["'",""""]):{"string"};
						case ((_x select [0,1]) in _digitChars && {((_x splitstring "") - _digitChars) isEqualTo []}):{"number"};
						case (tolower _x in VAL_MAGIC_VARS):{"magicVar"};
						case ((_x select [0,1]) in ["_"] && {((_x splitstring "") - _varChars) isEqualTo []}):{"localVar"};
						case ((["_fnc_",_x select [1,count _x - 2]] call BIS_fnc_inString) && {((_x splitstring "") - _varChars) isEqualTo []}):{"function"};
						//case (_x in VAL_BRACKETS):{"bracket"};
						//case (_x in _supportedOperators):{"operator"};
						case (tolower _x in VAL_PREPROCESSOR && {(_output param [_forEachIndex - 1,""]) == "#"}):{"preprocessor"};
						case (tolower _x in VAL_KEYWORDS):{"keyword"};
						case (tolower _x in VAL_LITERALS):{"literal"};
						case (tolower _x in VAL_NULLS):{"null"};
						case (tolower _x in _supportedCommands):{"command"};
						case (((_x splitstring "") - _varChars) isEqualTo []):{"globalVar"};
						default {""};
					};
					_x = ["replaceStructuredCharacters",_x] call THIS_FUNC;
					_output set [_forEachIndex,
						if (_type == "") then {_x} else {
							"<t color='"+(["themeColour",_type] call THIS_FUNC)+"'>"+_x+"</t>"
						}
					];
				} foreach _output;

				_output = ["stringReplace",[_output joinstring "",tostring[13],""]] call THIS_FUNC;
				// blank lines dont maintain original line height on modified sizes
				_output = ["stringReplace",[_output,toString[10],"─<br/>"]] call THIS_FUNC;
				_output = ["stringReplace",[_output,toString[9],"&#32;&#32;&#32;&#32;"]] call THIS_FUNC;
			};

			private _savedFuncs = _ctrlViewerContent getVariable [VAR_SAVED_FUNCS,[]];
			_savedFuncs pushBackUnique _savedVar;
			_ctrlViewerContent setVariable [VAR_SAVED_FUNCS,_savedFuncs];

			_themeFunc set [_fileLoadMode,_output];
			_savedContents set [_theme,_themeFunc];
			_savedFunc set [1,_savedContents];
			_ctrlViewerContent setVariable [_savedVar,_savedFunc];
		};

		_ctrlViewerContent ctrlSetStructuredText parseText (format["<t color='%1' size='%2'>",["themeColour",""] call THIS_FUNC,profileNamespace getVariable [VAR_FONT_SIZE,1]] + _output + "</t>");

		_ctrlViewerLoadbarP set [2,_ctrlViewerLoadbarW];
		_ctrlViewerLoadbar ctrlSetPosition _ctrlViewerLoadbarP;
		_ctrlViewerLoadbar ctrlCommit 0;
	};
	case "themeColour":{
		private _theme = profileNamespace getVariable [VAR_THEME,0];
		(switch _params do {//         dark+     light+    one dark  one light
			case "background":		{["#1e1e1e","#ffffff","#282c34","#fafafa"]};
			case "func":			{["#e9e9e9","#0e0e0e","#eaeaeb","#333333"]};
			case "path":			{["#959595","#424242","#949597","#4B4B4B"]};
			case "lineNumber":		{["#858585","#227893","#495162","#5C5C5C"]};

			case "comment":			{["#608932","#098000","#7f848f","#a0a1a7"]};
			case "string":			{["#ce9178","#a31514","#7dc361","#50a150"]};
			case "number":			{["#a9cd88","#09885a","#d19a66","#986801"]};
			case "magicVar":		{["#569cd6","#033cff","#e5c07b","#e4564a"]};
			case "localVar":		{["#9cdcfe","#001980","#e06c75","#e4564a"]};
			case "function":		{["#e8e8e7","#795e26","#56b6c2","#0084bc"]};
			//case "bracket":		{[]};
			//case "operator":		{[]};
			case "preprocessor":	{["#9cdcfe","#001980","#e06c75","#e4564a"]};
			case "keyword":			{["#c586c0","#af2adb","#c678de","#a626a4"]};
			case "literal":			{["#569cd6","#033cff","#e5c07b","#e4564a"]};
			case "null":			{["#569cd6","#795e26","#d19a66","#986801"]};
			case "command":			{["#dcdcaa","#795e26","#61afef","#4178f2"]};
			case "globalVar":		{["#e8e8e7","#001980","#56b6c2","#0084bc"]};

			default 				{["#d4d4d4","#000000","#bbbbbb","#333333"]};
		})#_theme;
	};


	case "callExtension":{
		_params params ["_func","_data"];
		private _return = "ExtendedFunctionViewer" callExtension [_func,_data];
		_return params ["","_taskID"];
		USE_DISPLAY(THIS_DISPLAY);
		_display setVariable [VAR_EXT_TASK_ID,_taskID];
		if (_taskID == -2) then {
			[
				"Extension parsing encountered an error.<br/>Reverting to sqf parsing.",
				"ExtendedFunctionViewer",
				true,false,
				"\a3\3den\data\displays\display3denmsgbox\picture_ca.paa",
				_display
			] call BIS_fnc_3DENShowMessage;

			_display setVariable [VAR_EXT_LOADED,false];

			USE_CTRL(_ctrlButtonExtParsing,IDC_BUTTON_EXT_PARSING);
			_ctrlButtonExtParsing ctrlEnable false;
			_ctrlButtonExtParsing ctrlRemoveAllEventHandlers "ButtonClick";
			_ctrlButtonExtParsing ctrlSetTooltip "Extension parsing is not available.";
		};
		_taskID
	};
	case "extensionCallback":{
		_params params ["_name","_func","_data"];
		if (_name != "cau_extendedfunctionviewer") exitWith {};

		(_func splitString ":") params ["_func","_taskID"];
		_taskID = parseNumber _taskID;

		USE_DISPLAY(THIS_DISPLAY);

		private _activeTaskID = _display getVariable [VAR_EXT_TASK_ID,-1];
		if (_taskID != _activeTaskID) exitWith {};

		private _taskData = _display getVariable [VAR_EXT_TASK_DATA(_taskID),[]];
		_taskData params ["_savedVar","_fileLoadMode"];

		USE_CTRL(_ctrlViewerContent,IDC_STRUCTURED_VIEWER_CONTENT);

		private _savedFunc = _ctrlViewerContent getVariable [_savedVar,[]];
		private _savedFuncs = _ctrlViewerContent getVariable [VAR_SAVED_FUNCS,[]];
		_savedFuncs pushBackUnique _savedVar;
		_ctrlViewerContent setVariable [VAR_SAVED_FUNCS,_savedFuncs];

		switch _func do {
			case "countlines":{
				_taskData params ["","","_lineInterpretStateInt"];

				private _savedLineCounts = _savedFunc param [0,[]];
				private _loadModes = _savedLineCounts param [_fileLoadMode,[]];
				private _lineCount = _loadModes param [_lineInterpretStateInt,[]];

				_loadModes set [_lineInterpretStateInt,parseSimpleArray toString parseSimpleArray _data];
				_savedLineCounts set [_fileLoadMode,_loadModes];
				_savedFunc set [0,_savedLineCounts];
				_ctrlViewerContent setVariable [_savedVar,_savedFunc];

				["loadFunction"] call THIS_FUNC;
			};
			case "highlight":{
				_taskData params ["","","_theme","_arguments"];

				private _savedContents = _savedFunc param [1,[]];
				private _themeFunc = _savedContents param [_theme,[]];

				_themeFunc set [_fileLoadMode,toString parseSimpleArray _data];
				_savedContents set [_theme,_themeFunc];
				_savedFunc set [1,_savedContents];
				_ctrlViewerContent setVariable [_savedVar,_savedFunc];

				USE_CTRL(_ctrlViewerLoadbar,IDC_STATIC_VIEWER_LOADBAR);
				private _thread = _ctrlViewerLoadbar getVariable ["thread",scriptNull];
				terminate _thread;
				_thread = ["highlightContent",_arguments] spawn THIS_FUNC;
				_ctrlViewerLoadbar setVariable ["thread",_thread];
			};
		};

		_display setVariable [VAR_EXT_TASK_DATA(_taskID),nil];
	};


	case "recompileButtonClick":{
		_params params ["_ctrl"];
		USE_DISPLAY(ctrlParent _ctrl);
		USE_CTRL(_ctrlViewerContent,IDC_STRUCTURED_VIEWER_CONTENT);

		private _data = profileNamespace getVariable [VAR_SELECTED_FUNC,[]];
		if (_data isEqualTo []) exitWith {};

		_data params ["_func"];
		_func call BIS_fnc_recompile;

		_ctrlViewerContent setVariable [VAL_SAVED_FUNC_VAR(_func),nil];
		["loadFunction"] call THIS_FUNC;
	};
	case "recompileAllButtonClick":{
		1 call BIS_fnc_recompile;

		["clearSavedFuncs"] call THIS_FUNC;
		["loadFunction"] call THIS_FUNC;
	};
	case "copyButtonClick":{
		_params params ["_ctrl"];
		USE_DISPLAY(ctrlParent _ctrl);
		USE_CTRL(_ctrlComboLoad,IDC_COMBO_LOAD);

		private _data = profileNamespace getVariable [VAR_SELECTED_FUNC,[]];
		if (_data isEqualTo []) exitWith {};

		_data params ["_func","_file"];
		private _content = switch (lbCurSel _ctrlComboLoad) do {
			case 1:{preprocessFile _file};
			case 2:{preprocessFileLineNumbers _file};
			case 3:{
				private _var = str(missionNamespace getVariable [_func,{}]);
				_var select [1,count _var - 2];
			};
			default {loadFile _file};
		};

		// done like this so you can copy functions in MP too
		uiNameSpace setVariable ["Display3DENCopy_data",[_data#0,_content]];
		(THIS_DISPLAY) createDisplay "Display3DENCopy";
	};
	case "executeButtonClick":{
		_params params ["_ctrlButtonExecute"];

		private _data = profileNamespace getVariable [VAR_SELECTED_FUNC,[]];
		if (_data isEqualTo []) exitWith {};

		if (isNil "CAU_UserInputMenus_fnc_text") exitWith {
			[
				"<a href='https://steamcommunity.com/sharedfiles/filedetails/?id=1673595418'>User Input Menus</a> is required to execute functions.",
				"Missing Mod"
			] spawn BIS_fnc_guiMessage;
		};

		[
			[false,""],
			"Function Arguments",
			compile ("
				if _confirmed then {
					['executeArgumentProvided',[_text,'"+(_data#0)+"','"+(_data#1)+"']] call "+QUOTE(THIS_FUNC)+";
				};
			"),
			"Execute","",
			ctrlParent _ctrlButtonExecute
		] call CAU_UserInputMenus_fnc_text;
	};
	case "executeArgumentProvided":{
		_params params ["_text","_func","_file"];

		USE_DISPLAY(THIS_DISPLAY);
		USE_CTRL(_ctrlButtonExecute,IDC_BUTTON_EXECUTE);

		_ctrlButtonExecute ctrlEnable false;
		_ctrlButtonExecute ctrlSetText "Executing...";

		// spawn to ensure no errors occur from unscheduled execution
		[_ctrlButtonExecute,_text,_func,_file] spawn {
			params ["_ctrlButtonExecute","_text","_func","_file"];

			// Can't call _code with a nil argument, `nil call {}` doesn't execute and `call {}` inherits the upper scope's _this variable so nil arguments must default to a value (an array in this case)
			private _arguments = [call compile _text] param [0,[]];
			private _code = missionNameSpace getVariable [_func,0];
			if !(_code isEqualType {}) then {
				// do it in an if statement so we arent preprocessing a file if it has already loaded into a function
				_code = compile preprocessFileLineNumbers _file;
			};

			private _tick = diag_tickTime;
			private _return = [_arguments,_code] call {
				private ["_ctrlButtonExecute","_text","_func","_file","_arguments","_code","_tick"];
				(_this#0) call (_this#1);
			};
			private _duration = (diag_tickTime - _tick) * 1000;

			_ctrlButtonExecute ctrlEnable true;
			_ctrlButtonExecute ctrlSetText (_ctrlButtonExecute getVariable "text");

			if (isNil "_return") then {
				_return = text "";
			};

			uiNameSpace setVariable ["Display3DENCopy_data",[format["Return of %1 (%2ms)",_func,_duration toFixed 4],str _return]];
			(THIS_DISPLAY) createDisplay "Display3DENCopy";
		};
	};


	case "stringReplace":{
		_params params ["_input","_find","_replace"];
		private _findLen = count _find;
		_find = toLower _find;
		private _output = [];
		private _index = -1;
		for "_i" from 0 to 1 step 0 do {
			_index = tolower _input find _find;
			if (_index < 0) exitwith {_output pushback _input;};
			_output pushback (_input select [0,_index]);
			_output pushback _replace;
			_input = _input select [_index + _findLen,count _input];
		};
		_output joinString ""
	};
	case "stringSplitString":{
		_params params ["_input","_find"];
		private _findLen = count _find;
		_find = toLower _find;
		private _output = [];
		private _index = -1;
		for "_i" from 0 to 1 step 0 do {
			_index = tolower _input find _find;
			if (_index < 0) exitwith {_output pushback _input;};
			_output pushback (_input select [0,_index]);
			_input = _input select [_index + _findLen,count _input];
		};
		_output
	};
	case "stringStartsWith":{
		_params params ["_string","_search"];
		tolower _string find tolower _search == 0;
	};
	case "stringEndsWith":{
		_params params ["_string","_search"];
		(_string select [count _string - count _search,count _search]) == _search;
	};
	case "stringCount":{
		_params params ["_input","_find"];
		private _findLen = count _find;
		_find = toLower _find;
		private _found = 0;
		private _index = -1;
		for "_i" from 0 to 1 step 0 do {
			_index = tolower _input find _find;
			if (_index < 0) exitwith {};
			_found = _found + 1;
			_input = _input select [_index + _findLen,count _input];
		};
		_found
	};
	case "replaceStructuredCharacters":{
		{
			_params = ["stringReplace",[_params,_x#0,_x#1]] call THIS_FUNC;
			false
		} count [
			["&","&amp;"],
			["<","&lt;"],
			[">","&gt;"]
		];
		_params
	};
	case "htmlToRGBA1":{
		// Source: https://github.com/ConnorAU/A3ColorPicker
		private _out = [];
		{
			_out pushback linearConversion[0,255,[
				"00","01","02","03","04","05","06","07","08","09","0A","0B","0C","0D","0E","0F",
				"10","11","12","13","14","15","16","17","18","19","1A","1B","1C","1D","1E","1F",
				"20","21","22","23","24","25","26","27","28","29","2A","2B","2C","2D","2E","2F",
				"30","31","32","33","34","35","36","37","38","39","3A","3B","3C","3D","3E","3F",
				"40","41","42","43","44","45","46","47","48","49","4A","4B","4C","4D","4E","4F",
				"50","51","52","53","54","55","56","57","58","59","5A","5B","5C","5D","5E","5F",
				"60","61","62","63","64","65","66","67","68","69","6A","6B","6C","6D","6E","6F",
				"70","71","72","73","74","75","76","77","78","79","7A","7B","7C","7D","7E","7F",
				"80","81","82","83","84","85","86","87","88","89","8A","8B","8C","8D","8E","8F",
				"90","91","92","93","94","95","96","97","98","99","9A","9B","9C","9D","9E","9F",
				"A0","A1","A2","A3","A4","A5","A6","A7","A8","A9","AA","AB","AC","AD","AE","AF",
				"B0","B1","B2","B3","B4","B5","B6","B7","B8","B9","BA","BB","BC","BD","BE","BF",
				"C0","C1","C2","C3","C4","C5","C6","C7","C8","C9","CA","CB","CC","CD","CE","CF",
				"D0","D1","D2","D3","D4","D5","D6","D7","D8","D9","DA","DB","DC","DD","DE","DF",
				"E0","E1","E2","E3","E4","E5","E6","E7","E8","E9","EA","EB","EC","ED","EE","EF",
				"F0","F1","F2","F3","F4","F5","F6","F7","F8","F9","FA","FB","FC","FD","FE","FF"
			] find toUpper _x,0,1,true];
		} foreach [
			_params select [1,2],
			_params select [3,2],
			_params select [5,2]
		];
		_out + [1]
	};
};
