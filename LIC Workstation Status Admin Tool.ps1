#################################################################
# LIC Workstation Status Admin Tool								#
# Life Imaging Center, Albert-Ludwigs-Universität Freiburg		#
#																#
# Tobias Wernet													#
# 30.05.2023													#
# v 3.9a											 				#		
#																#
# Changelog:													#
#	- 															#
#	- added Systems												#
#	- added Hardware/Software Info								#
#	- added Systems												#
#	- added Lightsheet System									#
#	- added Classes and GUI changes								#
#	- added Imaging3											#
#	- added Imaging1											#
#	- fixed error												#
#	- added Celldiscoverer										#
#	- added RDP Button											#	
#	- Added Domain Check / WOL from external subnets (jumphost)	#
#	- Timeout for QWINSTA und Test-Connection					#
#	- Fixes to update and performance							#
#	- Data Collection (Session) major rebuild					#
#	- added "WOL not supported" option							#
#	- added some microscope systems								#
#	- modified Authentication Dialogue							#
#	- changed architecture (data collection background session)	#
#	- added auto-size to most elements for high-DPI scenarios	#
#	- added "About Window"										#
#	- added menu bar											#
#	- changes network check to work outside of LIC				#
#	- removed console view										#
#	- various improvements to code								#
#	- Added Logos												#
#	- Added external group share functionality					#
#	- New population method of GUI elements/entries				#
#	- New data array structure									#
#	- Various corrections										#
#	- Added WOL Info											#
#	- Initial Script											#
#																#		
#																#
#################################################################


##
# Build Instruction
#
# Build with Powershell ps2exe
# ps2exe "LIC Workstation Status Admin Tool.ps1" ".\LIC Workstation Status Admin Tool.exe" -title "LIC Workstation Status Admin Tool" -company "Albert-Ludwigs-Universität Freiburg" -copyright "Tobias Wernet" -version "3.9a" -product "LIC Workstation Status Admin Tool by Life Imaging Center (LIC)" -requireAdmin -credentialGUI -iconfile "C:\Temp\Logos\alu.ico" -DPIAware -supportOS -noconsole
##


# Tell  OS GUI/Tool is DPIAware (native API Call)
Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;
public class ProcessDPI {
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool SetProcessDPIAware();      
}
'@
$null = [ProcessDPI]::SetProcessDPIAware()

#Requires -RunAsAdministrator

# ErrorAction Definition
$ErrorActionPreference = "SilentlyContinue"

# UTF8 Encoding
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# Add Windows Forms
Add-Type -AssemblyName System.Windows.Forms
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void] [System.Windows.Forms.Application]::EnableVisualStyles() 

# Various Variables
$version = "3.9a"
$lastdate = "30.05.2023"
$tool = "LIC Workstation Status Admin Tool"
$global:jumphost = "ZBSAPC209.lic.ads.zbsa.privat"

# Definition LIC Workstation WOL MACs and FQDNs
$global:workstations = @()
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "LIC-Analysis001"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "LIC-Analysis001.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "00:25:90:24:CF:5B"
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Workstation"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "LIC-Analysis002"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "LIC-Analysis002.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "FC:AA:14:97:C2:6D"
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Workstation"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "LIC-Analysis003"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "LIC-Analysis003.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "FC:34:97:A6:A6:DD"
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Workstation"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "LIC-Analysis004"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "LIC-Analysis004.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "B4:2E:99:A9:46:CB"
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Workstation"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "LIC-Analysis005"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "LIC-Analysis005.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "FC:AA:14:74:42:48"
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Workstation"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "LIC-Analysis006"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "LIC-Analysis006.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "B4:2E:99:3F:55:7B"
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Workstation"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "LIC-Analysis007"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "LIC-Analysis007.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "B4:2E:99:A1:7A:0B"
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Workstation"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "LIC-Analysis008"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "LIC-Analysis008.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "00:25:90:C4:19:7C"
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Workstation"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "LIC-Analysis009"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "LIC-Analysis009.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "00:25:90:C4:AB:21"
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Workstation"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "LIC-Analysis010"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "LIC-Analysis010.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "B4:2E:99:3F:53:94"
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Workstation"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "LIC-Analysis011"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "LIC-Analysis011.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "B4:2E:99:3F:51:6E"
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Workstation"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "LIC-Analysis012"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "LIC-Analysis012.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "B4:2E:99:3F:F1:B8"
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Workstation"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "LightZ1-Ana"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "LightZ1-Ana.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value ""
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "0"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Workstation"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "AxioZoom"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "axiozoom.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value ""
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "System"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "STED"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "STED.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value ""
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "System"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "LSM-I-NLO"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "LSM-I-NLO.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value ""
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "System"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "LSM-U-NLO"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "LSM-U-NLO.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value ""
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "System"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "SP8-U-FLIM"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "SP8-U-FLIM.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value ""
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "System"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "LSM-V"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "LSM-V.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value ""
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "System"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "Celldiscoverer"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "Celldiscoverer.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value ""
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "System"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "Imaging1"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "Imaging1.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "18:60:24:9C:42:1A"
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "System"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "Imaging3"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "Imaging3.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value ""
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "System"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "Imaging4"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "Imaging4.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value ""
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "System"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "SD-I-ABL"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "SD-I-ABL.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value ""
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "System"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "SD-Till"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "SD-Till.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "B8:CA:3A:B1:5A:0B"
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "System"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "BiostationII"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "biostationii.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value ""
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "System"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "Lightsheet"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "Lightsheet.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value ""
$item | Add-Member -type NoteProperty -Name 'Share' -Value "data"
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "System"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "Niro-Thunder"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "Niro-Thunder.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "B4:2E:99:3F:55:7D"
$item | Add-Member -type NoteProperty -Name 'Share' -Value ""
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Office"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "ZBSAPC058"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "ZBSAPC058.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "64:00:6A:3D:2E:87"
$item | Add-Member -type NoteProperty -Name 'Share' -Value ""
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Office"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "ZBSAPC054"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "ZBSAPC054.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "64:00:6A:4A:3C:29"
$item | Add-Member -type NoteProperty -Name 'Share' -Value ""
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Office"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "ZBSAPC095"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "ZBSAPC095.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value "64:00:6A:49:AD:53"
$item | Add-Member -type NoteProperty -Name 'Share' -Value ""
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "1"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Office"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "licbook002"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "licbook002.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value ""
#$item | Add-Member -type NoteProperty -Name 'MAC' -Value "50:7B:9D:E2:F0:91"
$item | Add-Member -type NoteProperty -Name 'Share' -Value ""
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "0"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Office"
$workstations += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Computer' -Value "marlene"
$item | Add-Member -type NoteProperty -Name 'FQDN' -Value "marlene.lic.ads.zbsa.privat"
$item | Add-Member -type NoteProperty -Name 'MAC' -Value ""
#$item | Add-Member -type NoteProperty -Name 'MAC' -Value "C8:5B:76:3F:E5:1D"
$item | Add-Member -type NoteProperty -Name 'Share' -Value ""
$item | Add-Member -type NoteProperty -Name 'Shutdown' -Value "0"
$item | Add-Member -type NoteProperty -Name 'Class' -Value "Office"
$workstations += $item



$global:groupshares = @()
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Index' -Value "0" 
$item | Add-Member -type NoteProperty -Name 'Group' -Value "LIC (Employees)"
$item | Add-Member -type NoteProperty -Name 'Path' -Value "\\frink.lic.ads.zbsa.privat\Group"
$item | Add-Member -type NoteProperty -Name 'Domain' -Value "lic.ads.zbsa.privat"
$groupshares += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Index' -Value "1" 
$item | Add-Member -type NoteProperty -Name 'Group' -Value "Signalling Campus (Test)"
$item | Add-Member -type NoteProperty -Name 'Path' -Value "\\hermes.bwsfs.ads.sc.privat\sctest"
$item | Add-Member -type NoteProperty -Name 'Domain' -Value "ads.sc.privat"
$groupshares += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Index' -Value "2" 
$item | Add-Member -type NoteProperty -Name 'Group' -Value "Biologie: AG Reiff"
$item | Add-Member -type NoteProperty -Name 'Path' -Value "\\skandha.neuro.ads.bio1.privat"
$item | Add-Member -type NoteProperty -Name 'Domain' -Value "neuro.ads.bio1.privat"
$groupshares += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Index' -Value "3" 
$item | Add-Member -type NoteProperty -Name 'Group' -Value "Biologie: AG Driever"
$item | Add-Member -type NoteProperty -Name 'Path' -Value "\\fischli.ebio.ads.bio1.privat"
$item | Add-Member -type NoteProperty -Name 'Domain' -Value "ebio.ads.bio1.privat"
$groupshares += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Index' -Value "4" 
$item | Add-Member -type NoteProperty -Name 'Group' -Value "Biologie: AG Neubueser"
$item | Add-Member -type NoteProperty -Name 'Path' -Value "\\develo.ebio.ads.bio1.privat"
$item | Add-Member -type NoteProperty -Name 'Domain' -Value "ebio.ads.bio1.privat"
$groupshares += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Index' -Value "5" 
$item | Add-Member -type NoteProperty -Name 'Group' -Value "Biologie: AG Staubach"
$item | Add-Member -type NoteProperty -Name 'Path' -Value "\\ag-oeko.oeko.zoologie.privat"
$item | Add-Member -type NoteProperty -Name 'Domain' -Value "oeko.zoologie.privat"
$groupshares += $item
$item = New-Object PSObject
$item | Add-Member -type NoteProperty -Name 'Index' -Value "6" 
$item | Add-Member -type NoteProperty -Name 'Group' -Value "Biologie: Ökologie (neu)"
$item | Add-Member -type NoteProperty -Name 'Path' -Value "\\srv01.eco.ads.bio1.privat"
$item | Add-Member -type NoteProperty -Name 'Domain' -Value "eco.ads.bio1.privat "
$groupshares += $item


# Environment Check: The tool is written for the LIC domain network environment, SCF, Albert-Ludwigs-Universität Freiburg.
$global:domain_check = $env:UserDNSDomain
if (!($domain_check -eq "lic.ads.zbsa.privat"))
{
	$result_domain=[System.Windows.Forms.MessageBox]::Show("Warning$([System.Environment]::NewLine)The tool is written for the LIC domain network environment, SCF, Albert-Ludwigs-Universität Freiburg. $([System.Environment]::NewLine)$([System.Environment]::NewLine)Your computer $env:computername is not part of the LIC domain.$([System.Environment]::NewLine)WOL only works in the local LIC subnet / network or by using the LIC jumphost over a VPN connection. Additionally the session information only works if the tool is run with LIC administrative credentials$([System.Environment]::NewLine)$([System.Environment]::NewLine)Do you want to continue anyway?","$tool",4)			
	if($result_domain -eq "No")
	{
		Exit
	}
}


# WOL Function to compose the magic packet
function Invoke-WakeOnLan
{
  param
  (
    # MAC Address(es) mandatory
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    # MAC Address pattern match (regex pattern)
    [ValidatePattern('^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$')]
    [string[]]
    $MacAddress 
  )
  begin
  {
    # Instantiate UDP client
    $UDPclient = [System.Net.Sockets.UdpClient]::new()
  }
  process
  {
    foreach($_ in $MacAddress)
    {
      try 
	  {
		$currentMacAddress = $_
        
        # Get Byte Array from MAC Address
        $mac = $currentMacAddress -split '[:-]' |
        # Convert hex to byte:
        ForEach-Object {[System.Convert]::ToByte($_, 16)}
 
        # Compose the "magic packet"
        # Create a byte array with 102 bytes initialized to 255 each
        $packet = [byte[]](,0xFF * 102)
        
        # Leave the first 6 bytes untouched and repeat the target MAC address bytes in bytes 7 through 102
        6..101 | Foreach-Object {$packet[$_] = $mac[($_ % 6)]}
        
        # Connect to port 400 on broadcast address
        $UDPclient.Connect(([System.Net.IPAddress]::Broadcast),4000)
        
        # Send the magic packet to the broadcast address
        $null = $UDPclient.Send($packet, $packet.Length)
      }
      catch 
      {
        Write-Warning "Unable to send ${mac}: $_"
      }
    }
  }
  end
  {
    # Release the UDP client and free memory
    $UDPclient.Close()
    $UDPclient.Dispose()
  }
}

