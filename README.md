IseDemo
------

Similar to Start-Demo, except instead of executing commands one at a time, this moves through a series of files in the ISE.
Basically, it's an executable slide deck, cutting down on time spent typing or copying / pasting.

Demos are directory structures:

<Root Path>\1\
<Root Path>\2\
etc

The numbered folders can contain any number of files, which will all be opened in the ISE when you advanced to that "slide".
Each numbered folder may optionally contain a file named Hint.txt.  This won't be opened in the ISE, but will be displayed
in the console if you use the -ShowHints switch of Start-IseDemo.

When you advanced to a new slide, all open files in the current ISE Powershell tab will be closed, then the files of the new
slide will be opened.  Advancing to the next or previous slide can be done with the keyboard shortcuts CTRL+ALT+Right and
CTRL+ALT+Left .  (These shortcuts just execute the commands Invoke-NextIseDemo and Invoke-PreviousIseDemo.)

To start the demo, run Start-IseDemo -Path $PathToRootFolder [-ShowHints].
