# tw-autohotkey


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



