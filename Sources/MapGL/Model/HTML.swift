enum HTML {
	static let html = """
<!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="UTF-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0" />
	<meta http-equiv="X-UA-Compatible" content="ie=edge" />
	<style>
		html,
		body,
		#map {
			margin: 0;
			width: 100%;
			height: 100%;
			overflow: hidden;
		}
	</style>

</head>

<body>
	<div id="map"></div>
	<script>
		window.onerror = (msg, url, line, column, error) => {
			const message = {
				message: msg,
				url: url,
				line: line,
				column: column,
				error: JSON.stringify(error)
			}
			if (window.webkit) {
				window.webkit.messageHandlers.error.postMessage(message);
			} else {
				console.log("Error:", message);
			}
		};
	</script>
	<script src="https://mapgl.2gis.com/api/js"></script>
	<script src="https://unpkg.com/@2gis/mapgl-clusterer@^1/dist/clustering.js"></script>
	<script src="https://unpkg.com/@2gis/mapgl-directions@^1/dist/directions.js"></script>
	<script>
		const postMessage = (name, args) => {
			window.webkit.messageHandlers.dgsMessage.postMessage({
				type: name,
				value: args
			});
		};

		try {
			var objects = new Map();
			var directionsMap = new Map();
			let selectedIds = [];
			const container = document.getElementById('map');
			window.initializeMap = function(options) {
				window.map = new mapgl.Map(container, options);
				window.map.on('click', (ev) => {
					window.webkit.messageHandlers.dgsMessage.postMessage({
						type: "mapClick",
						value: JSON.stringify(ev)
					});
				});

				window.map.on('centerend', (ev) => {
					window.webkit.messageHandlers.dgsMessage.postMessage({
						type: "centerChanged",
						value: window.map.getCenter()
					});
				});

				window.map.on('zoomend', (ev) => {
					window.webkit.messageHandlers.dgsMessage.postMessage({
						type: "zoomChanged",
						value: window.map.getZoom()
					});
					window.webkit.messageHandlers.dgsMessage.postMessage({
						type: "styleZoomChanged",
						value: window.map.getStyleZoom()
					});
				});

				window.map.on('rotationend', (ev) => {
					window.webkit.messageHandlers.dgsMessage.postMessage({
						type: "rotationChanged",
						value: window.map.getRotation()
					});
				});

				window.map.on('pitchend', (ev) => {
					window.webkit.messageHandlers.dgsMessage.postMessage({
						type: "pitchChanged",
						value: window.map.getPitch()
					});
				});

				window.map.on('floorplanshow', (ev) => {
					window.webkit.messageHandlers.dgsMessage.postMessage({
						type: "floorPlanShow",
						value: ev
					});
				});

				window.map.on('floorplanhide', (ev) => {
					window.webkit.messageHandlers.dgsMessage.postMessage({
						type: "floorPlanHide",
						value: ev
					});
				});
			}
			window.addMarker = function (options) {
				const marker = new mapgl.Marker(window.map, options);
				window.setupObject(options.id, marker);
			}
			window.addCircleMarker = function (options) {
				const marker = new mapgl.CircleMarker(window.map, options);
				window.setupObject(options.id, marker);
			}
			window.addCluster = function (id, radius, markers) {
				const clusterer = new mapgl.Clusterer(window.map, {
					radius: radius,
				});
				clusterer.__id = id
				clusterer.on('click', (event) => {
					window.webkit.messageHandlers.dgsMessage.postMessage({
						type: "clusterClick",
						value: event.target.data,
						id: id
					});
				});
				objects.set(id, clusterer);
				window.updateCluster(id, markers);
			}
			window.updateCluster = function (id, markers) {
				const clusterer = objects.get(id);
				clusterer.load(markers);
			}
			window.hideObject = function (id) {
				const object = objects.get(id);
				object.hide();
			}
			window.showObject = function (id) {
				const marker = objects.get(id);
				marker.show();
			}
			window.selectObject = function (id) {
				if (!selectedIds.includes(id)) {
					selectedIds.push(id);
					window.map.setSelectedObjects(selectedIds);
				}
			}
			window.deselectObject = function (id) {
				if (selectedIds.includes(id)) {
					ids = selectedIds.filter((i) => i !== id);
					window.setSelectedObjects(ids);
				}
			}
			window.setSelectedObjects = function (ids) {
				selectedIds = ids;
				window.map.setSelectedObjects(selectedIds);
			}
			window.setStyle = function (id) {
				window.map.setStyleById(id);
			}
			window.setStyleState = function (styleState) {
				window.map.setStyleState(styleState);
			}
			window.patchStyleState = function (styleState) {
				window.map.patchStyleState(styleState);
			}
			window.setPadding = function (padding) {
				window.map.setPadding(padding);
			}
			window.setLanguage = function (language) {
				window.map.setLanguage(language);
			}
			window.setFloorPlanLevel = function (floorPlanId, floorLevelIndex) {
				window.map.setFloorPlanLevel(floorPlanId, floorLevelIndex);
			}
			window.setMarkerCoordinates = function (id, coordinates) {
				const marker = objects.get(id);
				marker.setCoordinates(coordinates);
			}
			window.addPolygon = function (options) {
				const polygon = new mapgl.Polygon(window.map, options);
				window.setupObject(options.id, polygon);
			}
			window.addCircle = function (options) {
				const circle = new mapgl.Circle(window.map, options);
				window.setupObject(options.id, circle);
			}
			window.addPolyline = function (options) {
				const polyline = new mapgl.Polyline(window.map, options);
				window.setupObject(options.id, polyline);
			}
			window.addLabel = function (options) {
				const label = new mapgl.Label(window.map, options);
				window.setupObject(options.id, label);
			}
			window.destroyObject = function (id) {
				const object = objects.get(id);
				object.destroy();
				objects.delete(id);
			}
			window.setupObject = function (id, object) {
				object.__id = id;
				objects.set(id, object);
				object.on('click', (event) => {
					window.webkit.messageHandlers.dgsMessage.postMessage({
						type: "objectClick",
						value: id
					});
				})
			}
			window.directions = function (id, directionsApiKey) {
				const direction = new mapgl.Directions(map, {
					directionsApiKey: directionsApiKey,
				});
				directionsMap.set(id, direction);
			}
			window.carRoute = function (directionId, completionId, options) {
				const direction = directionsMap.get(directionId);
				direction.carRoute(options).then(
					(value) => { postMessage("carRouteCompletion", {
						directionId: directionId,
						completionId: completionId,
						error: ""
					})},
					(reason) => { postMessage("carRouteCompletion", {
						directionId: directionId,
						completionId: completionId,
						error: reason.toString()
					})}
				);
			}
			window.pedestrianRoute = function (directionId, completionId, options) {
				const direction = directionsMap.get(directionId);
				direction.pedestrianRoute(options).then(
					(value) => { postMessage("carRouteCompletion", {
						directionId: directionId,
						completionId: completionId,
						error: ""
					})},
					(reason) => { postMessage("carRouteCompletion", {
						directionId: directionId,
						completionId: completionId,
						error: reason.toString()
					})}
				);
			}
			window.clearCarRoute = function (id) {
				const direction = directionsMap.get(id);
				direction.clear();
			}
			window.destroyDirections = function (id) {
				window.clearCarRoute(id);
				directionsMap.delete(id);
			}
			window.addEventListener('resize', () => window.map.invalidateSize());
			const support = {
				notSupportedReason: mapgl.notSupportedReason({failIfMajorPerformanceCaveat: false}),
				notSupportedWithGoodPerformanceReason: mapgl.notSupportedReason({failIfMajorPerformanceCaveat: true})
			}
			window.webkit.messageHandlers.dgsMessage.postMessage({
				type: "supportChanged",
				value: support
			});

		} catch(e) {
			const support = {
				notSupportedReason: e.toString()
			}
			window.webkit.messageHandlers.dgsMessage.postMessage({
				type: "supportChanged",
				value: support
			});
		}
	</script>
</body>

</html>
"""
}
