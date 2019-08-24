$SaveAsClick = {

	# -- Ask use where to save file
	$SaveChooser = New-Object -Typename System.Windows.Forms.SaveFileDialog
	$SaveChooser.Filename = 'Route'
	$SaveChooser.title = "Save Route"
	$SaveChooser.filter = "CSV Files|*.CSV|All Files|*.*"
	$SaveChooser.InitialDirectory = $Root_path
	$SaveChooser.ShowDialog()

	# -- read file path
	$TempFilePath = $SaveChooser.Filename

	If ($TempFilePath -ne 'Route') {
		$global:CurrentFilePath = $TempFilePath

		# -- Add header to file.
		'System,First,Last' | Out-File $global:CurrentFilePath

		$global:Saved = $True

		# -- add rows to File
		ForEach ($Row in $SysSetBox.Rows) {
			$('{0},{1},{2}' -f $Row.Cells[0].VALUE, $Row.Cells[1].VALUE, $Row.Cells[2].VALUE) | Out-File $global:CurrentFilePath -append
		}
	}
}
