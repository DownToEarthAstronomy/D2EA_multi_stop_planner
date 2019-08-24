[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null

$Root_path = $('{0}\..' -f $PSScriptRoot)
$global:CurrentFilePath = ''
$global:Saved = $True

# -- Import code blocks
. $Root_path\lib\GetCoords.ps1
. $Root_path\lib\GetRouteLength.ps1
. $Root_path\lib\UpdateRouteLength.ps1
. $Root_path\lib\NewClick.ps1
. $Root_path\lib\OpenClick.ps1
. $Root_path\lib\SaveClick.ps1
. $Root_path\lib\SaveAsClick.ps1
. $Root_path\lib\LocListSelect.ps1
. $Root_path\lib\SysSetBoxClick.ps1
. $Root_path\lib\SysSetBoxDelete.ps1
. $Root_path\lib\WPAddClick.ps1
. $Root_path\lib\OptimizeRoute.ps1

$Font = New-Object System.Drawing.Font("Times New Roman", 14)

$SplashProcess = start-process powershell $('{0}\lib\SplashForm.ps1' -f $Root_path) -PassThru -NoNewWindow

# -- Creating the window
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "D2EA Multi-Waypoint"
$Form.Size = New-Object System.Drawing.Size(900, 750)
$Form.StartPosition = "CenterScreen"
$Form.MinimizeBox = $True
$Form.MaximizeBox = $False
$Form.FormBorderStyle = 'Fixed3D'
$Form.Font = $Font

# -- Adding banner
$Banner = [System.Drawing.Image]::Fromfile("$Root_path\Elements\banner.png")
$pictureBox = new-object Windows.Forms.PictureBox
$pictureBox.Width = $Banner.Size.Width
$pictureBox.Height = $Banner.Size.Height
$pictureBox.Image = $Banner
$Form.controls.add($pictureBox)

# -- Adding New button
$NewButton = New-Object System.Windows.Forms.Button
$NewButton.Location = New-Object System.Drawing.Size(40, 150)
$NewButton.Size = New-Object System.Drawing.Size(80, 25)
$NewButton.Text = "New"
$NewButton.Add_Click($NewClick)
$Form.Controls.Add($NewButton)

# -- Adding Open button
$OpenButton = New-Object System.Windows.Forms.Button
$OpenButton.Location = New-Object System.Drawing.Size(130, 150)
$OpenButton.Size = New-Object System.Drawing.Size(80, 25)
$OpenButton.Text = "Open"
$OpenButton.Add_Click($OpenClick)
$Form.Controls.Add($OpenButton)

# -- Adding Save button
$SaveButton = New-Object System.Windows.Forms.Button
$SaveButton.Location = New-Object System.Drawing.Size(220, 150)
$SaveButton.Size = New-Object System.Drawing.Size(80, 25)
$SaveButton.Text = "Save"
$SaveButton.Add_Click($SaveClick)
$Form.Controls.Add($SaveButton)

# -- Adding SaveAs button
$SaveAsButton = New-Object System.Windows.Forms.Button
$SaveAsButton.Location = New-Object System.Drawing.Size(310, 150)
$SaveAsButton.Size = New-Object System.Drawing.Size(80, 25)
$SaveAsButton.Text = "Save As"
$SaveAsButton.Add_Click($SaveAsClick)
$Form.Controls.Add($SaveAsButton)

# -- Adding Optimize route button
$OptimizeButton = New-Object System.Windows.Forms.Button
$OptimizeButton.Location = New-Object System.Drawing.Size(430, 150)
$OptimizeButton.Size = New-Object System.Drawing.Size(160, 25)
$OptimizeButton.Text = "Optimize route!"
$OptimizeButton.Add_Click($OptimizeRoute)
$Form.Controls.Add($OptimizeButton)

# -- Adding search label
$SearchLabel = New-Object System.Windows.Forms.label
$SearchLabel.Location = New-Object System.Drawing.Point(40, 195)
$SearchLabel.size = New-Object System.Drawing.Size(300, 25)
$SearchLabel.font = $Font
$SearchLabel.text = "Search Systems"
$Form.Controls.Add($SearchLabel)

# -- Add search box
Write-Host 'Adding systems to Auto Complete Source'

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(40, 220)
$textBox.Size = New-Object System.Drawing.Size(225, 25)
$textBox.AutoCompleteMode = 'SuggestAppend'
$textBox.AutoCompleteSource = 'CustomSource'
Get-content $('{0}\{1}' -f $PSScriptRoot, 'systems.csv') | ForEach-Object { $textbox.AutoCompleteCustomSource.AddRange($_) }
$Form.Controls.Add($textBox)

# -- Adding WP add button
$SearchButton = New-Object System.Windows.Forms.Button
$SearchButton.Location = New-Object System.Drawing.Size(275, 220)
$SearchButton.Size = New-Object System.Drawing.Size(140, 25)
$SearchButton.Text = "Add Waypoint"
$SearchButton.Add_Click($WPAddClick)
$Form.Controls.Add($SearchButton)

# -- Adding common location label
$ComLocLabel = New-Object System.Windows.Forms.label
$ComLocLabel.Location = New-Object System.Drawing.Point(40, 265)
$ComLocLabel.size = New-Object System.Drawing.Size(300, 25)
$ComLocLabel.font = $Font
$ComLocLabel.text = "Common Locations"
$Form.Controls.Add($ComLocLabel)

# -- Add commen locatiosn box
Write-Host 'Populating common locations'

$LocListBox = New-Object System.Windows.Forms.ComboBox
$LocListBox.Location = New-Object System.Drawing.Point(40, 290)
$LocListBox.Size = New-Object System.Drawing.Size(375, 25)
$LocListBox.name = 'Loc_Box'
$LocListBox.DropDownStyle = 'DropDownList'
# -- read commen locations CSV
$ComLocs = Import-Csv $('{0}\{1}' -f $PSScriptRoot, 'Common_locations.csv')

# -- Distinct list of groups
$groups = $ComLocs.group | Sort-Object -unique

$first_group = $True
ForEach ($group in $groups) {

	If ($first_group -eq $False) {
		$LocListBox.items.add('') | Out-Null
	}
	Else {
		$first_group = $False
	}

	$LocListBox.items.add($('--- {0} ---' -f $group)) | Out-Null
	$LocListBox.items.add('') | Out-Null
	$locs = $ComLocs | Where-Object { $_.group -eq $group }

	ForEach ($loc in $locs) {
		$LocListBox.items.add($('{0} - {1}' -f $loc.name, $loc.system)) | Out-Null
	}
}
$LocListBox.add_SelectedIndexChanged($LocListSelectEvent)
$Form.Controls.Add($LocListBox)

# -- Adding Promo label
$PromoLabel = New-Object System.Windows.Forms.label
$PromoLabel.Location = New-Object System.Drawing.Point(40, 580)
$PromoLabel.size = New-Object System.Drawing.Size(350, 50)
$PromoLabel.font = $(New-Object System.Drawing.Font("Times New Roman", 14))
$PromoLabel.text = "Find this tool usefull? `nThen make a small donation, Thank you!"
$Form.Controls.Add($PromoLabel)

# -- Adding Paypal img
$Paypal = [System.Drawing.Image]::Fromfile("$Root_path\Elements\paypal.png")
$PaypalImg = new-object Windows.Forms.PictureBox
$PaypalImg.Location = New-Object System.Drawing.Point(40, 645)
$PaypalImg.Width = 50
$PaypalImg.Height = 50
$PaypalImg.SizeMode = 'Zoom'
$PaypalImg.Add_Click( { Start-Process "https://www.paypal.me/D2EA" })
$PaypalImg.Image = $Paypal
$Form.controls.add($PaypalImg)

# -- Adding Patreon img
$Patreon = [System.Drawing.Image]::Fromfile("$Root_path\Elements\patreon.png")
$PatreonImg = new-object Windows.Forms.PictureBox
$PatreonImg.Location = New-Object System.Drawing.Point(110, 645)
$PatreonImg.Width = 50
$PatreonImg.Height = 50
$PatreonImg.SizeMode = 'Zoom'
$PatreonImg.Add_Click( { Start-Process "https://www.patreon.com/downtoearthastronomy" })
$PatreonImg.Image = $Patreon
$Form.controls.add($PatreonImg)

# -- Adding System Settings box
$SysSetBox = New-Object System.Windows.Forms.DataGridView
$SysSetBox.Location = New-Object System.Drawing.Size(430, 185)
$SysSetBox.size = New-Object System.Drawing.Size(430, 475)
$SysSetBox.AllowUserToAddRows = $False
$SysSetBox.AllowUserToDeleteRows = $True
$SysSetBox.ColumnHeadersVisible = $True
$SysSetBox.RowHeadersVisible = $False
$SysSetBox.SelectionMode = 'FullRowSelect'
$SysSetBox.BackgroundColor = 'White'

$SysSetBox.Add_CellContentClick($SysSetBoxClick)
$SysSetBox.Add_UserDeletingRow($SysSetBoxDelete)

$Column = New-Object System.Windows.Forms.DataGridViewTextboxColumn
$Column.name = 'System'
$Column.width = 275
$Column.ReadOnly = $True
$SysSetBox.Columns.Add($Column) | Out-Null

$Column = New-Object System.Windows.Forms.DataGridViewCheckBoxColumn
$Column.name = 'Start'
$Column.width = 60
$SysSetBox.Columns.Add($Column) | Out-Null

$Column = New-Object System.Windows.Forms.DataGridViewCheckBoxColumn
$Column.name = 'End'
$Column.width = 60
$SysSetBox.Columns.Add($Column) | Out-Null

$Column = New-Object System.Windows.Forms.DataGridViewImageColumn
$Column.name = ''
$Column.width = 30

$Copy_icon = [System.Drawing.Image]::Fromfile("$Root_path\Elements\copy_icon.png")
$Column.image = $Copy_icon
$SysSetBox.Columns.Add($Column) | Out-Null

$Form.Controls.Add($SysSetBox)

# -- Adding Length label
$LengthLabel = New-Object System.Windows.Forms.label
$LengthLabel.Location = New-Object System.Drawing.Point(430, 670)
$LengthLabel.size = New-Object System.Drawing.Size(350, 50)
$LengthLabel.font = $(New-Object System.Drawing.Font("Times New Roman", 14))
$LengthLabel.text = "Total Route Length: 0 Ly"
$Form.Controls.Add($LengthLabel)

Write-Host 'Form Completed'

Stop-Process -InputObject $SplashProcess

$Form.ShowDialog()
