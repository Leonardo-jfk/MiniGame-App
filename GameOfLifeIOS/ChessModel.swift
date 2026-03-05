//
//  ChessModel.swift.swift
//  GameOfLifeIOS
//
//  Created by Leonardo Aurelio on 08/02/2026.
//

// MARK: - ChessModel.swift
import Foundation
import SwiftUI
import DotLottie
import Combine

// MARK: - Types & Enums
enum PieceType: String, CaseIterable {
    case king = "♔"
    case queen = "♕"
    case rook = "♖"
    case bishop = "♗"
    case knight = "♘"
    case pawn = "♙"
    case none = ""
}

enum PieceColor {
    case white
    case black
}


extension PieceType {
    var value: Int {
        switch self {
        case .pawn:   return 10
        case .knight: return 30
        case .bishop: return 30
        case .rook:   return 50
        case .queen:  return 90
        case .king:   return 900
        case .none:   return 0
        }
    }
}

enum GameEndReason {
    case checkmate(PieceColor)  // Le gagnant
    case stalemate              // Pat
    case insufficientMaterial   // Matériel insuffisant
    case resignation(PieceColor) // Abandon
    // etc.
}

enum BotDifficulty: String, CaseIterable {
    case easy = "Facile"
    case medium = "Moyen"
    case hard = "Expert"
}

enum BoardTheme: String, CaseIterable {
    case classic = "Classique"
    case wood = "Bois"
    case purple = "Violet"
}


// MARK: - ChessPiece
struct ChessPiece: Identifiable {
    let id = UUID()
    var type: PieceType
    var color: PieceColor
    var position: (row: Int, col: Int)
    var hasMoved: Bool = false
}

