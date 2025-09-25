/*
This script defines two hotkeys for interacting with TiddlyWiki (node.js version):

1. Win+F: Takes a screenshot of the active window, saves it to specified folder
2. Win+X: Save image into specified folder from `Save As` dialog

The specified folder is under the tiddlywiki root folder and defined as `tiddlywikiPath`. The files are stored under `files/images/YYYY/` subfolder with filename as timestamp.

The image macro is automatically generated and copied to clipboard, which can be pasted into TiddlyWiki. The macro text can be modified in the `InsertImageToTiddlyWiki` function.

If Tiddlywiki [tw-livebridge](https://tw-livebridge.bangyou.me/) (>=0.0.12) is installed and running, the macro text is also sent to TiddlyWiki via WebSocket with message type `modify-tiddler`.

If VS Code exenstion [TiddlyEdit](https://github.com/byzheng/vscode-tiddlyedit) (>=0.2.5) is installed and running, the image macro is also inserted into the current tiddler being edited.

Usage:
- Modify the `tiddlywikiPath` variable to point to your TiddlyWiki folder.
- Modify the `tiddlywikiWsUrl` variable if your WebSocket URL is different.
- Modify the `InsertImageToTiddlyWiki` function to change the image macro format if needed.
- Ensure you have AutoHotkey v2.0 or above installed.
- Use #Include tiddlywiki.ahk to include this script in your main AHK script.


Author: [Bangyou Zheng]
Date: [2024-09-25]
Version: [0.1.0]
License: [MIT License]
*/

#Requires AutoHotkey v2.0

tiddlywikiPath := "C:\tiddlywiki"
tiddlywikiWsUrl := "ws://127.0.0.1:8080/ws"

; -------- Helpers --------
FormatTimeString() => FormatTime(A_Now, "yyyyMMddHHmmss")

GetFileName(ts) {
    year := SubStr(ts, 1, 4)
    return tiddlywikiPath "\files\images\" year "\" ts ".png"
}

ShowSplashText(msg, title := "", w := 500, h := 50, duration := 2500) {
    splash := Gui("+AlwaysOnTop +Disabled -SysMenu +Owner", title)
    splash.BackColor := "White"
    splash.AddText("Center w" . (w-20) . " h" . (h-20), msg)
    splash.Show("x" (A_ScreenWidth - w - 300) " y50 w" w " h" h " NoActivate")
    SetTimer(() => splash.Destroy(), -duration)
}

JsonEscape(str) {
    str := StrReplace(str, "\", "\\")
    str := StrReplace(str, "`r", "\r")
    str := StrReplace(str, "`n", "\n")
    str := StrReplace(str, "`t", "\t")
    str := StrReplace(str, "`b", "\b")
    str := StrReplace(str, "`f", "\f")
    str := StrReplace(str, '"', '\\\"')
    return str
}

; --- your original PS commands kept ---
SaveClipboardImage(filepath) {
    cmd := "powershell -STA -Command Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; if ([System.Windows.Forms.Clipboard]::ContainsImage()) { $image = [System.Windows.Forms.Clipboard]::GetImage(); $image.Save('" filepath "', [System.Drawing.Imaging.ImageFormat]::Png); Write-Host 'Image saved successfully.' } else { Write-Host 'No image data found in clipboard.' }"
    RunWait(cmd, ,"Hide")
}

SendWebSocket(msg, wsUrl := tiddlywikiWsUrl) {
    EscMsg := JsonEscape(msg)
    JSON := '{\"type\":\"modify-tiddler\",\"op\":\"insert\",\"content\":\"' EscMsg '\"}'

    psCmd := "$ws=New-Object System.Net.WebSockets.ClientWebSocket;" 
        . "$ws.ConnectAsync([Uri]'"
        . wsUrl
        . "',[Threading.CancellationToken]::None).Wait();"
        . "$b=[System.Text.Encoding]::UTF8.GetBytes('" JSON "');"
        . "$s=New-Object System.ArraySegment[byte](,$b);"
        . "$ws.SendAsync($s,[System.Net.WebSockets.WebSocketMessageType]::Text,$true,[Threading.CancellationToken]::None).Wait();"
        . "$ws.Dispose()"

    RunWait('powershell -STA -Command ' . Chr(34) . psCmd . Chr(34), , "Hide")
}

InsertImageToTiddlyWiki(fullPath, ts) {
    year := SubStr(ts, 1, 4)
    img_macro := '<<wikitext-clipboard src:"""<<image-basic "./files/images/' year '/' ts '.png" caption:"" width:"95`%" align:"center">>""">>'
    A_Clipboard := img_macro
    SendWebSocket(img_macro "`n`n")
    ShowSplashText("A new image has been saved to " fullPath)
}

; -------- Hotkeys --------

; Win+F → take screenshot and insert into TW
#f:: {
    Send "{Alt Down}{PrintScreen}{Alt Up}"
    Sleep 500
    ts := FormatTimeString()
    fullPath := GetFileName(ts)
    SaveClipboardImage(fullPath)
    InsertImageToTiddlyWiki(fullPath, ts)
}

; Ctrl+Win+F → auto-fill Save As dialog filename + insert into TW
#x:: {
    activeTitle := WinGetTitle("A")
    if !RegExMatch(activeTitle, "i)Save (As|File|image)")
        return
    ts := FormatTimeString()
    fullPath := GetFileName(ts)
    
    A_Clipboard := fullPath
    Send "^v{Enter}"
    Sleep 300
    
    InsertImageToTiddlyWiki(fullPath, ts)
}