# Windows Authentication API Credential Function
function global:external_authentication
{
	param
	(
		[Parameter()]
		[string]$domain
	)
	# Get credentials to authenticate via external Domains and map external network shares
	# Credentials are temporarily stored in a secure PS credential object (and only valid in the owner's user session for the current runtime/session of the script/tool)

	# Prompt for Credentials and verify them by using the DirectoryServices.AccountManagement assembly.
	Add-Type -AssemblyName System.DirectoryServices.AccountManagement
	
	# Extract the current user's domain and also pre-format the user name to be used in the credential prompt.
	# Pre-Define the external Domainserver for authentication (if configured in the initial list of external shares)
	$UserDomain = $domain
	$UserName = "$UserDomain\"
	
	# Define the starting number (always #1) and the desired maximum number of attempts, and the initial credential prompt message to use.
	$Attempt = 1
	$MaxAttempts = 3
	$CredentialPrompt = "Please provide your external home-lab credentials to continue. $([System.Environment]::NewLine)We already populated the appropriate domain controller for your selected network share. $([System.Environment]::NewLine)Please enter your home-lab user name behind the backslash in the user field.$([System.Environment]::NewLine)$([System.Environment]::NewLine)Note: $([System.Environment]::NewLine)Do not provide your LIC credentials in this dialogue."
	
	# Set ValidAccount to false so it can be used to exit the loop when a valid account is found (and the value is changed to $True).
	$ValidAccount = $False

	# Loop through prompting for and validating credentials, until the credentials are confirmed, or the maximum number of attempts is reached.
	Do {
		# Blank any previous failure messages and then prompt for credentials with the custom message and the pre-populated domain\user name.
		$FailureMessage = $Null
		$script:credx = Get-Credential -UserName $UserName -Message $CredentialPrompt
		
		# Verify the credentials prompt wasn't bypassed.
		If ($credx) 
		{
			# If the user name was changed, then switch to using it for this and future credential prompt validations.
			If ($credx.UserName -ne $UserName) 
			{
				$UserName = $credx.UserName
			}
			
			# Test the user name (even if it was changed in the credential prompt) and password.
			$ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain
			Try 
			{
				$PrincipalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext $ContextType,$UserDomain
			} 
			Catch 
			{
				If ($_.Exception.InnerException -like "*The server could not be contacted*") 
				{
					$FailureMessage = "Could not contact a server for the specified domain on attempt #$Attempt out of $MaxAttempts."
				} Else 
				{
					$FailureMessage = "Unpredicted failure: `"$($_.Exception.Message)`" on attempt #$Attempt out of $MaxAttempts."
				}
			}
			
			# If there wasn't a failure talking to the domain test the validation of the credentials, and if it fails record a failure message.
			If (-not($FailureMessage)) 
			{
				$ValidAccount = $PrincipalContext.ValidateCredentials($UserName,$credx.GetNetworkCredential().Password)
				If (-not($ValidAccount)) 
				{
					$FailureMessage = "Bad user name or password used on credential prompt attempt #$Attempt out of $MaxAttempts.$([System.Environment]::NewLine)$([System.Environment]::NewLine)Please provide your external home-lab credentials to continue.$([System.Environment]::NewLine)Do not provide your LIC credentials in this dialogue."
				}
			}
		# Otherwise the credential prompt was (most likely accidentally) bypassed so record a failure message.
		} Else 
		{
			Break
		}
			 
		# If there was a failure message recorded above, display it, and update credential prompt message.
		If ($FailureMessage) 
		{
			Write-Warning "$FailureMessage"
			$Attempt++
			If ($Attempt -le $MaxAttempts) 
			{
				$CredentialPrompt = "Authentication error. $([System.Environment]::NewLine)Please provide your external home-lab credentials to continue.$([System.Environment]::NewLine)$([System.Environment]::NewLine)Do not provide your LIC credentials in this dialogue. $([System.Environment]::NewLine)Please try again (attempt #$Attempt out of $MaxAttempts):"
			} 
		}
	} Until (($ValidAccount) -or ($Attempt -gt $MaxAttempts))
	
	if ($Attempt -gt $MaxAttempts)
	{
		# Break function if exceeded max. attempts.
		Break
	}
}

# Function for GUI buffer
function SetDoubleBuffered()
{
    param([System.Windows.Forms.Control] $TargetControl)

    [System.Reflection.PropertyInfo] $DoubleBufferedProp = [System.Windows.Forms.Control].GetProperty("DoubleBuffered", [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance)
    $DoubleBufferedProp.SetValue($TargetControl, $True, $Null)
}

# Function to get user session via qwinsta and formating output
function Get-WS
{
    param
	(
		[Parameter()]
		[string]$Computer
	)
	if (Test-Connection -BufferSize 32 -Count 1 -ComputerName $Computer 2>$null)
	{
		qwinsta /server:$Computer | ForEach-Object {$_ -replace "\s{2,18}","," } | ConvertFrom-Csv
	}
}

# Function for the Shutdown button
function global:handler_click_Shutdown 
{
	param
	(
		[Parameter()]
		[string]$Para1
	)
	$computer = $Para1
	$host_sel = $host_list | where-object {$_.Computer -eq $Para1 -and $_.Status -eq $true}
	Remove-Variable -name "name" 2>$null
	$name = $null
	$name = ($active_sessions | where-object {$_.Computer -eq $Para1}).Session
	if ($name)
	{
		$message = [System.Windows.Forms.MessageBox]::Show("Shutdown prevented. User $name has an active session on $Para1.$([System.Environment]::NewLine)In order to shutdown $Para1 with this tool, please end all active user sessions on the target machine.","LIC Workstation Status Tool",0)
	} else
	{
		$confirm = [System.Windows.Forms.MessageBox]::Show("Do you want to shutdown $Para1 ? $([System.Environment]::NewLine)Warning:$([System.Environment]::NewLine)All unsaved data of any open sessions will be lost." , "Confirmation prompt" , 4)
		if ($confirm -eq "Yes")
		{
			$check = $null
			$check = Test-Connection -BufferSize 32 -Count 1 -ComputerName $Para1 | Select-Object @{Name='Computer';Expression={$_.Address}},@{Name='Status';Expression={if ($_.StatusCode -eq 0) { $true } else { $false }}} | sort-object -property Computer 2>$null
			if ($check.Status -eq $true)
			{
				Stop-Computer -computername $Para1 -Force
			}
		}
	}
}


# Function for the RDP button
function global:handler_click_RDP 
{
	param
	(
		[Parameter()]
		[string]$Para1
	)
	$computer = $Para1
	$host_sel = $host_list | where-object {$_.Computer -eq $Para1 -and $_.Status -eq $true}
	
	Remove-Variable -name "name" 2>$null
	$name = $null
	$name = ($active_sessions | where-object {$_.Computer -eq $Para1}).Session
	if ($name)
	{
		$message = [System.Windows.Forms.MessageBox]::Show("User $name has an active session on $Para1.$([System.Environment]::NewLine)If you establish a Remote Desktop Connection to $para1, you will close any active session that is not your own.","LIC Workstation Status Tool",0)
	}
	$confirm = [System.Windows.Forms.MessageBox]::Show("Do you want to open a Remote Desktop Connection (RDP) to $Para1 ? $([System.Environment]::NewLine)", "Confirmation prompt" , 4)
	if ($confirm -eq "Yes")
	{
		$check = $null
		$check = Test-Connection -BufferSize 32 -Count 1 -ComputerName $Para1 | Select-Object @{Name='Computer';Expression={$_.Address}},@{Name='Status';Expression={if ($_.StatusCode -eq 0) { $true } else { $false }}} | sort-object -property Computer 2>$null
		if ($check.Status -eq $true)
		{
			Start-Process "$env:windir\system32\mstsc.exe" -ArgumentList "/v:$Para1"
		}
	}
}

# Get-Installed Applications Function
# by xkln.net
# Function reads the Registry Hive of Global System and all local users
function Get-InstalledApplications() {
	[cmdletbinding(DefaultParameterSetName = 'GlobalAndAllUsers')]

	Param (
		[Parameter(ParameterSetName="Global")]
		[switch]$Global,
		[Parameter(ParameterSetName="GlobalAndCurrentUser")]
		[switch]$GlobalAndCurrentUser,
		[Parameter(ParameterSetName="GlobalAndAllUsers")]
		[switch]$GlobalAndAllUsers,
		[Parameter(ParameterSetName="CurrentUser")]
		[switch]$CurrentUser,
		[Parameter(ParameterSetName="AllUsers")]
		[switch]$AllUsers
	)

	# Excplicitly set default param to True if used to allow conditionals to work
	if ($PSCmdlet.ParameterSetName -eq "GlobalAndAllUsers") {
		$Global = $true
	}

	# Check if running with Administrative privileges if required
	if ($GlobalAndAllUsers -or $AllUsers) {
		$RunningAsAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
		if ($RunningAsAdmin -eq $false) {
			Write-Error "Finding all user applications requires administrative privileges"
			break
		}
	}

	# Empty array to store applications
	$Apps = @()
	$32BitPath = "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
	$64BitPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"

	# Retreive globally insatlled applications
	if ($Global -or $GlobalAndAllUsers -or $GlobalAndCurrentUser) {
		#Write-Host "Processing global registry hive"
		$Apps += Get-ItemProperty "HKLM:\$32BitPath"
		$Apps += Get-ItemProperty "HKLM:\$64BitPath"
	}

	if ($CurrentUser -or $GlobalAndCurrentUser) {
		#Write-Host "Processing current user registry hive"
		$Apps += Get-ItemProperty "Registry::\HKEY_CURRENT_USER\$32BitPath"
		$Apps += Get-ItemProperty "Registry::\HKEY_CURRENT_USER\$64BitPath"
	}

	if ($AllUsers -or $GlobalAndAllUsers) {
		#Write-Host "Collecting registry hive data for all users"
		$AllProfiles = Get-CimInstance Win32_UserProfile | Select LocalPath, SID, Loaded, Special | Where {$_.SID -like "S-1-5-21-*"}
		$MountedProfiles = $AllProfiles | Where {$_.Loaded -eq $true}
		$UnmountedProfiles = $AllProfiles | Where {$_.Loaded -eq $false}

		#Write-Host "Processing mounted registry hives"
		$MountedProfiles | % {
			$Apps += Get-ItemProperty -Path "Registry::\HKEY_USERS\$($_.SID)\$32BitPath"
			$Apps += Get-ItemProperty -Path "Registry::\HKEY_USERS\$($_.SID)\$64BitPath"
		}

		#Write-Host "Processing unmounted registry hives"
		$UnmountedProfiles | % {

			$Hive = "$($_.LocalPath)\NTUSER.DAT"
			#Write-Host " -> Mounting registry hive at $Hive"

			if (Test-Path $Hive) {
			
				REG LOAD HKU\temp $Hive

				$Apps += Get-ItemProperty -Path "Registry::\HKEY_USERS\temp\$32BitPath"
				$Apps += Get-ItemProperty -Path "Registry::\HKEY_USERS\temp\$64BitPath"

				# Run manual GC to allow hive to be unmounted
				[GC]::Collect()
				[GC]::WaitForPendingFinalizers()
			
				REG UNLOAD HKU\temp

			} else {
				Write-Warning "Unable to access registry hive at $Hive"
			}
		}
	}
	Write-Output $Apps
}	


# Function to collect status
function global:handler_Status 
{
	if ($status_jobs)
	{
		$status_jobs | get-job | remove-job -force
	}
	$global:status_jobs = $workstations | ForEach-Object { Test-Connection -BufferSize 32 -Count 1 -ComputerName $_.FQDN -AsJob } 
}


# Function to collect hardware info
function global:handler_HWI
{
	$computers = ($host_list | where-object {$_.Status -eq $true}).Computer
			
	$macs = get-netneighbor
	$host_list_active = $computers | ForEach-Object { Test-Connection -BufferSize 32 -Count 1 -ComputerName $_ -AsJob } | Get-Job | Receive-Job -Wait | Select-Object @{Name='Computer';Expression={$_.Address}},@{Name='Status';Expression={if ($_.StatusCode -eq 0) { $true } else { $false }}} | Where-Object {$_.Status -eq $true}
	$system_info = Invoke-Command -computername $host_list_active.computer -ScriptBlock {get-computerinfo} | Out-Null
	$system_info_cpu = Invoke-Command -computername $host_list_active.computer -ScriptBlock {Get-CimInstance -ClassName CIM_Processor} | Out-Null
	$system_info_gpu = Invoke-Command -computername $host_list_active.computer -ScriptBlock {Get-CimInstance -ClassName Win32_VideoController} | Out-Null
	$system_info_vram = Invoke-Command -computername $host_list_active.computer {(Get-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0*")."HardwareInformation.qwMemorySize"}| Out-Null
	$system_info_hdd = Invoke-Command -computername $host_list_active.computer -ScriptBlock {Get-CimInstance Win32_LogicalDisk} | Out-Null
	$system_info_lan = Invoke-Command -computername $host_list_active.computer -ScriptBlock {get-netadapter | Where-Object { $_.Status -eq "Up"}} | Out-Null
				
}



# Function to collect sessions
function global:handler_Session 
{
		param
	(
		[Parameter()]
		$workstations
	)
	$session_scriptBlock = {
		param ($input)
		
		if ($status_ses_jobs)
		{
			$status_ses_jobs | get-job | remove-job -force
		}
		$global:status_ses_jobs = $input | ForEach-Object { Test-Connection -BufferSize 32 -Count 1 -ComputerName $_.FQDN -AsJob } 
		if ($status_ses_jobs)
		{
			$ses_list = $status_ses_jobs | Get-Job | Receive-Job -Wait  | Select-Object @{Name='Computer';Expression={$_.Address.Substring(0, $_.Address.IndexOf("."))}},@{Name='Status';Expression={if ($_.StatusCode -eq 0) { $true } else { $false }}} | sort-object -property Computer
		}
		$ses_pos_list = $ses_list | where-Object {$_.Status -eq $true}
		$global:sessions = @()
		foreach ($computer in $ses_pos_list.Computer)
		{
			Remove-Variable -name "name_de" 2>$null
			Remove-Variable -name "name_en" 2>$null
			$session = qwinsta /server:$Computer | ForEach-Object {$_ -replace "\s{2,18}","," } | ConvertFrom-Csv
			$name_de = $session | where-object {$_.Benutzername -ne ""}.GetNewClosure() | select-object -expandproperty "Benutzername" 2>$null
			$name_en = $session | where-object {$_.Username -ne ""}.GetNewClosure() | select-object -expandproperty "Username" 2>$null
			$item = New-Object PSObject
			$item | Add-Member -type NoteProperty -Name 'Computer' -Value "$computer"
			if ($name_de)
			{
				$item | Add-Member -type NoteProperty -Name 'Session' -Value "$name_de"
			} elseif ($name_en)
			{
				$item | Add-Member -type NoteProperty -Name 'Session' -Value "$name_en"
			}else
			{
				$item | Add-Member -type NoteProperty -Name 'Session' -Value ""
			}
			$global:sessions += $item
		}
		$sessions
	}
	$global:session_job = Start-Job -ScriptBlock $session_scriptBlock -InputObject $workstations -ArgumentList @($workstations)
}



function Sort-ListViewColumn
{
	param (
		[ValidateNotNull()]
		[Parameter(Mandatory = $true)]
		[System.Windows.Forms.ListView]$ListView,
		[Parameter(Mandatory = $true)]
		[int]$ColumnIndex,
		[System.Windows.Forms.SortOrder]$SortOrder = 'None')
	
	if (($ListView.Items.Count -eq 0) -or ($ColumnIndex -lt 0) -or ($ColumnIndex -ge $ListView.Columns.Count))
	{
		return;
	}
	
	#region Define ListViewItemComparer
	try
	{
		$local:type = [ListViewItemComparer]
	}
	catch
	{
	Add-Type -ReferencedAssemblies ('System.Windows.Forms') -TypeDefinition  @" 
	using System;
	using System.Windows.Forms;
	using System.Collections;
	public class ListViewItemComparer : IComparer
	{
	    public int column;
	    public SortOrder sortOrder;
	    public ListViewItemComparer()
	    {
	        column = 0;
			sortOrder = SortOrder.Ascending;
	    }
	    public ListViewItemComparer(int column, SortOrder sort)
	    {
	        this.column = column;
			sortOrder = sort;
	    }
	    public int Compare(object x, object y)
	    {
			if(column >= ((ListViewItem)x).SubItems.Count)
				return  sortOrder == SortOrder.Ascending ? -1 : 1;
		
			if(column >= ((ListViewItem)y).SubItems.Count)
				return sortOrder == SortOrder.Ascending ? 1 : -1;
		
			if(sortOrder == SortOrder.Ascending)
	        	return String.Compare(((ListViewItem)x).SubItems[column].Text, ((ListViewItem)y).SubItems[column].Text);
			else
				return String.Compare(((ListViewItem)y).SubItems[column].Text, ((ListViewItem)x).SubItems[column].Text);
	    }
	}
"@ | Out-Null
	}
	#endregion
	
	if ($ListView.Tag -is [ListViewItemComparer])
	{
		#Toggle the Sort Order
		if ($SortOrder -eq [System.Windows.Forms.SortOrder]::None)
		{
			if ($ListView.Tag.column -eq $ColumnIndex -and $ListView.Tag.sortOrder -eq 'Ascending')
			{
				$ListView.Tag.sortOrder = 'Descending'
			}
			else
			{
				$ListView.Tag.sortOrder = 'Ascending'
			}
		}
		else
		{
			$ListView.Tag.sortOrder = $SortOrder
		}
		
		$ListView.Tag.column = $ColumnIndex
		$ListView.Sort()#Sort the items
	}
	else
	{
		if ($Sort -eq [System.Windows.Forms.SortOrder]::None)
		{
			$Sort = [System.Windows.Forms.SortOrder]::Ascending
		}
		
		#Set to Tag because for some reason in PowerShell ListViewItemSorter prop returns null
		$ListView.Tag = New-Object ListViewItemComparer ($ColumnIndex, $SortOrder)
		$ListView.ListViewItemSorter = $ListView.Tag #Automatically sorts
	}
}

# Function of the main GUI HWI Button
function global:handler_click_HWI 
{
	param
	(
		[Parameter()]
		[string]$entry
	)			
		
	if (Test-Connection -BufferSize 32 -Count 1 -ComputerName $entry)
	{
		$macs = get-netneighbor
		$system_info = Invoke-Command -computername $entry -ScriptBlock {get-computerinfo}
		$system_info_cpu = Invoke-Command -computername $entry -ScriptBlock {Get-CimInstance -ClassName CIM_Processor} 
		#$system_info_gpu = Invoke-Command -computername $entry -ScriptBlock {Get-CimInstance -ClassName Win32_VideoController} 
		#$system_info_vram = Invoke-Command -computername $entry {(Get-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0*")."HardwareInformation.qwMemorySize"}
		$system_info_gpu = Invoke-Command -computername $entry {(Get-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0*")}
		$system_info_hdd = Invoke-Command -computername $entry -ScriptBlock {get-volume | where-object { $_.DriveLetter -ne $null}}
		$system_info_lan = Invoke-Command -computername $entry -ScriptBlock {get-netadapter | Where-Object { $_.Status -eq "Up"}} 

		$si_name = ($system_info).CsName 
		$si_FQDN = ([System.Net.Dns]::GetHostByName($entry)).HostName
		$si_IP = ([System.Net.Dns]::GetHostByName($entry)).AddressList.IPAddressToString
		$si_mac = $macs | Where IPAddress -eq $si_IP | Select LinkLayerAddress -ExpandProperty LinkLayerAddress
		
		$si_sys = ($system_info).CsModel 
		$si_bios = ($system_info).BiosVersion 

		$si_win_name = ($system_info).WindowsProductName 
		$si_win_ver = ($system_info).WindowsVersion 
		$si_win_build = ($system_info).OsBuildNumber 
		$si_win_inst = ($system_info).OsInstallDate 
		
		$si_proc =  ($system_info_cpu).Name
		$si_proc_clock = ($system_info_cpu).MaxClockSpeed
		$si_ram = [math]::Round((($system_info).CsPhyicallyInstalledMemory) / 1MB, 3)
		
		$si_lan = ($system_info_lan).InterfaceDescription 
		$si_lan_link = ($system_info_lan).LinkSpeed 

		$si_gpu_name = ($system_info_gpu).Name 
		$si_gpu_Res = ($system_info_gpu).VideoModeDescription 
		$si_gpu_ram = [math]::Round(($system_info_vram) / 1GB)

		$si_hdd_ID = ($system_info_hdd).DriveLetter 
		$si_hdd_size = ($system_info_hdd).Size 
		$si_hdd_free = ($system_info_hdd).SizeRemaining  
	}
	
	$nly = 70
	$nlxa = 10
	$nlxb = 170
	$sizel = 150
	$sized = 600

	$hw_array = @()
	$item = New-Object PSObject
	$item | Add-Member -type NoteProperty -Name 'Label' -Value "FQDN"
	$item | Add-Member -type NoteProperty -Name 'Data' -Value $si_FQDN
	$hw_array += $item
	$item = New-Object PSObject
	$item | Add-Member -type NoteProperty -Name 'Label' -Value "IP"
	$item | Add-Member -type NoteProperty -Name 'Data' -Value $si_IP
	$hw_array += $item
	$item = New-Object PSObject
	$item | Add-Member -type NoteProperty -Name 'Label' -Value "MAC"
	$item | Add-Member -type NoteProperty -Name 'Data' -Value $si_mac
	$hw_array += $item
	$item = New-Object PSObject
	$item | Add-Member -type NoteProperty -Name 'Label' -Value "System"
	$item | Add-Member -type NoteProperty -Name 'Data' -Value $si_sys
	$hw_array += $item
	$item = New-Object PSObject
	$item | Add-Member -type NoteProperty -Name 'Label' -Value "BIOS"
	$item | Add-Member -type NoteProperty -Name 'Data' -Value $si_bios
	$hw_array += $item
	$item = New-Object PSObject
	$item | Add-Member -type NoteProperty -Name 'Label' -Value ""
	$item | Add-Member -type NoteProperty -Name 'Data' -Value ""
	$hw_array += $item
	$item = New-Object PSObject
	$item | Add-Member -type NoteProperty -Name 'Label' -Value "OS"
	$item | Add-Member -type NoteProperty -Name 'Data' -Value $si_win_name
	$hw_array += $item
	$item = New-Object PSObject
	$item | Add-Member -type NoteProperty -Name 'Label' -Value "OS Version"
	$item | Add-Member -type NoteProperty -Name 'Data' -Value $si_win_ver
	$hw_array += $item
	$item = New-Object PSObject
	$item | Add-Member -type NoteProperty -Name 'Label' -Value "OS Build"
	$item | Add-Member -type NoteProperty -Name 'Data' -Value $si_win_build
	$hw_array += $item
	$item = New-Object PSObject
	$item | Add-Member -type NoteProperty -Name 'Label' -Value "OS Inst. Date"
	$item | Add-Member -type NoteProperty -Name 'Data' -Value $si_win_inst
	$hw_array += $item
	$item = New-Object PSObject
	$item | Add-Member -type NoteProperty -Name 'Label' -Value ""
	$item | Add-Member -type NoteProperty -Name 'Data' -Value ""
	$hw_array += $item
	
	$cpu_no = 1
	foreach ($item in $system_info_cpu)
	{
		$si_proc =  ($item).Name
		$si_proc_clock = ($item).MaxClockSpeed
		
		$item = New-Object PSObject
		$item | Add-Member -type NoteProperty -Name 'Label' -Value "Processor $cpu_no"
		$item | Add-Member -type NoteProperty -Name 'Data' -Value $si_proc
		$hw_array += $item
		$item = New-Object PSObject
		$item | Add-Member -type NoteProperty -Name 'Label' -Value "Processor $cpu_no Clock"
		$item | Add-Member -type NoteProperty -Name 'Data' -Value "$si_proc_clock MHz"
		$hw_array += $item
		$item = New-Object PSObject
		$item | Add-Member -type NoteProperty -Name 'Label' -Value ""
		$item | Add-Member -type NoteProperty -Name 'Data' -Value ""
		$hw_array += $item
		$cpu_no += 1
	}
	
	$item = New-Object PSObject
	$item | Add-Member -type NoteProperty -Name 'Label' -Value "RAM"
	$item | Add-Member -type NoteProperty -Name 'Data' -Value "$si_ram GB"
	$hw_array += $item
	$item = New-Object PSObject
	$item | Add-Member -type NoteProperty -Name 'Label' -Value ""
	$item | Add-Member -type NoteProperty -Name 'Data' -Value ""
	$hw_array += $item
	
	$lan_no = 1
	foreach ($item in $system_info_lan)
	{
		$si_lan = ($item).InterfaceDescription 
		$si_lan_link = ($item).LinkSpeed 
		
		$item = New-Object PSObject
		$item | Add-Member -type NoteProperty -Name 'Label' -Value "Network $lan_no"
		$item | Add-Member -type NoteProperty -Name 'Data' -Value $si_lan
		$hw_array += $item
		$item = New-Object PSObject
		$item | Add-Member -type NoteProperty -Name 'Label' -Value "Link Speed $lan_no"
		$item | Add-Member -type NoteProperty -Name 'Data' -Value $si_lan_link
		$hw_array += $item
			$item = New-Object PSObject
		$item | Add-Member -type NoteProperty -Name 'Label' -Value ""
		$item | Add-Member -type NoteProperty -Name 'Data' -Value ""
		$hw_array += $item
		$lan_no += 1
	}
	
	$gpu_no = 1
	foreach ($item in $system_info_gpu)
	{
		$si_gpu_name = $item.'HardwareInformation.AdapterString'
		$si_gpu_ram = [math]::Round(($item.'HardwareInformation.qwMemorySize') / 1GB)
		
		$item = New-Object PSObject
		$item | Add-Member -type NoteProperty -Name 'Label' -Value "GPU $gpu_no"
		$item | Add-Member -type NoteProperty -Name 'Data' -Value $si_gpu_name
		$hw_array += $item
		$item = New-Object PSObject
		$item | Add-Member -type NoteProperty -Name 'Label' -Value "GPU $gpu_no VRAM"
		$item | Add-Member -type NoteProperty -Name 'Data' -Value "$si_gpu_ram GB"
		$hw_array += $item
		$item = New-Object PSObject
		$item | Add-Member -type NoteProperty -Name 'Label' -Value ""
		$item | Add-Member -type NoteProperty -Name 'Data' -Value ""
		$hw_array += $item
		$gpu_no += 1
	}
	
	$hdd_no = 1
	foreach ($item in $system_info_hdd)
	{
		if ($item.Size -ne $null)
		{
			$si_hdd_ID = ($item).DriveLetter
			$si_hdd_size = [math]::Round(($item.Size / 1GB ),2)
			$si_hdd_free = [math]::Round(($item.SizeRemaining / 1GB ),2)
			
			$si_hdd_size = $(($item.Size /1GB) -as [decimal]).ToString('N2')
			$si_hdd_free = $(($item.SizeRemaining /1GB) -as [decimal]).ToString('N2')

			$item = New-Object PSObject
			$item | Add-Member -type NoteProperty -Name 'Label' -Value "Drive Letter $hdd_no"
			$item | Add-Member -type NoteProperty -Name 'Data' -Value $si_hdd_ID
			$hw_array += $item
			$item = New-Object PSObject
			$item | Add-Member -type NoteProperty -Name 'Label' -Value "Partition Size $hdd_no"
			$item | Add-Member -type NoteProperty -Name 'Data' -Value "$si_hdd_size GB"
			$hw_array += $item
			$item = New-Object PSObject
			$item | Add-Member -type NoteProperty -Name 'Label' -Value "Free Space $hdd_no"
			$item | Add-Member -type NoteProperty -Name 'Data' -Value "$si_hdd_free GB"
			$hw_array += $item
			$item = New-Object PSObject
			$item | Add-Member -type NoteProperty -Name 'Label' -Value ""
			$item | Add-Member -type NoteProperty -Name 'Data' -Value ""
			$hw_array += $item
			$hdd_no += 1
		}
	}

	#This creates the HWI window 
	$HWIForm = New-Object System.Windows.Forms.Form 
	$HWIform.Text = "$tool"
	$HWIform.Size = New-Object System.Drawing.Size(600,500) 
	$HWIform.AutoSize = $true
	$HWIform.Autosize = $true
	$HWIform.StartPosition = "CenterScreen"
	$HWIform.Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($iconstream).GetHIcon()))
	$HWIform.FormBorderStyle = 'Fixed3D'
	$HWIform.MaximizeBox = $false
	$HWIform.KeyPreview = $True
	$HWIform.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
	{$HWIform.Close()}})
	$HWIform.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
	{$HWIform.Close()}})
	
	#This creates a label for the HWI Header
	$HWIformLabel = New-Object System.Windows.Forms.Label
	$HWIformLabel.Location = New-Object System.Drawing.Size(10,10) 
	$HWIformLabel.Size = New-Object System.Drawing.Size(450,30) 
	$HWIformLabel.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)
	$HWIformLabel.Text = $entry
	$HWIformLabel.Autosize = $true
	$HWIform.Controls.Add($HWIformLabel) 
	
	
	foreach ($item in $hw_array)
	{
		#This creates a label for the HWI Text
		$HWIformLabel = New-Object System.Windows.Forms.Label
		$HWIformLabel.Location = New-Object System.Drawing.Size($nlxa,$nly) 
		$HWIformLabel.Size = New-Object System.Drawing.Size($sizel,20) 
		$HWIformLabel.Autosize = $true	
		$HWIformLabel.Font = New-Object System.Drawing.Font("Arial",9)
		$HWIformLabel.Text = $item | Select-Object -ExpandProperty Label 
		$HWIform.Controls.Add($HWIformLabel)
		
		#This creates a data label for the HWI Text
		$HWIformData = New-Object System.Windows.Forms.Label
		$HWIformData.Location = New-Object System.Drawing.Size($nlxb,$nly) 
		$HWIformData.Size = New-Object System.Drawing.Size($sized,20) 
		$HWIformData.Autosize = $false	
		$HWIformData.Font = New-Object System.Drawing.Font("Arial",9)
		$HWIformData.Text = $item | Select-Object -ExpandProperty Data 
		$HWIform.Controls.Add($HWIformData) 
		$nly += 30
	}
	
	$objpictureBoxUFRa = New-Object Windows.Forms.PictureBox
	$objpictureBoxUFRa.Location = New-Object System.Drawing.Size(600,$nly)
	$objpictureBoxUFRa.Size = New-Object System.Drawing.Size(240,80)
	$objpictureBoxUFRa.Autosize = $true
	$objpictureBoxUFRa.Image = $imgUFR
	$HWIform.controls.add($objpictureBoxUFRa)
	$nly += 50
	
	#This creates the OK button and sets the Close event
	$OKButtona = New-Object System.Windows.Forms.Button
	$OKButtona.Location = New-Object System.Drawing.Size($nlxa,$nly)
	$OKButtona.Size = New-Object System.Drawing.Size(75,30)
	$OKButtona.Text = "OK"
	$OKButtona.Autosize = $true
	$OKButtona.Add_Click({$HWIform.Close()})
	$HWIform.Controls.Add($OKButtona)
		
	SetDoubleBuffered $HWIform
	[void] $HWIform.ShowDialog()
} 


# Function of the main GUI SWI Button
function global:handler_click_SWI 
{
	param
	(
		[Parameter()]
		[string]$Para1
	)
	$nly = 70
	$nlxa = 10
	$nlxb = 170
	$sizel = 150
	$sized = 600
		
	if (Test-Connection -BufferSize 32 -Count 1 -ComputerName $Para1)
	{
		$system_software = Invoke-Command -computername $Para1 -ScriptBlock ${function:Get-InstalledApplications}
	}
		
	#This creates the SWI window 
	$SWIForm = New-Object System.Windows.Forms.Form 
	$SWIform.Text = "$tool"
	$SWIform.Size = New-Object System.Drawing.Size(1500,1100) 
	$SWIform.Autosize = $true
	$SWIform.StartPosition = "CenterScreen"
	$SWIform.Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($iconstream).GetHIcon()))
	$SWIform.FormBorderStyle = 'Fixed3D'
	$SWIform.MaximizeBox = $false
	$SWIform.KeyPreview = $True
	$SWIform.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
	{$SWIform.Close()}})
	$SWIform.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
	{$SWIform.Close()}})
	
	#This creates a label for the SWI Header
	$SWIformLabel = New-Object System.Windows.Forms.Label
	$SWIformLabel.Location = New-Object System.Drawing.Size(10,10) 
	$SWIformLabel.Size = New-Object System.Drawing.Size(450,30) 
	$SWIformLabel.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)
	$SWIformLabel.Text = $Para1
	$SWIformLabel.Autosize = $true
	$SWIform.Controls.Add($SWIformLabel) 
	
	# Create a ListView, set the view to 'Details' and add columns
	$listView = New-Object System.Windows.Forms.ListView
	$listView.View = 'Details'
	$listView.Width = 1450
	$listView.Height = 900
	$listView.AutoSize = $true
	$listView.Location = New-Object System.Drawing.Size($nlxa,$nly) 
	
	$listView.Font = New-Object System.Drawing.Font("Arial",10,[System.Drawing.FontStyle]::Bold)
	$listView.Columns.Add('Software Package Name')
	$listView.Columns.Add('Version')
	$listView.Columns.Add('Install Date')

	foreach ($item in $system_software)
	{
		if ($item.DisplayName -ne $null)
		{
			$software = $item | Select-Object -ExpandProperty DisplayName
			$version = $item | Select-Object -ExpandProperty DisplayVersion
			$instdatex = $item | Select-Object -ExpandProperty InstallDate
			$instdate = get-date ([DateTime]::ParseExact($instdatex, 'yyyyMMdd', $null)) -format "dd.MM.yyyy"
			
			
			$item1 = New-Object System.Windows.Forms.ListViewItem($software)
			$item1.Font = New-Object System.Drawing.Font("Arial",8,[System.Drawing.FontStyle]::Regular)
			$item1.SubItems.Add($version)
			$item1.SubItems.Add($instdate)
			$listView.Items.Add($item1)
		}
	}
	$ListView.AutoResizeColumns(1)
	$listView.Add_ColumnClick({
		param($sender,$e)
		# Sort as Text String (not [int])
		Sort-ListViewColumn -ListView $this -ColumnIndex $e.column
	})
	$SWIform.Controls.Add($listView)
	
	#This creates the OK button and sets the Close event
	$OKButtona = New-Object System.Windows.Forms.Button
	$OKButtona.Location = New-Object System.Drawing.Size(10,1050)
	$OKButtona.Size = New-Object System.Drawing.Size(75,30)
	$OKButtona.Text = "OK"
	$OKButtona.Autosize = $true
	$OKButtona.Add_Click({$SWIform.Close()})
	$SWIform.Controls.Add($OKButtona)
		
	$objpictureBoxUFRa = New-Object Windows.Forms.PictureBox
	$objpictureBoxUFRa.Location = New-Object System.Drawing.Size(1200,1000)
	$objpictureBoxUFRa.Size = New-Object System.Drawing.Size(240,80)
	$objpictureBoxUFRa.Autosize = $true
	$objpictureBoxUFRa.Image = $imgUFR
	$SWIform.controls.add($objpictureBoxUFRa)
	
	SetDoubleBuffered $SWIform
	[void] $SWIform.ShowDialog()
}


# Function of the main GUI OK button
function global:handler_click_OK 
{}

# Function of the Drive OK button
function global:handler_click_drive_OK 
{
	$global:letter = $lettertemp
}

function global:handler_click_drive_CANCEL 
{
	$global:letter = $null
}

# Function of the WOL button
function global:handler_click_WOL 
{
	param
	(
		[Parameter()]
		[string]$Para1,
		[string]$Para2
	)
	
	if (!($domain_check -eq "lic.ads.zbsa.privat"))
	{
		$result_WOL=[System.Windows.Forms.MessageBox]::Show("Warning$([System.Environment]::NewLine)Your computer $env:computername is not part of the LIC domain.$([System.Environment]::NewLine)WOL only works in the local LIC subnet / network. $([System.Environment]::NewLine)$([System.Environment]::NewLine)Do you want to send the WOL command via the LIC jump-host / proxy $jumphost (LIC administrative credentials required)?","$tool",4)			
		if($result_WOL -eq "Yes")
		{
			if ((Test-Connection -BufferSize 32 -Count 1 -ComputerName $jumphost 2>$null))
			{
				# Prompt for Credentials and verify them by using the DirectoryServices.AccountManagement assembly.
				Add-Type -AssemblyName System.DirectoryServices.AccountManagement
				
				# Extract the current user's domain and also pre-format the user name to be used in the credential prompt.
				$UserDomain = "LIC.ads.zbsa.privat"
				$UserName = "$UserDomain\"
				
				# Define the starting number (always #1) and the desired maximum number of attempts, and the initial credential prompt message to use.
				$Attempt = 1
				$MaxAttempts = 3
				$CredentialPrompt = "Please authenticate to access the LIC jumphost $jumphost. (Attempt #$Attempt of $MaxAttempts):"
				
				# Set ValidAccount to false so it can be used to exit the loop when a valid account is found (and the value is changed to $True).
				$ValidAccount = $False

				# Loop through prompting for and validating credentials, until the credentials are confirmed, or the maximum number of attempts is reached.
				Do 
				{
					# Blank any previous failure messages and then prompt for credentials with the custom message and the pre-populated domain\user name.
					$FailureMessage = $Null
					$credxwol = Get-Credential -UserName $UserName -Message $CredentialPrompt
					
					# Verify the credentials prompt wasn't bypassed.
					If ($credxwol) 
					{
						# If the user name was changed, then switch to using it for this and future credential prompt validations.
						If ($credxwol.UserName -ne $UserName) 
						{
							$UserName = $credxwol.UserName
						}
						# Test the user name (even if it was changed in the credential prompt) and password.
						$ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain
						Try 
						{
							$PrincipalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext $ContextType,$UserDomain
						} 
						Catch 
						{
							If ($_.Exception.InnerException -like "*The server could not be contacted*") 
							{
								$FailureMessage = "Could not contact a server for the specified domain on attempt #$Attempt out of $MaxAttempts."
							} Else 
							{
								$FailureMessage = "Unpredicted failure: `"$($_.Exception.Message)`" on attempt #$Attempt out of $MaxAttempts."
							}
						}
						# If there wasn't a failure talking to the domain test the validation of the credentials, and if it fails record a failure message.
						If (-not($FailureMessage)) 
						{
							$ValidAccount = $PrincipalContext.ValidateCredentials($UserName,$credxwol.GetNetworkCredential().Password)
							If (-not($ValidAccount)) 
							{
								$FailureMessage = "Bad user name or password used on credential prompt attempt #$Attempt out of $MaxAttempts."
							}
						}
						
					# Otherwise the credential prompt was (most likely accidentally) bypassed so record a failure message.
					} Else 
					{
						Break
					}
				 
					# If there was a failure message recorded above, display it, and update credential prompt message.
					If ($FailureMessage) 
					{
						Write-Warning "$FailureMessage"
						$Attempt++
						If ($Attempt -lt $MaxAttempts) 
						{
							$CredentialPrompt = "Authentication error. Please try again (attempt #$Attempt out of $MaxAttempts):"
						} 
					}
					
				} Until (($ValidAccount) -or ($Attempt -gt $MaxAttempts))
				if ($Attempt -gt $MaxAttempts)
				{
					# Break if exceeded max. attempts.
					Break
				}

				If ($ValidAccount)
				{
					invoke-command -computername $jumphost -Credential $credxwol -Scriptblock {
						param($Para1, $Para2)
						function Invoke-WakeOnLan
						{
						  param
						  (
							# MAC Address(es) mandatory
							[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
							
							# MAC Address pattern match (regex pattern)
							[ValidatePattern('^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$')]
							[string[]]
							$MacAddress 
						  )
						  begin
						  {
							# Instantiate UDP client
							$UDPclient = [System.Net.Sockets.UdpClient]::new()
						  }
						  process
						  {
							foreach($_ in $MacAddress)
							{
							  try 
							  {
								$currentMacAddress = $_
								
								# Get Byte Array from MAC Address
								$mac = $currentMacAddress -split '[:-]' |
								
								# Convert hex to byte
								ForEach-Object {[System.Convert]::ToByte($_, 16)}
						 
								# Compose the "magic packet"
								# Create a byte array with 102 bytes initialized to 255 each
								$packet = [byte[]](,0xFF * 102)
								
								# Leave the first 6 bytes untouched and repeat the target MAC address bytes in bytes 7 through 102
								6..101 | Foreach-Object {$packet[$_] = $mac[($_ % 6)]}
								
								# Connect to port 400 on broadcast address
								$UDPclient.Connect(([System.Net.IPAddress]::Broadcast),4000)
								
								# Send the magic packet to the broadcast address
								$null = $UDPclient.Send($packet, $packet.Length)
							  }
							  catch 
							  {
								Write-Warning "Unable to send ${mac}: $_"
							  }
							}
						  }
						  end
						  {
							# Release the UDP client and free memory
							$UDPclient.Close()
							$UDPclient.Dispose()
						  }
						}
						Invoke-WakeOnLan -MacAddress $Para1
						
					} -Argumentlist $Para1, $Para2
					$message = [System.Windows.Forms.MessageBox]::Show("WOL magic packet sent to wake-up computer $Para2 (MAC: $Para1).$([System.Environment]::NewLine)Depending on hardware and configuration it may take a few minutes before the computer is fully up and running.","$tool",0)
				}
			}else
			{
				$warning = [System.Windows.Forms.MessageBox]::Show("$jumphost is not available. WOL magic packet cannot be sent from outside the LIC subnet.$([System.Environment]::NewLine)Please check the status of $jumphost or execute this tool on a computer within the LIC domain.","$tool",0)
			}
		} 
	
	}else
	{
		$message = [System.Windows.Forms.MessageBox]::Show("WOL magic packet sent to wake-up computer $Para2 (MAC: $Para1).$([System.Environment]::NewLine)Depending on hardware and configuration it may take a few minutes before the computer is fully up and running.","$tool",0)
		Invoke-WakeOnLan -MacAddress $Para1
	}
}

