//
//  MapTab.swift
//  Class_Task
//
//  Created by Sohan Weerasinghe on 10/7/2026.
//

import SwiftUI
import MapKit

struct MapTab: View {
    @StateObject private var locationService = LocationService.shared
    @StateObject private var sessionStore = GameSessionStore.shared
    
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0),
            span: MKCoordinateSpan(latitudeDelta: 80.0, longitudeDelta: 80.0)
        )
    )
    @State private var selectedSessionID: GameSession.ID?
    
    private var pinnedSessions: [GameSession] {
        sessionStore.sessions.filter { $0.accuracy > 0 }
    }
    
    // Dark Theme Collr create
    private let darkBackground = Color(red: 13/255, green: 15/255, blue: 23/255)
    
    var body: some View {
        ZStack {
            
            darkBackground
                .ignoresSafeArea()
            
            // Back / Front Glow Effects
            RadialGradient(
                colors: [Color.purple.opacity(0.18), Color.clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 350
            )
            .ignoresSafeArea()
            
            RadialGradient(
                colors: [Color.cyan.opacity(0.15), Color.clear],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Header title
                VStack(spacing: 6) {
                    Text("MAP ARENA")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.cyan)
                        .tracking(3)
                    
                    Text("Game Footprint")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .cyan.opacity(0.4), radius: 8, x: 0, y: 0)
                    
                    Text("Places where you completed games")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.6))
                }
                .padding(.top, 16)
                
                // Apple Map Display Box
                Map(position: $cameraPosition, selection: $selectedSessionID) {
                    if locationService.isLocationAllowed {
                        UserAnnotation()
                    }
                    
                    ForEach(pinnedSessions) { session in
                        Marker(
                            "\(session.gameName) • \(session.score) pts",
                            coordinate: CLLocationCoordinate2D(
                                latitude: session.latitude,
                                longitude: session.longitude
                            )
                        )
                        .tint(selectedSessionID == session.id ? .yellow : .cyan)
                        .tag(session.id)
                    }
                }
                .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
                .mapControls {
                    if locationService.isLocationAllowed {
                        MapUserLocationButton()
                    }
                    MapCompass()
                }
                .frame(height: 260)
                .cornerRadius(22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 6)
                .padding(.horizontal, 20)
                
                // Status Bar & Clear Button
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(locationService.permissionText)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(locationService.accuracyText)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    if !sessionStore.sessions.isEmpty {
                        Button("Clear History") {
                            selectedSessionID = nil
                            sessionStore.clearSessions()
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.pink)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.pink.opacity(0.15))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.pink.opacity(0.4), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 24)
                
                // Empty state or list View of the Past Location of the user played
                if sessionStore.sessions.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "mappin.slash.circle")
                            .font(.system(size: 32))
                            .foregroundColor(Color.cyan.opacity(0.6))
                        
                        Text("Finish a game to add a pin to the map.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                } else {
                    if pinnedSessions.isEmpty {
                        Text("Saved games need location permission before they can appear as map pins.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                    }
                    
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 12) {
                                ForEach(sessionStore.sessions.reversed()) { session in
                                    Button {
                                        selectSession(session)
                                    } label: {
                                        MapSessionCard(
                                            session: session,
                                            isSelected: selectedSessionID == session.id
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .id(session.id)
                                    .disabled(session.accuracy <= 0)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .onChange(of: selectedSessionID) { _, newValue in
                            guard let newValue else { return }
                            
                            withAnimation(.easeInOut(duration: 0.25)) {
                                proxy.scrollTo(newValue, anchor: .center)
                            }
                        }
                    }
                }
                
                Spacer(minLength: 0)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
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
        .onChange(of: selectedSessionID) { _, newValue in
            guard let newValue,
                  let session = sessionStore.sessions.first(where: { $0.id == newValue }) else {
                return
            }
            
            moveMapToSession(session)
        }
    }
    
    // to reset map to current location based on conditions
    private func moveMapToBestLocation() {
        if let selectedSessionID,
           let selectedSession = sessionStore.sessions.first(where: { $0.id == selectedSessionID }) {
            moveMapToSession(selectedSession)
            return
        }
        
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
    
    private func selectSession(_ session: GameSession) {
        guard session.accuracy > 0 else { return }
        
        selectedSessionID = session.id
    }
    
    private func moveMapToSession(_ session: GameSession) {
        guard session.accuracy > 0 else { return }
        
        let coordinate = CLLocationCoordinate2D(
            latitude: session.latitude,
            longitude: session.longitude
        )
        setMapCenter(coordinate)
    }
}

// Map Session Item Card Component
struct MapSessionCard: View {
    let session: GameSession
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Badge
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill((isSelected ? Color.yellow : Color.cyan).opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke((isSelected ? Color.yellow : Color.cyan).opacity(0.5), lineWidth: 1.5)
                    )
                
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(isSelected ? .yellow : .cyan)
            }
            .frame(width: 52, height: 52)
            .shadow(color: (isSelected ? Color.yellow : Color.cyan).opacity(0.2), radius: 4, x: 0, y: 0)
            
            // Game Info
            VStack(alignment: .leading, spacing: 4) {
                Text(session.gameName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(session.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.5))
                
                if session.accuracy > 0 {
                    Text("Accuracy ~\(Int(session.accuracy))m")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.green)
                } else {
                    Text("No location captured")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.4))
                }
            }
            
            Spacer()
            
            // Score Tag
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(session.score)")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(isSelected ? .yellow : .cyan)
                    .shadow(color: (isSelected ? Color.yellow : Color.cyan).opacity(0.4), radius: 4, x: 0, y: 0)
                
                Text("PTS")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.4))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isSelected ? Color.yellow.opacity(0.12) : Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isSelected ? Color.yellow.opacity(0.75) : Color.white.opacity(0.12), lineWidth: isSelected ? 1.5 : 1)
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    NavigationStack {
        MapTab()
    }
}
