package;

#if windows
@:cppFileCode('#include <stdlib.h>
#include <stdio.h>
#include <windows.h>
#include <wingdi.h>
#include <winuser.h>
#include <dwmapi.h>
#include <strsafe.h>
#include <shellapi.h>
#include <iostream>
#include <string>

#pragma comment(lib, "Dwmapi")
#pragma comment(lib, "Shell32.lib")')
#end


class WindowsAPI {
    #if windows
    @:functionCode('
        int darkMode = enable ? 1 : 0;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        }
        UpdateWindow(window);
    ')
    #end
    public static function setWindowDarkModeValue(darkMode:Bool) {
        trace('window is now ' + (darkMode ? 'dark' : 'light'));
    }

    #if windows
    @:functionCode('
    HWND window = GetActiveWindow();
    HICON smallIcon = (HICON) LoadImage(NULL, path, IMAGE_ICON, 16, 16, LR_LOADFROMFILE);
    HICON icon = (HICON) LoadImage(NULL, path, IMAGE_ICON, 0, 0, LR_LOADFROMFILE | LR_DEFAULTSIZE);
    SendMessage(window, WM_SETICON, ICON_SMALL, (LPARAM)smallIcon);
    SendMessage(window, WM_SETICON, ICON_BIG, (LPARAM)icon);
    ')
    #end
    public static function setWindowIcon(path:String) {}

    #if windows
    @:functionCode('
    #define DMDO_DEFAULT    0
    #define DMDO_90         1
    #define DMDO_180        2
    #define DMDO_270        3
    DISPLAY_DEVICE displayDevice;
    displayDevice.cb = sizeof(displayDevice);
    EnumDisplayDevices(NULL, 0, &displayDevice, 0);

    // Get the current display settings for the first display
    DEVMODE devMode;
    devMode.dmSize = sizeof(devMode);
    EnumDisplaySettings(displayDevice.DeviceName, ENUM_CURRENT_SETTINGS, &devMode);

    // Rotate the display by 0 degrees
    devMode.dmDisplayOrientation = DMDO_DEFAULT;

    // Change the display settings to apply the rotation
    LONG result = ChangeDisplaySettings(&devMode, CDS_UPDATEREGISTRY);
    ')
    #end
    public static function putDisplayBackToNormal() {}

    #if windows
    @:functionCode('
    #define DMDO_DEFAULT    0
    #define DMDO_90         1
    #define DMDO_180        2
    #define DMDO_270        3
    DISPLAY_DEVICE displayDevice;
    displayDevice.cb = sizeof(displayDevice);
    EnumDisplayDevices(NULL, 0, &displayDevice, 0);

    // Get the current display settings for the first display
    DEVMODE devMode;
    devMode.dmSize = sizeof(devMode);
    EnumDisplaySettings(displayDevice.DeviceName, ENUM_CURRENT_SETTINGS, &devMode);

    // Rotate the display by 180 degrees
    devMode.dmDisplayOrientation = DMDO_180;

    // Change the display settings to apply the rotation
    LONG result = ChangeDisplaySettings(&devMode, CDS_UPDATEREGISTRY);
    ')
    #end
    public static function putDisplayUpsidedown() {}

    public static function setWindowIconOther(path:String) {
        lime.app.Application.current.window.setIcon(lime.utils.Assets.getImage(path));
    }
}