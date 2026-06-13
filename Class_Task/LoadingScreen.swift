//
//  LoadingScreen.swift
//  Class_Task
//
//  Created by Sohan Weerasinghe on 2026-06-07.
//
import SwiftUI

struct LoadingScreen: View {
    @State private var navigateToGame = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("loadingIMG")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                // Button
                Button(action: {
                    navigateToGame = true
                }) {
                    Text("Start Game")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 280, height: 80)
                        .background(Color.blue)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                }
            }
            .navigationDestination(isPresented: $navigateToGame) {
                ContentView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    LoadingScreen()
}
