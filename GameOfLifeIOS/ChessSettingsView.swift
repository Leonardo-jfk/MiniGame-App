//
//  ChessSettingsView.swift
//  GameOfLifeIOS
//
//  Created by Leonardo Aurelio on 21/02/2026.
//

import Foundation
import SwiftUI
import DotLottie
import Combine





//struct ChessSettingsView: View {
//    @Environment(\.dismiss) var dismiss
//    
//    // Utilisation de AppStorage pour sauvegarder les choix
//    @AppStorage("BotDifficulty") private var botDifficulty = BotDifficulty.medium.rawValue
//    @AppStorage("boardTheme") private var boardTheme = BoardTheme.classic.rawValue
//    @AppStorage("soundEnabled") private var soundEnabled = true
//    @AppStorage("hapticEnabled") private var hapticEnabled = true
//    //ff
//    
////    @AppStorage("soundEnabled") private var soundEnabled = true
////       @AppStorage("hapticEnabled") private var hapticEnabled = true
//       
//       @AppStorage("musicEnabled") private var musicEnabled: Bool = true
//          @StateObject private var audioManager = AudioManager.shared
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // Fond dégradé similaire à votre application
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.black]),
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .ignoresSafeArea()
//                
//                List {
//                    // SECTION : JEU
//                    Section(header: Text("Paramètres du Jeu").foregroundColor(.white)) {
//                        HStack {
//                            Label("Difficulté", systemImage: "cpu")
//                            Spacer()
//                            Picker("", selection: $botDifficulty) {
//                                ForEach(botDifficulty.allCases, id: \.self) { diff in
//                                    Text(diff.rawValue).tag(diff.rawValue)
//                                }
//                            }
//                            .pickerStyle(.menu)
//                        }
//                        
//                        HStack {
//                            Label("Thème du Plateau", systemImage: "paintbrush")
//                            Spacer()
//                            Picker("", selection: $boardTheme) {
//                                ForEach(BoardTheme.allCases, id: \.self) { theme in
//                                    Text(theme.rawValue).tag(theme.rawValue)
//                                }
//                            }
//                            .pickerStyle(.menu)
//                        }
//                    }
//                    .listRowBackground(Color.white.opacity(0.1))
//                    Section("music"){
//                                                           Toggle("music's switch", isOn: $audioManager.musicEnabled)
//                                                           if musicEnabled {
//                                                               Slider(value: $audioManager.musicVolume, in: 0...1, step: 0.1)
//                                                                   .tint(.blue)
//                                                           }
//                                                       }
//                    
//                    
//                    // SECTION : AUDIO & RETOURS
//                    Section(header: Text("Audio & Vibrations").foregroundColor(.white)) {
//                        Toggle(isOn: $soundEnabled) {
//                            Label("Effets Sonores", systemImage: "speaker.wave.2")
//                        }
//                        Toggle(isOn: $hapticEnabled) {
//                            Label("Vibrations (Haptique)", systemImage: "hand.tap")
//                        }
//                    }
//                    .listRowBackground(Color.white.opacity(0.1))
//                    
//                    // SECTION : INFOS
//                    Section(header: Text("À propos").foregroundColor(.white)) {
//                        HStack {
//                            Text("Version")
//                            Spacer()
//                            Text("1.0.0").foregroundColor(.gray)
//                        }
//                    }
//                    .listRowBackground(Color.white.opacity(0.1))
//                }
//                .scrollContentBackground(.hidden) // Rend la liste transparente pour voir le dégradé
//            }
//            .navigationTitle("Ajustements")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("OK") { dismiss() }
//                        .foregroundColor(.purple)
//                        .bold()
//                }
//            }
//        }
//        .preferredColorScheme(.dark)
//    }
//}
struct ChessSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    // On utilise les clés exactes de tes fichiers
    @AppStorage("BotDifficulty") private var botDifficulty = "Moyen"
    @AppStorage("boardTheme") private var boardTheme = "Classique"
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @AppStorage("musicEnabled") private var musicEnabled = true
    
    @StateObject private var audioManager = AudioManager.shared
    @State  var isVsBot: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fond
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.black]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                List {
                    // 1. Section Algorithme
                    Section(header: Text("Paramètres du Jeu").foregroundColor(.white)) {
                        if isVsBot == true {
                            HStack {
                                Label("Niveau de l'algorithme", systemImage: "cpu")
                                Spacer()
                                Picker("", selection: $botDifficulty) {
                                    // On boucle sur les cas de l'enum défini dans ChessModel
                                    ForEach(BotDifficulty.allCases, id: \.self) { diff in
                                        Text(diff.rawValue).tag(diff.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                        }
                        
                        HStack {
                            Label("Thème du Plateau", systemImage: "paintbrush")
                            Spacer()
                            Picker("", selection: $boardTheme) {
                                ForEach(BoardTheme.allCases, id: \.self) { theme in
                                    Text(theme.rawValue).tag(theme.rawValue)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.1))

                    // 2. Section Audio
                    Section("Musique") {
                        Toggle("Musique d'ambiance", isOn: $audioManager.musicEnabled)
                        if audioManager.musicEnabled {
                            Slider(value: $audioManager.musicVolume, in: 0...1, step: 0.1)
                                .tint(.blue)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.1))
                    
                    // 3. Section Retours
                    Section(header: Text("Audio & Vibrations").foregroundColor(.white)) {
                        Toggle(isOn: $soundEnabled) {
                            Label("Effets Sonores", systemImage: "speaker.wave.2")
                        }
                        Toggle(isOn: $hapticEnabled) {
                            Label("Vibrations (Haptique)", systemImage: "hand.tap")
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.1))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Ajustements")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("OK") { dismiss() }.foregroundColor(.purple).bold()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