# Function of the data drive button
function global:handler_click_DATA 
{
	param
	(
		[Parameter()]
		[string]$Para1
	)
	& explorer.exe $Para1
}

# Function of the remove share button
function global:handler_click_REMOVESHARE 
{
	param
	(
		[Parameter()]
		[string]$Para1
	)
	$gshare = Get-PSdrive | where-object {$_.DisplayRoot -eq $Para1}
	if ($gshare)
	{
		$drive = $gshare.Name+":\"
		$netdrive = $gshare.Name+":"
		$Result = [System.Windows.Forms.MessageBox]::Show("Do you want to disconnect the network share $Para1 on $drive ? $([System.Environment]::NewLine)You can re-connect it again any time.","$tool",4)
		
		if($Result -eq "Yes")
		{
			Remove-PSDrive $gshare.Name -Force 2>$null
			net use "$netdrive" /delete /y 2>$null
			$objGroupShareButton.Enabled = $false
		}
	}
}

# Function for the map network share button
function global:handler_click_MAPSHARE 
{
	param
	(
		[Parameter()]
		[string]$Para1
	)
	$gshare = Get-PSdrive | where-object {$_.DisplayRoot -eq $Para1}
	if ($gshare)
	{
		$drive = $gshare.Name+":\"
		[System.Windows.Forms.MessageBox]::Show("Network share already connected. $([System.Environment]::NewLine)A network share mapping to $Para1 is already mapped to drive $drive.$([System.Environment]::NewLine)Opening $drive in Explorer.","$tool",0)
		& explorer.exe $drive
	} else
	{
		$Result = [System.Windows.Forms.MessageBox]::Show("Network share not found on the local system. $([System.Environment]::NewLine)A network share mapping to $Para1 is not present for your user on the current system. $([System.Environment]::NewLine)Would you like to set-up a persistent mapping to your home-lab network share?","$tool",4)
		if($Result -eq "Yes")
		{
			$domain = ($groupshares | where-object {$_.group -eq $objGroupDriveList.SelectedItem}).domain
			external_authentication ($domain)
			
			if ($credx)
			{
				# Populate list of drive letters and eliminate letters already in use	
				$AllLetters = 65..90 | ForEach-Object {[char]$_ }
				$letters = (get-psdrive).name 
				$freeletters = $allletters | where {$letters -notcontains "$($_)"}
				
				## GUI selection for drive letter for network share
				#This creates the drive letter form 
				$driveForm = New-Object System.Windows.Forms.Form 
				$driveForm.Text = "$tool"
				$driveForm.Size = New-Object System.Drawing.Size(500,300) 
				$driveForm.Autosize = $true
				$driveForm.StartPosition = "CenterScreen"
				$driveForm.Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($iconstream).GetHIcon()))
				$driveForm.FormBorderStyle = 'Fixed3D'
				$driveForm.MaximizeBox = $false
				$driveForm.KeyPreview = $True
				$driveForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
				{$driveForm.Close()}})
				$driveForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
				{$driveForm.Close()}})
				
				#This creates a label for the Header
				$driveFormLabel = New-Object System.Windows.Forms.Label
				$driveFormLabel.Location = New-Object System.Drawing.Size(10,10) 
				$driveFormLabel.Size = New-Object System.Drawing.Size(350,30) 
				$driveFormLabel.Font = New-Object System.Drawing.Font("Arial",8)
				$driveFormLabel.Text = "Select drive letter for:"
				$driveFormLabel.Autosize = $true
				$driveForm.Controls.Add($driveFormLabel)
				
				#This creates a label for the share name
				$driveFormLabel1 = New-Object System.Windows.Forms.Label
				$driveFormLabel1.Location = New-Object System.Drawing.Size(10,40) 
				$driveFormLabel1.Size = New-Object System.Drawing.Size(350,40) 
				$driveFormLabel1.Font = New-Object System.Drawing.Font("Arial",8,[System.Drawing.FontStyle]::Bold )
				$driveFormLabel1.Text = "$groupshare_sel"
				$driveFormLabel1.Autosize = $true
				$driveForm.Controls.Add($driveFormLabel1)

				#This creates a label for the drop-down Header
				$driveFormLabel2 = New-Object System.Windows.Forms.Label
				$driveFormLabel2.Location = New-Object System.Drawing.Size(10,80) 
				$driveFormLabel2.Size = New-Object System.Drawing.Size(350,30) 
				$driveFormLabel2.Autosize = $true
				$driveFormLabel2.Font = New-Object System.Drawing.Font("Arial",8)
				$driveFormLabel2.Text = "Available drive letters:" 
				$driveForm.Controls.Add($driveFormLabel2)
			
				# This creates the drive list drop-down menu
				$driveFormDriveList = New-Object System.Windows.Forms.ComboBox
				$driveFormDriveList.Location = New-Object System.Drawing.Size(10,110) 
				$driveFormDriveList.Text = "Drive Letter"
				$driveFormDriveList.Width = 180
				$driveFormDriveList.Autosize = $true
				
				# Populate the drop-down list with free drive letters
				$freeletters | ForEach-Object {[void] $driveFormDriveList.Items.Add($_)}
				$driveFormDriveList.add_SelectedIndexChanged({
				$global:lettertemp = $driveFormDriveList.SelectedItem
				})
				$driveForm.Controls.Add($driveFormDriveList)
					
				#This creates the OK button and sets the event
				$OKButtond = New-Object System.Windows.Forms.Button
				$OKButtond.Location = New-Object System.Drawing.Size(10,210)
				$OKButtond.Size = New-Object System.Drawing.Size(75,30)
				$OKButtond.Text = "OK"
				$OKButtond.Autosize = $true
				$OKButtond.Add_Click({handler_click_drive_OK; $driveForm.Close()})
				$driveForm.Controls.Add($OKButtond)
					
				#This creates the Cancel button and sets the event
				$CancelButtond = New-Object System.Windows.Forms.Button
				$CancelButtond.Location = New-Object System.Drawing.Size(100,210)
				$CancelButtond.Size = New-Object System.Drawing.Size(75,30)
				$CancelButtond.Text = "Cancel"
				$CancelButtond.Autosize = $true
				$CancelButtond.Add_Click({handler_click_drive_CANCEL; $driveForm.Close()})
				$driveForm.Controls.Add($CancelButtond)
				
				$objpictureBoxUFRd = New-Object Windows.Forms.PictureBox
				$objpictureBoxUFRd.Location = New-Object System.Drawing.Size(240,160)
				$objpictureBoxUFRd.Size = New-Object System.Drawing.Size(240,80)
				$objpictureBoxUFRd.Autosize = $true
				$objpictureBoxUFRd.Image = $imgUFR
				$driveForm.controls.add($objpictureBoxUFRd)
				
				SetDoubleBuffered $driveForm
				[void] $driveForm.ShowDialog()
				
				if ($letter)
				{
					New-PSdrive -Name $letter -Root $Para1 -PSProvider "FileSystem" -Persist -Scope Global -Credential $credx
					$drive = (get-psdrive | where-object {$_.DisplayRoot -eq $Para1}).Name+":\"
					$objGroupShareButton.Enabled = $true
					& explorer.exe $drive
				}
			}
		}
	}
}

