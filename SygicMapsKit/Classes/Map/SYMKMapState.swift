//// SYMKMapState.swift
//
// Copyright (c) 2019 - Sygic a.s.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the &quot;Software&quot;), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import SygicMaps

/// Map zoom constants
public enum SYMKMapZoomLevels: CGFloat {
    /// Earth level
    case level0 = 0
    case level1 = 1
    case level2 = 2
    case level3 = 3
    case level4 = 4
    case level5 = 5
    case level6 = 6
    case level7 = 7
    case level8 = 8
    case level9 = 9
    /// City
    case level10 = 10
    case level11 = 11
    case level12 = 12
    case level13 = 13
    case level14 = 14
    case level15 = 15
    case level16 = 16
    /// Street level
    case level17 = 17
    case level18 = 18
    case level19 = 19
    case level20 = 20
    case level21 = 21
    case level22 = 22
    
    /// Default initial zoom level
    public static var cityZoom: CGFloat {
        return SYMKMapZoomLevels.level10.rawValue
    }
    
    public static var streetsZoom: CGFloat {
        return SYMKMapZoomLevels.level17.rawValue
    }
}

/// Implement MapControl protocol for update components with new state based on map changes.
internal protocol MapControl {
    func update(with mapState: SYMKMapState)
}

/// Map state class holds state of map.
public class SYMKMapState: NSCopying {
    
    // MARK: - Public Properties
    
    /// Map to which a state belongs.
    ///
    /// When you pass map state between multiple modules, you can pass `SYMapView` as
    /// well, so you don't need to allocate new `SYMapView` object. You will prevent
    /// black screen, the moment while `SYMapView` is allocated.
    public var map: SYMapView?
    
    /// Center of a map
    public var geoCenter: SYGeoCoordinate = SYGeoCoordinate(latitude: 0, longitude: 0) {
        didSet {
            if map?.camera.geoCenter != geoCenter {
                map?.camera.geoCenter = geoCenter
            }
        }
    }
    
    /// Zoom of a map.
    public var zoom: CGFloat = 0 {
        didSet {
            if map?.camera.zoom != zoom {
                map?.camera.zoom = zoom
            }
        }
    }
    
    /// Rotation of a map.
    public var rotation: CGFloat = 0 {
        didSet {
            if map?.camera.rotation != rotation {
                map?.camera.rotation = rotation
            }
        }
    }
    
    /// Tilt of a map.
    public var tilt: CGFloat = 0 {
        didSet {
            if map?.camera.tilt != tilt {
                map?.camera.tilt = tilt
            }
        }
    }
    
    /// Camera movement mode. Default is `.free`.
    public var cameraMovementMode: SYCameraMovement = .free {
        didSet {
            if map?.camera.movementMode != cameraMovementMode {
                map?.camera.movementMode = cameraMovementMode
            }
        }
    }
    
    /// Camera rotation mode. Default is `.free`.
    public var cameraRotationMode: SYCameraRotation = .free {
        didSet {
            if map?.camera.rotationMode != cameraRotationMode {
                map?.camera.rotationMode = cameraRotationMode
            }
        }
    }
    
    /// Returns, whether tilt is 3D or not.
    public var isTilt3D: Bool {
        return tilt >= 0.01
    }
    
    // MARK: Skins
    
    public enum MapSkins: String {
        /// Light map appearance
        case day
        /// Dark map appearance
        case night
        /// Day / night map skin is chosen by device appearance light / dark setting
        case device
    }
    
    public enum UsersLocationSkins: String {
        case pedestrian
        case car
    }
    
    /// Map appearance
    public var mapSkin: MapSkins = .device {
        didSet {
            map?.activeSkins = activeSkins
        }
    }
    
    /// User location indicator appearance
    public var userLocationSkin: UsersLocationSkins = .car {
        didSet {
            map?.activeSkins = activeSkins
        }
    }
    
    // MARK: - Private properties
    
