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
	$highlight = $null
	$buttonface = $null
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
		$data = $($global:dataset | Where-Object -Property Round -eq $($hash[$filter]))
	} elseif ($filter -in $plist ) {
		$data = $($global:dataset | Where-Object -Property Position -eq $($hash[$filter]))
	} elseif ($filter -eq "Available Players") {
		$data = $($global:dataset | Where-Object -not Selected)
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
		$container=Create-Label -height 27 -width 183 -top 0 -left 0 -name ("Item_"+[string]$_) -text $($list[($_-1)])
		$container.margin=New-Object System.Windows.Forms.Padding(0, 0, 0, 0)
		$container.padding=New-Object System.Windows.Forms.Padding(0, 0, 0, 0)
		$container.TextAlign="MiddleLeft"
		$container.BackColor=[System.Drawing.Color]::FromName("Buttonface")
		$container.add_Click({
			$form = $this.parent.parent.parent.parent.parent.parent
			$right = $form.controls.Find("RightPanel",$true)[0]
			$togglebx = $form.controls.Find("togglebx",$true)[0]

			Select-MenuItem -menuitem $this
			Update-Players -panel $right -filter $this.text
			Update-PositionCounts -element $togglebx

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
	
}
Function Create-Handle () {
	[CmdletBinding()]
	param ( [object] $parent, [int] $height, [int] $width, [int] $top, [int] $left,
		[string] $name, [string] $text )

	$brdr				= Create-Panel -height $height -width $width -top $top -left $left -name "border" -text ""
	$drwr				= Create-Panel -height 300 -width $width -top ($top+$height) -left 2 -name "drawer" -text $name
	$drwr.Visible		= $false
	$drwr.BorderStyle	= "FixedSingle"
	Set-Drawers -parent $drwr

	$btn				= Create-Label -height $height -width $width -top 0 -left 0 -name $name -text $text
	$btn.Padding		= New-Object System.Windows.Forms.Padding(10, 0, 0, 0)
	$btn.BackColor		= [System.Drawing.Color]::FromName("Buttonface")
	$btn.BorderStyle	= "FixedSingle"
	$btn.add_Click({
		$initialwidth=$this.width
		$scroller = $this.parent.parent
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
			$this.parent.BackColor = [System.Drawing.Color]::FromARGB(0,120,215)
		} else {
			$this.Top=0
			$this.Left=0
			$this.width=$this.parent.width
			$this.height=$this.parent.height
			$this.parent.parent.controls[$idx].visible = $false
			$this.parent.BackColor = [System.Drawing.Color]::FromName("Buttonface")
		}
	})

	$brdr.controls.add($btn)
	$parent.controls.addRange(@($brdr,$drwr))
	$brdr = $null
	$drwr = $null
}
Function Load-Data () {
	Get-DraftOrder
	$global:dataset = New-Object -TypeName System.Collections.Generic.List[PsObject]

	$obj=Import-CSV -Delimiter "," -Path "H:\Fantasy Football\2021\data\Fantasy Pros ADP.csv"
	$global:teams = Import-CSV -Delimiter "," -Path "H:\Fantasy Football\2021\data\Teams.csv"
	Initialize-PositionCounts

	$obj | ForEach-Object -Process {
		Increment-PositionCounts -position $_.Position
		Switch ($_.Team) {
			"JAC" { $_.Team="JAX" }
			"GB" { $_.Team="GBP" }
			"NE" { $_.Team="NEP" }
			"TB" { $_.Team="TBB" }
			"SF" { $_.Team="SFO" }
			"KC" { $_.Team="KCC" }
		}
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
			Overall		= ""
			Round		= ""
			Pick		= ""
			Owner		= ""
			Card		= ""
		}
		$curatedobj = New-Object -TypeName PSObject -Property $props
		$global:dataset.Add(($curatedobj | Select-Object -Property Rank,Name,
						Position,Team,Selected,Overall,Round,Pick,Owner,Card))
	}
}
Function Create-Cards () {
	[CmdletBinding()]
	param (	[object] $parent, $data )
	$tmpcollection = New-Object -TypeName System.Collections.Generic.List[PsObject]
	$scrlr = Create-Scroller -parent $parent -name "cardscroller" -height 592 -width 695 -top 55 -left 2.5

	$data | ForEach-Object -Process {
		$card=Create-Panel -height 78 -width 670 -top 0 -left 0 -name "Card $($_.Rank)" -text "Card #$($_.Rank)"
		$card.BorderStyle="FixedSingle"
		$card.Visible = $true
		Create-Rank -parent $card -item $_
		Create-PlayerDetails -parent $card -item $_
		Create-Drafted -parent $card -item $_
		$card.add_Paint({
			$nmecntrl=$this.controls.Find("PlyrDetails",$true)[0].controls[0]
			$poscntrl=$this.controls.Find("PlyrDetails",$true)[0].controls[1]
			$poscntrl.Left = $nmecntrl.Width + 3
			$nmecntrl = $null
			$poscntrl = $null
		})
		$_.Card = $card
		$tmpcollection.add($card)
		$card = $null
	}
	$scrlr.visible = $false
	$scrlr.controls.addRange($tmpcollection)
	$scrlr.visible = $true
	$tmpcollection = $null

	$parent.controls.add($scrlr)
	$scrlr = $null
}
Function Create-Toggles () {
	[CmdletBinding()]
		param (	[object] $parent )
	$navy=[System.Drawing.Color]::FromARGB(31,45,86)
	$white=[System.Drawing.Color]::FromName("White")
	$buttonface=[System.Drawing.Color]::FromName("Buttonface")

	$box = Create-Panel -height 36 -width 406 -top 18 -left 2 -name "togglebx" -text "toggles"
	$txt = Create-Panel -height 31 -width 285.4 -top 20 -left 407 -name "ListName" -text "ListName"
	$txt.BorderStyle="FixedSingle"
	$parent.controls.add($txt)

	$iWidth = 4
	
	$global:currentdata = $global:dataset
	$global:maastertoggles = New-Object -TypeName System.Collections.Generic.List[PsObject]
	"QB", "RB", "WR", "TE", "PK", "DST" | ForEach-Object {
		$count=($global:currentdata | Where-Object -Property Position -eq $_).count
		$hdr=Create-Label -height 30 -width 28 -top 0 -left 0 -name "$($_)Txt" -text $_
		$hdr.TextAlign="MiddleCenter"
		$hdr.BackColor = $navy
		$hdr.ForeColor = $white
		$hdr.Font = $MsansXsmallBold
		$hdr.add_Click({$this.parent.add_Click})

		$pnlbottom=Create-Label -height 31 -width 65 -top 0 -left 0 -name "$($_)bottom" -text $count
		if ($global:poscnts.DST -lt 10) {$pad=36.5} elseif ($global:poscnts.DST -lt 100) {$pad=34.5} else {$pad=32.5}
		$pnlbottom.Padding=New-Object System.Windows.Forms.Padding($pad, 0, 0, 0)
		$pnlbottom.Font = $MsansXsmallBold
		$pnlbottom.BackColor = $buttonface
		$pnlbottom.add_Click({Toggle-PositionFilters -element $this})

		$pnltop=Create-Label -height 31 -width 65 -top 1.5 -left $iWidth -name "$($_)top" -text ""
		$pnltop.BorderStyle="FixedSingle"
		$pnltop.BackColor = $buttonface

		$pnlbottom.controls.add($hdr)
		$pnltop.controls.add($pnlbottom)
		$box.controls.add($pnltop)
		$iWidth+=67

		$props=[ordered]@{
			Count = $count
			Position = $_
			Toggle = $pnltop
		}
		$obj=New-Object -TypeName PsObject -Property $props
		$global:maastertoggles.add($obj)
	}
	$parent.controls.add($box)
	$box = $null
	$txt = $null
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
	
	$right = $null
	$btn = $null
	$bx = $null
	$hdr = $null
	$brdr = $null
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
	$right = $null
	$tglecol = $null
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
	$tmpcollection = $null
}
Function Get-DraftOrder () {
	$global:owners=New-Object -TypeName System.Collections.Generic.List[PsObject]
	$olist=@("Drew","Massachusetts 420","Nathan","Jax",
			"Darkside","ATLien","Stuart","Marinomania",
			"Y.W.Snappers","Sheriff","Pete","Riverside")

	$icnt = 1
	1..16 | ForEach-Object -Process {
		$idx = $_
		if (($_ % 2) -eq 0) {
			($olist.Length-1)..0 | ForEach-Object {
				$props=[ordered]@{
					Overall = $icnt
					Pick = 12-$_
					Round = $idx
					Owner = $olist[$_]
					Time = ''
				}
				$obj = New-Object -TypeName PSObject -Property $props
				$global:owners.add(($obj | Select-Object -Property Overall, Pick, Round, Owner, Time))
				$icnt += 1
			}
		} else {
			0..($olist.Length-1) | ForEach-Object {
				$props=[ordered]@{
					Overall = $icnt
					Pick = $_+1
					Round = $idx
					Owner = $olist[$_]
					Time = ''
				}
				$obj = New-Object -TypeName PSObject -Property $props
				$global:owners.add(($obj | Select-Object -Property Overall, Pick, Round, Owner, Time))
				$icnt += 1
			}
		}
	}
}
Function Get-NextPicks () {
	[CmdletBinding()]
		param (	[object] $clock, [object] $deck )

	$onclock=($global:owners | Select-Object -First 1).Owner
	$ondeck=(($global:owners | Select-Object -First 2) | Select-Object -Skip 1).Owner

	$lbl = Create-Label -height 30 -width 197 -top 18 -left 0 -name "ClockTxt" -text $onclock
	$lbl.Padding = New-Object System.Windows.Forms.Padding(25,0,0,0)
	$lbl.Font = $MsansXsmallBold
	#$lbl.TextAlign = "MiddleCenter"
	$clock.controls.add($lbl)

	$lbl = Create-Label -height 30 -width 197 -top 18 -left 0 -name "DeckTxt" -text $ondeck
	$lbl.Padding = New-Object System.Windows.Forms.Padding(25,0,0,0)
	$lbl.Font = $MsansXsmallBold
	#$lbl.TextAlign = "MiddleCenter"
	$deck.controls.add($lbl)
	
	$lbl = $null
	$onclock = $null
	$ondeck = $null
}