[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

$Root_path = $('{0}\..' -f $PSScriptRoot)

$Font = New-Object System.Drawing.Font("Times New Roman", 14)

# -- Create Splash screen
$SplashImg = [System.Drawing.Image]::Fromfile("$Root_path\Elements\Splash.png")

$splash = New-Object System.Windows.Forms.Form
$splash.Text = "D2EA Multi-Waypoint - splash"
$splash.Size = New-Object System.Drawing.Size($SplashImg.Size.Width, $SplashImg.Size.Height)
$splash.StartPosition = "CenterScreen"
$splash.MinimizeBox = $False
$splash.MaximizeBox = $False
$splash.Topmost = $True
$splash.FormBorderStyle = 'None'
$splash.Font = $Font

# -- Add image to screen
$SplashBox = new-object Windows.Forms.PictureBox
$SplashBox.Width = $SplashImg.Size.Width
$SplashBox.Height = $SplashImg.Size.Height
$SplashBox.Image = $SplashImg
$splash.controls.add($SplashBox)

$splash.ShowDialog()
