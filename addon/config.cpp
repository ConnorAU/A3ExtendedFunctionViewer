/*──────────────────────────────────────────────────────┐
│   Author: Connor                                      │
│   Steam:  https://steamcommunity.com/id/_connor       │
│   Github: https://github.com/ConnorAU                 │
│                                                       │
│   Please do not modify or remove this comment block   │
└──────────────────────────────────────────────────────*/

class CfgPatches {
	class CAU_ExtendedFunctionViewer {
        name="ExtendedFunctionViewer";
        author="Connor";
        url="https://steamcommunity.com/id/_connor";

		requiredVersion=0.01;
		requiredAddons[]={"A3_3DEN","A3_Ui_F"};
		units[]={};
		weapons[]={};
	};
};

class CfgFunctions {
	class CAU_xFuncViewer {
		class script {
			class system {
				file="cau\extendedfunctionviewer\system.sqf";
			};
		};
	};
};

// Inherit Ctrls
class ctrlDefault;

class ctrlDefaultText;
class ctrlStatic;
class ctrlStaticBackground;
class ctrlStaticFooter;
class ctrlStaticOverlay;
class ctrlStaticTitle;
class ctrlStaticBackgroundDisableTiles;
class ctrlEdit;
class ctrlCombo;

class ctrlStructuredText;

class ctrlDefaultButton;
class ctrlButton;
class ctrlButtonCancel;
class ctrlButtonClose;
class ctrlButtonSearch;

class ctrlControlsGroup;
class ctrlControlsGroupNoScrollbars;

class ctrlTree;

class ctrlMenu;
class ctrlMenuStrip;

#include "\a3\3den\ui\macros.inc"
#include "_defines.inc"
#include "display.cpp"

// Add button to 3den toolbar
class Display3DEN {
	class controls {
		class MenuStrip: ctrlMenuStrip {
			class Items {
				class Tools {
					items[]+={"CAU_xFuncViewer"};
				};
				class CAU_xFuncViewer {
					text="Extended Function Viewer";
					action="['init',_this] call CAU_xFuncViewer_fnc_system";
					picture="\a3\3DEN\Data\Displays\Display3DEN\EntityMenu\functions_ca.paa";
				};
			};
		};
	};
};

// Modify button on debug menu
class RscControlsGroup;
class RscControlsGroupNoScrollbars;
class RscShortcutButton;
class RscButtonMenu;
class RscDebugConsole: RscControlsGroupNoScrollbars {
	class controls {
		delete ButtonFunctions;
		class CAU_xFuncViewer: RscButtonMenu {
			idc=-1;
			onLoad="(_this#0) ctrlSetText format['x%1',localize 'STR_A3_RscDebugConsole_ButtonFunctions'];";
			onButtonClick="['init',_this] call CAU_xFuncViewer_fnc_system;false";
			x="7.5 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
			y="19.4 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
			w="7.4 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
			h="1 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
		};
	};
};