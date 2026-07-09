import SwiftUI
import MapKit

struct GameMapView: View {
    @StateObject private var locationService = LocationService.shared
    @StateObject private var sessionStore = GameSessionStore.shared
    
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    )
    
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
                    UserAnnotation()
                    
                    ForEach(sessionStore.sessions) { session in
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
                    MapUserLocationButton()
                    MapCompass()
                }
                .frame(height: 300)
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 25)
                
                Text(locationService.permissionText)
                    .font(.caption)
                    .foregroundColor(.black)
                
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
            moveMapToCurrentLocation()
        }
        .onChange(of: locationService.currentLocation) {
            moveMapToCurrentLocation()
        }
    }
    
    private func moveMapToCurrentLocation() {
        guard let location = locationService.currentLocation else { return }
        
        cameraPosition = .region(
            MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
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
