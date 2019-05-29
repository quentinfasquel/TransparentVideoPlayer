//
//  GridViewController.swift
//  TestComposition
//
//  Created by Quentin Fasquel on 27/04/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation
import AlphaPlayer
import UIKit

enum AppError: Error {
    case resourceNotFound
}

/// This controller is mostly useful to test the performance of multiple players (in parallel)
class GridViewController: UIViewController {

    var players: [AlphaPlayerProtocol] = []

    let clipCellsToBounds: Bool = true
    
     // 3 x 5 is still working fine
    let gridView = GridView(columnCount: 2, rowCount: 4)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gridView.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.addSubview(gridView)

        NSLayoutConstraint.activate([
            gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gridView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gridView.topAnchor.constraint(equalTo: view.topAnchor),
            gridView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])

        setupMultipleOutputPlayer()
//        setupMultiplePlayers()
    }

    private func setupMultipleOutputPlayer() {
        gridView.reset(4, rowCount: 4)

        guard let player = try? createPlayer() else {
            return
        }
        
        players.append(player)
        
        (0..<4).forEach { (col) in
            (0..<4).forEach({ (row) in
                let playerView = createPlayerView(into: gridView.cellView(col, row))
                playerView.setPlayer(player)
            })
        }
 
        player.seek(to: .zero)        
    }
    
    private func setupMultiplePlayers() {
        func addPlayer(_ col: Int, _ row: Int) {
            guard let player = try? createPlayer() else {
                return
            }

            players.append(player)
            
            // let layer = AlphaPlayerLayer(player: player), set playerView's layer?
            let playerView = createPlayerView(into: gridView.cellView(col, row))
            // TODO: Get playerItem size, apply to playerView
            playerView.setPlayer(player)
            player.seek(to: .zero)
        }

        addPlayer(0, 0)
        addPlayer(0, 1)
        addPlayer(0, 2)
        addPlayer(0, 3)
//        addPlayer(0, 4)
        addPlayer(1, 0)
        addPlayer(1, 1)
        addPlayer(1, 2)
        addPlayer(1, 3)
//        addPlayer(1, 4)
//        addPlayer(2, 0)
//        addPlayer(2, 1)
//        addPlayer(2, 2)
//        addPlayer(2, 3)
//        addPlayer(2, 4)
    }

    private func createPlayer() throws -> AlphaPlayerProtocol {
        let basename = "playdoh-bat"
        let bundle = Bundle.main

        guard let url1 = bundle.url(forResource: "\(basename)-rgb", withExtension: "mp4"),
            let url2 = bundle.url(forResource: "\(basename)-alpha", withExtension: "mp4") else {
                throw AppError.resourceNotFound
        }
        

        let playerItem = try AlphaPlayerItemComposition(url1, url2)

        // TODO: Investigate why "replay one item" does not work with AVQueuePlayer
//        let queuePlayer = AlphaQueuePlayer(alphaPlayerItem: playerItem)
//        queuePlayer.actionAtItemEnd = .pause
//        return queuePlayer

        // TODO: sublass AVPlayerLooper AlphaPlayerLooper?
//        playerLooper = AlphaPlayerLooper(player: player, templateItem: playerItem)

        return AlphaPlayer(composition: playerItem)
    }
    
    private func createPlayerView(into container: UIView) -> AlphaPlayerView {
        // Setup video view
        let playerView = AlphaPlayerView(
            frame: CGRect(x: 0, y: 0, width: 460.0 / 2.0, height: 286.0 / 2.0),
            device: MTLCreateSystemDefaultDevice())

        playerView.translatesAutoresizingMaskIntoConstraints = false
        container.clipsToBounds = clipCellsToBounds
        container.addSubview(playerView)

        let width: CGFloat = 460.0 / 2.0
        let height: CGFloat = 286.0 / 2.0
        
        NSLayoutConstraint.activate([
            playerView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            playerView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            playerView.widthAnchor.constraint(equalToConstant: width),
            playerView.heightAnchor.constraint(equalToConstant: height)
        ])

        // Setup 'Tap to restart'
        let tapToRestart = UITapGestureRecognizer(target: self, action: #selector(restartPlayer))
        playerView.addGestureRecognizer(tapToRestart)
        
        return playerView
    }

    // MARK: -
    
    @objc private func restartPlayer(_ sender: UIGestureRecognizer) {
        guard let player = (sender.view as? AlphaPlayerView)?.player else {
            return
        }

        player.seek(to: .zero)
        player.play()
    }
}
