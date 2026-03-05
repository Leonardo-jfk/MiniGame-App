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




    struct ChessSettingsView: View {
        @Environment(\.dismiss) var dismiss
        @StateObject private var themeManager = ThemeManager.shared
        
        // On utilise les clés exactes de tes fichiers
        @AppStorage("BotDifficulty") private var botDifficulty = "Moyen"
        @AppStorage("boardTheme") private var boardTheme = "Classique"
        @AppStorage("soundEnabled") private var soundEnabled = true
        @AppStorage("hapticEnabled") private var hapticEnabled = true
        @AppStorage("musicEnabled") private var musicEnabled = true
        
        @StateObject private var audioManager = AudioManager.shared
        @State var isVsBot: Bool
        
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
                        // Section Thème avec aperçu
                        Section(header: Text("Thème du Plateau").foregroundColor(.white)) {
                            ForEach(BoardTheme.allCases, id: \.self) { theme in
                                Button(action: {
                                    themeManager.currentTheme = theme.rawValue
                                }) {
                                    HStack {
                                        // Petit aperçu des couleurs
                                        HStack(spacing: 2) {
                                            Rectangle()
                                                .fill(themeManager.getColors(for: theme.rawValue).lightSquare)
                                                .frame(width: 20, height: 20)
                                            Rectangle()
                                                .fill(themeManager.getColors(for: theme.rawValue).darkSquare)
                                                .frame(width: 20, height: 20)
                                        }
                                        .cornerRadius(4)
                                        .padding(.trailing, 8)
                                        
                                        Text(theme.rawValue)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        if themeManager.currentTheme == theme.rawValue {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.purple)
                                        }
                                    }
                                }
                                .listRowBackground(Color.white.opacity(0.1))
                            }
                        }
                        
                        // Section Algorithme (seulement si vs Bot)
                        if isVsBot {
                            Section(header: Text("Niveau de difficulté").foregroundColor(.white)) {
                                Picker("Difficulté", selection: $botDifficulty) {
                                    ForEach(BotDifficulty.allCases, id: \.self) { difficulty in
                                        Text(difficulty.rawValue).tag(difficulty.rawValue)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .listRowBackground(Color.white.opacity(0.1))
                            }
                        }
                        
                        // Section Audio
                        Section(header: Text("Musique").foregroundColor(.white)) {
                            Toggle(isOn: $audioManager.musicEnabled) {
                                Label("Musique d'ambiance", systemImage: "music.note")
                            }
                            
                            if audioManager.musicEnabled {
                                VStack(alignment: .leading) {
                                    Text("Volume: \(Int(audioManager.musicVolume * 100))%")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Slider(value: $audioManager.musicVolume, in: 0...1, step: 0.1)
                                        .tint(.purple)
                                }
                                .padding(.leading)
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.1))
                        
                        // Section Retours
                        Section(header: Text("Audio & Vibrations").foregroundColor(.white)) {
                            Toggle(isOn: $soundEnabled) {
                                Label("Effets Sonores", systemImage: "speaker.wave.2")
                            }
                            
                            Toggle(isOn: $hapticEnabled) {
                                Label("Vibrations (Haptique)", systemImage: "hand.tap")
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.1))
                        
                        // Section Infos
                        Section(header: Text("À propos").foregroundColor(.white)) {
                            HStack {
                                Label("Version", systemImage: "info.circle")
                                Spacer()
                                Text("1.0.0")
                                    .foregroundColor(.gray)
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.1))
                    }
                    .scrollContentBackground(.hidden)
                }
                .navigationTitle("Ajustements")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("OK") {
                            // Sauvegarder les paramètres si nécessaire
                            dismiss()
                        }
                        .foregroundColor(.purple)
                        .bold()
                    }
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                // Synchroniser boardTheme avec themeManager si nécessaire
                if boardTheme != themeManager.currentTheme {
                    themeManager.currentTheme = boardTheme
                }
            }
            .onChange(of: themeManager.currentTheme) { oldValue, newValue in
                boardTheme = newValue
            }
        }
    }

