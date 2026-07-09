import SwiftUI
import MapKit

struct GameMapView: View {
    @StateObject private var locationService = LocationService.shared
    @StateObject private var sessionStore = GameSessionStore.shared
    
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0),
            span: MKCoordinateSpan(latitudeDelta: 80.0, longitudeDelta: 80.0)
        )
    )
    
    private var pinnedSessions: [GameSession] {
        sessionStore.sessions.filter { $0.accuracy > 0 }
    }
    
    var body: some View {
        ZStack {
            Image("back2")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.6)
            
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Map")
                        .font(.system(size: 50, weight: .black))
                        .foregroundColor(.black)
                        .fontDesign(.serif)
                    
                    Text("Places where you completed games")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                .padding(.top, 30)
                
                Map(position: $cameraPosition) {
                    if locationService.isLocationAllowed {
                        UserAnnotation()
                    }
                    
                    ForEach(pinnedSessions) { session in
                        Marker(
                            "\(session.gameName) - \(session.score) pts",
                            coordinate: CLLocationCoordinate2D(
                                latitude: session.latitude,
                                longitude: session.longitude
                            )
                        )
                        .tint(.purple)
                    }
                }
                .mapControls {
                    if locationService.isLocationAllowed {
                        MapUserLocationButton()
                    }
                    MapCompass()
                }
                .frame(height: 300)
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 25)
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(locationService.permissionText)
                            .font(.caption)
                            .foregroundColor(.black)
                        
                        Text(locationService.accuracyText)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    if !sessionStore.sessions.isEmpty {
                        Button("Clear History") {
                            sessionStore.clearSessions()
                        }
                        .font(.caption)
                        .bold()
                        .foregroundColor(.purple)
                    }
                }
                
                if sessionStore.sessions.isEmpty {
                    Text("Finish a game to add a pin to the map.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 25)
                } else {
                    if pinnedSessions.isEmpty {
                        Text("Saved games need location permission before they can appear as map pins.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(18)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .padding(.horizontal, 25)
                    }
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(sessionStore.sessions.reversed()) { session in
                                MapSessionCard(session: session)
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                }
                
                Spacer()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            locationService.requestLocation()
            moveMapToBestLocation()
        }
        .onChange(of: locationService.currentLocation) {
            moveMapToBestLocation()
        }
        .onChange(of: sessionStore.sessions.count) {
            moveMapToBestLocation()
        }
    }
    
    private func moveMapToBestLocation() {
        if let location = locationService.currentLocation,
           location.horizontalAccuracy > 0,
           location.horizontalAccuracy <= 100 {
            setMapCenter(location.coordinate)
        } else if let lastSession = pinnedSessions.last {
            let coordinate = CLLocationCoordinate2D(
                latitude: lastSession.latitude,
                longitude: lastSession.longitude
            )
            setMapCenter(coordinate)
        }
    }
    
    private func setMapCenter(_ coordinate: CLLocationCoordinate2D) {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
            )
        )
    }
}

struct MapSessionCard: View {
    let session: GameSession
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.purple)
                .cornerRadius(15)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.gameName)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.black)
                
                Text(session.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if session.accuracy > 0 {
                    Text("Accuracy about \(Int(session.accuracy))m")
                        .font(.caption2)
                        .foregroundColor(.gray)
                } else {
                    Text("No map pin - location was not captured")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Text("\(session.score)")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundColor(.purple)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NavigationStack {
        GameMapView()
    }
}
