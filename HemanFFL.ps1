. (Join-Path $PSScriptRoot .\ui\controls.ps1)
. (Join-Path $PSScriptRoot .\functions\functions.ps1)

Function Main-Routine() {
	$ErrorActionPreference = 'Stop'
	Set-StrictMode -Version Latest

	Load-Data
	$global:currentdata = $global:dataset

	$MainForm=Create-Form -height 668 -width 936 -name "Heman FFL 2021" -text "HemanFFL v.5.0"

	$LeftPanel=Create-Groupbox -height 650 -width 215 -top 7 -left 8 -name "LeftPanel" -text "Groups and Filters"
	$RightPanel=Create-Groupbox -height 650 -width 700 -top 7 -left 227 -name "RightPanel" -text "Fantasy Football 2021"

	$MenuScroller = Create-Scroller -parent $LeftPanel -name "menuscroller" -height 423 -width 210 -top 17 -left 2
	$MenuScroller.VerticalScroll.Maximum=0
	Create-Handle -Parent $MenuScroller -Height 30 -Width 205 -Top 0 -Left 0 -Name "Players" -Text "Players"
	Create-Handle -Parent $MenuScroller -Height 30 -Width 205 -Top 65 -Left 0 -Name "Owners" -Text "Owners"
	Create-Handle -Parent $MenuScroller -Height 30 -Width 205 -Top 105 -Left 0 -Name "Round" -Text "Round"

	$actionstatus=Create-Groupbox -height 213 -width 204 -top 432 -left 5 -name "actionstatus" -text ""
	$global:onclock=Create-Groupbox -height 50 -width 198 -top 105 -left 3 -name "onclock" -text "On the Clock"
	$global:ondeck=Create-Groupbox -height 50 -width 198 -top 158 -left 3 -name "ondeck" -text "On Deck"
	$draft=Create-Button -height 40 -width 195 -top 16 -left 5 -name "DraftBtn" -text "Draft Player"
	$undo=Create-Button -height 40 -width 195 -top 60 -left 5 -name "UndoBtn" -text "Undo Last Pick"
	$actionstatus.controls.addRange(@($draft,$undo,$onclock,$ondeck))
	$draft.add_Click({Draft-Player -control $this.parent})
	$undo.add_Click({Undraft-Player -control $this.parent})
	$draft.enabled = $false

	Create-Toggles -parent $RightPanel
	Create-Cards -parent $RightPanel -data $global:currentdata
	Get-NextPicks -clock $onclock -deck $ondeck 

	$LeftPanel.controls.addRange(@($MenuScroller,$actionstatus))
	$MainForm.controls.addRange(@($LeftPanel,$RightPanel))

	$Available=$MainForm.controls.Find("Available Players",$true)[0]
	Select-MenuItem -menuitem $Available
	Update-Players -panel $MainForm.controls[1] -filter "Available Players"
	$Available = $null

	$PlayersDrwr=$MainForm.controls.Find("PlayersDrawer",$true)[0]
	$PlayersDrwr.visible = $true
	$PlayersDrwr = $null

	$MainForm.ShowDialog()
	$global:dataset | ForEach-Object -Process { $_.Card.Dispose()}
	$global:currentdata | ForEach-Object -Process { $_.Card.Dispose()}

	$LeftPanel.Dispose()
	$RightPanel.Dispose()
	$MenuScroller.Dispose()
	$MainForm.Dispose()
}

& Main-Routine