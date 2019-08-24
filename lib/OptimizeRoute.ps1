$OptimizeRoute = {

	$SystemsInRoute = $SysSetBox.Rows.count

	If ($SystemsInRoute -gt 1) {
		$HasFirst = $Flase
		$HasLast = $False

		# give the use a warning
		$DoRun = [Microsoft.VisualBasic.Interaction]::MsgBox("You are about optimize you route. `n This will alter the order of you selected systems `n Do you wish to Continue?", 'YesNo,Question', "Create New Route?")

		If ($DoRun -eq 'yes') {

			$Systems = @()
			$ErrorCount = 0
			$SystemID = 0

			# loop over all rows added to route
			ForEach ($Row in $SysSetBox.Rows) {

				# read system name
				$SystemName = $Row.cells[0].Value

				# get Coordinates
				$X, $Y, $Z = GetCoords $Row

				# let's see if there is any first / last systems
				$IsFirst = $False
				$IsLast = $False

				If ($Row.Cells[1].Value) {
					$HasFirst = $True
					$IsFirst = $True
				}

				If ($Row.Cells[2].Value) {
					$HasLast = $True
					$IsLast = $True
				}

				# Save row data in PSObject (easier to work with later
				$SystemsObj = New-Object -TypeName psobject -Property @{
					ID    = $SystemID
					Name  = $SystemName
					x     = $x
					y     = $y
					z     = $z
					First = $IsFirst
					Last  = $IsLast
				}
				$Systems += $SystemsObj

				$SystemID += 1
			}

			# Once all system data have been read, we make sure we didnt encounter any errors.
			# If we do we tell the user and leav hte optimizer.
			If ($ErrorCount -ne 0) {
				[Microsoft.VisualBasic.Interaction]::MsgBox($('Error encountered during system metadata load' -f $SystemName), 'OKonly', "Unknown System") | out-null
			}
			Else {
				# time to optimize the route!

				#Build system dist array
				$SystemDistanceArray = New-Object 'object[,]' $SystemsInRoute, $SystemsInRoute

				For ($i = 0; $i -lt $SystemsInRoute; $i++) {
					For ($j = 0; $j -lt $SystemsInRoute; $j++) {
						$SystemDistanceArray[$i, $j] = [math]::sqrt([math]::pow(($Systems[$i].x - $Systems[$j].x), 2) + [math]::pow(($Systems[$i].y - $Systems[$j].y), 2) + [math]::pow(($Systems[$i].z - $Systems[$j].z), 2))
					}
				}

				$Route = @()

				# add first and last system to route
				If ($HasFirst) {
					$Route += $Systems | Where-Object { $_.First -eq $True }
				}
				If ($HasLast) {
					$Route += $Systems | Where-Object { $_.Last -eq $True }
				}

				#make a list of system to loop over
				$LoopSystem = $Systems | Where-Object { ($_.First -eq $False) -and ($_.Last -eq $False) }

				ForEach ($System in $LoopSystem) {

					$BestLength = 0
					$CurrentRouteCount = $($Route.count)

					For ($i = 0; $i -le $CurrentRouteCount; $i++) {
						If ( -not (($HasFirst -and $i -eq 0) -or ($HasLast -and $i -eq $CurrentRouteCount))) {

							# build the route to test
							If ($i -eq 0) {
								$TestRoute = @($System) + $Route
							}
							ElseIf ($i -eq $CurrentRouteCount) {
								$TestRoute = $Route + $System
							}
							Else {
								$TestRoute = $Route[0..($i - 1)] + $System + $Route[$i..($CurrentRouteCount - 1)]
							}

							$CurrentRouteLength = GetRouteLength $TestRoute $SystemDistanceArray

							If (($CurrentRouteLength -lt $BestLength) -or ($BestLength -eq 0)) {
								$BestLength = $CurrentRouteLength
								$BestRoute = $TestRoute
							}
						}
					}

					$Route = $BestRoute
				}

				# No longer latest version
				$global:Saved = $False

				# clear DataGridView
				$SysSetBox.ROWS.Clear()

				$FirstSystem = $True

				ForEach ($System in $Route) {
					#Pull data for new row
					$SystemName = $System.name
					$IsFirst = $System.First
					$IsLast = $System.Last

					If ($IsFirst -and $IsLast) {
						If ($FirstSystem) {
							$IsLast = $False
						}
						Else {
							$IsFirst = $False
						}
					}

					$Coords = $('{0};{1};{2}' -f $System.x, $System.y, $System.z)

					# Yes yes yes i know. it's not pretty.
					If ($HasFirst) {
						If ($IsFirst) {
							$StartReadOnly = $False
						}
						Else {
							$StartReadOnly = $True
						}
					}
					Else {
						$StartReadOnly = $False
					}

					If ($HasLast) {
						If ($IsLast) {
							$EndReadOnly = $False
						}
						Else {
							$EndReadOnly = $True
						}
					}
					Else {
						$EndReadOnly = $False
					}

					#adding row to DataGridView
					$SysSetBox.Rows.Add($SystemName, $IsFirst, $IsLast)

					# finding row we just added
					$MaxRowIndex = $($SysSetBox.Rows.count - 1)
					$NewRow = $SysSetBox.Rows[$MaxRowIndex]

					#setting readonly state
					$NewRow.Cells[1].ReadOnly = $StartReadOnly
					$NewRow.Cells[2].ReadOnly = $EndReadOnly

					$NewRow.tag = $Coords

					$SysSetBox.EndEdit()

					$FirstSystem = $False
				}
			}
		}
	}
	UpdateRouteLength $SysSetBox $LengthLabel
}
