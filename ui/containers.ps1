Function Create-Scroller () {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true)] [object] $parent,
		[Parameter(Mandatory=$true)] [object] $name,
		[Parameter(Mandatory=$false)] [object] $width=0,
		[Parameter(Mandatory=$false)] [object] $height=0,
		[Parameter(Mandatory=$false)] [object] $top=0,
		[Parameter(Mandatory=$false)] [object] $left=0 )

	$font=New-Object System.Drawing.Font("Courier New", 9)

	$flowpanel=New-Object System.Windows.Forms.FlowLayoutPanel
	$flowpanel.HorizontalScroll.Maximum=0
	$flowpanel.Name=$name
	$flowpanel.AutoScroll=$true
	$flowpanel.AutoSize=$false
	$flowpanel.Top=$top
	$flowpanel.Left=$left
	$flowpanel.Height=$height
	$flowpanel.Width=$width
	$flowpanel.FlowDirection = "TopDown"
	$flowpanel.WrapContents = $false
	$flowpanel.Padding=New-Object System.Windows.Forms.Padding(0,0,0,0)
	$flowpanel.BorderStyle="none"

	return $flowpanel
}
Function Create-Cards () {
	[CmdletBinding()]
	param (	[object] $parent, $data )
	$buttonface=[System.Drawing.Color]::FromName("Buttonface")
	$tmpcollection = New-Object -TypeName System.Collections.Generic.List[PsObject]
	$scrlr = Create-Scroller -parent $parent -name "cardscroller" -height 592 -width 695 -top 55 -left 2.5

	$data | ForEach-Object -Process {
		$brdr=Create-Panel -height 78 -width 670 -top 0 -left 0 -name "CardBorder $($_.Rank)" -text "CrdBrdr #$($_.Rank)"
		$brdr.BorderStyle="FixedSingle"
		$brdr.BackColor = $buttonface
		
		$card=Create-Panel -height 70 -width 662 -top 3 -left 2 -name "Card $($_.Rank)" -text "Card #$($_.Rank)"
		$card.BackColor = $buttonface
		$brdr.controls.add($card)
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

		$_.Card = $brdr
		$tmpcollection.add($brdr)

		$card = $null
		$brdr = $null
	}
	$scrlr.visible = $false
	$scrlr.controls.addRange($tmpcollection)
	$scrlr.visible = $true
	$tmpcollection = $null

	$parent.controls.add($scrlr)
	$scrlr = $null
	$parent=$null
	$data=$null
}
Function Create-Toggles () {
	[CmdletBinding()]
		param (	[object] $parent )
	$navy=[System.Drawing.Color]::FromARGB(31,45,86)
	$white=[System.Drawing.Color]::FromName("White")
	$buttonface=[System.Drawing.Color]::FromName("Buttonface")

	$box = Create-Panel -height 36 -width 406 -top 18 -left 2 -name "togglebx" -text "toggles"
	$txt = Create-Label -height 31 -width 285.4 -top 20 -left 407 -name "ListName" -text ""
	$txt.TextAlign="MiddleCenter"
	$txt.Font = $MsansLargeBold
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
	$hdr = $null
	$txt = $null
	$box = $null
	$pnltop = $null
	$pnlbottom = $null
	$parent = $null
}
Function Create-Drafted () {
	[CmdletBinding()]
	param (	[object] $parent, [PsObject] $item )
	$navy=[System.Drawing.Color]::FromARGB(31,45,86)
	$white=[System.Drawing.Color]::FromName("White")

	$box=Create-Panel -height 68 -width 256 -top 1 -left 407 -name "PlyrDraft" -text "PlyrDraft"
	$box.add_Click({ Select-Card -border $this.parent.parent })
	$box.BorderStyle="FixedSingle"

	If ( $item.Selected ) { $status = "Drafted" } else { $status = "Undrafted" }
	$hdr=Create-Label -height 22 -width 260 -top 0 -left 0 -name "Drafted-Undrafted" -text $status
	$hdr.add_Click({ Select-Card -border $this.parent.parent.parent })
	$hdr.Padding=New-Object System.Windows.Forms.Padding(5, 0, 0, 0)
	$hdr.BackColor = $navy
	$hdr.ForeColor = $white

	Create-Overall -parent $box -item $item
	Create-Round -parent $box -item $item
	Create-Pick -parent $box -item $item
	Create-Owner -parent $box -item $item

	$box.controls.addRange(@($hdr))
	$parent.controls.add($box)

	$hdr = $null
	$box = $null
	$item = $null
	$parent = $null
}
Function Create-Owner () {
	param (	[object] $parent, [PsObject] $item )
	$navy=[System.Drawing.Color]::FromARGB(31,45,86)
	$white=[System.Drawing.Color]::FromName("White")

	$box=Create-Label -height 44 -width 105 -top 24 -left 149 -name "Owner" -text $item.Owner
	$box.Padding=New-Object System.Windows.Forms.Padding(1, 5, 0, 0)
	$box.add_Click({ Select-Card -border $this.parent.parent.parent })
	$box.TextAlign = "TopLeft"
	$box.BorderStyle="FixedSingle"
	$box.add_TextChanged({ if ($this.Text.Length -gt 12) { $this.Font = $MsansXsmallBold } else { $this.Font = $MsansSmallBold } })

	$hdr=Create-Label -height 16 -width 105 -top 26 -left 0 -name "Owner" -text "Owner"
	$hdr.Padding=New-Object System.Windows.Forms.Padding(2, 0, 0, 3)
	$hdr.add_Click({ Select-Card -border $this.parent.parent.parent.parent })
	$hdr.BackColor = $navy
	$hdr.ForeColor = $white
	$hdr.Font = $MsansXSmallBold

	$box.controls.addRange(@($hdr))
	$parent.controls.add($box)

	$hdr = $null
	$box = $null
	$item = $null
	$parent = $null
}
Function Create-Pick () {
	param (	[object] $parent, [PsObject] $item )
	$navy=[System.Drawing.Color]::FromARGB(31,45,86)
	$white=[System.Drawing.Color]::FromName("White")

	$box=Create-Label -height 44 -width 48 -top 24 -left 99 -name "Pick" -text $item.Pick
	if ($item.Pick -lt 10) {$pad=15} elseif ($item.Pick -lt 100) {$pad=12} else {$pad=7}
	$box.Padding=New-Object System.Windows.Forms.Padding($pad, 5, 0, 0)
	$box.add_Click({ Select-Card -border $this.parent.parent.parent })
	$box.TextAlign = "TopLeft"
	$box.BorderStyle="FixedSingle"

	$hdr=Create-Label -height 16 -width 48 -top 26 -left 0 -name "Pick" -text "Pick"
	$hdr.Padding=New-Object System.Windows.Forms.Padding(2, 0, 0, 3)
	$hdr.add_Click({ Select-Card -border $this.parent.parent.parent.parent })
	$hdr.BackColor = $navy
	$hdr.ForeColor = $white
	$hdr.Font = $MsansXSmallBold

	$box.controls.addRange(@($hdr))
	$parent.controls.add($box)

	$hdr = $null
	$box = $null
	$item = $null
	$parent = $null
}
Function Create-Round () {
	param (	[object] $parent, [PsObject] $item )
	$navy=[System.Drawing.Color]::FromARGB(31,45,86)
	$white=[System.Drawing.Color]::FromName("White")

	$box=Create-Label -height 44 -width 48 -top 24 -left 50 -name "RoundPick" -text $item.Round
	if ($item.Round -lt 10) {$pad=15} elseif ($item.Round -lt 100) {$pad=12} else {$pad=7}
	$box.Padding=New-Object System.Windows.Forms.Padding($pad, 5, 0, 0)
	$box.add_Click({ Select-Card -border $this.parent.parent.parent })
	$box.TextAlign = "TopLeft"
	$box.BorderStyle="FixedSingle"

	$hdr=Create-Label -height 16 -width 48 -top 26 -left 0 -name "Round" -text "Round"
	$hdr.Padding=New-Object System.Windows.Forms.Padding(2, 0, 0, 3)
	$hdr.add_Click({ Select-Card -border $this.parent.parent.parent.parent })
	$hdr.BackColor = $navy
	$hdr.ForeColor = $white
	$hdr.Font = $MsansXSmallBold

	$box.controls.addRange(@($hdr))
	$parent.controls.add($box)

	$hdr = $null
	$box = $null
	$item = $null
	$parent = $null
}
Function Create-Overall () {
	param (	[object] $parent, [PsObject] $item )
	$navy=[System.Drawing.Color]::FromARGB(31,45,86)
	$white=[System.Drawing.Color]::FromName("White")

	$box=Create-Label -height 44 -width 48 -top 24 -left 1 -name "OverallPick" -text $item.Overall
	if ($item.Overall -lt 10) {$pad=15} elseif ($item.Overall -lt 100) {$pad=12} else {$pad=7}
	$box.Padding=New-Object System.Windows.Forms.Padding($pad, 5, 0, 0)
	$box.add_Click({ Select-Card -border $this.parent.parent.parent })
	$box.TextAlign = "TopLeft"
	$box.BorderStyle="FixedSingle"

	$hdr=Create-Label -height 16 -width 48 -top 26 -left 0 -name "Overall" -text "Overall"
	$hdr.Padding=New-Object System.Windows.Forms.Padding(2, 0, 0, 3)
	$hdr.add_Click({ Select-Card -border $this.parent.parent.parent.parent })
	$hdr.BackColor = $navy
	$hdr.ForeColor = $white
	$hdr.Font = $MsansXSmallBold

	$box.controls.addRange(@($hdr))
	$parent.controls.add($box)
	
	$hdr = $null
	$box = $null
	$item = $null
	$parent = $null
}
Function Create-PlayerDetails () {
	[CmdletBinding()]
	param (	[object] $parent, [PsObject] $item)

	$box=Create-Panel -height 68 -width 340 -top 1 -left 66 -name "PlyrDetails" -text "PlyrDetails"
	$box.add_Click({ Select-Card -border $this.parent.parent })
	$box.BorderStyle="FixedSingle"

	$nme=Create-Label -height 40 -width 225 -top 11 -left 0 -name "pname" -text $item.Name
	$nme.add_Click({ Select-Card -border $this.parent.parent.parent })
	$nme.Font = $MsansXLargeBold
	$nme.Autosize = $true

	$pos=Create-Label -height 33.5 -width 48 -top 9 -left ($item.Name.Length*11) -name "ppos" -text "($($item.Position))"
	$pos.add_Click({ Select-Card -border $this.parent.parent.parent })
	$pos.Font = $MsansSmallBold
	$pos.TextAlign = "MiddleLeft"

	$tm=Create-Label -height 24 -width 268 -top 44 -left 0 -name "pteam" -text $item.Team
	$tm.add_Click({ Select-Card -border $this.parent.parent.parent })
	$tm.Padding=New-Object System.Windows.Forms.Padding(4, 0, 0, 0)
	$tm.Font = $MsansSmallBoldItalic
	$tm.TextAlign = "TopLeft"

	$box.controls.addRange(@($nme,$pos,$tm))
	$parent.controls.add($box)

	$tm = $null
	$pos = $null
	$nme = $null
	$box = $null
	$item = $null
	$parent = $null
}
Function Create-Rank () {
	[CmdletBinding()]
	param (	[object] $parent, [PsObject] $item)
	$rank = $item.Rank
	$navy=[System.Drawing.Color]::FromARGB(31,45,86)
	$white=[System.Drawing.Color]::FromName("White")

	$box=Create-Panel -height 68 -width 65 -top 1 -left 0 -name "Rank $rank" -text "Card #($rank)"
	$box.Font = $MsansNormalBold
	$box.BorderStyle="FixedSingle"

	$hdr=Create-Label -height 23 -width 65 -top 0 -left 0 -name "Rank $rank" -text "Rank"
	$hdr.add_Click({ Select-Card -border $this.parent.parent.parent })
	$hdr.BackColor = $navy
	$hdr.ForeColor = $white

	$txt=Create-Label -height 43 -width 65 -top 23 -left 0 -name "Card $_" -text $rank
	if ($rank -lt 10) {$indent=22} elseif ($rank -lt 100) {$indent=16.5} else {$indent=11}
	$txt.Padding=New-Object System.Windows.Forms.Padding($indent, 0, 0, 0)
	$txt.Font=$MsansNormalBold
	$txt.add_Click({ Select-Card -border $this.parent.parent.parent })

	$box.controls.addRange(@($hdr,$txt))
	$parent.controls.add($box)
	
	$txt = $null
	$hdr = $null
	$box = $null
	$white = $null
	$navy = $null
	$rank = $null
	$parent = $null
}

Function Show-Error ( [string]$text, [string]$title ) { [void] [System.Windows.MessageBox]::Show($text, $title, 'Ok', 'Error') }