// MARK: - ChessGame
class ChessGame: ObservableObject {
    @Published var board: [[ChessPiece?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8)
    @Published var currentPlayer: PieceColor = .white
    @Published var selectedPiece: ChessPiece? = nil
    @Published var validMoves: [(row: Int, col: Int)] = []
    @Published var capturedWhitePieces: [ChessPiece] = []
    @Published var capturedBlackPieces: [ChessPiece] = []
    
    @Published var gameOver = false
    @Published var winner: PieceColor? = nil
    @Published var gameEndReason: GameEndReason?
    
    @AppStorage("BotDifficulty") var botDifficulty: String = BotDifficulty.medium.rawValue

    
    init() {
        setupBoard()
    }
    
    func resetGame() {
        board = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        currentPlayer = .white
        selectedPiece = nil
        validMoves = []
        capturedWhitePieces = []
        capturedBlackPieces = []
        setupBoard()
    }
    

    
    private func setupBoard() {
        // Placement des pièces noires (rangée 0)
        board[0][0] = ChessPiece(type: .rook, color: .black, position: (0, 0))
        board[0][1] = ChessPiece(type: .knight, color: .black, position: (0, 1))
        board[0][2] = ChessPiece(type: .bishop, color: .black, position: (0, 2))
        board[0][3] = ChessPiece(type: .queen, color: .black, position: (0, 3))
        board[0][4] = ChessPiece(type: .king, color: .black, position: (0, 4))
        board[0][5] = ChessPiece(type: .bishop, color: .black, position: (0, 5))
        board[0][6] = ChessPiece(type: .knight, color: .black, position: (0, 6))
        board[0][7] = ChessPiece(type: .rook, color: .black, position: (0, 7))
        
        // Pions noirs (rangée 1)
        for col in 0..<8 {
            board[1][col] = ChessPiece(type: .pawn, color: .black, position: (1, col))
        }
        
        // Pions blancs (rangée 6)
        for col in 0..<8 {
            board[6][col] = ChessPiece(type: .pawn, color: .white, position: (6, col))
        }
        
        // Placement des pièces blanches (rangée 7)
        board[7][0] = ChessPiece(type: .rook, color: .white, position: (7, 0))
        board[7][1] = ChessPiece(type: .knight, color: .white, position: (7, 1))
        board[7][2] = ChessPiece(type: .bishop, color: .white, position: (7, 2))
        board[7][3] = ChessPiece(type: .queen, color: .white, position: (7, 3))
        board[7][4] = ChessPiece(type: .king, color: .white, position: (7, 4))
        board[7][5] = ChessPiece(type: .bishop, color: .white, position: (7, 5))
        board[7][6] = ChessPiece(type: .knight, color: .white, position: (7, 6))
        board[7][7] = ChessPiece(type: .rook, color: .white, position: (7, 7))
    }
    
   func selectPiece(at row: Int, col: Int) {
        guard !gameOver else { return } // Empêche toute sélection si le jeu est fini
        
        if let piece = board[row][col], piece.color == currentPlayer {
            selectedPiece = piece
            validMoves = calculateValidMoves(for: piece)
            
            // Petite vibration de sélection
            if UserDefaults.standard.bool(forKey: "hapticEnabled") {
                HapticManager.shared.playSelection()
            }
        } else {
            selectedPiece = nil
            validMoves = []
        }
        objectWillChange.send()
    }
    
    private func calculateValidMoves(for piece: ChessPiece) -> [(Int, Int)] {
        var moves: [(Int, Int)] = []
        let row = piece.position.row
        let col = piece.position.col
        switch piece.type {
        case .pawn:
            let direction = (piece.color == .white) ? -1 : 1
            if isValidSquare(row: row + direction, col: col) && board[row + direction][col] == nil {
                moves.append((row + direction, col))
                if !piece.hasMoved && board[row + 2 * direction][col] == nil {
                    moves.append((row + 2 * direction, col))
                }
            }
            for dc in [-1, 1] {
                if isValidSquare(row: row + direction, col: col + dc),
                   let target = board[row + direction][col + dc],
                   target.color != piece.color {
                    moves.append((row + direction, col + dc))
                }
            }
        case .rook:
            moves.append(contentsOf: linearMoves(row: row, col: col, directions: [(1,0), (-1,0), (0,1), (0,-1)]))
        case .knight:
            let knightMoves = [(2,1), (2,-1), (-2,1), (-2,-1), (1,2), (1,-2), (-1,2), (-1,-2)]
            for (dr, dc) in knightMoves {
                if isValidSquare(row: row + dr, col: col + dc) {
                    if let target = board[row + dr][col + dc] {
                        if target.color != piece.color {
                            moves.append((row + dr, col + dc))
                        }
                    } else {
                        moves.append((row + dr, col + dc))
                    }
                }
            }
        case .bishop:
            moves.append(contentsOf: linearMoves(row: row, col: col, directions: [(1,1), (1,-1), (-1,1), (-1,-1)]))
        case .queen:
            moves.append(contentsOf: linearMoves(row: row, col: col, directions: [(1,0), (-1,0), (0,1), (0,-1), (1,1), (1,-1), (-1,1), (-1,-1)]))
        case .king:
            for dr in -1...1 {
                for dc in -1...1 {
                    if dr == 0 && dc == 0 { continue }
                    if isValidSquare(row: row + dr, col: col + dc) {
                        if let target = board[row + dr][col + dc] {
                            if target.color != piece.color {
                                moves.append((row + dr, col + dc))
                            }
                        } else {
                            moves.append((row + dr, col + dc))
                        }
                    }
                }
            }
        case .none:
            break
        }
        return moves
    }
    
    private func linearMoves(row: Int, col: Int, directions: [(Int, Int)]) -> [(Int, Int)] {
        var moves: [(Int, Int)] = []
        
        //  Récupérons la pièce une seule fois au début de façon sécurisée
            guard let currentPiece = board[row][col] else {
                return moves // Si pas de pièce, retourne un tableau vide
            }
        
        for (dr, dc) in directions {
            var currentRow = row + dr
            var currentCol = col + dc
            while isValidSquare(row: currentRow, col: currentCol) {
                
                
                if let piece = board[currentRow][currentCol] {
                    if piece.color != currentPiece.color {
                        moves.append((currentRow, currentCol))
                    }
                    break
                } else {
                    moves.append((currentRow, currentCol))
                }
                currentRow += dr
                currentCol += dc
            }
        }
        return moves
    }
    
    private func isValidSquare(row: Int, col: Int) -> Bool {
        return row >= 0 && row < 8 && col >= 0 && col < 8
    }
    
    private func isValidMove(row: Int, col: Int) -> Bool {
        return validMoves.contains { $0.0 == row && $0.1 == col }
    }
    // MARK: - ChessGame (ajoutez ces méthodes)
    
    // Ajoutez cette méthode pour trouver le roi d'une couleur
    private func findKing(of color: PieceColor) -> ChessPiece? {
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = board[row][col],
                   piece.type == .king ,
                   piece.color == color {
                    return piece
                }
            }
        }
        return nil
    }
    private func findQueen(of color: PieceColor) -> ChessPiece? {
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = board[row][col],
                   piece.type == .queen  ,
                   piece.color == color {
                    return piece
                }
            }
        }
        return nil
    }
    
    // Ajoutez cette méthode pour vérifier si une case est attaquée
    private func isSquareAttacked(row: Int, col: Int, by color: PieceColor) -> Bool {
        for r in 0..<8 {
            for c in 0..<8 {
                if let piece = board[r][c],
                   piece.color == color {
                    let moves = calculateValidMoves(for: piece)
                    if moves.contains(where: { $0.0 == row && $0.1 == col }) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    // Ajoutez cette méthode pour vérifier si le roi est en échec
     func isKingInCheck(of color: PieceColor) -> Bool {
        guard let king = findKing(of: color) else { return false }
        let opponentColor: PieceColor = (color == .white) ? .black : .white
        return isSquareAttacked(row: king.position.row, col: king.position.col, by: opponentColor)
    }
     func isQueenInCheck(of color: PieceColor) -> Bool {
        guard let  queen = findQueen(of: color) else { return false }
        let opponentColor: PieceColor = (color == .white) ? .black : .white
        return isSquareAttacked(row: queen.position.row, col: queen.position.col, by: opponentColor)
    }
    
    
    func movePiece(to row: Int, col: Int) {
        // SÉCURITÉ 1 : Si le jeu est fini, on ne fait rien
        guard let selected = selectedPiece, !gameOver else { return }
        AudioManager.shared.playMoveSound()
        let hapticEnabled = UserDefaults.standard.bool(forKey: "hapticEnabled")
            if hapticEnabled {
                // .medium donne un ressenti physique satisfaisant pour un déplacement de pièce
                HapticManager.shared.playImpact(style: .medium)
            }
        // SAUVEGARDE AVANT LE MOUVEMENT
        saveState()
        let oldRow = selected.position.row
        let oldCol = selected.position.col
                
               
        
//        if let capturedPiece = board[row][col] {
//            if capturedPiece.color == .white {
//                capturedWhitePieces.append(capturedPiece)
//            } else {
//                capturedBlackPieces.append(capturedPiece)
//            }
//            
//            if capturedPiece.type == .king {
//                gameOver = true
//                winner = selected.color // Définit le gagnant
//                gameEndReason = .checkmate(selected.color)
//            }
//        }
        // Dans ChessModel.swift, cherchez la fonction movePiece
        if let capturedPiece = board[row][col] {
            if hapticEnabled { HapticManager.shared.playImpact(style: .heavy) }
            
            if capturedPiece.color == .white {
                capturedWhitePieces.append(capturedPiece)
            } else {
                capturedBlackPieces.append(capturedPiece)
            }
            
            if capturedPiece.type == .king {
                // IMPORTANT : Définir le gagnant d'abord
                self.winner = currentPlayer
                self.gameEndReason = .checkmate(currentPlayer)
                
                // Ensuite seulement, arrêter le jeu
                self.gameOver = true
                return
            }
        }
        
        // Logique de déplacement
        var updatedPiece = selected
        updatedPiece.position = (row, col)
        updatedPiece.hasMoved = true
        
        board[row][col] = updatedPiece
        board[oldRow][oldCol] = nil
        
        selectedPiece = nil
        validMoves = []
        
        // SÉCURITÉ 2 : On ne change de tour que si le jeu continue
        if !gameOver {
            currentPlayer = (currentPlayer == .white) ? .black : .white
            checkGameState()
        }
        
        objectWillChange.send()
    }
    
    
    // Ajoutez cette méthode pour vérifier le pat
        func checkStalemate() -> Bool {
            // Vérifier si le joueur actuel n'a aucun mouvement légal et n'est pas en échec
            guard !isKingInCheck(of: currentPlayer) else { return false }
            return !hasAnyValidMove(for: currentPlayer)
        }
        
        // Après chaque mouvement, vérifiez l'état du jeu
    func checkGameState() {
        if gameOver { return }
        
        if isKingInCheck(of: currentPlayer) {
            if !hasAnyValidMove(for: currentPlayer) {
                // Échec et mat
                gameOver = true
                winner = currentPlayer == .white ? .black : .white
                gameEndReason = .checkmate(winner!)
            }
        } else if !hasAnyValidMove(for: currentPlayer) {
            // Pat
            gameOver = true
            winner = nil
            gameEndReason = .stalemate
        }
    }
    // Ajoutez cette méthode pour vérifier s'il reste des mouvements valides
    private func hasAnyValidMove(for color: PieceColor) -> Bool {
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = board[row][col],
                   piece.color == color {
                    let moves = calculateValidMoves(for: piece)
                    if !moves.isEmpty {
                        // Tester chaque mouvement pour voir s'il sort le roi de l'échec
                        for move in moves {
                            // Simuler le mouvement
                            let originalBoard = board
                            
                            // Effectuer le mouvement temporaire
                            board[row][col] = nil
                            var tempPiece = piece
                            tempPiece.position = (move.0, move.1)
                            board[move.0][move.1] = tempPiece
                            
                            // Vérifier si le roi n'est plus en échec
                            let stillInCheck = isKingInCheck(of: color)
                            
                            // Restaurer le plateau
                            board = originalBoard
                            
                            if !stillInCheck {
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    
    
    func isKingAtRisk(row: Int, col: Int) -> Bool {
        guard let piece = board[row][col], piece.type == .king else { return false }
        return isKingInCheck(of: piece.color)
    }
    func isQueenAtRisk(row: Int, col: Int) -> Bool {
        guard let piece = board[row][col], piece.type == .queen else { return false }
        return isQueenInCheck(of: piece.color)
    }
    
    
    
    // Pile pour stocker l'historique des plateaux
         var boardHistory: [[[ChessPiece?]]] = []
        
        // Appelez cette méthode au DEBUT de movePiece() pour sauvegarder l'état actuel
        func saveState() {
            // IMPORTANT: Sauvegarder l'état AVANT le mouvement
               let currentBoardCopy = self.board.map { $0.map { $0 } }
               boardHistory.append(currentBoardCopy)
               
               // Limiter l'historique si nécessaire (ex: 20 derniers coups)
               if boardHistory.count > 20 {
                   boardHistory.removeFirst()
               }
        }
        
    func undoMove() {
        // Vérifier s'il y a quelque chose à annuler
        guard !boardHistory.isEmpty else {
            print("Historique vide")
            return
        }
        
        // Récupérer le dernier état
        let previousBoard = boardHistory.removeLast()
        
        // Restaurer l'état
        self.board = previousBoard
        
        // Inverser le tour
//        self.currentPlayer = (currentPlayer == .white) ? .black : .white
        self.capturedWhitePieces = []
           self.capturedBlackPieces = []
        
        // Réinitialiser les indicateurs de sélection et de fin de jeu
        self.selectedPiece = nil
        self.validMoves = []
        self.gameOver = false
        self.winner = nil
        self.gameEndReason = nil
        
        // Forcer la mise à jour de l'interface
        objectWillChange.send()
    }
    
    
    
    // ICI j'ai tout pour le algorithim
    
    // MARK: - Algorithme Minimax (Corrigé)
    // On ajoute le paramètre 'currentBoard' pour ne pas utiliser la variable @Published
//    var transpositionTable: [String: (score: Int, depth: Int)] = [:]
//    
//    func minimax(boardState: [[ChessPiece?]], depth: Int, isMaximizing: Bool, alpha: Int, beta: Int) -> Int {
//        let boardKey = generateHash(for: boardState)
//        if let cached = transpositionTable[boardKey], cached.depth >= depth {
//                return cached.score
//            }
//        
//        if depth == 0 || gameOver {
//            return evaluateBoard(boardState) // On évalue l'état simulé
//        }
//        
//        var currentAlpha = alpha
//        var currentBeta = beta
//        var tempBoard = boardState // On travaille sur une copie locale
//        
//        let finalEval: Int
//        
//        if isMaximizing {
//            var maxEval = -10000
//            let moves = getAllPossibleMoves(for: .black, on: tempBoard)
//            
//            for move in moves {
//                let captured = tempBoard[move.to.row][move.to.col]
//                
//                // Simulation locale
//                tempBoard[move.to.row][move.to.col] = tempBoard[move.from.row][move.from.col]
//                tempBoard[move.from.row][move.from.col] = nil
//                
//                let currentMoveEval = minimax(boardState: tempBoard, depth: depth - 1, isMaximizing: false, alpha: currentAlpha, beta: currentBeta)
//                
//                // Annulation locale
//                tempBoard[move.from.row][move.from.col] = tempBoard[move.to.row][move.to.col]
//                tempBoard[move.to.row][move.to.col] = captured
//                
//                maxEval = max(maxEval, currentMoveEval)
//                currentAlpha = max(currentAlpha, currentMoveEval)
//                if currentBeta <= currentAlpha { break }
//            }
//            finalEval = maxEval
//        } else {
//            var minEval = 10000
//            let moves = getAllPossibleMoves(for: .white, on: tempBoard)
//            
//            for move in moves {
//                let captured = tempBoard[move.to.row][move.to.col]
//                
//                tempBoard[move.to.row][move.to.col] = tempBoard[move.from.row][move.from.col]
//                tempBoard[move.from.row][move.from.col] = nil
//                
//                let currentMoveEval = minimax(boardState: tempBoard, depth: depth - 1, isMaximizing: true, alpha: currentAlpha, beta: currentBeta)
//                
//                tempBoard[move.from.row][move.from.col] = tempBoard[move.to.row][move.to.col]
//                tempBoard[move.to.row][move.to.col] = captured
//                
//                minEval = min(minEval, currentMoveEval)
//                currentBeta = min(currentBeta, currentMoveEval)
//                if currentBeta <= currentAlpha { break }
//            }
//            finalEval =  minEval
//        }
//        
//        if transpositionTable.count > 100_000 { // Limite arbitraire
//            transpositionTable.removeAll(keepingCapacity: true)
//        }
//        transpositionTable[boardKey] = (score: finalEval, depth: depth)
//            return finalEval
//    }
    // 1. Ajoutez un verrou en haut de votre classe ChessGame
    private let tableLock = NSLock()
    var transpositionTable: [String: (score: Int, depth: Int)] = [:]

    func minimax(boardState: [[ChessPiece?]], depth: Int, isMaximizing: Bool, alpha: Int, beta: Int) -> Int {
        let boardKey = generateHash(for: boardState)
        
        // 2. Utilisez le verrou pour LIRE
        tableLock.lock()
        let cached = transpositionTable[boardKey]
        tableLock.unlock()
        
        if let cached = cached, cached.depth >= depth {
            return cached.score
        }
        
        if depth == 0 || gameOver {
                   return evaluateBoard(boardState) // On évalue l'état simulé
               }
       
               var currentAlpha = alpha
               var currentBeta = beta
               var tempBoard = boardState // On travaille sur une copie locale
       
               let finalEval: Int
       
               if isMaximizing {
                   var maxEval = -10000
                   let moves = getAllPossibleMoves(for: .black, on: tempBoard)
       
                   for move in moves {
                       let captured = tempBoard[move.to.row][move.to.col]
       
                       // Simulation locale
                       tempBoard[move.to.row][move.to.col] = tempBoard[move.from.row][move.from.col]
                       tempBoard[move.from.row][move.from.col] = nil
       
                       let currentMoveEval = minimax(boardState: tempBoard, depth: depth - 1, isMaximizing: false, alpha: currentAlpha, beta: currentBeta)
       
                       // Annulation locale
                       tempBoard[move.from.row][move.from.col] = tempBoard[move.to.row][move.to.col]
                       tempBoard[move.to.row][move.to.col] = captured
       
                       maxEval = max(maxEval, currentMoveEval)
                       currentAlpha = max(currentAlpha, currentMoveEval)
                       if currentBeta <= currentAlpha { break }
                   }
                   finalEval = maxEval
               } else {
                   var minEval = 10000
                   let moves = getAllPossibleMoves(for: .white, on: tempBoard)
       
                   for move in moves {
                       let captured = tempBoard[move.to.row][move.to.col]
       
                       tempBoard[move.to.row][move.to.col] = tempBoard[move.from.row][move.from.col]
                       tempBoard[move.from.row][move.from.col] = nil
       
                       let currentMoveEval = minimax(boardState: tempBoard, depth: depth - 1, isMaximizing: true, alpha: currentAlpha, beta: currentBeta)
       
                       tempBoard[move.from.row][move.from.col] = tempBoard[move.to.row][move.to.col]
                       tempBoard[move.to.row][move.to.col] = captured
       
                       minEval = min(minEval, currentMoveEval)
                       currentBeta = min(currentBeta, currentMoveEval)
                       if currentBeta <= currentAlpha { break }
                   }
                   finalEval =  minEval
               }
               
        
        // 3. Utilisez le verrou pour ÉCRIRE
        tableLock.lock()
        if transpositionTable.count > 100_000 {
            transpositionTable.removeAll(keepingCapacity: true)
        }
        transpositionTable[boardKey] = (score: finalEval, depth: depth)
        tableLock.unlock()
        
        return finalEval
    }
    
    
    
    func makeBotMove() {
        // 1. On capture l'état actuel du board sur le thread principal
        let currentBoardSnapshot = self.board
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var bestMove: BotMove?
            var bestValue = -10000
            
            // On travaille sur notre snapshot
            let possibleMoves = self.getAllPossibleMoves(for: .black, on: currentBoardSnapshot)
            var tempBoard = currentBoardSnapshot
            
            for move in possibleMoves {
                let captured = tempBoard[move.to.row][move.to.col]
                
                // Faire le coup
                tempBoard[move.to.row][move.to.col] = tempBoard[move.from.row][move.from.col]
                tempBoard[move.from.row][move.from.col] = nil
               
//                //niveux d'echeque
//                var depthLevel = 1
//                if x { depthLevel = 3}
//                if z { depthLevel = 5}
//                
//                let boardValue = self.minimax(boardState: tempBoard, depth: depthLevel, isMaximizing: false, alpha: -10000, beta: 10000)

                let Botdepth = getBotDepth()
                
                let boardValue = self.minimax(
                                    boardState: tempBoard,
                                    depth: Botdepth,
                                    isMaximizing: false,
                                    alpha: -10000,
                                    beta: 10000
                                )
                
                // Annuler le coup
                tempBoard[move.from.row][move.from.col] = tempBoard[move.to.row][move.to.col]
                tempBoard[move.to.row][move.to.col] = captured
                
                if boardValue > bestValue {
                    bestValue = boardValue
                    bestMove = move
                }
            }
            
            // 2. On revient sur le Main Thread UNIQUEMENT pour le coup final
            DispatchQueue.main.async {
                if let move = bestMove {
                    self.executeMove(move)
                }
            }
        }
    }
    
    private func getBotDepth() -> Int {
            switch botDifficulty {
            case BotDifficulty.easy.rawValue:
                return 1  // Facile: ne regarde qu'1 coup ahead
            case BotDifficulty.medium.rawValue:
                return 3  // Moyen: regarde 3 coups ahead
            case BotDifficulty.hard.rawValue:
                return 5  // Difficile: regarde 5 coups ahead
            default:
                return 2
            }
        }

    private func simulateMove(on board: [[ChessPiece?]], move: BotMove) -> [[ChessPiece?]] {
        var newBoard = board  // Crée une nouvelle copie
        newBoard[move.to.row][move.to.col] = newBoard[move.from.row][move.from.col]
        newBoard[move.from.row][move.from.col] = nil
        return newBoard
    }
    
    struct BotMove {
        let from: (row: Int, col: Int)
        let to: (row: Int, col: Int)
        var capturedPiece: ChessPiece? = nil
    }
    
    
    func evaluateBoard(_ boardToEvaluate: [[ChessPiece?]]) -> Int {
        var totalScore = 0
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = boardToEvaluate[row][col] {
                    let value = piece.type.value
                    totalScore += (piece.color == .black) ? value : -value
                }
            }
        }
        return totalScore
    }
    
    
    // Version pour les calculs - ne déclenche PAS de rafraîchissement
    private func makeTemporaryMove(_ move: BotMove) -> ChessPiece? {
        // 1. Sauvegarder la pièce capturée
        let capturedPiece = board[move.to.row][move.to.col]
        
        // 2. Modifier le tableau directement, mais SANS notifier SwiftUI
        board[move.to.row][move.to.col] = board[move.from.row][move.from.col]
        board[move.from.row][move.from.col] = nil
        
        // 3. Retourner la pièce capturée pour pouvoir annuler
        return capturedPiece
    }

    private func undoTemporaryMove(_ move: BotMove, capturedPiece: ChessPiece?) {
        // Remettre les pièces comme avant, SANS notifier SwiftUI
        board[move.from.row][move.from.col] = board[move.to.row][move.to.col]
        board[move.to.row][move.to.col] = capturedPiece
    }
    
    
    
    
    
    
    func executeMove(_ move: BotMove) {
        // Cette fonction utilise ta logique existante qui met à jour l'UI
        selectPiece(at: move.from.row, col: move.from.col)
        movePiece(to: move.to.row, col: move.to.col)
    }
    
    private func getAllPossibleMoves(for color: PieceColor, on targetBoard: [[ChessPiece?]]) -> [BotMove] {
        var allMoves: [BotMove] = []
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = targetBoard[row][col], piece.color == color {
                    // Ici, assure-toi que calculateValidMoves peut aussi prendre un board en paramètre
                    // Si ce n'est pas le cas, tu peux utiliser ta version actuelle mais attention aux bugs
                    let destinations = calculateValidMoves(for: piece)
                    for dest in destinations {
                        allMoves.append(BotMove(from: (row, col), to: (dest.0, dest.1)))
//                        allMoves.append(BotMove(from: (row, col), to: (dest.0, dest.1)))
                    }
                }
            }
        }
        return allMoves
    }

    
    func generateHash(for board: [[ChessPiece?]]) -> String {
        var hash = ""
        for row in board {
            for slot in row {
                if let piece = slot {
                    // On utilise une lettre pour la couleur et une pour le type
                    // Ex: "BK" pour Black King, "WP" pour White Pawn
                    let colorChar = (piece.color == .black) ? "B" : "W"
                    let typeChar = String(describing: piece.type).prefix(1).uppercased()
                    hash += colorChar + typeChar
                } else {
                    hash += "." // Case vide
                }
            }
        }
        return hash
    }
    
    
    
    //
    //Haptique
    //
    class HapticManager {
        static let shared = HapticManager()
        
        func playSelection() {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
        
        func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
    
    struct BoardThemeColors {
        let lightSquare: Color
        let darkSquare: Color
        let borderColor: Color
        let highlightColor: Color
        let checkColor: Color
        
        // Propriétés pour les images de fond
        var lightSquareImage: Image? = nil
        var darkSquareImage: Image? = nil
    }

    class ThemeManager: ObservableObject {
        static let shared = ThemeManager()
        
        @AppStorage("boardTheme") var currentTheme: String = BoardTheme.classic.rawValue {
            didSet {
                objectWillChange.send()
            }
        }
        
        func getColors(for theme: String) -> BoardThemeColors {
            switch theme {
            case BoardTheme.classic.rawValue:
                return BoardThemeColors(
                    lightSquare: Color(red: 0.94, green: 0.86, blue: 0.76),
                    darkSquare: Color(red: 0.56, green: 0.41, blue: 0.26),
                    borderColor: .brown,
                    highlightColor: .green.opacity(0.5),
                    checkColor: .red.opacity(0.7)
                )
                
            case BoardTheme.wood.rawValue:
                return BoardThemeColors(
                    lightSquare: .clear,
                    darkSquare: .clear,
                    borderColor: Color(red: 0.36, green: 0.25, blue: 0.15),
                    highlightColor: .yellow.opacity(0.4),
                    checkColor: .orange.opacity(0.8),
                    lightSquareImage: Image("WoodLight"),
                    darkSquareImage: Image("WoodDark")
                )
                
            case BoardTheme.purple.rawValue:
                return BoardThemeColors(
                    lightSquare: Color(red: 0.9, green: 0.8, blue: 0.95),
                    darkSquare: Color(red: 0.5, green: 0.3, blue: 0.7),
                    borderColor: .purple,
                    highlightColor: .cyan.opacity(0.5),
                    checkColor: .pink.opacity(0.8)
                )
                
            default:
                return BoardThemeColors(
                    lightSquare: Color(red: 0.94, green: 0.86, blue: 0.76),
                    darkSquare: Color(red: 0.56, green: 0.41, blue: 0.26),
                    borderColor: .brown,
                    highlightColor: .green.opacity(0.5),
                    checkColor: .red.opacity(0.7)
                )
            }
        }
        
        var currentColors: BoardThemeColors {
            getColors(for: currentTheme)
        }
    }
    
    
    // MARK: - StyledBoardView.swift
    struct StyledBoardView: View {
        @ObservedObject var game: ChessGame
        let gradientColors: [Color]
        @StateObject private var themeManager = ThemeManager.shared
        
        var body: some View {
            VStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { col in
                            ThemedChessSquare(
                                row: row,
                                col: col,
                                piece: game.board[row][col],
                                isSelected: game.selectedPiece?.position.row == row &&
                                           game.selectedPiece?.position.col == col,
                                isValidMove: game.validMoves.contains { $0.0 == row && $0.1 == col },
                                isKingInCheck: game.isKingAtRisk(row: row, col: col),
                                themeColors: themeManager.currentColors
                            ) {
                                if let piece = game.board[row][col] {
                                    game.selectPiece(at: row, col: col)
                                } else if !game.validMoves.isEmpty {
                                    game.movePiece(to: row, col: col)
                                } else {
                                    game.selectPiece(at: row, col: col)
                                }
                            }
                        }
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(themeManager.currentColors.borderColor, lineWidth: 3)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(radius: 10)
            .onChange(of: themeManager.currentTheme) { oldValue, newValue in
                game.objectWillChange.send()
            }
        }
    }
    
    
    
    // MARK: - ThemedChessSquare.swift
    struct ThemedChessSquare: View {
        let row: Int
        let col: Int
        let piece: ChessPiece?
        let isSelected: Bool
        let isValidMove: Bool
        let isKingInCheck: Bool
        let themeColors: BoardThemeColors
        let action: () -> Void
        
        private var isLightSquare: Bool {
            (row + col) % 2 == 0
        }
        
        var body: some View {
            Button(action: action) {
                ZStack {
                    // Fond de la case avec image ou couleur
                    Group {
                        if isLightSquare {
                            if let image = themeColors.lightSquareImage {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                Rectangle()
                                    .fill(themeColors.lightSquare)
                            }
                        } else {
                            if let image = themeColors.darkSquareImage {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                Rectangle()
                                    .fill(themeColors.darkSquare)
                            }
                        }
                    }
                    .overlay(
                        Rectangle()
                            .stroke(themeColors.borderColor, lineWidth: 1)
                    )
                    
                    // Surbrillance pour la case sélectionnée
                    if isSelected {
                        Rectangle()
                            .stroke(Color.blue, lineWidth: 3)
                            .padding(2)
                    }
                    
                    // Surbrillance pour le mouvement valide
                    if isValidMove {
                        if piece == nil {
                            // Case vide : cercle
                            Circle()
                                .fill(themeColors.highlightColor)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        } else {
                            // Case avec pièce : contour
                            Rectangle()
                                .stroke(themeColors.highlightColor, lineWidth: 4)
                        }
                    }
                    
                    // Surbrillance rouge si le roi est en échec
                    if isKingInCheck {
                        Rectangle()
                            .fill(themeColors.checkColor)
                            .opacity(0.3)
                    }
                    
                    // La pièce d'échec
                    if let piece = piece {
                        Text(piece.type.rawValue)
                            .font(.system(size: 40))
                            .foregroundColor(piece.color == .white ? .white : .black)
                            .shadow(color: .black.opacity(0.5), radius: 3, x: 2, y: 2)
                            .shadow(color: .white.opacity(0.3), radius: 2, x: -1, y: -1)
                    }
                }
            }
            .frame(height: UIScreen.main.bounds.width / 9)
            .clipShape(Rectangle())
        }
    }
    
    
    
    
    
    
    //gg
    
    
    
    
}
























