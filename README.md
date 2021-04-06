# powershell based (zipped archive installer)
powershell based - small, flexible and easy to use installer; working out of zipped archives after extracting it


## How it works (what it does)
- The cmd is the "starter" for easy run as Admin by rightclick. it runs the dnInstall.ps1 (in facht both of this two names are variable to use as long they do have the same basename)
- The dnInstall.ps1 extracts and runs the file install.ps1 (dotsourced) - for each zip
- A archive name like "0001-Prepare.zip will be created in the Registry to make it possible to have a simple status (Exitcode and Versiondate) - Versiondate is the timestamp of the zip-file


## Filestructure
At the moment copy to a local source - example: to c:\users\public\*.*

C:\USERS\PUBLIC\_DNINSTALL
- 0001-Prepare.zip<blue>
- 0110-MyMSIX-Packages.zip
  - install.ps1
- 9001-PublicDesktop.zip
  - install.ps1</blue>
- **dnInstall.cmd**
- **dnInstall.ps1**


## How to use (how you should use)
- copy to a local location (dnInstall.ps1,dnInstall.cmd,xxx.zip) - all to the same locateion see Filestructure
- run as admin dnInstall.cmd - or Powershell as admin and run the dnInstall.ps1 - File

Enjoy
