SNPver v1.3
-----
[USAGE 1]:
	-> Launch SNPver.exe

[USAGE 2]:
[1] OPEN CMD as ADMINISTRATOR:
	->Key: [WINDOWS] + [R]
	->powershell "Start-Process cmd -Verb RunAs"


[2] Go to the folder where SNPver.ps1 is located:
	-> cd C:\Users\my-user\Documents\SNPver-v1.2

[3] Set a POWERSHELL environment, execution policy, and RUN SNPver.ps1
	->powershell -ExecutionPolicy Bypass -File SNPver.ps1


[4] WAIT UNTIL script finished... (maybe 60 seconds?)

[5] Send the final generated report to RemsFlems
	->C:\Users\my-user\Documents\SNPver-v1.2\NPChek-DESKTOP-XXXXX-2020-XX-XX-report.log


--------------
[REBUILD EXE]
Use PS2EXE tool (some sources included in package but -> PS2EXE IS NOT MY SOURCE...Check Their Licence!)
(Just run PS2EXE-GUI\Win-PS2EXE.exe)