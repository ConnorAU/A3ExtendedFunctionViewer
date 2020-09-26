class CAU_displayExtendedFunctionViewer {
	idd=-1;
	onLoad="['onLoad',_this] call CAU_xFuncViewer_fnc_system";
	onUnload="['onUnload',_this] call CAU_xFuncViewer_fnc_system";
	enableSimulation=0;

	#define DIALOG_W ((safezoneW/GRID_W) - 10)
	#define DIALOG_H ((safezoneH/GRID_H) - 10)

	class controlsBackground {
		class tiles: ctrlStaticBackgroundDisableTiles {};
		class background: ctrlStaticBackground {
			x=CENTER_XA(DIALOG_W);
			y=CENTER_YA(DIALOG_H);
			w=PX_WA(DIALOG_W);
			h=PX_HA(DIALOG_H);
		};
		class title: ctrlStaticTitle {
			idc=IDC_STATIC_TITLE;
			moving=0;
			x=CENTER_XA(DIALOG_W);
			y=CENTER_YA(DIALOG_H);
			w=PX_WA(DIALOG_W);
			h=PX_HA(SIZE_M);
		};
		class footer: ctrlStaticFooter {
			x=CENTER_XA(DIALOG_W);
			y=CENTER_YA(DIALOG_H) + PX_HA(DIALOG_H) - PX_HA(SIZE_XXL);
			w=PX_WA(DIALOG_W);
			h=PX_HA(SIZE_XXL);
		};
	};
	class controls {
		class toolbarBackground: ctrlStaticOverlay {
			x=CENTER_XA(DIALOG_W);
			y=CENTER_YA(DIALOG_H) + PX_HA(SIZE_M);
			w=PX_WA(DIALOG_W);
			h=PX_HA(SIZE_XXL);
		};

		class searchEdit: ctrlEdit {
			idc=IDC_EDIT_SEARCH;
			x=CENTER_XA(DIALOG_W) + PX_WA(2);
			y=CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HA(1);
			w=(PX_WA((10*SIZE_M)) min PX_WA((1/5*DIALOG_W))) - PX_WA(SIZE_M);
			h=PX_HA(SIZE_M);
		};
		class searchButton: ctrlButtonSearch {
			idc=IDC_BUTTON_SEARCH;
			x=CENTER_XA(DIALOG_W) + PX_WA(2) + (PX_WA((10*SIZE_M)) min PX_WA((1/5*DIALOG_W))) - PX_WA(SIZE_M);
			y=CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HA(1);
			w=PX_WA(SIZE_M);
			h=PX_HA(SIZE_M);
		};

		class themeCombo: ctrlCombo {
			idc=IDC_COMBO_THEME;
			x=CENTER_XA(DIALOG_W) + PX_WA(2) + PX_WA((1/5*DIALOG_W)) + PX_WA(2);
			y=CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HA(1);
			w=PX_WA((10*SIZE_M));
			h=PX_HA(SIZE_M);
		};
		class loadCombo: themeCombo {
			idc=IDC_COMBO_LOAD;
			x=CENTER_XA(DIALOG_W) + PX_WA(2) + PX_WA((1/5*DIALOG_W)) + PX_WA(3) + PX_WA((10*SIZE_M));
		};
		class seperator1: ctrlStaticBackground {
			x=CENTER_XA(DIALOG_W) + PX_WA(2) + PX_WA((1/5*DIALOG_W)) + PX_WA(4) + 2*(PX_WA((10*SIZE_M))) + PX_WA(1);
			y=CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HA(1);
			w=pixelW;
			h=PX_HA(SIZE_M);
		};
		class sizeUpButton: ctrlButtonPicture {
			idc=IDC_BUTTON_SIZEUP;
			colorBackground[]={0,0,0,0};
			x=CENTER_XA(DIALOG_W) + PX_WA(2) + PX_WA((1/5*DIALOG_W)) + PX_WA(4) + 2*(PX_WA((10*SIZE_M))) + PX_WA(2);
			y=CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HA(1);
			w=PX_WA(SIZE_M);
			h=PX_HA(SIZE_M);
		};
		class sizeDownButton: sizeUpButton {
			idc=IDC_BUTTON_SIZEDOWN;
			x=CENTER_XA(DIALOG_W) + PX_WA(2) + PX_WA((1/5*DIALOG_W)) + PX_WA(4) + 2*(PX_WA((10*SIZE_M))) + PX_WA(3) + PX_WA(SIZE_M);
		};
		class highlightButton: sizeUpButton {
			idc=IDC_BUTTON_HIGHLIGHT;
			x=CENTER_XA(DIALOG_W) + PX_WA(2) + PX_WA((1/5*DIALOG_W)) + PX_WA(4) + 2*(PX_WA((10*SIZE_M))) + PX_WA(4) + 2*(PX_WA(SIZE_M));
		};
		class lineInterpretButton: sizeUpButton {
			idc=IDC_BUTTON_LINE_INTERPRET;
			x=CENTER_XA(DIALOG_W) + PX_WA(2) + PX_WA((1/5*DIALOG_W)) + PX_WA(4) + 2*(PX_WA((10*SIZE_M))) + PX_WA(5) + 3*(PX_WA(SIZE_M));
		};
		class extensionParsingButton: sizeUpButton {
			idc=IDC_BUTTON_EXT_PARSING;
			x=CENTER_XA(DIALOG_W) + PX_WA(2) + PX_WA((1/5*DIALOG_W)) + PX_WA(4) + 2*(PX_WA((10*SIZE_M))) + PX_WA(6) + 4*(PX_WA(SIZE_M));
		};

		class treeCombo: ctrlCombo {
			idc=IDC_COMBO_TREE_MODE;
			x=CENTER_XA(DIALOG_W) + PX_WA(2);
			y=CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HA(SIZE_XXL) + PX_HA(2);
			w=PX_WA((1/5*DIALOG_W)) - PX_WA((SIZE_M*2));
			h=PX_HA(SIZE_M);
		};
		class collapseButton: ctrlButtonPicture {
			idc=IDC_BUTTON_TREE_COLLAPSE;
			colorBackground[]={0,0,0,0};
			x=CENTER_XA(DIALOG_W) + PX_WA(2) + PX_WA((1/5*DIALOG_W)) - PX_WA((SIZE_M*2));
			y=CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HA(SIZE_XXL) + PX_HA(2);
			w=PX_WA(SIZE_M);
			h=PX_HA(SIZE_M);
		};
		class expandButton: collapseButton {
			idc=IDC_BUTTON_TREE_EXPAND;
			x=CENTER_XA(DIALOG_W) + PX_WA(2) + PX_WA((1/5*DIALOG_W)) - PX_WA(SIZE_M);
		};
		class tree: ctrlTree {
			idc=IDC_TREE_VIEW;
			colorBorder[]={0,0,0,0};
			colorBackground[]={COLOR_OVERLAY_RGBA};
			x=CENTER_XA(DIALOG_W) + PX_WA(2);
			y=CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HA(SIZE_XXL) + PX_HA(2) + PX_HA(SIZE_M);
			w=PX_WA((1/5*DIALOG_W));
			h=PX_HA(DIALOG_H) - PX_HA(SIZE_M) - PX_HA(SIZE_XXL) - PX_HA(SIZE_XXL) - PX_HA(4) - PX_HA(SIZE_M);
		};

		class viewerBackground: ctrlStaticBackground {
			idc=IDC_STATIC_VIEWER_BG;
			x=CENTER_XA(DIALOG_W) + PX_WA(2) + PX_WA((1/5*DIALOG_W)) + PX_WA(2);
			y=CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HA(SIZE_XXL) + PX_HA(2);
			w=PX_WA((4/5*DIALOG_W)) - PX_WA(6);
			h=PX_HA(DIALOG_H) - PX_HA(SIZE_M) - PX_HA(SIZE_XXL) - PX_HA(SIZE_XXL) - PX_HA(4);
		};
		class viewerHeaderBackground: ctrlStaticBackground {
			colorBackground[]={0,0,0,0.3};
			x=CENTER_XA(DIALOG_W) + PX_WA(2) + PX_WA((1/5*DIALOG_W)) + PX_WA(2);
			y=CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HA(SIZE_XXL) + PX_HA(2);
			w=PX_WA((4/5*DIALOG_W)) - PX_WA(6);
			h=PX_HA((14+SIZE_XL));
		};
		class viewerHeaderFunction: ctrlStatic {
			idc=IDC_STATIC_VIEWER_FUNC;
			text="Select a function";
			font="RobotoCondensedBold";
			sizeEx=PX_HA(13.5);
			shadow=0;


			x=CENTER_XA(DIALOG_W) + PX_WA(2) + PX_WA((1/5*DIALOG_W)) + PX_WA(2);
			y=CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HA(SIZE_XXL) + PX_HA(2);
			w=PX_WA((4/5*DIALOG_W)) - PX_WA(6);
			h=PX_HA(13.5);
		};
		class viewerHeaderFilepath: viewerHeaderFunction {
			idc=IDC_STATIC_VIEWER_PATH;
			font="RobotoCondensed";
			sizeEx=PX_HA(SIZE_M);

			y=CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HA(SIZE_XXL) + PX_HA(2) + PX_HA(13.5);
			h=PX_HA(SIZE_M);
		};

		class viewerMainGroup: ctrlControlsGroup {
			x=CENTER_XA(DIALOG_W) + PX_WA(2) + PX_WA((1/5*DIALOG_W)) + PX_WA(2);
			y=CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HA(SIZE_XXL) + PX_HA(2) + PX_HA((14+SIZE_XL));
			w=PX_WA((4/5*DIALOG_W)) - PX_WA(6);
			h=PX_HA(DIALOG_H) - PX_HA(SIZE_M) - PX_HA(SIZE_XXL) - PX_HA(SIZE_XXL) - PX_HA(4) - PX_HA((14+SIZE_XL));

			class controls {
				class viewerLineNumbers: ctrlStructuredText {
					idc=IDC_STRUCTURED_VIEWER_LINES;
					size=PX_HA(SIZE_S);
					colorBackground[]={0,0,0,0.3};
					shadow=0;

					class Attributes
					{
						align="right";
						font="EtelkaMonospacePro";
					};
				};
				class viewerContent: ctrlStructuredText {
					idc=IDC_STRUCTURED_VIEWER_CONTENT;
					size=PX_HA(SIZE_S);
					shadow=0;

					class Attributes
					{
						font="EtelkaMonospacePro";
					};
				};
			};
		};
		class viewerLoadingBar: ctrlStaticTitle {
			idc=IDC_STATIC_VIEWER_LOADBAR;
			x=CENTER_XA(DIALOG_W) + PX_WA(2) + PX_WA((1/5*DIALOG_W)) + PX_WA(2);
			y=CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HA(SIZE_XXL) + PX_HA(2);
			w=PX_WA((4/5*DIALOG_W)) - PX_WA(6);
			h=PX_HA(1);
		};

		class buttonClose: ctrlButtonClose {
			idc=IDC_BUTTON_CLOSE;
			x=CENTER_XA(DIALOG_W) + PX_WA(DIALOG_W) - PX_WA((8*SIZE_M)) - PX_WA(1);
			y=CENTER_YA(DIALOG_H) + PX_HA(DIALOG_H) - PX_HA(SIZE_M) - PX_HA(1);
			w=PX_WA((8*SIZE_M));
			h=PX_HA(SIZE_M);
		};
		class buttonRecompileAll: ctrlButton {
			idc=IDC_BUTTON_RECOMPILE_ALL;
			text="$STR_A3_RscFunctionsViewer_btnRecompileAll";
			x=CENTER_XA(DIALOG_W) + PX_WA(DIALOG_W) - (PX_WA((8*SIZE_M))*2) - PX_WA(2);
			y=CENTER_YA(DIALOG_H) + PX_HA(DIALOG_H) - PX_HA(SIZE_M) - PX_HA(1);
			w=PX_WA((8*SIZE_M));
			h=PX_HA(SIZE_M);
		};
		class buttonRecompileSingle: buttonRecompileAll {
			idc=IDC_BUTTON_RECOMPILE;
			text="Recompile Selected";
			x=CENTER_XA(DIALOG_W) + PX_WA(DIALOG_W) - (PX_WA((8*SIZE_M))*3) - PX_WA(3);
		};
		class buttonExecute: buttonRecompileAll {
			idc=IDC_BUTTON_EXECUTE;
			text="Execute Selected";
			x=CENTER_XA(DIALOG_W) + PX_WA(DIALOG_W) - (PX_WA((8*SIZE_M))*4) - PX_WA(4);
		};
		class buttonCopyToClipboard: buttonRecompileAll {
			idc=IDC_BUTTON_COPY;
			text="Copy to Clipboard";
			x=CENTER_XA(DIALOG_W) + PX_WA(DIALOG_W) - (PX_WA((8*SIZE_M))*5) - PX_WA(5);
		};
	};
};
