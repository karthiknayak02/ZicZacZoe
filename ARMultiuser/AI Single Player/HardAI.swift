//
//  Medium.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Deavin Hester on 12/11/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class HardAI {
    
    var cw = CheckWinner()
    let human = "X"
    let ai = "O"
    var depthCount = 0
    var difficulty = 2
    var availablePositions: [String]
    var cube: [[[Cell]]]
    
    let winningCombos = [
        // Y axis
        ["000", "001", "002", "003"], ["100", "011", "012", "013"], ["020", "021", "022", "023"], ["030", "031", "032", "033"],
        ["100", "101", "102", "103"], ["110", "111", "112", "113"], ["120", "121", "122", "123"], ["130", "131", "132", "133"],
        ["200", "201", "202", "203"], ["210", "211", "212", "213"], ["220", "221", "222", "223"], ["230", "231", "232", "233"],
        ["300", "301", "302", "303"], ["310", "311", "312", "313"], ["320", "321", "322", "323"], ["330", "331", "332", "333"],
        // Z axis
        ["000", "010", "020", "030"], ["100", "110", "120", "130"], ["200", "210", "220", "230"], ["300", "310", "320", "330"],
        ["001", "011", "021", "031"], ["101", "111", "121", "131"], ["201", "211", "221", "231"], ["301", "311", "321", "331"],
        ["002", "012", "022", "032"], ["102", "112", "122", "132"], ["202", "212", "222", "232"], ["302", "312", "322", "332"],
        ["003", "013", "023", "033"], ["103", "113", "123", "133"], ["203", "213", "223", "233"], ["303", "313", "323", "333"],
        // X axis
        ["000", "100", "200", "300"], ["010", "110", "210", "310"], ["020", "120", "220", "320"], ["030", "130", "230", "330"],
        ["001", "101", "201", "301"], ["011", "111", "211", "311"], ["021", "121", "221", "321"], ["031", "131", "231", "331"],
        ["002", "102", "202", "302"], ["012", "112", "212", "312"], ["022", "122", "222", "322"], ["032", "132", "232", "332"],
        ["003", "103", "203", "303"], ["013", "113", "213", "313"], ["023", "123", "223", "323"], ["033", "133", "233", "333"],
        // XY axis
        ["033", "132", "231", "330"], ["023", "122", "221", "320"], ["013", "112", "211", "310"], ["003", "102", "201", "300"],
        ["333", "232", "131", "030"], ["323", "222", "121", "020"], ["313", "212", "111", "010"], ["303", "202", "101", "000"],
        // ZY axis
        ["033", "022", "011", "000"], ["133", "122", "111", "100"], ["233", "222", "211", "200"], ["333", "322", "311", "300"],
        ["003", "012", "021", "030"], ["103", "112", "121", "130"], ["203", "212", "221", "230"], ["303", "312", "321", "330"],
        // XZ axis
        ["033", "123", "213", "303"], ["032", "122", "212", "302"], ["031", "121", "211", "301"], ["030", "120", "210", "300"],
        ["003", "113", "223", "333"], ["002", "112", "222", "332"], ["001", "111", "221", "331"], ["000", "110", "220", "330"],
        // XYZ axis
        ["033", "122", "211", "300"], ["303", "212", "121", "030"], ["333", "222", "111", "000"], ["003", "112", "221", "330"]]
    
    
    init(availablePos: [String], cube: [[[Cell]]]) {
        self.availablePositions = availablePos
        self.cube = cube
    }
    
    func getMove(availablePos: [String], cubeState: [[[Cell]]]) -> String {
        self.availablePositions = availablePos
        self.cube = cubeState
        
        var bestScore = -1000
        var bestMove = ""
        var h: Int
        
        let oldAP = self.availablePositions
        let oldCube = self.cube
        for move in oldAP {
            //self.availablePositions.remove(at: self.availablePositions.firstIndex(of: move)!)
            if cw.checkGameState(cubeState: self.cube, pos: move) == Cell.cellState.cross {
                bestMove = move
                //self.availablePositions = oldAP
                break
            }
            else {
                h = thinkAhead(player: self.human, a: -1000, b: 1000)
                print(self.depthCount)
                self.depthCount = 0
                if h >= bestScore {
                    bestScore = h
                    bestMove = move
                }
                unMove(ap: oldAP, cubeState: oldCube)
                
                // See if it blocks the player
                if cw.checkGameState(cubeState: self.cube, pos: move) == Cell.cellState.sphere { //if self.complete and self.winner == self.human:
                    if 1001 >= bestScore {
                        bestScore = 1001
                        bestMove = move
                    }
                }
            }
        }
        
        return bestMove
    }
    
    // Recursive Minimax & Alpha-Beta method to find the advisable moves
    private func thinkAhead(player: String, a: Int, b: Int) -> Int {
        var alpha = a
        var beta = b
        
        if self.depthCount == self.difficulty { print("depth hit wall", terminator:"  ~~~  "); return simpleHeuristic() }
        
        if self.depthCount <= self.difficulty {
            self.depthCount += 1
            var h: Int  // define heuristic value
            let oldAP = self.availablePositions
            let oldCube = self.cube
            
            if player == self.ai {
                h = -1000
                for move in self.availablePositions {
                    //self.availablePositions.remove(at: self.availablePositions.firstIndex(of: move)!)
                    if cw.checkGameState(cubeState: self.cube, pos: move) == Cell.cellState.cross { // if ai wins
                         return 1000
                    }
                    else {
                        Move(pos: move, isAI: true)
                        h = thinkAhead(player: human, a: alpha, b: beta)
                        if h > alpha { alpha = h }
                        unMove(ap: oldAP, cubeState: oldCube)
                    }
                    
                    if alpha >= beta { break }
                }
                
                return alpha
            }
            else {  // player == human
                h = 1000
                for move in self.availablePositions {
                    //self.availablePositions.remove(at: self.availablePositions.firstIndex(of: move)!)
                    if cw.checkGameState(cubeState: self.cube, pos: move) == Cell.cellState.sphere { // if human wins
                         return -1000
                    }
                    else {
                        Move(pos: move, isAI: false)
                        h = thinkAhead(player: ai, a: alpha, b: beta)
                        if h < beta { beta = h }
                        unMove(ap: oldAP, cubeState: oldCube)
                    }
                    
                    if alpha >= beta { break }
                }
                
                return beta
            }
        }
        else { print("ELSE", terminator:"  ~~~  "); return simpleHeuristic() }
    }
    
    private func Move(pos: String, isAI: Bool) {
        let i = Int(String(Array(pos)[0])),
            j = Int(String(Array(pos)[1])),
            k = Int(String(Array(pos)[2]))
        
        if isAI {
            self.cube[i!][j!][k!].state = Cell.cellState.cross
        }
        else {  // simulated player move
            self.cube[i!][j!][k!].state = Cell.cellState.sphere
        }
        
        self.availablePositions.remove(at: self.availablePositions.firstIndex(of: pos)!)
    }
    
    private func unMove(ap: [String], cubeState: [[[Cell]]]) {
        self.availablePositions = ap
        self.cube = cubeState
    }
    
    /* Number of spaces available to win for the AI with the number
     of spaces available for the Human to win subtracted. Higher numbers
     are more favorable for the AI */
    private func simpleHeuristic() -> Int {
        let a = checkAvailable(player: self.ai)
        let b = checkAvailable(player: self.human)
        print("ai: \(a)\tperson: \(b)\th: \(a-b)")
        return a - b
        //return checkAvailable(player: self.ai) - checkAvailable(player: self.human)
    }
    
    // Check the number of available wins on the current board state
    private func checkAvailable(player: String) -> Int {
        var enemy = Cell.cellState.empty
        if player == self.human { enemy = Cell.cellState.cross }
        else { enemy = Cell.cellState.sphere }
        var wins = 0
        
        for pos in self.winningCombos {
            var possibleWin = true
            for cell in pos {
                let arr = Array(cell)
                if self.cube[Int(String(arr[0]))!][Int(String(arr[1]))!][Int(String(arr[2]))!].state == enemy {
                    possibleWin = false
                    break
                }
            }
            if possibleWin { wins += 1 }
        }
        
        return wins
    }
    
}
