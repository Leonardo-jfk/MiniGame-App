//
//  ChessViews.swift.swift
//  GameOfLifeIOS
//
//  Created by Leonardo Aurelio on 08/02/2026.
//

// MARK: - ChessViews.swift
import Foundation
import SwiftUI
import DotLottie
import Combine

// MARK: - Extension Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


// MARK: - ChessSquareView (VERSION SIMPLIFIÉE POUR TEST)
struct ChessSquareView: View {
    @ObservedObject var game: ChessGame
    let row: Int
    let col: Int
    @StateObject private var themeManager = ThemeManager.shared
    
    var isSelected: Bool {
        game.selectedPiece?.position.row == row &&
        game.selectedPiece?.position.col == col
    }
    
    var isValidMove: Bool {
        game.validMoves.contains { $0.row == row && $0.col == col }
    }
    
    var isLightSquare: Bool {
        (row + col) % 2 == 0
    }
    
    var isUnderAttack: Bool {
        guard let piece = game.board[row][col] else { return false }
        return piece.type == .king && game.isKingInCheck(of: piece.color)
    }
    
    var body: some View {
        ZStack {
            // FOND - Test direct des images
            if themeManager.currentTheme == BoardTheme.wood.rawValue {
                if isLightSquare {
                    Image("WoodLight")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
//                        .border(Color.gray, width: 3) // Bordure de test
                } else {
                    Image("WoodDark")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
//                        .border(Color.gray, width: 3) // Bordure de test
                }
            } else {
                // Autres thèmes
                Rectangle()
                    .fill(isLightSquare ?
                          themeManager.currentColors.lightSquare :
                          themeManager.currentColors.darkSquare)
            }
            
            // Overlays (sélection, mouvements, échec)
            if isSelected {
                Rectangle()
                    .strokeBorder(Color.blue, lineWidth: 4)
                    .padding(2)
            }
            
            if isValidMove && game.board[row][col] == nil {
                Circle()
                    .fill(themeManager.currentColors.highlightColor)
                    .frame(width: 30, height: 30)
            }
            
            if isValidMove && game.board[row][col] != nil {
                Rectangle()
                    .stroke(themeManager.currentColors.highlightColor, lineWidth: 4)
            }
            
            if isUnderAttack {
                Circle()
                    .fill(themeManager.currentColors.checkColor)
                    .opacity(0.3)
                    .padding(2)
            }
            
            // Pièce
            if let piece = game.board[row][col] {
                Text(piece.type.rawValue)
                    .font(.system(size: 30))
                    .foregroundColor(piece.color == .white ? .white : .black)
                    .shadow(color: .black.opacity(0.5), radius: 3)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onTapGesture {
            if let selected = game.selectedPiece, isValidMove {
                game.movePiece(to: row, col: col)
            } else {
                game.selectPiece(at: row, col: col)
            }
        }
    }
}





// MARK: - ChessBoardView
struct ChessBoardView: View {
    @ObservedObject var game: ChessGame
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { col in
                        ChessSquareView(game: game, row: row, col: col)
                    }
                }
            }
        }
    }
}


struct CapturedPiecesView: View {
    // On passe directement les comptes au lieu de passer tout l'objet game
    let blackCapturedCount: Int
    let whiteCapturedCount: Int
    
    var body: some View {
        VStack(spacing: 5) {
            Text("CAPTURES")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack(spacing: 15) {
                // Score pour les Blancs (combien de pièces noires ils ont pris)
                Text("⚪ \(blackCapturedCount)")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                
                // Score pour les Noirs (combien de pièces blanches ils ont pris)
                Text("⚫ \(whiteCapturedCount)")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
    }
}




// MARK: - StyledBoardView (Le design centralisé)
//struct StyledBoardView: View {
//    @ObservedObject var game: ChessGame
//    let gradientColors: [Color] // On permet de changer les couleurs selon le mode
//    @StateObject private var themeManager = ThemeManager.shared
//    
//    var body: some View {
//        VStack {
//            ChessBoardView(game: game)
//                .padding(5)
//                .background(Color.black.opacity(0.3))
//                .clipShape(RoundedRectangle(cornerRadius: 20))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(
//                            LinearGradient(
//                                colors: gradientColors,
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            ),
//                            lineWidth: 10
//                        )
//                )
//                .shadow(color: themeManager.currentColors.borderColor.opacity(0.5), radius: 20)
//                .overlay(alignment: .bottomLeading) {
//                    if let selected = game.selectedPiece {
//                        Text("Sélection : \(selected.type.rawValue)")
//                            .font(.caption)
//                            .bold()
//                            .foregroundColor(.white)
//                            .padding(8)
//                            .background(Color.black.opacity(0.7))
//                            .cornerRadius(10)
//                            .padding(15)
//                    }
//                }
//        }
//        .onChange(of: themeManager.currentTheme) { oldValue, newValue in
//            // Forcer la mise à jour quand le thème change
//            game.objectWillChange.send()
//        }
//    }
//}
// MARK: - StyledBoardView (Le design centralisé)
struct StyledBoardView: View {
    @ObservedObject var game: ChessGame
    let gradientColors: [Color] // On garde pour la compatibilité
    @StateObject private var themeManager = ThemeManager.shared
    
    // Couleurs de bordure selon le thème (version plus riche)
    private var borderColors: [Color] {
        switch themeManager.currentTheme {
        case BoardTheme.classic.rawValue:
            return [
                themeManager.currentColors.borderColor,
                themeManager.currentColors.borderColor.opacity(0.7),
                .orange.opacity(0.5)
            ]
        case BoardTheme.wood.rawValue:
            return [
                Color(red: 0.36, green: 0.25, blue: 0.15), // Brun foncé
                Color(red: 0.52, green: 0.35, blue: 0.19), // Brun moyen
                .orange.opacity(0.3)
            ]
        case BoardTheme.purple.rawValue:
            return [
                .purple,
                themeManager.currentColors.borderColor,
                .black.opacity(0.5)
            ]
        default:
            return gradientColors
        }
    }
    
