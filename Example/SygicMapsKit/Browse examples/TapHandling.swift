//// TapHandling.swift
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

import UIKit
import SygicMaps
import SygicMapsKit


class CustomDataHandlingViewController: UIViewController, SYMKModulePresenter {
    
    var presentedModules = [SYMKModuleViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Custom Tap Handling Example"
        
        let browseMap = SYMKBrowseMapViewController()
        browseMap.mapState.geoCenter = SYGeoCoordinate(latitude: 48.147128, longitude: 17.103641)
        browseMap.mapState.zoom = 16
        browseMap.delegate = self
        browseMap.mapSelectionMode = .all
        presentModule(browseMap)
    }
    
}

extension CustomDataHandlingViewController: SYMKBrowseMapViewControllerDelegate {
    
    func browseMapController(_ browseController: SYMKBrowseMapViewController, didSelect data: SYMKPlaceDataProtocol) {
        let alert = UIAlertController(title: nil, message: "\(data)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func browseMapControllerShouldAddPinOnTap(_ browseController: SYMKBrowseMapViewController, coordinates: SYGeoCoordinate) -> SYMKMapPin? {
        return nil
    }
    
    func browseMapControllerShouldPresentDefaultPoiDetail(_ browseController: SYMKBrowseMapViewController) -> Bool {
        return false
    }
    
}
