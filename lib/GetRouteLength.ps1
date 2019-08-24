Function GetRouteLength($TestRoute, $SystemDistanceArray) {

	$TestRouteLenght = $TestRoute.count
	$RouteLength = 0

	For ($i = 0; $i -lt ($TestRouteLenght - 1); $i++) {
		$RouteLength += $SystemDistanceArray[$TestRoute[$i].ID, $TestRoute[$i + 1].ID]
	}

	Return $RouteLength
}