# Function for the Cancel button
function global:handler_click_Cancel 
{}

# Function to stop the timer
function global:stopTimer 
{
	$timer.Enabled = $false
	$timer2.Enabled = $false
	$timer3.Enabled = $false
	$clock.Enabled = $false
}

# Function clock timer
function global:handler_clock 
{
	#This creates a label for the timer
	$global:nn--
	$objwsclock.Text = "Updating in $nn seconds."
	$objForm.Controls.Add($objwsclock) 	
	$objForm.Refresh()
}

# Function for About Menu Entry
function global:About 
{
			#This creates the About window 
			$aboutForm = New-Object System.Windows.Forms.Form 
			$aboutform.Text = "$tool"
			$aboutform.Size = New-Object System.Drawing.Size(600,500) 
			$aboutform.Autosize = $true
			$aboutform.StartPosition = "CenterScreen"
			$aboutform.Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($iconstream).GetHIcon()))
			$aboutform.FormBorderStyle = 'Fixed3D'
			$aboutform.MaximizeBox = $false
			$aboutform.KeyPreview = $True
			$aboutform.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
			{$aboutform.Close()}})
			$aboutform.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
			{$aboutform.Close()}})
			
			#This creates a label for the About Header
			$aboutformLabel = New-Object System.Windows.Forms.Label
			$aboutformLabel.Location = New-Object System.Drawing.Size(10,10) 
			$aboutformLabel.Size = New-Object System.Drawing.Size(450,30) 
			$aboutformLabel.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)
			$aboutformLabel.Text = "$tool"
			$aboutformLabel.Autosize = $true
			$aboutform.Controls.Add($aboutformLabel) 
			
			#This creates a label for the About version Text
			$aboutformLabel = New-Object System.Windows.Forms.Label
			$aboutformLabel.Location = New-Object System.Drawing.Size(10,70) 
			$aboutformLabel.Size = New-Object System.Drawing.Size(450,100) 
			$aboutformLabel.Autosize = $true	
			$aboutformLabel.Font = New-Object System.Drawing.Font("Arial",10)
			$aboutformLabel.Text = "Version $version - $lastdate  `r`nThis is some additional random text for the `r`n$tool."
			$aboutform.Controls.Add($aboutformLabel) 
	
			#This creates a label for the Copyright text
			$aboutformLabel = New-Object System.Windows.Forms.Label
			$aboutformLabel.Location = New-Object System.Drawing.Size(10,200) 
			$aboutformLabel.Size = New-Object System.Drawing.Size(450,150) 
			$aboutformLabel.Font = New-Object System.Drawing.Font("Arial",8)
			$aboutformLabel.Text = "Copyright © 2022 - Alle Rechte vorbehalten. `r`n`r`nTobias Wernet `r`nUniversity of Freiburg `r`nSignaling Campus Freiburg `r`nLife Imaging Center `r`nHabsburgerstr. 49 `r`n79104 Freiburg im Breisgau"
			$aboutform.Controls.Add($aboutformLabel) 
			
			#This creates a label for Contact E-Mail
			$aboutformLink = New-Object System.Windows.Forms.LinkLabel
			$aboutformLink.Location = New-Object System.Drawing.Size(10,360) 
			$aboutformLink.Size = New-Object System.Drawing.Size(300,40)
			$aboutformLink.Autosize = $true			
			$aboutformLink.Font = New-Object System.Drawing.Font("Arial",8)
			$aboutformLink.Text = "lic@imaging.uni-freiburg.de"
			$aboutformLink.LinkColor ="blue"
			$aboutformLink.add_Click({[system.Diagnostics.Process]::start("mailto:lic@imaging.uni-freiburg.de")})
			$aboutform.Controls.Add($aboutformLink) 
	
			#This creates the OK button and sets the Close event
			$OKButtona = New-Object System.Windows.Forms.Button
			$OKButtona.Location = New-Object System.Drawing.Size(10,415)
			$OKButtona.Size = New-Object System.Drawing.Size(75,30)
			$OKButtona.Text = "OK"
			$OKButtona.Autosize = $true
			$OKButtona.Add_Click({handler_click_drive_OK; $aboutform.Close()})
			$aboutform.Controls.Add($OKButtona)
				
			$objpictureBoxUFRa = New-Object Windows.Forms.PictureBox
			$objpictureBoxUFRa.Location = New-Object System.Drawing.Size(320,370)
			$objpictureBoxUFRa.Size = New-Object System.Drawing.Size(240,80)
			$objpictureBoxUFRa.Autosize = $true
			$objpictureBoxUFRa.Image = $imgUFR
			$aboutform.controls.add($objpictureBoxUFRa)
			
			SetDoubleBuffered $aboutform
			[void] $aboutform.ShowDialog()
}
	
