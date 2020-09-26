// ~ Operations
#define QUOTE(a) #a
#define JOIN(a,b) a##b

#ifdef DISPLAY_NAME
    #define THIS_DISPLAY DISPLAY(DISPLAY_NAME)
#endif
#define DISPLAY(name) uiNamespace getVariable [QUOTE(name),displayNull]
#define USE_DISPLAY(display) private _display = display
#define USE_CTRL(ctrl,idc) private ctrl = _display displayCtrl idc

// ~ Functions
#ifdef THIS_FUNC
    #define FUNC_SUBVAR(suffix) THIS_FUNC##_##suffix
#endif

// ~ UI Positioning
#ifdef pixelScale
    #define PX_WA(n) n*GRID_W
    #define PX_HA(n) n*GRID_H
    #define CENTER_XA(n) CENTER_X-(0.5*(PX_WA(n)))
    #define CENTER_YA(n) CENTER_Y-(0.5*(PX_HA(n)))
    #define SIZE_XXL 7
#endif

// ~ Display IDCs
#define IDC_STATIC_TITLE                1
#define IDC_EDIT_SEARCH                 2
#define IDC_BUTTON_SEARCH               3
#define IDC_COMBO_THEME                 4
#define IDC_COMBO_LOAD                  5
#define IDC_BUTTON_SIZEUP               6
#define IDC_BUTTON_SIZEDOWN             7
#define IDC_BUTTON_HIGHLIGHT            8
#define IDC_BUTTON_LINE_INTERPRET       9
#define IDC_BUTTON_EXT_PARSING          10
#define IDC_COMBO_TREE_MODE             11
#define IDC_BUTTON_TREE_COLLAPSE        12
#define IDC_BUTTON_TREE_EXPAND          13
#define IDC_TREE_VIEW                   14
#define IDC_STATIC_VIEWER_BG            15
#define IDC_STATIC_VIEWER_FUNC          16
#define IDC_STATIC_VIEWER_PATH          17
#define IDC_STRUCTURED_VIEWER_LINES     18
#define IDC_STRUCTURED_VIEWER_CONTENT   19
#define IDC_STATIC_VIEWER_LOADBAR       20
#define IDC_BUTTON_COPY                 21
#define IDC_BUTTON_EXECUTE              22
#define IDC_BUTTON_RECOMPILE            23
#define IDC_BUTTON_RECOMPILE_ALL        24
#define IDC_BUTTON_CLOSE                25
