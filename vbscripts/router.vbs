Set oShell = CreateObject("WScript.Shell")
    oShell.run"cmd.exe"
    WScript.Sleep 500
    oShell.SendKeys"telnet 192.168.1.1"
    oShell.SendKeys("{Enter}")
    WScript.Sleep 1000
    oShell.SendKeys"root"
    oShell.SendKeys("{Enter}")
    WScript.Sleep 500
    oShell.SendKeys"admin"
    oShell.SendKeys("{Enter}")
    WScript.Sleep 500
    oShell.SendKeys"wl scan;sleep 1;wl scanresults"
    oShell.SendKeys("{Enter}")
    WScript.sleep 500
    oShell.Sendkeys"wl join ZEBRA"
    oShell.SendKeys("{Enter}")
    oShell.Sendkeys"wl status"
    oShell.SendKeys("{Enter}")
    WScript.sleep 5000
    oShell.Sendkeys"exit"
    oShell.SendKeys("{Enter}")
    WScript.sleep 1000
    oShell.Sendkeys"exit"
    oShell.SendKeys("{Enter}")