    var body: some View {
        VStack {
            ChessBoardView(game: game)
                .padding(5)
                .background(Color.black.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: borderColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 10
                        )
                )
                .shadow(color: themeManager.currentColors.borderColor.opacity(0.5), radius: 20)
                .overlay(alignment: .bottomLeading) {
                    if let selected = game.selectedPiece {
                        Text("Sélection : \(selected.type.rawValue)")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                            .padding(15)
                    }
                }
        }
        .onChange(of: themeManager.currentTheme) { oldValue, newValue in
            // Forcer la mise à jour quand le thème change
            game.objectWillChange.send()
        }
    }
}





// MARK: - ControlButton
struct ControlButton: View {
    let icon: String
    let primaryText: String
    let secondaryText: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Circle()
                    .fill(.gray)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                
                VStack(spacing: 2) {
                    Text(primaryText)
                        .font(.caption)
                        .foregroundColor(.white)
                    Text(secondaryText)
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - HintView
struct HintView: View {
    @ObservedObject var game: ChessGame
    @Environment(\.dismiss) var dismiss
    @State private var suggestedMove: ChessGame.BotMove?
    @State private var isLoading = true
    @State private var showError = false
    
    var body: some View {
        ZStack {
            // Fond
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // En-tête
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)
                    Text("Conseil du Bot")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                }
                
                if isLoading {
                    // Chargement
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Le bot réfléchit...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(40)
                } else if let move = suggestedMove {
                    // Conseil trouvé
                    VStack(spacing: 20) {
                        // Échiquier miniature avec le mouvement
                        HintBoardPreview(
                            game: game,
                            from: move.from,
                            to: move.to
                        )
                        .frame(width: 200, height: 200)
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(20)
                        
                        // Description du mouvement
                        VStack(spacing: 15) {
                            Text("🎯 Mouvement suggéré")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.yellow)
                            
                            HStack(spacing: 30) {
                                // Pièce à déplacer
                                if let piece = game.board[move.from.row][move.from.col] {
                                    VStack {
                                        Text(piece.type.rawValue)
                                            .font(.system(size: 40))
                                        Text("De")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text("\(positionToString(move.from))")
                                            .font(.title3)
                                            .bold()
                                    }
                                }
                                
                                Image(systemName: "arrow.right")
                                    .font(.title)
                                    .foregroundColor(.green)
                                
                                // Destination
                                VStack {
                                    Text(game.board[move.to.row][move.to.col]?.type.rawValue ?? "⬜")
                                        .font(.system(size: 40))
                                        .opacity(game.board[move.to.row][move.to.col] == nil ? 0.3 : 1)
                                    Text("Vers")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(positionToString(move.to))")
                                        .font(.title3)
                                        .bold()
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(15)
                            
                            if game.board[move.to.row][move.to.col] != nil {
                                Text("⚠️ Ce mouvement capturera une pièce adverse")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        
                        // Boutons d'action
                        VStack(spacing: 12) {
                            Button(action: {
                                // Jouer le mouvement suggéré
                                game.selectPiece(at: move.from.row, col: move.from.col)
                                game.movePiece(to: move.to.row, col: move.to.col)
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Jouer ce coup")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Garder mon idée")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.top)
                    }
                } else if showError {
                    // Erreur
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Aucun conseil disponible")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("Le bot n'a trouvé aucun mouvement valide pour vous.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button("OK") {
                            dismiss()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .task {
            // Calculer le conseil de manière asynchrone
            await calculateHint()
        }
    }
    
    private func calculateHint() async {
        isLoading = true
        showError = false
        
        // Simuler un délai pour l'UX
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 seconde
        
        // Obtenir le conseil pour le joueur actuel
        let move = game.getHint(for: game.currentPlayer)
        
        await MainActor.run {
            if let move = move {
                suggestedMove = move
            } else {
                showError = true
            }
            isLoading = false
        }
    }
    
    private func positionToString(_ pos: (row: Int, col: Int)) -> String {
        let colLetter = ["A", "B", "C", "D", "E", "F", "G", "H"][pos.col]
        let rowNumber = 8 - pos.row
        return "\(colLetter)\(rowNumber)"
    }
}

// MARK: - HintBoardPreview
struct HintBoardPreview: View {
    @ObservedObject var game: ChessGame
    let from: (row: Int, col: Int)
    let to: (row: Int, col: Int)
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { col in
                        ZStack {
                            // Couleur de la case
                            Rectangle()
                                .fill((row + col) % 2 == 0 ?
                                      Color(red: 0.94, green: 0.86, blue: 0.76) :
                                      Color(red: 0.56, green: 0.41, blue: 0.26))
                            
                            // Surbrillance pour le mouvement suggéré
                            if row == from.row && col == from.col {
                                Rectangle()
                                    .stroke(Color.blue, lineWidth: 3)
                            }
                            if row == to.row && col == to.col {
                                Rectangle()
                                    .stroke(Color.green, lineWidth: 3)
                                    .background(Color.green.opacity(0.2))
                            }
                            
                            // Pièce
                            if let piece = game.board[row][col] {
                                Text(piece.type.rawValue)
                                    .font(.system(size: 20))
                                    .foregroundColor(piece.color == .white ? .white : .black)
                            }
                        }
                    }
                }
            }
        }
    }
}
