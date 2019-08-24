$LocListSelectEvent = {
	If ($($LocListBox.text) -match '\s[-]\s(.*)') {
		$textBox.text = $matches[1]
	}
}
