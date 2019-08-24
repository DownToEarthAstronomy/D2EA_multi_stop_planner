$NewClick = {

	$MakeNew = 'yes'

	If (-not $global:Saved) {
		$MakeNew = [Microsoft.VisualBasic.Interaction]::MsgBox("You are about to create a new Route. `n All unsaved changes will be lost `n Continue?", 'YesNo,Question', "Create New Route?")
	}

	If ($MakeNew -eq 'yes') {
		# -- Reset currnt file path
		$global:CurrentFilePath = ''
		$global:Saved = $True

		# -- Delete old rows
		$SysSetBox.ROWS.Clear()

		UpdateRouteLength $SysSetBox $LengthLabel
	}
}
