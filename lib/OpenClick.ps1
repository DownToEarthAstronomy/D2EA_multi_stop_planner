$OpenClick = {

	$MakeNew = 'yes'

	If (-not $global:Saved) {
		$MakeNew = [Microsoft.VisualBasic.Interaction]::MsgBox("You are about to open a new Route. `n All unsaved changes will be lost `n Continue?", 'YesNo,Question', "Create New Route?")
	}

	If ($MakeNew -eq 'yes') {
		# -- Ask use What file to open
		$OpenChooser = New-Object -Typename System.Windows.Forms.OpenFileDialog
		$OpenChooser.title = "Open Route"
		$OpenChooser.filter = "CSV Files|*.CSV|All Files|*.*"
		$OpenChooser.InitialDirectory = $Root_path
		$OpenChooser.ShowDialog()

		# -- read file path
		$TempFilePath = $OpenChooser.Filename

		If ($TempFilePath -ne '') {
			$global:CurrentFilePath = $TempFilePath

			# -- Delete old rows
			$SysSetBox.ROWS.Clear()

			# -- Read Csv file
			$CsvContent = Import-Csv $global:CurrentFilePath

			# -- Check that we have no more then one start and end system
			$StarCount = $($CsvContent.First | Where-Object { $_ -eq 'True' }).count
			$EndCount = $($CsvContent.Last | Where-Object { $_ -eq 'True' }).count

			If (($StarCount -gt 1) -or ($EndCount -gt 1)) {
				# -- only one start and end at the time.
				[Microsoft.VisualBasic.Interaction]::MsgBox("Only one start and end system allowed per route!", 'OkOnly,Exclamation', "File Format Error")
			}
			Else {
				$global:Saved = $True
				# -- check if there is any start or end
				$HasStart = $($StarCount -eq 1)
				$HasEnd = $($EndCount -eq 1)

				ForEach ($Row in $CsvContent) {
					$SystemName = $Row.System
					$First = $($Row.First -eq 'True')
					$Last = $($Row.Last -eq 'True')

					If ($SystemName -ne '') {

						# -- figure out of this rows start field is read-only
						If ($HasStart) {
							$StartReadOly = $True

							If ($First -eq 'True') {
								$StartReadOly = $False
							}
						}
						Else {
							$StartReadOly = $False
						}

						# -- figure out of this rows end field is read-only
						If ($HasEnd) {
							$EndReadOnly = $True

							If ($First -eq 'True') {
								$EndReadOnly = $False
							}
						}
						Else {
							$EndReadOnly = $False
						}

						$SysSetBox.Rows.Add($SystemName, $First, $Last)

						$NewRow = $SysSetBox.Rows | Where-Object { $_.Cells[0].Value -eq $SystemName }

						$NewRow.Cells[1].ReadOnly = $StartReadOly
						$NewRow.Cells[2].ReadOnly = $EndReadOnly

						$SysSetBox.EndEdit()
					}
				}
				UpdateRouteLength $SysSetBox $LengthLabel
			}
		}
	}
}