# Global update function
function global:handler_click_Update
{
	# Collect Background Job Data
	if ($status_jobs)
	{
		Remove-Variable -name "host_list" 2>$null
		$global:host_list = $status_jobs | Get-Job | Wait-Job -Timeout 5 | Receive-Job | Select-Object @{Name='Computer';Expression={$_.Address.Substring(0, $_.Address.IndexOf("."))}},@{Name='Status';Expression={if ($_.StatusCode -eq 0) { $true } else { $false }}} | sort-object -property Computer
	}
	if ($session_job)
	{
		$global:active_sessions = $session_job | Get-Job | Wait-Job -Timeout 5 | Receive-Job 
	}
 	
	$num = 3
	
	foreach ($item in $workstations)
	{
		if ($item.class -match "Workstation")
		{
			$computer = $item.computer

			$posx = (30 * $num) + 25
			$posxa = (30 * $num) + 30
	
		
			#This updates the Workstation Status entry
			$posy = 180
			$sizex = 30
			$sizey = 100
			$objstat = New-Object System.Windows.Forms.Label
			$objstat.Name = "status_$computer"
			$objstat.Location = New-Object System.Drawing.Size($posy,$posxa) 
			$objstat.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objstat.Autosize = $true
			$objForm.Controls.RemoveByKey("status_$computer")
			$check_stat = $host_list | where-object {$_.Computer -eq $computer}
			if ($check_stat.Status -eq $true)
			{
				$objstat.ForeColor = "green"
				$objstat.Text = "ONLINE"
			} else
			{
				$objstat.ForeColor = "red"
				$objstat.Text = "OFFLINE"
			}
			$objForm.Controls.RemoveByKey("status_$computer")
			$objForm.Controls.Add($objstat)
			
			#This updates the Workstation WOL Button
			$posy = 280
			$sizex = 30
			$sizey = 180
			$objWOLButton = New-Object System.Windows.Forms.Button 
			$objWOLButton.Name = "WOL_$computer"
			$objWOLButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objWOLButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objWOLButton.Text = "Wake-Up (WOL)"
			$objWOLButton.Autosize = $true
			$mac = $null
			$mac = ($workstations | Where-Object {$_.computer -eq $computer}.GetNewClosure()).MAC
			$objWOLButton.Add_Click({handler_click_WOL $mac $computer}.GetNewClosure())
			if ($mac)
			{
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $false)
				{
					$objWOLButton.Enabled = $true
				}
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
				{
					$objWOLButton.Enabled = $false
				}
			}
			else
			{
				#This creates the WOL not supported entry
				$objWOLButton.Text = "WOL not supported"
				$objWOLButton.Enabled = $false
			}
			$objForm.Controls.RemoveByKey("WOL_$computer")
			$objForm.Controls.Add($objWOLButton) 
			
			#This updates the Workstation Data Share Button
			$posy = 500
			$sizex = 30
			$sizey = 180
			$objDataButton = New-Object System.Windows.Forms.Button 
			$objDataButton.Name = "data_$computer"
			$objDataButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objDataButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objDataButton.Text = "Access Data Share"
			$objDataButton.Autosize = $true
			$dataFQDN = ($workstations | Where-Object {$_.Computer -eq $computer}).FQDN
			$dshare = ($workstations | Where-Object {$_.Computer -eq $computer}).Share
			$datashare = "\\$dataFQDN\$dshare"
			$objDataButton.Add_Click({handler_click_DATA($datashare)}.GetNewClosure())
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				if ($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Share)
				{
					$objDataButton.Text = "Access Data Share"
					$objDataButton.Enabled = $true
				} else 
				{
					$objDataButton.Text = "Share not supported"
					$objDataButton.Enabled = $false
				}
			} else
			{
				if ($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Share)
				{
					$objDataButton.Text = "Access Data Share"
					$objDataButton.Enabled = $false
				} else 
				{
					$objDataButton.Text = "Share not supported"
					$objDataButton.Enabled = $false
				}
			}
			$objForm.Controls.RemoveByKey("data_$computer")
			$objForm.Controls.Add($objDataButton)
			
			#This updates the Workstation Session entry
			$posy = 710
			$sizex = 30
			$sizey = 140
			$objses = New-Object System.Windows.Forms.Label 
			$objses.Name = "session_$computer"
			$objses.Location = New-Object System.Drawing.Size($posy,$posxa) 
			$objses.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objses.Autosize = $true
		
			$host_sel = $host_list | where-object {$_.Computer -eq $computer -and $_.Status -eq $true}
			if ($host_sel.Status -eq $true)
			{
				Remove-Variable -name "name" 2>$null
				$name = ($active_sessions | where-object {$_.Computer -eq $computer}).Session
				if ($name)
				{
					$objses.Text = $name
				} else
				{
					$objses.Text = $null
				}
			} else
			{
				$objses.Text = $null
			}
			$objForm.Controls.RemoveByKey("session_$computer")
			$objForm.Controls.Add($objses)
			
			#This creates the HW Info Button
			$posy = 890
			$sizex = 30
			$sizey = 170
			
			$objHWButton = New-Object System.Windows.Forms.Button 
			$objHWButton.Name = "HWI$computer"
			$objHWButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objHWButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objHWButton.Autosize = $true
			$objHWButton.Text = "Hardware Info"
			$objHWButton.Add_Click({handler_click_HWI($computer)}.GetNewClosure())
			
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objHWButton.Enabled = $true
			}else
			{
				$objHWButton.Enabled = $false
			}
		
			$objForm.Controls.RemoveByKey("HWI$computer")
			$objForm.Controls.Add($objHWButton)
			
			#This creates the SW Info Button
			$posy = 1100
			$sizex = 30
			$sizey = 170
			
			$objSWButton = New-Object System.Windows.Forms.Button 
			$objSWButton.Name = "SWI$computer"
			$objSWButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objSWButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objSWButton.Autosize = $true
			$objSWButton.Text = "Software Info"
			$objSWButton.Add_Click({handler_click_SWI $computer}.GetNewClosure())
			
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objSWButton.Enabled = $true
			}else
			{
				$objSWButton.Enabled = $false
			}
			
			$objForm.Controls.RemoveByKey("SWI$computer")
			$objForm.Controls.Add($objSWButton)
			
			
			#This creates the RDP Button
			$posy = 1310
			$sizex = 30
			$sizey = 170
			
			$objRDPButton = New-Object System.Windows.Forms.Button 
			$objRDPButton.Name = "RDP$computer"
			$objRDPButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objRDPButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objRDPButton.Autosize = $true
			$objRDPButton.Text = "Remote Desktop"
			$objRDPButton.Add_Click({handler_click_RDP($computer)}.GetNewClosure())
			
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objRDPButton.Enabled = $true
			} else
			{
				$objRDPButton.Enabled = $false
			}
			
			$objForm.Controls.RemoveByKey("RDP$computer")
			$objForm.Controls.Add($objRDPButton)
			
			
			#This updates the Workstation Shutdown Button
			$posy = 1520
			$sizex = 30
			$sizey = 200
			$objShutdownButton = New-Object System.Windows.Forms.Button 
			$objShutdownButton.Name = "shut$computer"
			$objShutdownButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objShutdownButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objShutdownButton.Autosize = $true
			$objShutdownButton.Text = "Shutdown"
			$objShutdownButton.Add_Click({handler_click_Shutdown($computer)}.GetNewClosure())
			
			if (($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Shutdown) -eq "1")
			{
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
				{
					$objShutdownButton.Enabled = $true
				} else
				{
					$objShutdownButton.Enabled = $false
				}
			} else 
			{
				$objShutdownButton.Text = "Shutdown not supported"
				$objShutdownButton.Enabled = $false
			}
			
			$objForm.Controls.RemoveByKey("shut$computer")
			$objForm.Controls.Add($objShutdownButton)
			
			$num++
		}
	}
	
	$num++
	$num++
	
	foreach ($item in $workstations)
	{
		if ($item.class -match "System")
		{
			$computer = $item.computer

			$posx = (30 * $num) + 25
			$posxa = (30 * $num) + 30
			
			#This updates the Workstation Status entry
			$posy = 180
			$sizex = 30
			$sizey = 100
			$objstat = New-Object System.Windows.Forms.Label
			$objstat.Name = "status_$computer"
			$objstat.Location = New-Object System.Drawing.Size($posy,$posxa) 
			$objstat.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objstat.Autosize = $true
			$objForm.Controls.RemoveByKey("status_$computer")
			$check_stat = $host_list | where-object {$_.Computer -eq $computer}
			if ($check_stat.Status -eq $true)
			{
				$objstat.ForeColor = "green"
				$objstat.Text = "ONLINE"
			} else
			{
				$objstat.ForeColor = "red"
				$objstat.Text = "OFFLINE"
			}
			$objForm.Controls.RemoveByKey("status_$computer")
			$objForm.Controls.Add($objstat)
			
			#This updates the Workstation WOL Button
			$posy = 280
			$sizex = 30
			$sizey = 180
			$objWOLButton = New-Object System.Windows.Forms.Button 
			$objWOLButton.Name = "WOL_$computer"
			$objWOLButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objWOLButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objWOLButton.Text = "Wake-Up (WOL)"
			$objWOLButton.Autosize = $true
			$mac = $null
			$mac = ($workstations | Where-Object {$_.computer -eq $computer}.GetNewClosure()).MAC
			$objWOLButton.Add_Click({handler_click_WOL $mac $computer}.GetNewClosure())
			if ($mac)
			{
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $false)
				{
					$objWOLButton.Enabled = $true
				}
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
				{
					$objWOLButton.Enabled = $false
				}
			}
			else
			{
				#This creates the WOL not supported entry
				$objWOLButton.Text = "WOL not supported"
				$objWOLButton.Enabled = $false
			}
			$objForm.Controls.RemoveByKey("WOL_$computer")
			$objForm.Controls.Add($objWOLButton) 
			
			#This updates the Workstation Data Share Button
			$posy = 500
			$sizex = 30
			$sizey = 180
			$objDataButton = New-Object System.Windows.Forms.Button 
			$objDataButton.Name = "data_$computer"
			$objDataButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objDataButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objDataButton.Text = "Access Data Share"
			$objDataButton.Autosize = $true
			$dataFQDN = ($workstations | Where-Object {$_.Computer -eq $computer}).FQDN
			$dshare = ($workstations | Where-Object {$_.Computer -eq $computer}).Share
			$datashare = "\\$dataFQDN\$dshare"
			$objDataButton.Add_Click({handler_click_DATA($datashare)}.GetNewClosure())
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				if ($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Share)
				{
					$objDataButton.Text = "Access Data Share"
					$objDataButton.Enabled = $true
				} else 
				{
					$objDataButton.Text = "Share not supported"
					$objDataButton.Enabled = $false
				}
			} else
			{
				if ($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Share)
				{
					$objDataButton.Text = "Access Data Share"
					$objDataButton.Enabled = $false
				} else 
				{
					$objDataButton.Text = "Share not supported"
					$objDataButton.Enabled = $false
				}
			}
			$objForm.Controls.RemoveByKey("data_$computer")
			$objForm.Controls.Add($objDataButton)
			
			#This updates the Workstation Session entry
			$posy = 710
			$sizex = 30
			$sizey = 140
			$objses = New-Object System.Windows.Forms.Label 
			$objses.Name = "session_$computer"
			$objses.Location = New-Object System.Drawing.Size($posy,$posxa) 
			$objses.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objses.Autosize = $true
		
			$host_sel = $host_list | where-object {$_.Computer -eq $computer -and $_.Status -eq $true}
			if ($host_sel.Status -eq $true)
			{
				Remove-Variable -name "name" 2>$null
				$name = ($active_sessions | where-object {$_.Computer -eq $computer}).Session
				if ($name)
				{
					$objses.Text = $name
				} else
				{
					$objses.Text = $null
				}
			} else
			{
				$objses.Text = $null
			}
			$objForm.Controls.RemoveByKey("session_$computer")
			$objForm.Controls.Add($objses)
			
					
			#This creates the HWI Button
			$posy = 890
			$sizex = 30
			$sizey = 170
			
			$objHWButton = New-Object System.Windows.Forms.Button 
			$objHWButton.Name = "HWI$computer"
			$objHWButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objHWButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objHWButton.Autosize = $true
			$objHWButton.Text = "Hardware Info"
			$objHWButton.Add_Click({handler_click_HWI($computer)}.GetNewClosure())
			
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objHWButton.Enabled = $true
			}else
			{
				$objHWButton.Enabled = $false
			}
			
			$objForm.Controls.RemoveByKey("HWI$computer")
			$objForm.Controls.Add($objHWButton)
			
			
			
			#This creates the SWI Button
			$posy = 1100
			$sizex = 30
			$sizey = 170
			
			$objSWButton = New-Object System.Windows.Forms.Button 
			$objSWButton.Name = "SWI$computer"
			$objSWButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objSWButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objSWButton.Autosize = $true
			$objSWButton.Text = "Software Info"
			$objSWButton.Add_Click({handler_click_SWI $computer}.GetNewClosure())
			
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objSWButton.Enabled = $true
			}else
			{
				$objSWButton.Enabled = $false
			}
			
			$objForm.Controls.RemoveByKey("SWI$computer")
			$objForm.Controls.Add($objSWButton)
			
			#This creates the RDP Button
			$posy = 1310
			$sizex = 30
			$sizey = 170
			
			$objRDPButton = New-Object System.Windows.Forms.Button 
			$objRDPButton.Name = "RDP$computer"
			$objRDPButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objRDPButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objRDPButton.Autosize = $true
			$objRDPButton.Text = "Remote Desktop"
			$objRDPButton.Add_Click({handler_click_RDP($computer)}.GetNewClosure())
			
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objRDPButton.Enabled = $true
			} else
			{
				$objRDPButton.Enabled = $false
			}
			
			$objForm.Controls.RemoveByKey("RDP$computer")
			$objForm.Controls.Add($objRDPButton)
			
			
			#This updates the Workstation Shutdown Button
			$posy = 1520
			$sizex = 30
			$sizey = 200
			$objShutdownButton = New-Object System.Windows.Forms.Button 
			$objShutdownButton.Name = "shut$computer"
			$objShutdownButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objShutdownButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objShutdownButton.Autosize = $true
			$objShutdownButton.Text = "Shutdown"
			$objShutdownButton.Add_Click({handler_click_Shutdown($computer)}.GetNewClosure())
			
			if (($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Shutdown) -eq "1")
			{
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
				{
					$objShutdownButton.Enabled = $true
				} else
				{
					$objShutdownButton.Enabled = $false
				}
			} else 
			{
				$objShutdownButton.Text = "Shutdown not supported"
				$objShutdownButton.Enabled = $false
			}
			
			$objForm.Controls.RemoveByKey("shut$computer")
			$objForm.Controls.Add($objShutdownButton)
			
			$num++
		}
	}
	
	$num++
	$num++
	
	foreach ($item in $workstations)
	{
		if ($item.class -match "Office")
		{
			$computer = $item.computer

			$posx = (30 * $num) + 25
			$posxa = (30 * $num) + 30
		
			#This updates the Workstation Status entry
			$posy = 180
			$sizex = 30
			$sizey = 100
			$objstat = New-Object System.Windows.Forms.Label
			$objstat.Name = "status_$computer"
			$objstat.Location = New-Object System.Drawing.Size($posy,$posxa) 
			$objstat.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objstat.Autosize = $true
			$objForm.Controls.RemoveByKey("status_$computer")
			$check_stat = $host_list | where-object {$_.Computer -eq $computer}
			if ($check_stat.Status -eq $true)
			{
				$objstat.ForeColor = "green"
				$objstat.Text = "ONLINE"
			} else
			{
				$objstat.ForeColor = "red"
				$objstat.Text = "OFFLINE"
			}
			$objForm.Controls.RemoveByKey("status_$computer")
			$objForm.Controls.Add($objstat)
			
			#This updates the Workstation WOL Button
			$posy = 280
			$sizex = 30
			$sizey = 180
			$objWOLButton = New-Object System.Windows.Forms.Button 
			$objWOLButton.Name = "WOL_$computer"
			$objWOLButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objWOLButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objWOLButton.Text = "Wake-Up (WOL)"
			$objWOLButton.Autosize = $true
			$mac = $null
			$mac = ($workstations | Where-Object {$_.computer -eq $computer}.GetNewClosure()).MAC
			$objWOLButton.Add_Click({handler_click_WOL $mac $computer}.GetNewClosure())
			if ($mac)
			{
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $false)
				{
					$objWOLButton.Enabled = $true
				}
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
				{
					$objWOLButton.Enabled = $false
				}
			}
			else
			{
				#This creates the WOL not supported entry
				$objWOLButton.Text = "WOL not supported"
				$objWOLButton.Enabled = $false
			}
			$objForm.Controls.RemoveByKey("WOL_$computer")
			$objForm.Controls.Add($objWOLButton) 
			
			#This updates the Workstation Data Share Button
			$posy = 500
			$sizex = 30
			$sizey = 180
			$objDataButton = New-Object System.Windows.Forms.Button 
			$objDataButton.Name = "data_$computer"
			$objDataButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objDataButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objDataButton.Text = "Access Data Share"
			$objDataButton.Autosize = $true
			$dataFQDN = ($workstations | Where-Object {$_.Computer -eq $computer}).FQDN
			$dshare = ($workstations | Where-Object {$_.Computer -eq $computer}).Share
			$datashare = "\\$dataFQDN\$dshare"
			$objDataButton.Add_Click({handler_click_DATA($datashare)}.GetNewClosure())
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				if ($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Share)
				{
					$objDataButton.Text = "Access Data Share"
					$objDataButton.Enabled = $true
				} else 
				{
					$objDataButton.Text = "Share not supported"
					$objDataButton.Enabled = $false
				}
			} else
			{
				if ($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Share)
				{
					$objDataButton.Text = "Access Data Share"
					$objDataButton.Enabled = $false
				} else 
				{
					$objDataButton.Text = "Share not supported"
					$objDataButton.Enabled = $false
				}
			}
			$objForm.Controls.RemoveByKey("data_$computer")
			$objForm.Controls.Add($objDataButton)
			
			#This updates the Workstation Session entry
			$posy = 710
			$sizex = 30
			$sizey = 140
			$objses = New-Object System.Windows.Forms.Label 
			$objses.Name = "session_$computer"
			$objses.Location = New-Object System.Drawing.Size($posy,$posxa) 
			$objses.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objses.Autosize = $true
		
			$host_sel = $host_list | where-object {$_.Computer -eq $computer -and $_.Status -eq $true}
			if ($host_sel.Status -eq $true)
			{
				Remove-Variable -name "name" 2>$null
				$name = ($active_sessions | where-object {$_.Computer -eq $computer}).Session
				if ($name)
				{
					$objses.Text = $name
				} else
				{
					$objses.Text = $null
				}
			} else
			{
				$objses.Text = $null
			}
			$objForm.Controls.RemoveByKey("session_$computer")
			$objForm.Controls.Add($objses)
			
			
			#This creates the HWI Button
			$posy = 890
			$sizex = 30
			$sizey = 170
			
			$objHWButton = New-Object System.Windows.Forms.Button 
			$objHWButton.Name = "HWI$computer"
			$objHWButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objHWButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objHWButton.Autosize = $true
			$objHWButton.Text = "Hardware Info"
			$objHWButton.Add_Click({handler_click_HWI($computer)}.GetNewClosure())
			
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objHWButton.Enabled = $true
			}else
			{
				$objHWButton.Enabled = $false
			}
						
			$objForm.Controls.RemoveByKey("HWI$computer")
			$objForm.Controls.Add($objHWButton)
			
			#This creates the SWI Button
			$posy = 1100
			$sizex = 30
			$sizey = 170
			
			$objSWButton = New-Object System.Windows.Forms.Button 
			$objSWButton.Name = "SWI$computer"
			$objSWButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objSWButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objSWButton.Autosize = $true
			$objSWButton.Text = "Software Info"
			$objSWButton.Add_Click({handler_click_SWI $computer}.GetNewClosure())
			
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objSWButton.Enabled = $true
			}else
			{
				$objSWButton.Enabled = $false
			}
						
			$objForm.Controls.RemoveByKey("SWI$computer")
			$objForm.Controls.Add($objSWButton)
			
			
			#This creates the RDP Button
			$posy = 1310
			$sizex = 30
			$sizey = 170
			
			$objRDPButton = New-Object System.Windows.Forms.Button 
			$objRDPButton.Name = "RDP$computer"
			$objRDPButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objRDPButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objRDPButton.Autosize = $true
			$objRDPButton.Text = "Remote Desktop"
			$objRDPButton.Add_Click({handler_click_RDP($computer)}.GetNewClosure())
			
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objRDPButton.Enabled = $true
			} else
			{
				$objRDPButton.Enabled = $false
			}
			
			$objForm.Controls.RemoveByKey("RDP$computer")
			$objForm.Controls.Add($objRDPButton)
			
			
			#This updates the Workstation Shutdown Button
			$posy = 1520
			$sizex = 30
			$sizey = 200
			$objShutdownButton = New-Object System.Windows.Forms.Button 
			$objShutdownButton.Name = "shut$computer"
			$objShutdownButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objShutdownButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objShutdownButton.Autosize = $true
			$objShutdownButton.Text = "Shutdown"
			$objShutdownButton.Add_Click({handler_click_Shutdown($computer)}.GetNewClosure())
			
			if (($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Shutdown) -eq "1")
			{
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
				{
					$objShutdownButton.Enabled = $true
				} else
				{
					$objShutdownButton.Enabled = $false
				}
			} else 
			{
				$objShutdownButton.Text = "Shutdown not supported"
				$objShutdownButton.Enabled = $false
			}
			
			$objForm.Controls.RemoveByKey("shut$computer")
			$objForm.Controls.Add($objShutdownButton)
			
			$num++
		}
	}
	
	
	SetDoubleBuffered $objForm
	$objForm.Refresh()
	$global:nn = 60
}

