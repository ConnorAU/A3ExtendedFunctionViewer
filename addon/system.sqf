/*──────────────────────────────────────────────────────┐
│   Author: Connor                                      │
│   Steam:  https://steamcommunity.com/id/_connor       │
│   Github: https://github.com/ConnorAU                 │
│                                                       │
│   Please do not modify or remove this comment block   │
└──────────────────────────────────────────────────────*/

#define THIS_FUNC CAU_xFuncViewer_fnc_system
#define DISPLAY_NAME CAU_displayExtendedFunctionViewer

#include "\a3\3den\ui\dikcodes.inc"
#include "\a3\3den\ui\macros.inc"
#include "_defines.inc"

#define VAR_THEME QUOTE(FUNC_SUBVAR(setting_theme))
#define VAR_LOAD QUOTE(FUNC_SUBVAR(setting_load))
#define VAR_HIGHLIGHT QUOTE(FUNC_SUBVAR(setting_highlight))
#define VAR_FONT_SIZE QUOTE(FUNC_SUBVAR(setting_font_size))
#define VAR_TREE_MODE QUOTE(FUNC_SUBVAR(setting_tree_mode))

#define VAR_SELECTED_FUNC QUOTE(FUNC_SUBVAR(selected_func))

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

#define VAL_PREPROCESSOR ["include","define","ifdef","ifndef",/*"else",*/"endif","line"]
#define VAL_KEYWORDS ["case","catch","default","do","else","exit","exitwith","for","foreach","from","if","private","switch","then","throw","to","try","waituntil","while","with"]
#define VAL_LITTERALS ["blufor","civilian","confignull","controlnull","displaynull","east","endl","false","grpnull","independent","linebreak","locationnull","nil","objnull","opfor","pi","resistance","scriptnull","sideambientlife","sideempty","sidelogic","sideunknown","tasknull","teammembernull","true","west"]
#define VAL_MAGIC_VARS ["_this","_x","_foreachindex","_exception","_thisscript","_thisfsm","_thiseventhandler"]
#define VAL_NULLS ["nil","controlnull","displaynull","grpnull","locationnull","netobjnull","objnull","scriptnull","tasknull","teammembernull","confignull"]

#define VAL_SYNTAX_ON  "\cau\extendedfunctionviewer\a_highlight.paa"
#define VAL_SYNTAX_OFF "\cau\extendedfunctionviewer\a_plain.paa"


params[["_mode","",[""]],["_params",[]]];

