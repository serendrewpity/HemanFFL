. (Join-Path $PSScriptRoot ..\assemblies\assemblies.ps1)
. (Join-Path $PSScriptRoot ..\typeface\fonts.ps1)
. (Join-Path $PSScriptRoot .\containers.ps1)

Function Create-Form () {
	[CmdletBinding()]
	param (	[int] $height,	[int] $width, [string] $name, [string] $text )
	
	$frm					= New-Object system.Windows.Forms.Form
	$sze					= New-Object System.Drawing.Size($width,$height)

    $frm.ClientSize			= $sze
    $frm.Name				= $name
    $frm.text				= $text
    $frm.StartPosition		= "CenterScreen"
    $frm.FormBorderStyle	= "Fixed3D"

	return $frm
}
Function Create-Groupbox () {
	[CmdletBinding()]
	param (	[int] $height,	[int] $width,	[int] $top,	[int] $left,
		[string] $name,	[string] $text	)

	$gbx					= New-Object system.Windows.Forms.GroupBox
	$pnt					= New-Object system.drawing.point($left,$top)

	$gbx.Name				= $name
	$gbx.Text				= $text
	$gbx.width				= $width
	$gbx.height				= $height
	$gbx.Location			= $pnt

	return $gbx
}
Function Create-Panel () {
	[CmdletBinding()]
	param (	[int] $height,	[int] $width,	[int] $top,	[int] $left,	
		[string] $name,	[string] $text	)

	$pnl					= New-Object system.Windows.Forms.Panel
	$sze					= New-Object System.Drawing.Size($width,$height)
	$pnt					= New-Object system.drawing.point($left,$top)

	$pnl.Name				= $name
	$pnl.Text				= $text
	$pnl.size				= $sze
	$pnl.location			= $pnt
	$pnl.font				= $MsansSmallBold

	return $pnl
}
Function Create-Label () {
	[CmdletBinding()]
	param (	[int] $height,	[int] $width,	[int] $top,	[int] $left,	
		[string] $name, [string] $text )

	$lbl					= New-Object System.Windows.Forms.Label
	$sze					= New-Object System.Drawing.Size($width,$height)
	$pnt					= New-Object system.drawing.point($left,$top)
	
	$lbl.AutoSize			= $false
    $lbl.name				= $name
    $lbl.text				= $text
    $lbl.size				= $sze
	$lbl.location			= $pnt
	$lbl.TextAlign			= "MiddleLeft"
	$lbl.font				= $MsansSmallBold

	return $lbl
}
Function Create-Button () {
	[CmdletBinding()]
	param (	[int] $height,	[int] $width,	[int] $top,	[int] $left,	
		[string] $text	)

    $btn			= New-Object System.Windows.Forms.Button
	$pnt			= New-Object system.drawing.point($left,$top)
	
    $btn.Text		= $text
    $btn.Width		= $width
    $btn.Height		= $height
    $btn.Location	= $pnt

	return $btn
}
