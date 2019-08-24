$SysSetBoxClick = {

	$SysSetBox.EndEdit()
	$rowIndex = $SysSetBox.CurrentRow.Index
	$columnIndex = $SysSetBox.CurrentCell.ColumnIndex
	$CanElite = $(-not $SysSetBox.CurrentCell.ReadOnly)

	If ($CanElite) {
		If (1, 2 -contains $columnIndex) {

			$MaxRowIndex = $($SysSetBox.Rows.count - 1)
			For ($i = 0; $i -le $MaxRowIndex; $i++) {
				If ($i -ne $rowIndex) {
					$global:Saved = $False
					$SysSetBox.Rows[$i].Cells[$columnIndex].ReadOnly = $($SysSetBox.CurrentCell.Value)
				}
			}
		}
	}

	If ($columnIndex -eq 3) {
		$SysSetBox.Rows[$rowIndex].Cells[0].Value | clip
	}
	$SysSetBox.EndEdit()
}