switch _mode do {
	case "init":{
		ctrlParent(_params#0) createDisplay QUOTE(DISPLAY_NAME);
		USE_DISPLAY(THIS_DISPLAY);
		USE_CTRL(_ctrlTitle,IDC_STATIC_TITLE);
		USE_CTRL(_ctrlEditSearch,IDC_EDIT_SEARCH);
		USE_CTRL(_ctrlButtonSearch,IDC_BUTTON_SEARCH);
		USE_CTRL(_ctrlComboTheme,IDC_COMBO_THEME);
		USE_CTRL(_ctrlComboLoad,IDC_COMBO_LOAD);
		USE_CTRL(_ctrlButtonHighlight,IDC_BUTTON_HIGHLIGHT);
		USE_CTRL(_ctrlButtonSizeDown,IDC_BUTTON_SIZEDOWN);
		USE_CTRL(_ctrlButtonSizeUp,IDC_BUTTON_SIZEUP);
		USE_CTRL(_ctrlComboTree,IDC_COMBO_TREE_MODE);
		USE_CTRL(_ctrlButtonCollapse,IDC_BUTTON_TREE_COLLAPSE);
		USE_CTRL(_ctrlButtonExpand,IDC_BUTTON_TREE_EXPAND);
		USE_CTRL(_ctrlTree,IDC_TREE_VIEW);
		USE_CTRL(_ctrlViewerLoadbar,IDC_STATIC_VIEWER_LOADBAR);
		USE_CTRL(_ctrlButtonCopy,IDC_BUTTON_COPY);
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
			"preprocessFileLineNumbers"
		];
		_ctrlComboLoad ctrlSetTooltip "Function viewer file loading method";
		_ctrlComboLoad ctrlAddEventHandler ["LBSelChanged",{["loadLBSelChanged",_this] call THIS_FUNC}];
		_ctrlComboLoad lbSetCurSel (profileNamespace getVariable [VAR_LOAD,0]);

		_ctrlButtonHighlight ctrlSetText ([VAL_SYNTAX_OFF,VAL_SYNTAX_ON] select (profilenamespace getVariable [VAR_HIGHLIGHT,true]));
		_ctrlButtonHighlight ctrlSetTooltip "Toggle Syntax Highlighting";
		_ctrlButtonHighlight ctrlAddEventHandler ["ButtonClick",{["highlightButtonClick",_this] call THIS_FUNC}];


		_ctrlButtonSizeDown ctrlSetText "\cau\extendedfunctionviewer\a_down.paa";
		_ctrlButtonSizeDown ctrlSetTooltip "Decrease font size";
		_ctrlButtonSizeDown ctrlAddEventHandler ["ButtonClick",{["sizeButtonClick",_this] call THIS_FUNC}];

		_ctrlButtonSizeUp ctrlSetText "\cau\extendedfunctionviewer\a_up.paa";
		_ctrlButtonSizeUp ctrlSetTooltip "Increase font size";
		_ctrlButtonSizeUp ctrlAddEventHandler ["ButtonClick",{["sizeButtonClick",_this] call THIS_FUNC}];

		{_ctrlComboTree lbAdd _x} forEach [
			"CfgFunctions Hierarchy",
			"CfgFunctions Parent Groups",
			"Function Tags"
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

		["populateTree"] call THIS_FUNC;
	};
	case "onLoad":{
		uiNamespace setVariable [QUOTE(DISPLAY_NAME),_params#0];
	};


	case "populateTree":{
		USE_DISPLAY(THIS_DISPLAY);
		USE_CTRL(_ctrlTree,IDC_TREE_VIEW);
		USE_CTRL(_ctrlEditSearch,IDC_EDIT_SEARCH);
		USE_CTRL(_ctrlComboTree,IDC_COMBO_TREE);
	
		private _searchTerm = ctrlText _ctrlEditSearch;
		private _noSearch = _searchTerm == "";
		private _mode = profileNamespace getVariable [VAR_TREE_MODE,lbCurSel _ctrlComboTree];

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
		private _finalizePath = {
			if ((_ctrlTree tvCount _this) > 0) then {
				_ctrlTree tvSort [_this,false];
			} else {
				if !_noSearch then {
					_ctrlTree tvDelete _this;
				};
			};
		};

		private _data = uiNamespace getVariable [VAR_SELECTED_FUNC,[]];
		tvClear _ctrlTree;
		// bug fix: "tvCollapseAll" hides new entries
		tvExpandAll _ctrlTree;

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

								if (_data isEqualTo [_fileVar,_filePath]) then {
									_ctrlTree tvExpand [_configFileIndex,_rootIndex,_subIndex];
									_ctrlTree tvSetCurSel [_configFileIndex,_rootIndex,_subIndex,_fileIndex];
								};
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

								if (_data isEqualTo [_fileVar,_filePath]) then {
									_ctrlTree tvExpand [_parentIndex];
									_ctrlTree tvSetCurSel [_parentIndex,_fileIndex];
								};
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

								if (_data isEqualTo [_fileVar,_filePath]) then {
									_ctrlTree tvExpand [_rootIndex];
									_ctrlTree tvSetCurSel [_rootIndex,_fileIndex];
								};
							} forEach _subData;
						} foreach _rootData;
						[_rootIndex] call _finalizePath;
					} foreach _configData;
					[] call _finalizePath;
				};
			};

			if !_noSearch then {
				tvExpandAll _ctrlTree;
			};
		} forEach [
			[configFile,"configFile"] call _buildTreeData,
			[campaignConfigFile,"campaignConfigFile"] call _buildTreeData,
			[missionConfigFile,"missionConfigFile"] call _buildTreeData
		];
	};
	case "treeTVSelChanged":{
		_params params ["_ctrlTree","_selectionPath"];
		private _data = _ctrlTree tvData _selectionPath;
		if (_data != "") then {
			USE_DISPLAY(ctrlParent _ctrlTree);
			uiNamespace setVariable [VAR_SELECTED_FUNC,parseSimpleArray _data];
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
		saveProfilenamespace;
		switch _mode do {
			case "themeLBSelChanged":{["loadTheme"] call THIS_FUNC};
			case "loadLBSelChanged":{["loadFunction"] call THIS_FUNC};
			case "treeLBSelChanged":{["populateTree"] call THIS_FUNC};
		};
	};
	case "highlightButtonClick":{
		_params params ["_ctrl"];

		private _state = !(profilenamespace getVariable [VAR_HIGHLIGHT,true]);
		_ctrl ctrlSetText ([VAL_SYNTAX_OFF,VAL_SYNTAX_ON] select _state);
		profilenamespace setVariable [VAR_HIGHLIGHT,_state];
		saveProfilenamespace;

		["loadFunction"] call THIS_FUNC;
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
		saveProfilenamespace;

		["clearSavedFuncs"] call THIS_FUNC;
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
		USE_CTRL(_ctrlButtonHighlight,IDC_BUTTON_HIGHLIGHT);
		USE_CTRL(_ctrlTree,IDC_TREE_VIEW);
		USE_CTRL(_ctrlViewerLoadbar,IDC_STATIC_VIEWER_LOADBAR);
		USE_CTRL(_ctrlViewerFunc,IDC_STATIC_VIEWER_FUNC);
		USE_CTRL(_ctrlViewerPath,IDC_STATIC_VIEWER_PATH);
		USE_CTRL(_ctrlViewerLines,IDC_STRUCTURED_VIEWER_LINES);
		USE_CTRL(_ctrlViewerContent,IDC_STRUCTURED_VIEWER_CONTENT);

			
		private _data = uiNamespace getVariable [VAR_SELECTED_FUNC,[]];
		if (_data isEqualTo []) exitWith {};

		private _thread = _ctrlViewerLoadbar getVariable ["thread",scriptNull];
		terminate _thread;

		_data params ["_func","_file"];
		private _content = switch (lbCurSel _ctrlComboLoad) do {
			case 1:{preprocessFile _file};
			case 2:{preprocessFileLineNumbers _file};
			default {loadFile _file};
		};

		_ctrlViewerFunc ctrlSetText _func;
		_ctrlViewerPath ctrlSetText _file;

		private _fontSize = profileNamespace getVariable [VAR_FONT_SIZE,1];

		private _text = ["replaceStructuredCharacters",_content] call THIS_FUNC;

		// some files dont use [13,10] new lines :(
		_text = ["stringReplace",[_text,tostring[13],""]] call THIS_FUNC;
		// blank lines dont maintain original line height on modified sizes
		_text = ["stringReplace",[_text,tostring[10],"─<br/>"]] call THIS_FUNC;
		_text = ["stringReplace",[_text,toString[9],"&#32;&#32;&#32;&#32;"]] call THIS_FUNC;
		_text = ["stringReplace",[_text,"    ","&#32;&#32;&#32;&#32;"]] call THIS_FUNC;
		_text = format["<t color='%1' size='%2'>",["themeColour",""] call THIS_FUNC,_fontSize]+_text+"</t>";

		private _lineCount = [];
		for "_i" from 1 to (["stringCount",[_text,"<br/>"]] call THIS_FUNC)+1 do {
			_lineCount pushBack str _i;
		};
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
			_thread = ["highlightContent",[_func,_content,_display,_ctrlComboLoad,_ctrlViewerContent,_ctrlViewerLoadbar]] spawn THIS_FUNC;
			_ctrlViewerLoadbar setVariable ["thread",_thread];
		};
	};		
	case "highlightContent":{
		_params params ["_func","_text","_display","_ctrlComboLoad","_ctrlViewerContent","_ctrlViewerLoadbar"];

		private _savedVar = VAL_SAVED_FUNC_VAR(_func);
		private _savedFunc = _ctrlViewerContent getVariable [_savedVar,[]];

		private _theme = profileNamespace getVariable [VAR_THEME,0];
		private _mode = lbCurSel _ctrlComboLoad;

		if ((_savedFunc param [_theme,[]] param [_mode,""]) != "") exitWith {
			_ctrlViewerContent ctrlSetStructuredText parseText (_savedFunc#_theme#_mode);
		};

		private _textArray = _text splitString "";
		private _output = [];
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

		private _ctrlViewerLoadbarP = ctrlPosition _ctrlViewerLoadbar;
		private _ctrlViewerLoadbarW = _ctrlViewerLoadbar getVariable ["width",0];

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
					_index = (_segment select [0,count _segment]) find tostring[10];
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
					_segment = (_text select [_i,_textLen]) select [0,_index];	
					call _push;
					_i = _i + _index - 1;
				};
				case (_thisChar in VAL_BRACKETS);
				case (_thisChar == ",");
				case (_thisChar == tostring[10]):{
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
				case (tolower _x in VAL_PREPROCESSOR):{"preprocessor"};
				case (tolower _x in VAL_KEYWORDS):{"keyword"};
				case (tolower _x in VAL_LITTERALS):{"litteral"};
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

		_output = [format["<t color='%1' size='%2'>",["themeColour",""] call THIS_FUNC,profileNamespace getVariable [VAR_FONT_SIZE,1]]] + _output + ["</t>"];
		_output = ["stringReplace",[_output joinstring "",tostring[13],""]] call THIS_FUNC;
		// blank lines dont maintain original line height on modified sizes
		_output = ["stringReplace",[_output,toString[10],"─<br/>"]] call THIS_FUNC;
		_output = ["stringReplace",[_output,toString[9],"&#32;&#32;&#32;&#32;"]] call THIS_FUNC;

		_ctrlViewerContent ctrlSetStructuredText parseText _output;

		_ctrlViewerLoadbarP set [2,_ctrlViewerLoadbarW];
		_ctrlViewerLoadbar ctrlSetPosition _ctrlViewerLoadbarP;
		_ctrlViewerLoadbar ctrlCommit 0;

		private _savedFuncs = _ctrlViewerContent getVariable [VAR_SAVED_FUNCS,[]];
		_savedFuncs pushBackUnique _savedVar;
		_ctrlViewerContent setVariable [VAR_SAVED_FUNCS,_savedFuncs];

		private _themeFunc = _savedFunc param [_theme,[]];
		_themeFunc set [_mode,_output];
		_savedFunc set [_theme,_themeFunc];
		_ctrlViewerContent setVariable [_savedVar,_savedFunc];
	};
	case "themeColour":{
		private _theme = profileNamespace getVariable [VAR_THEME,0];
		switch _params do {//         dark+     light+    one dark  one light
			case "background":		{["#1e1e1e","#ffffff","#282c34","#fafafa"]#_theme};
			case "func":			{["#e9e9e9","#0e0e0e","#eaeaeb","#333333"]#_theme};
			case "path":			{["#959595","#424242","#949597","#4B4B4B"]#_theme};
			case "lineNumber":		{["#858585","#227893","#495162","#5C5C5C"]#_theme};

			case "comment":			{["#608932","#098000","#7f848f","#a0a1a7"]#_theme};
			case "string":			{["#ce9178","#a31514","#7dc361","#50a150"]#_theme};
			case "number":			{["#a9cd88","#09885a","#d19a66","#986801"]#_theme};
			case "magicVar":		{["#569cd6","#033cff","#e5c07b","#e4564a"]#_theme};
			case "localVar":		{["#9cdcfe","#001980","#e06c75","#e4564a"]#_theme};
			case "function":		{["#e8e8e7","#795e26","#56b6c2","#0084bc"]#_theme};
			//case "bracket":		{[]#_theme};
			//case "operator":		{[]#_theme};
			case "preprocessor":	{["#9cdcfe","#001980","#e06c75","#e4564a"]#_theme};
			case "keyword":			{["#c586c0","#af2adb","#c678de","#a626a4"]#_theme};
			case "litteral":		{["#569cd6","#033cff","#e5c07b","#e4564a"]#_theme};
			case "null":			{["#569cd6","#795e26","#d19a66","#986801"]#_theme};
			case "command":			{["#dcdcaa","#795e26","#61afef","#4178f2"]#_theme};
			case "globalVar":		{["#e8e8e7","#001980","#56b6c2","#0084bc"]#_theme};

			default 				{["#d4d4d4","#000000","#bbbbbb","#333333"]#_theme};
		};
	};


	case "recompileButtonClick":{
		_params params ["_ctrl"];
		USE_DISPLAY(ctrlParent _ctrl);
		USE_CTRL(_ctrlTree,IDC_TREE_VIEW);
		USE_CTRL(_ctrlViewerContent,IDC_STRUCTURED_VIEWER_CONTENT);

		private _data = uiNamespace getVariable [VAR_SELECTED_FUNC,[]];
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
		USE_CTRL(_ctrlTree,IDC_TREE_VIEW);
		USE_CTRL(_ctrlComboLoad,IDC_COMBO_LOAD);

		private _data = uiNamespace getVariable [VAR_SELECTED_FUNC,[]];
		if (_data isEqualTo []) exitWith {};

		private _file = _data # 1;
		private _content = switch (lbCurSel _ctrlComboLoad) do {
			case 1:{preprocessFile _file};
			case 2:{preprocessFileLineNumbers _file};
			default {loadFile _file};
		};

		// done like this so you can copy functions in MP too
		uiNameSpace setVariable ["Display3DENCopy_data",[_data#0,_content]];
		(THIS_DISPLAY) createDisplay "Display3DENCopy";
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