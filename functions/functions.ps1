Function Increment-PositionCounts() {
	[CmdletBinding()]
		param (	[object] $position )
	Switch ($position) {
		"QB" { $global:poscnts.QB+=1 }
		"RB" { $global:poscnts.RB+=1 }
		"WR" { $global:poscnts.WR+=1 }
		"TE" { $global:poscnts.TE+=1 }
		"PK" { $global:poscnts.PK+=1 }
		"DST" { $global:poscnts.DST+=1 }
	}
}
Function Initialize-PositionCounts () {
	$props = [ordered]@{
		QB		= [int] 0
		RB		= [int] 0
		WR		= [int] 0
		TE		= [int] 0
		PK		= [int] 0
		DST		= [int] 0
	}
	$global:poscnts = New-Object -TypeName PSObject -Property $props | Select-Object -Property QB, RB, WR, TE, PK, DST
}
Function Convert-TeamNames () {
	[CmdletBinding()]
		param (	[object] $team )
	$fullname=""
	$global:teams | Where-Object -Property Abbr -eq $team | ForEach-Object { $fullname = $_.Team }
	return $fullname
}
Function Select-MenuItem () {
	[CmdletBinding()]
		param (	[object] $menuitem )
	$highlight=[System.Drawing.Color]::FromARGB(0,120,215)
	$buttonface=[System.Drawing.Color]::FromName("Buttonface")
	$brdr = $menuitem.parent

	$form=$brdr.parent.parent.parent.parent.parent
	$form.controls.Find("ListName",$true)[0].Text = $menuitem.Text	
	$form.controls.Find("cardscroller",$true)[0].controls | Where {$_.BackColor -eq $highlight} | ForEach-Object -Process {
		$_.BackColor = $buttonface
	}

	if ($brdr.width -eq $menuitem.width) {
		Deselect-MenuItems -menuitem $menuitem
		$brdr.BackColor = $highlight
		$brdr.BorderStyle = "none"
		$menuitem.Top = 3
		$menuitem.Left = 3
		$menuitem.Height = $brdr.height-6
		$menuitem.Width = $brdr.width-6
	}
	$brdr = $null
	$form=$null
	$highlight = $null
	$buttonface = $null
	$menuitem = $null
}
Function Deselect-MenuItems () {
	[CmdletBinding()]
		param (	[object] $menuitem )
	$buttonface=[System.Drawing.Color]::FromName("Buttonface")
	$brdr = $menuitem.parent
	$scrlr = $brdr.parent
	$drwr = $scrlr.parent
	$scrlr.controls | ForEach-Object {
		$_.BorderStyle = "Fixed3D"
		$_.BackColor = $buttonface
		$_.controls[0].Top = 0
		$_.controls[0].Left = 0
		$_.controls[0].Height = $_.height
		$_.controls[0].Width = $_.width
	}
	
	$brdr  = $null
	$scrlr = $null
	$drwr = $null
	$buttonface = $null
}
Function Get-PlayerCards () {
	[CmdletBinding()]
	param ( [string] $filter )

	$tlist=New-Object -TypeName System.Collections.Generic.List[PsObject]
	$global:teams | ForEach-Object -Process { $tlist.add($_.Team) }

	$plist = @("Quarterbacks", "Running Backs", "Wide Receivers","Tightends", "Place Kickers", "Defenses")

	$olist=@("Drew","Massachusetts 420","Nathan","Jax","Darkside","ATLien","Stuart","Marinomania","Y.W.Snappers","Sheriff","Pete","Riverside")

	$rlist = @("Round One", "Round Two", "Round Three", "Round Four", "Round Five", "Round Six", "Round Seven", "Round Eight", "Round Nine", 
				"Round Ten", "Round Eleven", "Round Twelve", "Round Thirteen", "Round Fourteen", "Round Fifteen", "Round Sixteen")

	$hash = @{
		"Quarterbacks"		= "QB"
		"Running Backs"		= "RB"
		"Wide Receivers"	= "WR"
		"Tightends"			= "TE"
		"Place Kickers"		= "PK"
		"Defenses"			= "DST"
		"Round One"			= 1
		"Round Two"			= 2
		"Round Three"		= 3
		"Round Four"		= 4
		"Round Five"		= 5
		"Round Six"			= 6
		"Round Seven"		= 7
		"Round Eight"		= 8
		"Round Nine"		= 9
		"Round Ten"			= 10
		"Round Eleven"		= 11
		"Round Twelve"		= 12
		"Round Thirteen"	= 13
		"Round Fourteen"	= 14
		"Round Fifteen"		= 15
		"Round Sixteen"		= 16
	}

	if ($filter -in $tlist) {
		$data = $($global:dataset | Where-Object -Property Team -eq $filter)
	} elseif ($filter -in $olist) {
		$data = $($global:dataset | Where-Object -Property Owner -eq $filter)
	} elseif ($filter -in $rlist) {
		$data = $( $global:dataset | Where-Object {(($_.Round -eq $($hash[$filter])) -and ($_.Selected -eq $true))} | 
				Sort-Object -Property Pick)
	} elseif ($filter -in $plist ) {
		$data = $($global:dataset | Where-Object -Property Position -eq $($hash[$filter]))
	} elseif ($filter -eq "Available Players") {
		$data = $($global:dataset | Where-Object -Property Selected -eq $false)
	} else {
		$data = $global:dataset
	}

	$global:currentdata = $data
	$tlist = $null
	$olist = $null
	$rlist = $null
	$hash = $null

	return $data
}
Function Update-Players () {
	[CmdletBinding()]
	param ( [object] $panel, [string] $filter )
	$scroller = $panel.controls.Find("cardscroller",$true)[0]
	$tmpcollection = New-Object -TypeName System.Collections.Generic.List[PsObject]

	$filteredplayers = Get-PlayerCards -filter $filter
	Initialize-PositionCounts
	$filteredplayers | ForEach-Object {
		$tmpcollection.add($_.Card)
		Increment-PositionCounts -position $_.Position
	}

	$scroller.Visible = $false
	$scroller.controls.Clear()
	$scroller.controls.addRange($tmpcollection)
	$scroller.Visible = $true
	
	$scroller = $null
	$tmpcollection = $null
	$filteredplayers = $null
	$panel = $null
}
Function Set-Drawers () {
	[CmdletBinding()]
	param ( [object] $parent )
	$sclr = Create-Scroller -parent $parent -name "drwrscroller" -height $parent.height -width $parent.width -top 0 -left -2

	$teamnames=New-Object -TypeName System.Collections.Generic.List[PsObject]
	$global:teams | ForEach-Object -Process { $teamnames.add($_.Team) }
	$plist = "$(@("All Players", "Available Players", "Quarterbacks", "Running Backs", "Wide Receivers",
			"Tightends", "Place Kickers", "Defenses") -join ","),$($teamnames -join ",")" -split ","
	$olist=@("Drew","Massachusetts 420","Nathan","Jax","Darkside","ATLien","Stuart","Marinomania","Y.W.Snappers","Sheriff","Pete","Riverside")
	$rlist = @("Round One", "Round Two", "Round Three", "Round Four", "Round Five", "Round Six"
			"Round Seven", "Round Eight", "Round Nine", "Round Ten", "Round Eleven", "Round Twelve",
			"Round Thirteen", "Round Fourteen", "Round Fifteen", "Round Sixteen")

	if ($parent.text -eq "Players") {$list=$plist} elseif ($parent.text -eq "Owners") {$list=$olist} else {$list=$rlist}
	1..$list.Length | ForEach-Object -Process {
		$border=Create-Label -height 27 -width 183 -top 0 -left 0 -name ("Item_"+[string]$_) -text $($list[($_-1)])
		$border.BorderStyle = "Fixed3D"
		$container=Create-Label -height 27 -width 183 -top 0 -left 0 -name ("$($list[($_-1)])") -text $($list[($_-1)])
		$container.margin=New-Object System.Windows.Forms.Padding(0, 0, 0, 0)
		$container.padding=New-Object System.Windows.Forms.Padding(0, 0, 0, 0)
		$container.TextAlign="MiddleLeft"
		$container.BackColor=[System.Drawing.Color]::FromName("Buttonface")
		$container.add_Click({
			$form = $this.parent.parent.parent.parent.parent.parent
			$right = $form.controls.Find("RightPanel",$true)[0]
			$togglebx = $form.controls.Find("togglebx",$true)[0]
			$draftbtn = $form.controls.Find("DraftBtn",$true)[0]
			$draftbtn.enabled=$false
			
			Select-MenuItem -menuitem $this
			Update-Players -panel $right -filter $this.text
			Update-PositionCounts -element $togglebx

			$draftbtn = $null
			$togglebx = $null
			$right = $null
			$form = $null
		})
		$border.controls.add($container)
		$sclr.controls.add($border)
	}

	$parent.controls.add($sclr)
	$sclr = $null
	$teamnames = $null
	$plist = $null
	$olist = $null
	$rlist = $null
	$parent = $null
}
Function Create-Handle () {
	[CmdletBinding()]
	param ( [object] $parent, [int] $height, [int] $width, [int] $top, [int] $left,
		[string] $name, [string] $text )

	$brdr				= Create-Panel -height $height -width $width -top $top -left $left -name "border" -text ""
	$drwr				= Create-Panel -height 300 -width $width -top ($top+$height) -left 2 -name "$($name)Drawer" -text $name
	$drwr.Visible		= $false
	$drwr.BorderStyle	= "FixedSingle"
	Set-Drawers -parent $drwr

	$btn				= Create-Label -height $height -width $width -top 0 -left 0 -name $name -text $text
	$btn.Padding		= New-Object System.Windows.Forms.Padding(10, 0, 0, 0)
	$btn.BackColor		= [System.Drawing.Color]::FromName("Buttonface")
	$btn.BorderStyle	= "FixedSingle"
	$btn.add_Click({
		$initialwidth=$this.width
		$form = $this.parent.parent.parent.parent
		$scroller = $this.parent.parent
		$draftbtn = $form.controls.find("DraftBtn",$true)[0]
		$draftbtn.enabled = $false

		$plyrbtn = $scroller.controls[0]
		$plyrdrwr = $scroller.controls[1]

		$ownrbtn = $scroller.controls[2]
		$ownrdrwr = $scroller.controls[3]

		$rndbtn = $scroller.controls[4]
		$rnddrwr = $scroller.controls[5]

		$plyrdrwr.visible = $false
		$ownrdrwr.visible = $false
		$rnddrwr.visible = $false

		$plyrbtn.BackColor = [System.Drawing.Color]::FromName("Buttonface")
		$ownrbtn.BackColor = [System.Drawing.Color]::FromName("Buttonface")
		$rndbtn.BackColor = [System.Drawing.Color]::FromName("Buttonface")

		if ($plyrbtn.width -ne $plyrbtn.controls[0].width) {
			$plyrbtn.controls[0].Top = 0
			$plyrbtn.controls[0].Left = 0
			$plyrbtn.controls[0].width=$plyrbtn.width
			$plyrbtn.controls[0].height=$plyrbtn.height}
		if ($ownrbtn.width -ne $ownrbtn.controls[0].width) {
			$ownrbtn.controls[0].Top = 0
			$ownrbtn.controls[0].Left = 0
			$ownrbtn.controls[0].width=$ownrbtn.width
			$ownrbtn.controls[0].height=$ownrbtn.height}
		if ($rndbtn.width -ne $rndbtn.controls[0].width) {
			$rndbtn.controls[0].Top = 0
			$rndbtn.controls[0].Left = 0
			$rndbtn.controls[0].width=$rndbtn.width
			$rndbtn.controls[0].height=$rndbtn.height}

		$idx=$this.parent.parent.controls.GetChildIndex($this.parent)+1
		if ($initialwidth -eq $this.parent.width) {
			$this.Top=2
			$this.Left=2
			$this.width=$this.width-4
			$this.height=$this.height-4
			$this.parent.parent.controls[$idx].visible = $true
			if ($this.Text -eq "Players") { 
				Select-MenuItem -menuitem $this.parent.parent.controls[$idx].controls[0].controls[1].controls[0]
				Update-Players -panel $form.controls[1] -filter "Available Players"
			} elseif ($this.Text -eq "Owners") { 
				$pick=[int] ($global:owners | Where-Object -Property Time -eq '' | Sort-Object { [int] $_.Overall } | Select-Object -First 1).Pick - 1
				Select-MenuItem -menuitem $this.parent.parent.controls[$idx].controls[0].controls[$pick].controls[0]
				Update-Players -panel $form.controls[1] -filter $this.parent.parent.controls[$idx].controls[0].controls[$pick].controls[0].Text
			} else { 
				$round=($global:owners | Where-Object -Property Time -eq '' | Sort-Object { [int] $_.Overall } | Select-Object -First 1).Round - 1
				Select-MenuItem -menuitem $this.parent.parent.controls[$idx].controls[0].controls[$round].controls[0]
				Update-Players -panel $form.controls[1] -filter $this.parent.parent.controls[$idx].controls[0].controls[$round].controls[0].Text
			}
			$this.parent.BackColor = [System.Drawing.Color]::FromARGB(0,120,215)
		} else {
			$this.Top=0
			$this.Left=0
			$this.width=$this.parent.width
			$this.height=$this.parent.height
			$this.parent.parent.controls[$idx].visible = $false
			$this.parent.BackColor = [System.Drawing.Color]::FromName("Buttonface")
		}
			
		$plyrbtn = $null
		$plyrdrwr = $null
		$ownrbtn = $null
		$ownrdrwr = $null
		$rndbtn = $null
		$rnddrwr = $null
		$draftbtn = $null
		$scroller = $null
		$form = $null
	})

	$brdr.controls.add($btn)
	$parent.controls.addRange(@($brdr,$drwr))
	$parent = $null
	$btn = $null
	$brdr = $null
	$drwr = $null
}
function Get-ADPRanking () {

	$ADPRankingCSV = (Join-Path $PSScriptRoot ..\data\adprankings.csv)
	$proto="https:"
	$fqdn="docs.google.com"
	$workbook="2PACX-1vQjEJNN8xBJny-dYz9Et3a1pqXe_is3zptyE6lhRZQBPproZphEgZ5Jb9SfOyO3QRdBHBgpdeN4IRfa"
	$sheet="0"
	$path="spreadsheets/d/e/${workbook}/pub?gid=${sheet}&single=true&output=csv"

	if ( -not (Test-Path $ADPRankingCSV) ) {
		Invoke-WebRequest -Uri "$proto//$fqdn/$path" -Outfile $ADPRankingCSV
	}
	return $ADPRankingCSV
}
Function Get-Teams () {

	$teams = (Join-Path $PSScriptRoot ..\data\teams.csv)
	$proto="https:"
	$fqdn="docs.google.com"
	$workbook="2PACX-1vQjEJNN8xBJny-dYz9Et3a1pqXe_is3zptyE6lhRZQBPproZphEgZ5Jb9SfOyO3QRdBHBgpdeN4IRfa"
	$sheet="1459467330"
	$path="spreadsheets/d/e/${workbook}/pub?gid=${sheet}&single=true&output=csv"
	
	if ( -not (Test-Path $teams) ) {
		Invoke-WebRequest -Uri "$proto//$fqdn/$path" -Outfile $teams
	}
	return $teams
}
Function Get-Owners () {

	$owners = (Join-Path $PSScriptRoot ..\data\owners.csv)
	$proto="https:"
	$fqdn="docs.google.com"
	$workbook="2PACX-1vQjEJNN8xBJny-dYz9Et3a1pqXe_is3zptyE6lhRZQBPproZphEgZ5Jb9SfOyO3QRdBHBgpdeN4IRfa"
	$sheet="1991182108"
	$path="spreadsheets/d/e/${workbook}/pub?gid=${sheet}&single=true&output=csv"
	
	if ( -not (Test-Path $owners) ) {
		Invoke-WebRequest -Uri "$proto//$fqdn/$path" -Outfile $owners
	}
	return $owners
}
Function Load-LiveDraft () {
	$draft = (Join-Path $PSScriptRoot ..\data\selections.csv)
	if ( Test-Path $draft ) {
		$livedraftcsv=Import-CSV -Delimiter "," -Path $draft
		$livedraftcsv | Where-Object -Property Selected -eq $True | ForEach-Object -Process {
			$rank = $_.Rank
			$name = $_.Name
			$team = $_.Team
			$selected = $_.Selected
			$overall = $_.Overall
			$round = $_.Round
			$pick = $_.Pick
			$owner = $_.Owner
			$global:dataset | Where-Object {( ($_.Rank -eq $rank) -and ($_.Name -eq $name) -and ($_.Team -eq $team) )} | 
				ForEach-Object -Process {
					$_.Selected = $selected
					$_.Overall = $overall
					$_.Round = $round
					$_.Pick = $pick
					$_.Owner = $owner
				}
		}
		$global:owners | Where-OBject -Property Time -eq '' | Sort-Object -Property Overall | Select-Object -First 1
	}

}
Function Load-Data () {
	Get-DraftOrder
	$global:dataset = New-Object -TypeName System.Collections.Generic.List[PsObject]

	#$obj=Import-CSV -Delimiter "," -Path "H:\Fantasy Football\2021\scripts\powershell\data\Fantasy Pros ADP.csv"
	#$obj=Import-CSV -Delimiter "," -Path  (Join-Path $PSScriptRoot "..\data\Fantasy Pros ADP.csv")
	$obj=Import-CSV -Delimiter "," -Path  (Get-ADPRanking)
	$global:teams = Import-CSV -Delimiter "," -Path (Get-Teams)
	Initialize-PositionCounts

	$obj | ForEach-Object -Process {
		Increment-PositionCounts -position $_.Position

		if ($_.Team -eq "JAC") {$_.Team="JAX"}
		if ($_.Team -eq "GB") {$_.Team="GBP"}
		if ($_.Team -eq "NE") {$_.Team="NEP"}
		if ($_.Team -eq "TB") {$_.Team="TBB"}
		if ($_.Team -eq "SF") {$_.Team="SFO"}
		if ($_.Team -eq "KC") {$_.Team="KCC"}
		if ($_.Team -eq "NO") {$_.Team="NOS"}
		if ($_.Team -eq "LV") {$_.Team="LVR"}

		$tm = Convert-TeamNames -team $_.Team
		if ($_.Position -eq "K") {$_.Position="PK"} 
		if ($_.Position -eq "DEF") {$_.Position="DST"}
		$props = [ordered]@{
			Rank		= [int]$_.Rank
			Name		= $_.Name
			Position	= $_.Position
			Team		= $tm
			Abbr		= $_.Team
			Selected	= $false
			Overall	= ''
			Round		= ''
			Pick		= ''
			Owner		= ''
			Card		= ''
		}
		$curatedobj = New-Object -TypeName PSObject -Property $props
		$global:dataset.Add(($curatedobj | Select-Object -Property Rank,Name,
						Position,Team,Selected,Overall,Round,Pick,Owner,Card))
	}
	$curatedobj = $null
	Load-LiveDraft
}
Function Select-Card () {
	[CmdletBinding()]
		param (	[object] $border )
	$buttonface=[System.Drawing.Color]::FromName("Buttonface")
	$highlight=[System.Drawing.Color]::FromARGB(0,120,215)

	$border.parent.controls | Where {$_.BackColor -eq $highlight} | ForEach-Object { $_.BackColor = $buttonface }

	$drftbtn=$border.parent.parent.parent.controls.Find("DraftBtn",$true)[0]
	$plyrdrft=$border.controls.Find("Drafted-Undrafted",$true)[0]
	if ($border.parent.parent.parent.controls.Find("Players",$true)[0].parent.BackColor -ne $buttonface) {
		if ($plyrdrft.Text -eq "Drafted") {
			$drftbtn.enabled=$false
		} else {
			$border.parent.parent.parent.controls.Find("DraftBtn",$true)[0].enabled = $true
			$border.parent.parent.parent.controls.Find("DraftBtn",$true)[0].focus()
		}
	}

	if ( $border.BackColor -eq [System.Drawing.Color]::FromName("Buttonface") ) {
		$border.BackColor=$highlight } else { $border.BackColor=$buttonface }

	$border=$null
}
Function Select-Toggle () {
	[CmdletBinding()]
		param (	[object] $toggle )

	$highlight=[System.Drawing.Color]::FromARGB(0,120,215)
	$buttonface=[System.Drawing.Color]::FromName("Buttonface")
	$right = $toggle.parent.parent.parent
	$bx = $toggle.parent.parent
	$brdr = $toggle.parent
	$btn = $toggle
	$hdr = $btn.controls[0]
	
	$bx.enabled = $false

	if ($btn.width -eq $brdr.width) {
		$btn.parent.BackColor=$highlight
		$btn.top = 1.5
		$btn.left = 1.5
		$btn.width=$brdr.width-6
		$btn.height=$brdr.height-6
		$hdr.height=$brdr.height-6
	} else {
		$btn.parent.BackColor=$buttonface
		$btn.top = 0
		$btn.left = 0
		$btn.width=$brdr.width
		$btn.height=$brdr.height
		$hdr.height=$btn.height
	}

	$bx.enabled = $true
	
	$bx = $null
	$hdr = $null
	$btn = $null
	$brdr = $null
	$right = $null
	$toggle = $null
}
Function Get-SelectedToggles () {
	[CmdletBinding()]
		param (	[object] $toggle )

	$toggles = $element.parent.parent.controls

	$positions = New-Object -TypeName System.Collections.Generic.List[PsObject]

	$toggles | ForEach-Object {
		$pos=$_.controls[0].controls[0].text
		if ($_.BackColor -eq $highlight) {
			Switch ($pos) {
				"QB" {$togglecount=$global:poscnts.QB}
				"RB" {$togglecount=$global:poscnts.RB}
				"WR" {$togglecount=$global:poscnts.WR}
				"TE" {$togglecount=$global:poscnts.TE}
				"PK" {$togglecount=$global:poscnts.PK}
				"DST" {$togglecount=$global:poscnts.DST}
			}
			$_.controls[0].text = $togglecount
			$positions.add($_.controls[0].controls[0].Text)
		} else {
			$_.controls[0].text = 0
		}
	}
	if ($positions.Count -eq 0) { "QB", "RB", "WR", "TE", "PK", "DST" | ForEach-Object {$positions.add($_)} }
	
	$toggles = $null
	return $positions
}
Function Get-SelectedPosition() {
	[CmdletBinding()]
		param (	[object] $toggle, [object] $positions )

	$filteredplayers = New-Object -TypeName System.Collections.Generic.List[PsObject]
	$global:currentdata | Where-Object -Property Position -in -Value $positions | ForEach-Object {
		$filteredplayers.add($_)
	}
	return $filteredplayers
	$toggle = $null
	$positions = $null
}
Function Update-PositionCounts () {
	[CmdletBinding()]
		param (	[object] $element )

	$buttonface=[System.Drawing.Color]::FromName("Buttonface")

	$right = $element.parent
	$tglecol = $element
	$tglecol.enabled=$false
	 $tglecol.controls | ForEach-Object {
		Switch ($_.controls[0].controls[0].Text) {
			"QB" {$togglecount=$global:poscnts.QB}
			"RB" {$togglecount=$global:poscnts.RB}
			"WR" {$togglecount=$global:poscnts.WR}
			"TE" {$togglecount=$global:poscnts.TE}
			"PK" {$togglecount=$global:poscnts.PK}
			"DST" {$togglecount=$global:poscnts.DST}
		}
		$_.controls[0].text = $togglecount
		$_.controls[0].top = 0
		$_.controls[0].left = 0
		$_.controls[0].width=$_.width
		$_.controls[0].height=$_.height
		$_.controls[0].controls[0].height = $_.height
		$_.BackColor=$buttonface
	}
	$tglecol.enabled=$true
	$tglecol = $null
	$right = $null
	$element = $null
}
Function Toggle-PositionFilters () {
	[CmdletBinding()]
		param (	[object] $element )
	$highlight=[System.Drawing.Color]::FromARGB(0,120,215)
	$buttonface=[System.Drawing.Color]::FromName("Buttonface")
	$tmpcollection = New-Object -TypeName System.Collections.Generic.List[PsObject]

	Select-Toggle -toggle $element
	$filteredpos = Get-SelectedToggles -toggle $element
	$filtereddata = Get-SelectedPosition -toggle $element -positions $filteredpos

	$tglebx = $element.parent.parent
	if ($filteredpos.Length -eq 6) { Update-PositionCounts -element $tglebx }
	$right = $tglebx.parent
	$scroller = $right.controls.Find("cardscroller",$true)[0]
	$filtereddata | ForEach-Object { $tmpcollection.add($_.Card) }

	$scroller.visible = $false
	$scroller.controls.Clear()
	$scroller.controls.addRange($tmpcollection)
	$scroller.visible = $true

	$scroller = $null
	$right = $null
	$tglebx = $null
	$filteredpos = $null
	$filtereddata = $null
	$tmpcollection = $null
	$element = $null
}
Function Get-DraftOrder () {
	$draftorder = (Join-Path $PSScriptRoot ..\data\draftboard.csv)
	if ( Test-Path $draftorder ) {
		$global:owners = Import-CSV -Delimiter "," -Path $draftorder | Select-Object -Property @{Name='Overall';Expression=[int]$_.Overall},
						@{Name='Round';Expression=[int]$_.Round},@{Name='Pick';Expression=[int]$_.Pick}, Owner, Player, Position, Team,
						@{Name='Rank';Expression=[int]$_.Rank},@{Name='Time';Expression=[datetime]$_.Time}
	} else {
		$global:owners=New-Object -TypeName System.Collections.Generic.List[PsObject]
		$olist = New-Object -TypeName System.Collections.Generic.List[PsObject]
		$obj=Import-CSV -Delimiter "," -Path  (Get-Owners)
		$obj | ForEach-Object -Process { $olist.Add($_.Name) }
		# $olist=@("Drew","Massachusetts 420","Nathan","Jax","Darkside","ATLien",
		#	"Stuart","Marinomania","Y.W.Snappers","Sheriff","Pete","Riverside")

		$icnt = 1
		1..16 | ForEach-Object -Process {
			$idx = $_
			if (($_ % 2) -eq 0) {
				($olist.Count-1)..0 | ForEach-Object {
					$props=[ordered]@{
						Overall = [int] $icnt
						Pick = [int] 12-$_
						Round = [int] $idx
						Owner = $olist[$_]
						Player = ''
						Position = ''
						Team = ''
						Rank = ''
						Time = ''
					}
					$obj = New-Object -TypeName PSObject -Property $props
					$global:owners.add(($obj | Select-Object -Property Overall, Pick, Round, Owner, Player, Position, Team, Rank, Time))
					$icnt += 1
				}
			} else {
				0..($olist.Count-1) | ForEach-Object {
					$props=[ordered]@{
						Overall = [int] $icnt
						Pick = [int] $_+1
						Round = [int] $idx
						Owner = $olist[$_]
						Player = ''
						Position = ''
						Team = ''
						Rank = ''
						Time = ''
					}
					$obj = New-Object -TypeName PSObject -Property $props
					$global:owners.add(($obj | Select-Object -Property Overall, Pick, Round, Owner, Player, Position, Team, Rank, Time))
					$icnt += 1
				}
			}
		}
	}
	$olist = $null
}
Function Get-NextPicks () {
	[CmdletBinding()]
		param (	[object] $clock, [object] $deck )

	$onclock=($global:owners | Where-Object -Property Time -eq '' | Sort-Object { [int] $_.Overall } | Select-Object -First 1).Owner
	$ondeck=(($global:owners | Where-Object -Property Time -eq '' | Sort-Object { [int] $_.Overall }  | Select-Object -First 2) | Select-Object -Skip 1).Owner

	$lbl = Create-Label -height 30 -width 197 -top 18 -left 0 -name "ClockTxt" -text $onclock
	$lbl.Padding = New-Object System.Windows.Forms.Padding(25,0,0,0)
	$lbl.Font = $MsansSmallBold
	$clock.controls.add($lbl)

	$lbl = Create-Label -height 30 -width 197 -top 18 -left 0 -name "DeckTxt" -text $ondeck
	$lbl.Padding = New-Object System.Windows.Forms.Padding(25,0,0,0)
	$lbl.Font = $MsansSmallBold
	$deck.controls.add($lbl)
	
	$lbl = $null
	$onclock = $null
	$ondeck = $null
	$clock = $null
	$deck = $null
}
Function Get-CurrentPickNo () {
	$global:owners | Where-Object -Property Time -eq '' | Sort-Object -Property Overall | 
		Select-Object -Property Overall -First 1 | ForEach-Object -Process { return $_.Overall }
}
Function Draft-Player () {
	[CmdletBinding()]
		param (	[object] $control )
	$buttonface=[System.Drawing.Color]::FromName("Buttonface")
	$highlight=[System.Drawing.Color]::FromARGB(0,120,215)

	$form = $control.parent.parent
	$togglebx = $form.controls.Find("togglebx",$true)[0]
	$scroller = $form.controls.Find("cardscroller",$true)[0]
	$scroller.controls | Where {$_.BackColor -eq $highlight} | ForEach-Object -Proces {
		$name = $_.controls[0].controls[1].controls[0].Text 
		$rank = $_.controls[0].controls[0].controls[1].Text
		$pos  = $_.controls[0].controls[1].controls[1].Text.Replace("(","").Replace(")","")
		$team = $_.controls[0].controls[1].controls[2].Text
		$currentpick=(Get-CurrentPickNo)

		$global:owners | Where-Object {$_.Overall -eq $($currentpick)} | ForEach-Object -Process {
			$round	= $_.Round
			$pick	= $_.Pick
			$owner	= $_.Owner
			$_.Player	= $name
			$_.Position = $pos
			$_.Team	= $team
			$_.Rank	= $rank
			$_.Time	= $(Get-Date -Format o).Replace(":",".")
		}

		$_.controls[0].controls[2].controls[0].Text = $currentpick
		$_.controls[0].controls[2].controls[1].Text = $round
		$_.controls[0].controls[2].controls[2].Text = $pick
		$_.controls[0].controls[2].controls[3].Text = $owner
		
		$global:dataset | Where-Object {(($_.Name -eq $name) -and ($_.Rank -eq $rank))} | ForEach-Object -Process {
			$_.Overall=[int]$currentpick
			$_.Round= [int]$round
			$_.Pick=[int]$pick
			$_.owner=$owner
			$_.Selected = $true
		}
		$global:onclock.controls[0].Text = ($global:owners | Where-Object {$_.Overall -eq $($currentpick+1)}).Owner
		$global:ondeck.controls[0].Text  = ($global:owners | Where-Object {$_.Overall -eq $($currentpick+2)}).Owner

		$_.controls[0].controls[2].controls[4].Text = "Drafted"

		$Available=$scroller.parent.parent.controls.Find("Available Players",$true)[0]
		Select-MenuItem -menuitem $Available
		Update-Players -panel $form.controls[1] -filter "Available Players"
		Update-PositionCounts -element $togglebx
		$Available = $null
	}
	$draftbtn = $form.controls.Find("DraftBtn",$true)[0]
	$draftbtn.enabled = $false
	Save-Draft
	Save-Owners

	$form = $null
	$togglebx = $null
	$scroller = $null
	$form = $null
	$control = $null
}
Function Save-Owners () {
	$owners = (Join-Path $PSScriptRoot ..\data\draftboard.csv)
	$global:owners | Select-Object -Property Overall, Pick, Round, Owner, Player, Position, Team, Rank, Time | 
			Export-Csv $owners -NoTypeInformation
}
Function Save-Draft () {
	$draft = (Join-Path $PSScriptRoot ..\data\selections.csv)
		$global:dataset | Select-Object -Property Rank, Name, Position, Team,
			Selected, Overall, Round, Pick, Owner | Export-Csv $draft -NoTypeInformation
}
Function Undraft-Player () {
	[CmdletBinding()]
		param (	[object] $control )

	$lastpic = $(Get-CurrentPickNo) - 1
	#$global:owners | Where-Object -Property Overall -eq $lastpic | Sort-Object -Property Overall | Out-GridView
	
	$form = $control.parent.parent
	$togglebx = $form.controls.Find("togglebx",$true)[0]
	$scroller = $form.controls.Find("cardscroller",$true)[0]
	$global:dataset | Where-Object -Property Overall -eq $lastpic | ForEach-Object -Process {
		$_.Selected = $false
		$_.Overall = ""
		$_.Round = ""
		$_.Pick = ""
		$_.Owner = ""
		$_.Card.controls[0].controls[2].controls[0].Text = ""
		$_.Card.controls[0].controls[2].controls[1].Text = ""
		$_.Card.controls[0].controls[2].controls[2].Text = ""
		$_.Card.controls[0].controls[2].controls[3].Text = ""
		$_.Card.controls[0].controls[2].controls[4].Text = "Undrafted"

		$Available=$form.controls.Find("Available Players",$true)[0]
		Select-MenuItem -menuitem $Available
		Update-Players -panel $form.controls[1] -filter "Available Players"
		Update-PositionCounts -element $togglebx
		$Available = $null
	}
	$global:owners | Where-Object -Property Overall -eq $lastpic | ForEach-Object -Process {
		$_.Time = ""
	}
	$global:onclock.controls[0].Text = ($global:owners | Where-Object {$_.Overall -eq $($lastpic)}).Owner
	$global:ondeck.controls[0].Text  = ($global:owners | Where-Object {$_.Overall -eq $($lastpic+1)}).Owner
	
	$draftbtn = $form.controls.Find("DraftBtn",$true)[0]
	$draftbtn.enabled=$false
}
