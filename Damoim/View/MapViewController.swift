//
//  MapViewController.swift
//  Damoim
//
//  Created by 조규연 on 8/27/24.
//

import UIKit
import KakaoMapsSDK

final class MapViewController: BaseMapViewController {
    private let viewModel: MapViewModel
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addViews() {
        let defaultPosition: MapPoint = MapPoint(longitude: 127.0016985, latitude: 37.5642135)
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 7)
        
        mapController?.addView(mapviewInfo)
    }
    
    override func viewInit(viewName: String) {
        print("OK")
        createLodLabelLayer()
        createLodPois()
    }
    
    func createLodLabelLayer() {
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        // LodLabelLayer를 생성하기 위한 Option.
        // LodLayer에서는 효율적인 계산을 위해 POI의 중심에서 일정 반경(radius, 단위 : pixel)의 원으로 겹치는지를 확인한다.
        let custom = LodLabelLayerOptions(layerID: "custom", competitionType: .sameLower, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 10000, radius: _radius)
        
        let _ = manager.addLodLabelLayer(option: custom)
    }
    
    func createLodPois() {
        let input = MapViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.posts.forEach {
            loadImageAndAddMarker(for: $0)
        }
    }
    
    override func containerDidResized(_ size: CGSize) {
        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
        mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
    }
    
    var _radius: Float = 20.0
    
}

extension MapViewController {
    func loadImageAndAddMarker(for post: PostItem) {
        guard let imageURL = post.files.first else { return }
        
        NetworkManager.shared.fetchImage(parameter: imageURL) { [weak self] result in
            switch result {
            case .success(let imageData):
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self?.addMarker(for: post, with: image)
                    }
                }
            case .failure(let error):
                print("Failed to fetch image for post \(post.post_id): \(error)")
            }
        }
    }
    
    func addMarker(for post: PostItem, with image: UIImage) {
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        
        guard let resizedImage = image.resize(to: CGSize(width: 20, height: 20)) else {
            return
        }
        
        _radius = Float(resizedImage.size.width / 2.0)
        let anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let iconStyle = PoiIconStyle(symbol: resizedImage, anchorPoint: anchorPoint)
        
        let textLineStyles = [
            PoiTextLineStyle(textStyle: TextStyle(fontSize: 15, fontColor: UIColor.white, strokeThickness: 2, strokeColor: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)))
        ]
        
        let textStyle = PoiTextStyle(textLineStyles: textLineStyles)
        textStyle.textLayouts = [.bottom]
        let poiStyle = PoiStyle(styleID: "customStyle-\(post.post_id)", styles: [
            PerLevelPoiStyle(iconStyle: iconStyle, textStyle: textStyle, padding: -2.0, level: 0)
        ])
        
        manager.addPoiStyle(poiStyle)
        
        let options = PoiOptions(styleID: "customStyle-\(post.post_id)")
        options.transformType = .decal
        options.clickable = true
        options.addText(PoiText(text: post.title, styleIndex: 0))
        
        let mapPoint = MapPoint(longitude: post.coordinate.longitude, latitude: post.coordinate.latitude)
        
        if let layer = manager.getLodLabelLayer(layerID: "custom") {
            let poiAddResult = layer.addLodPois(options: [options], at: [mapPoint])
            layer.showAllLodPois()
        } else {
            print("LodLabelLayer 초기화 실패")
        }
    }
}
