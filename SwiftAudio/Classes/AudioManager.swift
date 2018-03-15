//
//  AudioManager.swift
//  Pods-SwiftAudio_Example
//
//  Created by Jørgen Henrichsen on 15/03/2018.
//

import Foundation
import MediaPlayer


public protocol AudioItem {
    
    var audioUrl: String { get }
    
    var artist: String? { get }
    
    var title: String? { get }
    
    var albumTitle: String? { get }
    
}

public struct DefaultAudioItem: AudioItem {
    
    public var audioUrl: String
    
    public var artist: String?
    
    public var title: String?
    
    public var albumTitle: String?
    
    public init(audioUrl: String, artist: String?, title: String?, albumTitle: String?) {
        self.audioUrl = audioUrl
        self.artist = artist
        self.title = title
        self.albumTitle = albumTitle
    }
}

public protocol AudioManagerDelegate: class {
    
    func audioManager(playerDidChangeState state: AudioPlayerState)
    
    func audioManagerItemDidComplete()
    
    func audioManager(secondsElapsed seconds: Double)
    
    func audioManager(failedWithError error: Error?)
    
    func audioManager(seekTo seconds: Int, didFinish: Bool)
}

/**
 The class managing the AudioPlayern and NowPlayingInfoCenter.
 */
public class AudioManager {
    
    let audioPlayer: AudioPlayer
    let nowPlayingInfoController: NowPlayingInfoController
    
    public weak var delegate: AudioManagerDelegate?
    public var currentItem: AudioItem?
    
    public var currentTime: Double {
        return audioPlayer.currentTime
    }
    
    public var duration: Double {
        return audioPlayer.duration
    }
    
    public var rate: Float {
        return audioPlayer.rate
    }
    
    public var playerState: AudioPlayerState {
        return audioPlayer.state
    }
    
    public init(config: AudioPlayer.Config = AudioPlayer.Config(), infoCenter: MPNowPlayingInfoCenter = MPNowPlayingInfoCenter.default()) {
        self.audioPlayer = AudioPlayer(config: config)
        self.nowPlayingInfoController = NowPlayingInfoController(infoCenter: infoCenter)
        
        self.audioPlayer.delegate = self
    }
    
    public func load(item: AudioItem, playWhenReady: Bool = true) {
        try? self.audioPlayer.load(from: item.audioUrl, playWhenReady: playWhenReady)
        
        self.currentItem = item
        nowPlayingInfoController.set(keyValues: [
            MediaItemProperty.artist(item.artist),
            MediaItemProperty.title(item.title),
            MediaItemProperty.albumTitle(item.albumTitle),
            ])
    }
    
    public func togglePlaying() {
        self.audioPlayer.togglePlaying()
    }
    
    public func seek(to seconds: TimeInterval) {
        self.audioPlayer.seek(to: seconds)
    }
    
    func updatePlaybackValues() {
        nowPlayingInfoController.set(keyValue: NowPlayingInfoProperty.elapsedPlaybackTime(audioPlayer.currentTime))
        nowPlayingInfoController.set(keyValue: MediaItemProperty.duration(audioPlayer.duration))
        nowPlayingInfoController.set(keyValue: NowPlayingInfoProperty.playbackRate(Double(audioPlayer.rate)))
    }
    
}

extension AudioManager: AudioPlayerDelegate {
    
    public func audioPlayer(didChangeState state: AudioPlayerState) {
        updatePlaybackValues()
        self.delegate?.audioManager(playerDidChangeState: state)
    }
    
    public func audioPlayerItemDidComplete() {
        self.delegate?.audioManagerItemDidComplete()
    }
    
    public func audioPlayer(secondsElapsed seconds: Double) {
        self.delegate?.audioManager(secondsElapsed: seconds)
    }
    
    public func audioPlayer(failedWithError error: Error?) {
        self.delegate?.audioManager(failedWithError: error)
    }
    
    public func audioPlayer(seekTo seconds: Int, didFinish: Bool) {
        self.delegate?.audioManager(seekTo: seconds, didFinish: didFinish)
    }
    
}