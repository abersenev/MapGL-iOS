import CoreLocation
import UIKit.UIColor

/// Style to draw a line
open class PolylineStyle {
	let color: UIColor
	let width: CGFloat
	let z: Int?

	/// Represents line style
	/// - Parameters:
	///   - color: Line stroke color
	///   - width: Stroke width in screen points.
	///   - z: Draw order.
	public init(color: UIColor, width: CGFloat, z: Int? = nil) {
		self.color = color
		self.width = width
		self.z = z
	}
}

/// Polyline map object
open class Polyline: MapObject {

	/// An array of polyline coordinates
	public let points: [CLLocationCoordinate2D]
	/// Topmost line style
	let style1: PolylineStyle?
	/// Middle line style, should be wider than style1
	let style2: PolylineStyle?
	/// Bottom line style, should be wider than style2
	let style3: PolylineStyle?

	/// Creates new polyline on map
	/// Can be draw using 3 different styles
	/// - Parameters:
	///   - id: Unique object id
	///   - points: An array of polyline coordinates
	///   - style1: Top level style, if missing use default width and color do draw a line
	///   - style2: Second level style if needed
	///   - style3: Third level style if needed
	public init(
		id: String = UUID().uuidString,
		points: [CLLocationCoordinate2D],
		style1: PolylineStyle? = nil,
		style2: PolylineStyle? = nil,
		style3: PolylineStyle? = nil
	) {
		assert(points.count > 1, "Polyline should countain more than 1 point")
		self.points = points
		self.style1 = style1
		self.style2 = style2
		self.style3 = style3
		super.init(id: id)
	}

}

extension Polyline: IJSOptions {
	func jsKeyValue() -> JSOptionsDictionary {
		return [
			"id": self.id,
			"coordinates": self.points,
			"color": self.style1?.color,
			"width": self.style1?.width,
			"zIndex": self.style1?.z,
			"color2": self.style2?.color,
			"width2": self.style2?.width,
			"zIndex2": self.style2?.z,
			"color3": self.style3?.color,
			"width3": self.style3?.width,
			"zIndex3": self.style3?.z,
		]
	}

	override func createJSCode() -> String {
		let js = """
		window.addPolyline(\(self.jsValue()));
		"""
		return js
	}

}