    internal var activeSkins: [String] {
        var skins: [String] = []
        guard let map = map else { return [] }
        if #available(iOS 12.0, *) {
            if mapSkin == .night || (mapSkin == .device && map.traitCollection.userInterfaceStyle == .dark) {
                skins.append(MapSkins.night.rawValue)
            } else {
                skins.append(MapSkins.day.rawValue)
            }
        } else {
            skins.append(mapSkin.rawValue)
        }
        if userLocationSkin == .pedestrian {
            skins.append(userLocationSkin.rawValue)
        }
        return skins
    }
    
    // MARK: - Public methods
    
    /// Returns SYMKMapState instance with default values for navigation map module
    public static func navigationMapState() -> SYMKMapState {
        let mapState = SYMKMapState()
        mapState.cameraMovementMode = .followGpsPositionWithAutozoom
        mapState.cameraRotationMode = .vehicle
        mapState.tilt = 60.0
        return mapState
    }
    
    /// Initializes and returns map. If map isn't already initialized, returns new map instance with defined state values.
    ///
    /// - Parameter frame: Initial frame of a map. Default is `CGRect.zero`.
    /// - Returns: Loaded `SYMapView` object.
    public func loadMap(with frame: CGRect = .zero) -> SYMapView {
        if let initializedMap = map {
            return initializedMap
        } else {
            map = SYMapView(frame: frame, geoCenter: geoCenter, rotation: rotation, zoom: zoom, tilt: tilt)
            map?.accessibilityLabel = "Map"
            resetMapCenter(duration: 0)
            map?.setup(with: self)
            return map!
        }
    }
    
    /// Sets visible map rectangle defined by parameters
    ///
    /// - Parameters:
    ///   - boundingBox: visible bounding box to be set
    ///   - edgeInsets: map edge insets around visible bounding box (in relative screen coordinates <0,1>)
    ///   - duration: map transition animation duration
    ///   - completion: completion block pass false when bounding box cannot be set or animation was canceled. True otherwise after animation was completed.
    public func setMapBoundingBox(_ boundingBox: SYGeoBoundingBox, edgeInsets: UIEdgeInsets, duration: TimeInterval = 0, completion: ((_ success: Bool)->())? = nil) {
        guard let map = map, map.bounds != .zero else { return }
        let properties = map.camera.calculateProperties(for: boundingBox,
                                                        transformCenter: CGPoint(x: 0.5, y: 0.5),
                                                        rotation: 0,
                                                        tilt: 0,
                                                        maxZoomLevel: SYMKMapZoomLevels.streetsZoom,
                                                        edgeInsets: edgeInsets)
        guard properties.geoCenter.isValid() else { return }
        if duration > 0 {
            map.camera.animate({ [weak self] in
                self?.applyMapProperties(properties)
            }, withDuration: duration, curve: .accelerateDecelerate, completion: { (_, success) in
                completion?(success)
            })
        } else {
            applyMapProperties(properties)
            completion?(true)
        }
    }
    
    /// Updates map camera offset to optimize view for navigating
    /// - Parameter landscape: layout orientation
    public func updateNavigatingMapCenter(_ landscape: Bool) {
        guard let camera = map?.camera else { return }
        let point = landscape ? CGPoint(x: 0.7, y: 0.2) : CGPoint(x: 0.5, y: 0.25)
        let offsetSetting = SYTransformCenterSettings(transformCenterFree: point,
                                                      animationCurveFree: .linear,
                                                      animationDurationFree: 0,
                                                      transformCenterFollowGps: point,
                                                      animationCurveFollowGps: .linear,
                                                      animationDurationFollowGps: 0)
        camera.setTransformCenterSettings(offsetSetting, withDuration: 1, curve: .accelerateDecelerate)
    }
    
    /// Updates map camera offset to optimize view for navigating
    /// - Parameter landscape: layout orientation
    public func updateMapCenter(_ landscape: Bool) {
        guard let camera = map?.camera else { return }
        let point = landscape ? CGPoint(x: 0.7, y: 0.5) : CGPoint(x: 0.5, y: 0.5)
        let offsetSetting = SYTransformCenterSettings(transformCenterFree: point,
                                                      animationCurveFree: .linear,
                                                      animationDurationFree: 0,
                                                      transformCenterFollowGps: point,
                                                      animationCurveFollowGps: .linear,
                                                      animationDurationFollowGps: 0)
        camera.setTransformCenterSettings(offsetSetting, withDuration: 1, curve: .accelerateDecelerate)
    }
    
    /// Resets map camera offset to standard map center in the middle of SYMapView
    public func resetMapCenter(duration: TimeInterval = 1) {
        guard let camera = map?.camera else { return }
        let defaultOffset = CGPoint(x: 0.5, y: 0.5)
        let offsetSetting = SYTransformCenterSettings(transformCenterFree: defaultOffset,
                                                      animationCurveFree: .linear,
                                                      animationDurationFree: 0,
                                                      transformCenterFollowGps: defaultOffset,
                                                      animationCurveFollowGps: .linear,
                                                      animationDurationFollowGps: 0)
        camera.setTransformCenterSettings(offsetSetting, withDuration: duration, curve: .accelerateDecelerate)
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = SYMKMapState()
        copy.map = map
        copy.geoCenter = geoCenter
        copy.zoom = zoom
        copy.rotation = rotation
        copy.tilt = tilt
        copy.cameraMovementMode = cameraMovementMode
        copy.cameraRotationMode = cameraRotationMode
        copy.userLocationSkin = userLocationSkin
        copy.mapSkin = mapSkin
        return copy
    }

    // MARK: - Private methods
    
    private func applyMapProperties(_ properties: SYCameraProperties) {
        geoCenter = properties.geoCenter
        tilt = properties.tilt
        rotation = properties.rotation
        zoom = properties.zoom
    }
}

extension SYMapView {
    
    /// Set up map with new state.
    ///
    /// - Parameter mapState: State for map.
    public func setup(with mapState: SYMKMapState) {
        camera.geoCenter = mapState.geoCenter
        camera.zoom = mapState.zoom
        camera.rotation = mapState.rotation
        camera.tilt = mapState.tilt
        camera.movementMode = mapState.cameraMovementMode
        camera.rotationMode = mapState.cameraRotationMode
        activeSkins = mapState.activeSkins
    }
    
}