function global:Workstation_GUI 
{
	# Calling handler_Status and Session  Functions
	handler_Status
	#handler_HWI
	handler_Session $workstations
		
	# Get latest data
	if ($status_jobs)
	{
		$global:host_list = $status_jobs | Get-Job | Receive-Job -Wait  | Select-Object @{Name='Computer';Expression={$_.Address.Substring(0, $_.Address.IndexOf("."))}},@{Name='Status';Expression={if ($_.StatusCode -eq 0) { $true } else { $false }}} | sort-object -property Computer
	}
	if ($session_job)
	{
		$global:active_sessions = $session_job | Get-Job | Receive-Job -wait
	}
		
	#This creates the form and sets its size and position
	$global:objForm = New-Object System.Windows.Forms.Form 
	$objForm.Text = "$tool"
	#$objForm.Size = New-Object System.Drawing.Size(770,400) 
	$objForm.AutoSize = $true
	$objForm.FormBorderStyle = 'Fixed3D'
	$objForm.MaximizeBox = $false
	$objForm.StartPosition = "CenterScreen"

	$objForm.KeyPreview = $True
	$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
		{handler_click_OK; $objForm.Close()}})

	$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
		{handler_click_Cancel; $objForm.Close()}})
	
	
	# This creates and bas64 encodes the UFR Icon
	$iconBase64 = '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'
	$iconBytes = [Convert]::FromBase64String($iconBase64)
	# initialize a Memory stream holding the bytes
	$iconstream = [System.IO.MemoryStream]::new($iconBytes, 0, $iconBytes.Length)
	$objForm.Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($iconstream).GetHIcon()))
		
	# Menu Options - Help / About
	$objFormmenu = New-Object System.Windows.Forms.MenuStrip
	$objForm.Controls.Add($objFormmenu)
	$objFormHelp = New-Object System.Windows.Forms.ToolStripMenuItem
	$objFormHelp.Text = "&About"
	$objFormHelp.Alignment = [System.Windows.Forms.ToolStripItemAlignment]::Right
	$objFormHelp.Add_Click({About})
	[void] $objFormmenu.Items.Add($objFormHelp)

	#This creates a label for the LIC Workstation hostname
	$posx = 40
	$posy = 10
	$sizex = 30
	$sizey = 160
	$objwsLabel = New-Object System.Windows.Forms.Label
	$objwsLabel.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objwsLabel.Size = New-Object System.Drawing.Size($sizey,$sizex) 
	$objwsLabel.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)
	$objwsLabel.Text = "Computer"
	$objwsLabel.Autosize = $true
	$objForm.Controls.Add($objwsLabel) 

	#This creates a label for the workstation status
	if ($objForm.Controls.ContainsKey("status_$computer")) 
	{
        $main_form.Controls.RemoveByKey("status_$computer")
	}
	$posy = 180
	$sizex = 30
	$sizey = 100
	$objstatLabel = New-Object System.Windows.Forms.Label
	$objstatLabel.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objstatLabel.Size = New-Object System.Drawing.Size($sizey,$sizex) 
	$objstatLabel.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)
	$objstatLabel.Text = "Status"
	$objstatLabel.Autosize = $true
	$objForm.Controls.Add($objstatLabel) 

	#This creates a label for the Wake-up / WOL button
	$posy = 280
	$sizex = 30
	$sizey = 180
	$objwolLabel = New-Object System.Windows.Forms.Label
	$objwolLabel.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objwolLabel.Size = New-Object System.Drawing.Size($sizey,$sizex) 
	$objwolLabel.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)
	$objwolLabel.Text = "Wake-Up WOL"
	$objwolLabel.Autosize = $true
	$objForm.Controls.Add($objwolLabel) 
	
	#This creates a label for the data share button
	$posy = 500
	$sizex = 30
	$sizey = 170
	$objdataLabel = New-Object System.Windows.Forms.Label
	$objdataLabel.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objdataLabel.Size = New-Object System.Drawing.Size($sizey,$sizex)
	$objdataLabel.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)			
	$objdataLabel.Text = "Data Share"
	$objdataLabel.Autosize = $true
	$objForm.Controls.Add($objdataLabel) 
	
	#This creates a label for the user session information
	$posy = 710
	$sizex = 30
	$sizey = 140
	$objdataLabel = New-Object System.Windows.Forms.Label
	$objdataLabel.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objdataLabel.Size = New-Object System.Drawing.Size($sizey,$sizex)
	$objdataLabel.Autosize = $true
	$objdataLabel.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)			
	$objdataLabel.Text = "Sessions"
	$objForm.Controls.Add($objdataLabel)

	#This creates a label for the HW Info button
	$posy = 890
	$sizex = 30
	$sizey = 170
	$objHWLabel = New-Object System.Windows.Forms.Label
	$objHWLabel.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objHWLabel.Autosize = $true
	$objHWLabel.Size = New-Object System.Drawing.Size($sizey,$sizex)
	$objHWLabel.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)			
	$objHWLabel.Text = "Hardware Info"
	$objForm.Controls.Add($objHWLabel)
	
	#This creates a label for the SW Info button
	$posy = 1100
	$sizex = 30
	$sizey = 170
	$objSWLabel = New-Object System.Windows.Forms.Label
	$objSWLabel.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objSWLabel.Autosize = $true
	$objSWLabel.Size = New-Object System.Drawing.Size($sizey,$sizex)
	$objSWLabel.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)			
	$objSWLabel.Text = "Software Info"
	$objForm.Controls.Add($objSWLabel)
	
	
	#This creates a label for the RDP button
	$posy = 1310
	$sizex = 30
	$sizey = 140
	$objRDPLabel = New-Object System.Windows.Forms.Label
	$objRDPLabel.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objRDPLabel.Autosize = $true
	$objRDPLabel.Size = New-Object System.Drawing.Size($sizey,$sizex)
	$objRDPLabel.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)			
	$objRDPLabel.Text = "RDP"
	$objForm.Controls.Add($objRDPLabel)
	
	#This creates a label for the Shutdown button
	$posy = 1520
	$sizex = 30
	$sizey = 130
	$objshutdownLabel = New-Object System.Windows.Forms.Label
	$objshutdownLabel.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objshutdownLabel.Autosize = $true
	$objshutdownLabel.Size = New-Object System.Drawing.Size($sizey,$sizex)
	$objshutdownLabel.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)			
	$objshutdownLabel.Text = "Shutdown"
	$objForm.Controls.Add($objshutdownLabel)
	
	
	#This creates a label for the group shares
	$posy = 1780
	$sizex = 30
	$sizey = 225
	$objGroupShareLabel = New-Object System.Windows.Forms.Label
	$objGroupShareLabel.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objGroupShareLabel.Size = New-Object System.Drawing.Size($sizey,$sizex)
	$objGroupShareLabel.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)			
	$objGroupShareLabel.Text = "Ext. Group Shares"
	$objGroupShareLabel.Autosize = $true
	$objForm.Controls.Add($objGroupShareLabel)
	
	#This creates the drop-down list header
	$posy = 1780
	$posx = 100
	$sizex = 30
	$sizey = 200
	$objListHeader = New-Object System.Windows.Forms.Label
	$objListHeader.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objListHeader.Size = New-Object System.Drawing.Size($sizey,$sizex)
	$objListHeader.Autosize = $true 
	$objListHeader.Text = "Select your home-lab network share:"
	$objForm.Controls.Add($objListHeader)
	
	#This creates the drop-down list for the group shares
	$posy = 1780
	$posx = 125
	$sizex = 40
	$sizey = 220
	$global:objGroupDriveList = New-Object System.Windows.Forms.ComboBox
	$objGroupDriveList.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objGroupDriveList.Text = "Network Shares"
	$objGroupDriveList.Size = New-Object System.Drawing.Size($sizey,$sizex)
	$objGroupDriveList.Autosize = $true

	# Populate the drop-down list
	$groupshares.group | ForEach-Object {[void] $objGroupDriveList.Items.Add($_)}
			
	#This creates the group share path header label
	$posy = 1780
	$posx = 180
	$objGroupShareHead = New-Object System.Windows.Forms.Label
	$objGroupShareHead.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objGroupShareHead.Autosize = $true 
	$objGroupShareHead.Text = "Group Share Path:"
	$objGroupShareHead.Autosize = $true
	$objGroupShareHead.Font = New-Object System.Drawing.Font("Arial",10,[System.Drawing.FontStyle]::Bold)
	$objForm.Controls.Add($objGroupShareHead) 	
		
	#This creates the group share path label
	$posy = 1780
	$posx = 210
	$sizex = 30
	$sizey = 120
	$objGroupShare = New-Object System.Windows.Forms.Label
	$objGroupShare.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objGroupShare.Autosize = $true 
	
	# This adds the IndexChange Trigger to the drop-down list
	$objGroupDriveList.add_SelectedIndexChanged({
		$global:groupshare_sel = ($groupshares | where-object {$_.group -eq $objGroupDriveList.SelectedItem}).path
		$objGroupShare.Text = $groupshare_sel
		$global:gshare = Get-PSdrive | where-object {$_.DisplayRoot -eq $groupshare_sel}
		
		#This updates the Network Mapping Button
		$objMapShareButton.Enabled = $true
		
		# This updates the Disconnect Group Share Button
		if ($gshare)
		{
			$objGroupShareButton.Enabled = $true
		} else
		{
			$objGroupShareButton.Enabled = $false
		}
		$objForm.Refresh()
	})
	
	#This creates the Network Mapping Button
	$posy = 1780
	$posx = 260
	$sizex = 30
	$sizey = 180
	$global:objMapShareButton = New-Object System.Windows.Forms.Button 
	$objMapShareButton.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objMapShareButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
	$objMapShareButton.Text = "Connect / Open Share"
	$objMapShareButton.Autosize = $true
	$objMapShareButton.Add_Click({handler_click_MAPSHARE($groupshare_sel)}.GetNewClosure())
	$objMapShareButton.Enabled = $false
	$objForm.Controls.Add($objMapShareButton)
	
	# This creates the Disconnect Group Share Button
	$posy = 1780
	$posx = 300
	$sizex = 30
	$sizey = 180
	$global:objGroupShareButton = New-Object System.Windows.Forms.Button 
	$objGroupShareButton.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objGroupShareButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
	$objGroupShareButton.Text = "Disconnect / Remove Share"
	$objGroupShareButton.Autosize = $true
	$objGroupShareButton.Add_Click({handler_click_REMOVESHARE($groupshare_sel)}.GetNewClosure())
	$objGroupShareButton.Enabled = $false
	$objForm.Controls.Add($objGroupShareButton)

	$objGroupShare.Text = $groupshare_sel

	$objForm.Controls.Add($objGroupDriveList)
	$objForm.Controls.Add($objGroupShare) 

	#This creates a label for the Workstation Class
	$posx = 90
	$posy = 10
	$sizex = 30
	$sizey = 160
	$objwsclassLabel = New-Object System.Windows.Forms.Label
	$objwsclassLabel.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objwsclassLabel.Size = New-Object System.Drawing.Size($sizey,$sizex) 
	$objwsclassLabel.Font = New-Object System.Drawing.Font("Arial",9,[System.Drawing.FontStyle]::Bold)
	$objwsclassLabel.Text = "Workstations"
	$objwsclassLabel.Autosize = $true
	$objForm.Controls.Add($objwsclassLabel) 
	
	
	$num = 3
	
	foreach ($item in $workstations)
	{
		if ($item.class -match "Workstation")
		{
			$computer = $item.computer

			$posx = (30 * $num) + 25
			$posxa = (30 * $num) + 30
					
			#This creates the Workstation host-name entry
			$posy = 10
			$sizex = 30
			$sizey = 150
			$objhost = New-Object System.Windows.Forms.Label
			$objhost.Name = "hostname_$computer"
			$objhost.Location = New-Object System.Drawing.Size($posy,$posxa) 
			$objhost.Size = New-Object System.Drawing.Size($sizey,$sizex) 
			$objhost.Text = $computer
			$objhost.Autosize = $true
			$objForm.Controls.Add($objhost) 
			
			#This creates the Workstation Status entry
			$posy = 180
			$sizex = 30
			$sizey = 100
			$objstat = New-Object System.Windows.Forms.Label 
			$objstat.Name = "status_$computer"
			$objstat.Location = New-Object System.Drawing.Size($posy,$posxa) 
			$objstat.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objstat.Autosize = $true
			$check_stat = $host_list | where-object {$_.Computer -eq $computer}
			if ($check_stat.Status -eq $true)
			{
				$objstat.ForeColor = "green"
				$objstat.Text = "ONLINE"
			} else
			{
				$objstat.ForeColor = "red"
				$objstat.Text = "OFFLINE"
			}
			$objForm.Controls.Add($objstat)
			
			#This creates the Workstation WOL Button
			$posy = 280
			$sizex = 30
			$sizey = 180
			$objWOLButton = New-Object System.Windows.Forms.Button 
			$objWOLButton.Name = "WOL_$computer"
			$objWOLButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objWOLButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objWOLButton.Text = "Wake-Up (WOL)"
			$objWOLButton.Autosize = $true
			$mac = $null
			$mac = ($workstations | Where-Object {$_.computer -eq $computer}.GetNewClosure()).MAC
			$objWOLButton.Add_Click({handler_click_WOL $mac $computer}.GetNewClosure())
			if ($mac)
			{
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $false)
				{
					$objWOLButton.Enabled = $true
				}
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
				{
					$objWOLButton.Enabled = $false
				}
			}else
			{
				#This creates the WOl not supported entry
				$objWOLButton.Text = "WOL not supported"
				$objWOLButton.Enabled = $false
			}
			$objForm.Controls.Add($objWOLButton)
			
			#This creates the Workstation Data Share Button
			$posy = 500
			$sizex = 30
			$sizey = 180
			$objDataButton = New-Object System.Windows.Forms.Button 
			$objDataButton.Name = "data_$computer"
			$objDataButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objDataButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objDataButton.Text = "Access Data Share"
			$objDataButton.Autosize = $true
			$dataFQDN = ($workstations | Where-Object {$_.Computer -eq $computer}).FQDN
			$dshare = ($workstations | Where-Object {$_.Computer -eq $computer}).Share
			$datashare = "\\$dataFQDN\$dshare"
			$objDataButton.Add_Click({handler_click_DATA($datashare)}.GetNewClosure())
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				if ($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Share)
				{
					$objDataButton.Text = "Access Data Share"
					$objDataButton.Enabled = $true
				} else 
				{
					$objDataButton.Text = "Share not supported"
					$objDataButton.Enabled = $false
				}
			} else
			{
				if ($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Share)
				{
					$objDataButton.Text = "Access Data Share"
					$objDataButton.Enabled = $false
				} else 
				{
					$objDataButton.Text = "Share not supported"
					$objDataButton.Enabled = $false
				}
			}
			$objForm.Controls.Add($objDataButton)
			
			#This creates the Workstation Session entry
			$posy = 710
			$sizex = 30
			$sizey = 140
			
			$objses = New-Object System.Windows.Forms.Label 
			$objses.Name = "session_$computer"
			$objses.Location = New-Object System.Drawing.Size($posy,$posxa) 
			$objses.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objses.Autosize = $true
		
			$host_sel = $host_list | where-object {$_.Computer -eq $computer -and $_.Status -eq $true}
			if ($host_sel.Status -eq $true)
			{
				Remove-Variable -name "name" 2>$null
				$name = ($active_sessions | where-object {$_.Computer -eq $computer}).Session
				if ($name)
				{
					$objses.Text = $name
				} else
				{
					$objses.Text = $null
				}
			}else
			{
				$objses.Text = $null
			}
			$objForm.Controls.Add($objses)
			
			#This creates the HW Info Button
			$posy = 890
			$sizex = 30
			$sizey = 170
			
			$objHWButton = New-Object System.Windows.Forms.Button 
			$objHWButton.Name = "HWInfo$computer"
			$objHWButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objHWButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objHWButton.Autosize = $true
			$objHWButton.Text = "Hardware Info"
			$objHWButton.Add_Click({handler_click_HWI($computer)}.GetNewClosure())
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objHWButton.Enabled = $true
			}else
			{
				$objHWButton.Enabled = $false
			}
			$objForm.Controls.Add($objHWButton)
			
			#This creates the SW Info Button
			$posy = 1100
			$sizex = 30
			$sizey = 170
			
			$objSWButton = New-Object System.Windows.Forms.Button 
			$objSWButton.Name = "SWInfo$computer"
			$objSWButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objSWButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objSWButton.Autosize = $true
			$objSWButton.Text = "Software Info"
			$objSWButton.Add_Click({handler_click_SWI $computer}.GetNewClosure())
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objSWButton.Enabled = $true
			}else
			{
				$objSWButton.Enabled = $false
			}
			$objForm.Controls.Add($objSWButton)
			

			#This creates the RDP Button
			$posy = 1310
			$sizex = 30
			$sizey = 170
			
			$objRDPButton = New-Object System.Windows.Forms.Button 
			$objRDPButton.Name = "RDP$computer"
			$objRDPButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objRDPButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objRDPButton.Autosize = $true
			$objRDPButton.Text = "Remote Desktop"
			$objRDPButton.Add_Click({handler_click_RDP($computer)}.GetNewClosure())
			
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objRDPButton.Enabled = $true
			}else
			{
				$objRDPButton.Enabled = $false
			}
			
			$objForm.Controls.Add($objRDPButton)
			
			#This creates the Workstation Shutdown Button
			$posy = 1520
			$sizex = 30
			$sizey = 200
			
			$objShutdownButton = New-Object System.Windows.Forms.Button 
			$objShutdownButton.Name = "shut$computer"
			$objShutdownButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objShutdownButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objShutdownButton.Autosize = $true
			$objShutdownButton.Text = "Shutdown"
			$objShutdownButton.Add_Click({handler_click_Shutdown($computer)}.GetNewClosure())
			if (($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Shutdown) -eq "1")
			{
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
				{
					$objShutdownButton.Enabled = $true
				}else
				{
					$objShutdownButton.Enabled = $false
				}
			} else 
			{
				$objShutdownButton.Text = "Shutdown not supported"
				$objShutdownButton.Enabled = $false
			}
			$objForm.Controls.Add($objShutdownButton)
		
			$num++
		}
	}
	
	
	
	$num++
	
	#This creates a label for the System Class
	$posx = (30 * $num) + 25
	$posy = 10
	$sizex = 30
	$sizey = 160
	$objwsclassLabel = New-Object System.Windows.Forms.Label
	$objwsclassLabel.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objwsclassLabel.Size = New-Object System.Drawing.Size($sizey,$sizex) 
	$objwsclassLabel.Font = New-Object System.Drawing.Font("Arial",9,[System.Drawing.FontStyle]::Bold)
	$objwsclassLabel.Text = "Systems"
	$objwsclassLabel.Autosize = $true
	$objForm.Controls.Add($objwsclassLabel) 
	
	
	$num++
	
	foreach ($item in $workstations)
	{
		if ($item.class -match "System")
		{
			$computer = $item.computer

			$posx = (30 * $num) + 25
			$posxa = (30 * $num) + 30
					
			#This creates the Workstation host-name entry
			$posy = 10
			$sizex = 30
			$sizey = 150
			$objhost = New-Object System.Windows.Forms.Label
			$objhost.Name = "hostname_$computer"
			$objhost.Location = New-Object System.Drawing.Size($posy,$posxa) 
			$objhost.Size = New-Object System.Drawing.Size($sizey,$sizex) 
			$objhost.Text = $computer
			$objhost.Autosize = $true
			$objForm.Controls.Add($objhost) 
			
			#This creates the Workstation Status entry
			$posy = 180
			$sizex = 30
			$sizey = 100
			$objstat = New-Object System.Windows.Forms.Label 
			$objstat.Name = "status_$computer"
			$objstat.Location = New-Object System.Drawing.Size($posy,$posxa) 
			$objstat.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objstat.Autosize = $true
			$check_stat = $host_list | where-object {$_.Computer -eq $computer}
			if ($check_stat.Status -eq $true)
			{
				$objstat.ForeColor = "green"
				$objstat.Text = "ONLINE"
			} else
			{
				$objstat.ForeColor = "red"
				$objstat.Text = "OFFLINE"
			}
			$objForm.Controls.Add($objstat)
			
			#This creates the Workstation WOL Button
			$posy = 280
			$sizex = 30
			$sizey = 180
			$objWOLButton = New-Object System.Windows.Forms.Button 
			$objWOLButton.Name = "WOL_$computer"
			$objWOLButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objWOLButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objWOLButton.Text = "Wake-Up (WOL)"
			$objWOLButton.Autosize = $true
			$mac = $null
			$mac = ($workstations | Where-Object {$_.computer -eq $computer}.GetNewClosure()).MAC
			$objWOLButton.Add_Click({handler_click_WOL $mac $computer}.GetNewClosure())
			if ($mac)
			{
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $false)
				{
					$objWOLButton.Enabled = $true
				}
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
				{
					$objWOLButton.Enabled = $false
				}
			}else
			{
				#This creates the WOl not supported entry
				$objWOLButton.Text = "WOL not supported"
				$objWOLButton.Enabled = $false
			}
			$objForm.Controls.Add($objWOLButton)
			
			#This creates the Workstation Data Share Button
			$posy = 500
			$sizex = 30
			$sizey = 180
			$objDataButton = New-Object System.Windows.Forms.Button 
			$objDataButton.Name = "data_$computer"
			$objDataButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objDataButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objDataButton.Text = "Access Data Share"
			$objDataButton.Autosize = $true
			$dataFQDN = ($workstations | Where-Object {$_.Computer -eq $computer}).FQDN
			$dshare = ($workstations | Where-Object {$_.Computer -eq $computer}).Share
			$datashare = "\\$dataFQDN\$dshare"
			$objDataButton.Add_Click({handler_click_DATA($datashare)}.GetNewClosure())
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				if ($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Share)
				{
					$objDataButton.Text = "Access Data Share"
					$objDataButton.Enabled = $true
				} else 
				{
					$objDataButton.Text = "Share not supported"
					$objDataButton.Enabled = $false
				}
			} else
			{
				if ($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Share)
				{
					$objDataButton.Text = "Access Data Share"
					$objDataButton.Enabled = $false
				} else 
				{
					$objDataButton.Text = "Share not supported"
					$objDataButton.Enabled = $false
				}
			}
			$objForm.Controls.Add($objDataButton)
			
			#This creates the Workstation Session entry
			$posy = 710
			$sizex = 30
			$sizey = 140
			
			$objses = New-Object System.Windows.Forms.Label 
			$objses.Name = "session_$computer"
			$objses.Location = New-Object System.Drawing.Size($posy,$posxa) 
			$objses.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objses.Autosize = $true
		
			$host_sel = $host_list | where-object {$_.Computer -eq $computer -and $_.Status -eq $true}
			if ($host_sel.Status -eq $true)
			{
				Remove-Variable -name "name" 2>$null
				$name = ($active_sessions | where-object {$_.Computer -eq $computer}).Session
				if ($name)
				{
					$objses.Text = $name
				} else
				{
					$objses.Text = $null
				}
			}else
			{
				$objses.Text = $null
			}
			$objForm.Controls.Add($objses)
			
			
			#This creates the HW Info Button
			$posy = 890
			$sizex = 30
			$sizey = 170
			
			$objHWButton = New-Object System.Windows.Forms.Button 
			$objHWButton.Name = "HWI$computer"
			$objHWButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objHWButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objHWButton.Autosize = $true
			$objHWButton.Text = "Hardware Info"
			$objHWButton.Add_Click({handler_click_HWI($computer)}.GetNewClosure())
			
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objHWButton.Enabled = $true
			}else
			{
				$objHWButton.Enabled = $false
			}
			$objForm.Controls.Add($objHWButton)
			
			#This creates the SW Info Button
			$posy = 1100
			$sizex = 30
			$sizey = 170
			
			$objSWButton = New-Object System.Windows.Forms.Button 
			$objSWButton.Name = "SWI$computer"
			$objSWButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objSWButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objSWButton.Autosize = $true
			$objSWButton.Text = "Software Info"
			$objSWButton.Add_Click({handler_click_SWI $computer}.GetNewClosure())
			
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objSWButton.Enabled = $true
			}else
			{
				$objSWButton.Enabled = $false
			}
			
			$objForm.Controls.Add($objSWButton)
			

			#This creates the RDP Button
			$posy = 1310
			$sizex = 30
			$sizey = 170
			
			$objRDPButton = New-Object System.Windows.Forms.Button 
			$objRDPButton.Name = "RDP$computer"
			$objRDPButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objRDPButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objRDPButton.Autosize = $true
			$objRDPButton.Text = "Remote Desktop"
			$objRDPButton.Add_Click({handler_click_RDP($computer)}.GetNewClosure())
			
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objRDPButton.Enabled = $true
			}else
			{
				$objRDPButton.Enabled = $false
			}
			
			$objForm.Controls.Add($objRDPButton)
			
			#This creates the Workstation Shutdown Button
			$posy = 1520
			$sizex = 30
			$sizey = 200
			
			$objShutdownButton = New-Object System.Windows.Forms.Button 
			$objShutdownButton.Name = "shut$computer"
			$objShutdownButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objShutdownButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objShutdownButton.Autosize = $true
			$objShutdownButton.Text = "Shutdown"
			$objShutdownButton.Add_Click({handler_click_Shutdown($computer)}.GetNewClosure())
			if (($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Shutdown) -eq "1")
			{
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
				{
					$objShutdownButton.Enabled = $true
				}else
				{
					$objShutdownButton.Enabled = $false
				}
			} else 
			{
				$objShutdownButton.Text = "Shutdown not supported"
				$objShutdownButton.Enabled = $false
			}
			$objForm.Controls.Add($objShutdownButton)
		
			$num++
		}
	}
	
	$num++
	
	#This creates a label for the Office Class
	$posx = (30 * $num) + 25
	$posy = 10
	$sizex = 30
	$sizey = 160
	$objwsclassLabel = New-Object System.Windows.Forms.Label
	$objwsclassLabel.Location = New-Object System.Drawing.Size($posy,$posx) 
	$objwsclassLabel.Size = New-Object System.Drawing.Size($sizey,$sizex) 
	$objwsclassLabel.Font = New-Object System.Drawing.Font("Arial",9,[System.Drawing.FontStyle]::Bold)
	$objwsclassLabel.Text = "Office"
	$objwsclassLabel.Autosize = $true
	$objForm.Controls.Add($objwsclassLabel) 
	
	
	$num++
	
	foreach ($item in $workstations)
	{
		if ($item.class -match "Office")
		{
			$computer = $item.computer

			$posx = (30 * $num) + 25
			$posxa = (30 * $num) + 30
			
			#This creates the Workstation host-name entry
			$posy = 10
			$sizex = 30
			$sizey = 150
			$objhost = New-Object System.Windows.Forms.Label
			$objhost.Name = "hostname_$computer"
			$objhost.Location = New-Object System.Drawing.Size($posy,$posxa) 
			$objhost.Size = New-Object System.Drawing.Size($sizey,$sizex) 
			$objhost.Text = $computer
			$objhost.Autosize = $true
			$objForm.Controls.Add($objhost) 
			
			#This creates the Workstation Status entry
			$posy = 180
			$sizex = 30
			$sizey = 100
			$objstat = New-Object System.Windows.Forms.Label 
			$objstat.Name = "status_$computer"
			$objstat.Location = New-Object System.Drawing.Size($posy,$posxa) 
			$objstat.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objstat.Autosize = $true
			$check_stat = $host_list | where-object {$_.Computer -eq $computer}
			if ($check_stat.Status -eq $true)
			{
				$objstat.ForeColor = "green"
				$objstat.Text = "ONLINE"
			} else
			{
				$objstat.ForeColor = "red"
				$objstat.Text = "OFFLINE"
			}
			$objForm.Controls.Add($objstat)
			
			#This creates the Workstation WOL Button
			$posy = 280
			$sizex = 30
			$sizey = 180
			$objWOLButton = New-Object System.Windows.Forms.Button 
			$objWOLButton.Name = "WOL_$computer"
			$objWOLButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objWOLButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objWOLButton.Text = "Wake-Up (WOL)"
			$objWOLButton.Autosize = $true
			$mac = $null
			$mac = ($workstations | Where-Object {$_.computer -eq $computer}.GetNewClosure()).MAC
			$objWOLButton.Add_Click({handler_click_WOL $mac $computer}.GetNewClosure())
			if ($mac)
			{
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $false)
				{
					$objWOLButton.Enabled = $true
				}
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
				{
					$objWOLButton.Enabled = $false
				}
			}else
			{
				#This creates the WOl not supported entry
				$objWOLButton.Text = "WOL not supported"
				$objWOLButton.Enabled = $false
			}
			$objForm.Controls.Add($objWOLButton)
			
			#This creates the Workstation Data Share Button
			$posy = 500
			$sizex = 30
			$sizey = 180
			$objDataButton = New-Object System.Windows.Forms.Button 
			$objDataButton.Name = "data_$computer"
			$objDataButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objDataButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objDataButton.Text = "Access Data Share"
			$objDataButton.Autosize = $true
			$dataFQDN = ($workstations | Where-Object {$_.Computer -eq $computer}).FQDN
			$dshare = ($workstations | Where-Object {$_.Computer -eq $computer}).Share
			$datashare = "\\$dataFQDN\$dshare"
			$objDataButton.Add_Click({handler_click_DATA($datashare)}.GetNewClosure())
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				if ($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Share)
				{
					$objDataButton.Text = "Access Data Share"
					$objDataButton.Enabled = $true
				} else 
				{
					$objDataButton.Text = "Share not supported"
					$objDataButton.Enabled = $false
				}
			} else
			{
				if ($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Share)
				{
					$objDataButton.Text = "Access Data Share"
					$objDataButton.Enabled = $false
				} else 
				{
					$objDataButton.Text = "Share not supported"
					$objDataButton.Enabled = $false
				}
			}
			$objForm.Controls.Add($objDataButton)
			
			#This creates the Workstation Session entry
			$posy = 710
			$sizex = 30
			$sizey = 140
			
			$objses = New-Object System.Windows.Forms.Label 
			$objses.Name = "session_$computer"
			$objses.Location = New-Object System.Drawing.Size($posy,$posxa) 
			$objses.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objses.Autosize = $true
		
			$host_sel = $host_list | where-object {$_.Computer -eq $computer -and $_.Status -eq $true}
			if ($host_sel.Status -eq $true)
			{
				Remove-Variable -name "name" 2>$null
				$name = ($active_sessions | where-object {$_.Computer -eq $computer}).Session
				if ($name)
				{
					$objses.Text = $name
				} else
				{
					$objses.Text = $null
				}
			}else
			{
				$objses.Text = $null
			}
			$objForm.Controls.Add($objses)
			
			#This creates the HW Info Button
			$posy = 890
			$sizex = 30
			$sizey = 170
			
			$objHWButton = New-Object System.Windows.Forms.Button 
			$objHWButton.Name = "HWI$computer"
			$objHWButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objHWButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objHWButton.Autosize = $true
			$objHWButton.Text = "Hardware Info"
			$objHWButton.Add_Click({handler_click_HWI($computer)}.GetNewClosure())
			
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objHWButton.Enabled = $true
			}else
			{
				$objHWButton.Enabled = $false
			}
			$objForm.Controls.Add($objHWButton)
			
			#This creates the SW Info Button
			$posy = 1100
			$sizex = 30
			$sizey = 170
			
			$objSWButton = New-Object System.Windows.Forms.Button 
			$objSWButton.Name = "SWI$computer"
			$objSWButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objSWButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objSWButton.Autosize = $true
			$objSWButton.Text = "Software Info"
			$objSWButton.Add_Click({handler_click_SWI $computer}.GetNewClosure())
			
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objSWButton.Enabled = $true
			}else
			{
				$objSWButton.Enabled = $false
			}
			$objForm.Controls.Add($objSWButton)
			
			#This creates the RDP Button
			$posy = 1310
			$sizex = 30
			$sizey = 170
			
			$objRDPButton = New-Object System.Windows.Forms.Button 
			$objRDPButton.Name = "RDP$computer"
			$objRDPButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objRDPButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objRDPButton.Autosize = $true
			$objRDPButton.Text = "Remote Desktop"
			$objRDPButton.Add_Click({handler_click_RDP($computer)}.GetNewClosure())
			
			if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
			{
				$objRDPButton.Enabled = $true
			}else
			{
				$objRDPButton.Enabled = $false
			}
			
			$objForm.Controls.Add($objRDPButton)
			
			#This creates the Workstation Shutdown Button
			$posy = 1520
			$sizex = 30
			$sizey = 200
			
			$objShutdownButton = New-Object System.Windows.Forms.Button 
			$objShutdownButton.Name = "shut$computer"
			$objShutdownButton.Location = New-Object System.Drawing.Size($posy,$posx) 
			$objShutdownButton.Size = New-Object System.Drawing.Size($sizey,$sizex)
			$objShutdownButton.Autosize = $true
			$objShutdownButton.Text = "Shutdown"
			$objShutdownButton.Add_Click({handler_click_Shutdown($computer)}.GetNewClosure())
			if (($($workstations | where-object {$_.Computer -eq $computer}.GetNewClosure()).Shutdown) -eq "1")
			{
				if ($($host_list | where-object {$_.Computer -eq $computer}.GetNewClosure()).Status -eq $true)
				{
					$objShutdownButton.Enabled = $true
				}else
				{
					$objShutdownButton.Enabled = $false
				}
			} else 
			{
				$objShutdownButton.Text = "Shutdown not supported"
				$objShutdownButton.Enabled = $false
			}
			$objForm.Controls.Add($objShutdownButton)
		
			$num++
		}
	}
	
	
	#This creates a separator line
	$sizex = (30 * $num) + 70
	$sizey = 5
	$objSeparator1 = New-Object System.Windows.Forms.Label
	$objSeparator1.Location = New-Object System.Drawing.Size(1750,40) 
	$objSeparator1.Size = New-Object System.Drawing.Size($sizey,$sizex)
	$objSeparator1.Autosize = $false
	$objSeparator1.BorderStyle = [System.Windows.Forms.FormBorderStyle]::Fixed3D
	$objForm.Controls.Add($objSeparator1)
	
	
	# This creates and bas64 encodes the UFR, I3d:bio and LIC Logo
	$imgUFRBase64 = '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/GMzLdsAAAAgY0hSTQAAeiUAAICDAAD5/wAAgOkAAHUwAADqYAAAOpgAABdvkl/FRgABLGVJREFUeAEA//8AAAH///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADs6+wAAAAAAAAAAAAAAAAAAAAAAAMDAwDz8/MA9PX0ABwbHADz8/MA/Pz8AP/+/wD/AP8AAQIBAAD/AAD+/v4AAQIBAAH/AQAAAQAA////AAEBAQAAAAAAAQEBBgEAAQz+//4SAAAAEQD/ABH/AP8QAAEABAH/Af3/AP8EAAAAAQAAAP4AAAD7AAAA+wABAP7////3AgEC7gEAAfH8/fzyBAQE8v8A//n9/f3/AP8AAAICAgADBAMA//7/AP7+/gAAAAAAAgICAP7//gAB/wEAAgMCAP39/QD4+PgABAQEABMVEwAIBwgA/v7+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwMDAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALAAAAJv///yj/AP8IAQIBEwD/ABv/AP8MAP8AEAEAAQz/Af8AAP8A/wAAAAAAAAD9AP8A/P8B//sCAAL6AQAB7//+//EAAgD0AgEC5gD/APoAAQD5AAAA3AAAANwAAAD3AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABkAAQAm////IQEBAfIAAADoAP8APP79/jMAAAAZAAAADAAAABH///8KAAAACAAAAAcAAAD6AAAAAAABAAYBAAEA////AAD/AAD/AP/4AP4A6P8A/9H+//7KAf8BygMCAxb+//4j/wD/7wABANMAAADuAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGQABAC0AAAAVAf8BD/7//vD////BAAAA7f/+//cEAwT4/gH+4AAAAPEA/wAJAAEAHQEAAQkAAAD0//7/JAABAPoBAQHpAQEBGP7+/v0BAgHsAP8A9wAAABEBAAEC/wD/sf///9UDAANHAQEBMP///+n+/P4sAAAA3AAAAMMAAAD2AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA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AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAD//wczpgqrKyhIAAAAAElFTkSuQmCC'
	$imgUFRBytes = [Convert]::FromBase64String($imgUFRBase64)
	
	# Initialize a Memory stream holding the image bytes
	$imgUFRstream = [System.IO.MemoryStream]::new($imgUFRBytes, 0, $imgUFRBytes.Length)
	$imgUFR = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($imgUFRstream).GetHIcon()))
		
	$posy = 1770
	$posx = (30 * $num) + 30
	$sizex = 80
	$sizey = 240
	$objpictureBoxUFR = New-Object Windows.Forms.PictureBox
	$objpictureBoxUFR.Location = New-Object System.Drawing.Size($posy,$posx)
	$objpictureBoxUFR.Size = New-Object System.Drawing.Size($sizey,$sizex)
	$objpictureBoxUFR.Autosize = $true
	$objpictureBoxUFR.Image = $imgUFR
	$objForm.controls.add($objpictureBoxUFR)
	
	
	$posx = (30 * $num) + 60
	#This creates the Ok button and sets the event
	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Size(10,$posx)
	$OKButton.Size = New-Object System.Drawing.Size(75,30)
	$OKButton.Text = "OK"
	$OKButton.Autosize = $true
	$OKButton.Add_Click({handler_click_OK; stopTimer; $objForm.Close()})
	$objForm.Controls.Add($OKButton)
		
	#This creates the Close button and sets the event
	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Size(100,$posx)
	$CancelButton.Size = New-Object System.Drawing.Size(75,30)
	$CancelButton.Text = "Close"
	$CancelButton.Autosize = $true
	$CancelButton.Add_Click({handler_click_Cancel; stopTimer; $objForm.Close()})
	$objForm.Controls.Add($CancelButton)

	#This creates a label for the update timer
	$global:nn = 60
	
	# This creates the timer and calls the clock function every interval
	$clock = New-Object System.Windows.Forms.Timer -Property @{Interval = 1000} 
	$clock.start()
	$clock.add_Tick({handler_clock})
	
	$posx = (30 * $num) + 100
	$objwsclock = New-Object System.Windows.Forms.Label
	$objwsclock.Location = New-Object System.Drawing.Size(10,$posx) 
	$objwsclock.Size = New-Object System.Drawing.Size(200,30) 
	$objwsclock.Text = "Updating in $nn seconds."
	$objwsclock.Autosize = $true
	$objForm.Controls.Add($objwsclock) 	
	
	# This creates the timer and calls the update function every interval
	$timer = New-Object System.Windows.Forms.Timer -Property @{Interval = 60000} 
	$timer.start()
	$timer.add_Tick({handler_click_Update})
	
	# This creates the timer and calls the status function every interval
	$timer2 = New-Object System.Windows.Forms.Timer -Property @{Interval = 8000} 
	$timer2.start()
	$timer2.add_Tick({handler_status})
		
	# This creates the timer and calls the session job every interval
	$timer3 = New-Object System.Windows.Forms.Timer -Property @{Interval = 8000} 
	$timer3.start()
	$timer3.add_Tick({handler_Session $workstations})
	
	$objForm.Add_Shown({$objForm.Activate()})
	$objForm.DataBindings.DefaultDataSourceUpdateMode = 0
	SetDoubleBuffered $objForm
	[void] $objForm.ShowDialog()
}

# Calling main GUI Function
workstation_gui
