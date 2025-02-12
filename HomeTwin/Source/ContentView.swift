import SwiftUI
import MapboxMaps

struct ContentView: View {
    
    let home = HomeController()
    let coordinateBounds = Utils.getCoordinateBoundsFromPlist()!
    
    var body: some View {
        MapReader { proxy in
            Map().mapStyle(.streets).cameraBounds(CameraBoundsOptions(bounds: coordinateBounds, minZoom: 16)).onStyleLoaded { _ in
                guard let map = proxy.map else { return }
                // Bit of force unwrapping since we should always have these images
                try! map.addImage(UIImage(named: "lamp_off")!, id: "lamp_off")
                try! map.addImage(UIImage(named: "lamp_on")!, id: "lamp_on")
                try! map.addImage(UIImage(named: "stairs")!, id: "stairs")
                home.map = map
            }.onMapTapGesture(perform: { context in
                home.mapTapped(context)
            }).onMapLoaded(action: { _ in
                proxy.map?.loadStyle(createStyle())
            })
            .ignoresSafeArea()
        }
    }
    
    func createStyle() -> String {
        var style = Utils.loadFileFromBundle(fileName: "style", fileType: "json")
        let source = Utils.loadFileFromBundle(fileName: "home", fileType: "geojson")
        style = style.replacingOccurrences(of: "\"sources\": {}", with: """
            "sources": {
                "home": {
                    "type": "geojson",
                    "minzoom": 16,
                    "tolerance": 0.0,
                    "lineMetrics": true,
                    "data": \(source)
                }
            }
        """)
        return style
    }
}

#Preview {
    ContentView()
}
