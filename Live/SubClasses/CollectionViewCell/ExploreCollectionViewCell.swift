//
//  ExploreCollectionViewCell.swift
//  Live
//
//  Created by ITPATH on 4/18/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ExploreCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var lblCollectionName:UILabel!
    @IBOutlet var playerView: UIView!
    @IBOutlet var collectionImgView: ImageViewForURL!
    
    var playerObserver:NSObjectProtocol?
    var player: AVPlayer?
    var playerViewController = AVPlayerViewController()
    var playerLayer: AVPlayerLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 4.0
        self.contentView.layer.masksToBounds = true
        // Initialization code
    }
    
    func playVideo(url: URL) {
        player = AVPlayer(url: url)
        self.playerView.isHidden = false
        self.player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = self.bounds
        playerLayer?.backgroundColor = UIColor.black.cgColor
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.playerView.layer.addSublayer(self.playerLayer!)
        player?.isMuted = true
        player?.play()
    }
    
    override func prepareForReuse() {
         super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
    }

}
