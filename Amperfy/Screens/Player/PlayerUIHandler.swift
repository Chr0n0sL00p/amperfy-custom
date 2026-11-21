//
//  PlayerUIHandler.swift
//  Amperfy
//
//  Created by Maximilian Bauer on 01.08.25.
//  Copyright (c) 2025 Maximilian Bauer. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import AmperfyKit
import CoreMedia
import MediaPlayer
import UIKit

// MARK: - PlayerUIStyle

enum PlayerUIStyle {
  case miniPlayerMac
  case popupPlayer
  case miniPlayeriOS
}

// MARK: - PlayerUIHandler

@MainActor
class PlayerUIHandler: NSObject {
  public static let playButtonImagePointSize: CGFloat = 25
  public static let bigButtonImagePointSize: CGFloat = 17
  public static let playAndNextiOSButtonImagePointSize: CGFloat = 15

  private var player: PlayerFacade
  private var style: PlayerUIStyle
  /// Only evaluated for the popup player style: hides the shuffle and repeat buttons when the
  /// surrounding UI already offers them (queue inspector next to the macOS player bar)
  var isShuffleAndRepeatHidden = false

  init(player: PlayerFacade, style: PlayerUIStyle) {
    self.player = player
    self.style = style
  }

  func playButtonPushed() {
    Haptics.light.vibrate(isHapticsEnabled: appDelegate.storage.settings.user.isHapticsEnabled)
    player.togglePlayPause()
  }

  func skipBackwardButtonPushed() {
    Haptics.light.vibrate(isHapticsEnabled: appDelegate.storage.settings.user.isHapticsEnabled)
    player.skipBackward(interval: player.skipBackwardMusicInterval)
    if NestCastManager.shared.isCasting {
      NestCastManager.shared.seek(to: player.elapsedTime)
    }
  }

  func skipForwardButtonPushed() {
    Haptics.light.vibrate(isHapticsEnabled: appDelegate.storage.settings.user.isHapticsEnabled)
    player.skipForward(interval: player.skipForwardMusicInterval)
    if NestCastManager.shared.isCasting {
      NestCastManager.shared.seek(to: player.elapsedTime)
    }
  }

  func previousButtonPushed() {
    Haptics.light.vibrate(isHapticsEnabled: appDelegate.storage.settings.user.isHapticsEnabled)
    switch player.playerMode {
    case .music:
      player.playPreviousOrReplay()
    case .podcast:
      player.skipBackward(interval: player.skipBackwardPodcastInterval)
    }
  }

  func nextButtonPushed() {
    Haptics.light.vibrate(isHapticsEnabled: appDelegate.storage.settings.user.isHapticsEnabled)
    switch player.playerMode {
    case .music:
      player.playNext()
    case .podcast:
      player.skipForward(interval: player.skipForwardPodcastInterval)
    }
  }

  func shuffleButtonPushed() {
    Haptics.light.vibrate(isHapticsEnabled: appDelegate.storage.settings.user.isHapticsEnabled)
    player.toggleShuffle()
  }

  func repeatButtonPushed() {
    Haptics.light.vibrate(isHapticsEnabled: appDelegate.storage.settings.user.isHapticsEnabled)
    player.setRepeatMode(player.repeatMode.nextMode)
  }

  func autoplayButtonPushed() {
    appDelegate.storage.settings.user.isAutoplayEnabled.toggle()
  }

  func refreshPlayButton(_ button: UIButton) {
    var buttonImg = UIImage()
    if player.isPlaying {
      if player.isStopInsteadOfPause {
        buttonImg = UIImage.stop
      } else {
        buttonImg = UIImage.pause
      }
    } else {
      buttonImg = UIImage.play
    }

    switch style {
    case .miniPlayerMac:
      buttonImg = buttonImg
        .withConfiguration(UIImage.SymbolConfiguration(pointSize: Self.playButtonImagePointSize))
    case .miniPlayeriOS:
      buttonImg = buttonImg
        .withConfiguration(
          UIImage
            .SymbolConfiguration(pointSize: Self.playAndNextiOSButtonImagePointSize)
        )
    case .popupPlayer:
      break
    }

    button.setImage(buttonImg, for: UIControl.State.normal)
    button.configuration?.image = buttonImg
    if player.isPlaying {
      button.accessibilityLabel = player.isStopInsteadOfPause ? "Stop" : "Pause"
    } else {
      button.accessibilityLabel = "Play"
    }
  }

  func refreshSkipButtons(skipBackwardButton: UIButton, skipForwardButton: UIButton) {
    skipBackwardButton.accessibilityLabel = "Skip Back 10 Seconds"
    skipForwardButton.accessibilityLabel = "Skip Forward 10 Seconds"
    switch player.playerMode {
    case .music:
      skipBackwardButton.isHidden = !appDelegate.storage.settings.user.isShowMusicPlayerSkipButtons
      skipBackwardButton.isEnabled = player.isSkipAvailable
      skipBackwardButton.alpha = !appDelegate.storage.settings.user
        .isShowMusicPlayerSkipButtons ? 0.0 : 1.0
      skipForwardButton.isHidden = !appDelegate.storage.settings.user.isShowMusicPlayerSkipButtons
      skipForwardButton.isEnabled = player.isSkipAvailable
      skipForwardButton.alpha = !appDelegate.storage.settings.user
        .isShowMusicPlayerSkipButtons ? 0.0 : 1.0
    case .podcast:
      skipBackwardButton.isHidden = true
      skipBackwardButton.isEnabled = true
      skipForwardButton.isHidden = true
      skipForwardButton.isEnabled = true
    }
  }

  func refreshPrevNextButtons(previousButton: UIButton, nextButton: UIButton) {
    previousButton.imageView?.contentMode = .scaleAspectFit
    nextButton.imageView?.contentMode = .scaleAspectFit

    var previouseImg = UIImage()
    var nextImg = UIImage()
    switch player.playerMode {
    case .music:
      previouseImg = UIImage.backwardFill
      nextImg = UIImage.forwardFill
      previousButton.accessibilityLabel = "Previous Song"
      nextButton.accessibilityLabel = "Next Song"
    case .podcast:
      previouseImg = UIImage.goBackward15
      nextImg = UIImage.goForward30
      previousButton.accessibilityLabel = "Skip Back 15 Seconds"
      nextButton.accessibilityLabel = "Skip Forward 30 Seconds"
    }

    switch style {
    case .miniPlayerMac:
      previouseImg = previouseImg.withConfiguration(UIImage.SymbolConfiguration(scale: .medium))
      nextImg = nextImg.withConfiguration(UIImage.SymbolConfiguration(scale: .medium))
    case .popupPlayer:
      break
    case .miniPlayeriOS:
      previouseImg = previouseImg
        .withConfiguration(
          UIImage
            .SymbolConfiguration(pointSize: Self.playAndNextiOSButtonImagePointSize)
        )
      nextImg = nextImg
        .withConfiguration(
          UIImage
            .SymbolConfiguration(pointSize: Self.playAndNextiOSButtonImagePointSize)
        )
    }

    previousButton.setImage(previouseImg, for: UIControl.State.normal)
    previousButton.configuration?.image = previouseImg
    nextButton.setImage(nextImg, for: UIControl.State.normal)
    nextButton.configuration?.image = nextImg
  }

  func refreshRepeatButton(repeatButton: UIButton) {
    let isSelected = player.repeatMode != .off
    var image: UIImage?
    switch player.repeatMode {
    case .off:
      image = .repeatMenu
      repeatButton.accessibilityLabel = "Repeat Off"
    case .all:
      image = .repeatAll
      repeatButton.accessibilityLabel = "Repeat All"
    case .single:
      image = .repeatOne
      repeatButton.accessibilityLabel = "Repeat One"
    }

    switch style {
    case .miniPlayeriOS, .miniPlayerMac:
      repeatButton.configuration?.image = image?
        .withConfiguration(UIImage.SymbolConfiguration(scale: .medium))
      repeatButton.tintColor = isSelected ? .tintColor : .secondaryLabel
      repeatButton.backgroundColor = isSelected ? .tintColor.withAlphaComponent(0.2) : .clear
    case .popupPlayer:
      var config = UIButton.Configuration.player(isSelected: isSelected)
      config.image = image?
        .withConfiguration(UIImage.SymbolConfiguration(scale: .medium))
      repeatButton.configuration = config
      repeatButton.isHidden = isShuffleAndRepeatHidden
    }
    repeatButton.isSelected = isSelected
  }

  func refreshShuffleButton(shuffleButton: UIButton) {
    shuffleButton.accessibilityLabel = player.isShuffle ? "Shuffle On" : "Shuffle Off"
    switch style {
    case .miniPlayeriOS, .miniPlayerMac:
      shuffleButton.configuration?.image = .shuffle
        .withConfiguration(UIImage.SymbolConfiguration(scale: .medium))
      shuffleButton.tintColor = player.isShuffle ? .tintColor : .secondaryLabel
      shuffleButton.backgroundColor = player.isShuffle ? .tintColor.withAlphaComponent(0.2) : .clear
    case .popupPlayer:
      var config = UIButton.Configuration.player(isSelected: player.isShuffle)
      config.image = .shuffle
        .withConfiguration(UIImage.SymbolConfiguration(scale: .medium))
      shuffleButton.configuration = config
      shuffleButton.isHidden = isShuffleAndRepeatHidden
    }
    shuffleButton.isEnabled = appDelegate.storage.settings.user.isPlayerShuffleButtonEnabled
    shuffleButton.isSelected = player.isShuffle
  }

  func refreshAutoplayButton(autoplayButton: UIButton) {
    let isActive = appDelegate.storage.settings.user.isAutoplayEnabled
    autoplayButton.accessibilityLabel = isActive ? "Autoplay On" : "Autoplay Off"

    switch style {
    case .miniPlayeriOS, .miniPlayerMac:
      autoplayButton.configuration?.image = .infinity
        .withConfiguration(UIImage.SymbolConfiguration(scale: .medium))
      autoplayButton.tintColor = isActive ? .tintColor : .secondaryLabel
      autoplayButton.backgroundColor = isActive ? .tintColor.withAlphaComponent(0.2) : .clear
    case .popupPlayer:
      var config = UIButton.Configuration.player(isSelected: isActive)
      config.image = .infinity
        .withConfiguration(UIImage.SymbolConfiguration(scale: .medium))
      autoplayButton.configuration = config
    }
    autoplayButton.isEnabled = player.playerMode == .music
    autoplayButton.isSelected = isActive
  }

  func refreshDisplayPlaylistButton(displayPlaylistButton: UIButton) {
    let isSelected = appDelegate.storage.settings.user.playerDisplayStyle == .compact
    displayPlaylistButton.accessibilityLabel = "Queue"

    switch style {
    case .miniPlayeriOS, .miniPlayerMac:
      displayPlaylistButton.tintColor = isSelected ? .tintColor : .label
    case .popupPlayer:
      var config = UIButton.Configuration.player(isSelected: isSelected)
      config.image = .playlistDisplayStyle
      displayPlaylistButton.isSelected = isSelected
      displayPlaylistButton.configuration = config
    }
  }

  func refreshDisplayLyrisButton(displayLyricsButton: UIButton) {
    let isSelected = appDelegate.storage.settings.user.isPlayerLyricsDisplayed

    switch style {
    case .miniPlayeriOS, .miniPlayerMac:
      displayLyricsButton.tintColor = isSelected ? .tintColor : .label
    case .popupPlayer:
      break
    }
  }

  func refreshPlayerOptions(
    optionsButton: UIButton?,
    menuCreateCB: @escaping () -> [UIMenuElement]
  ) {
    optionsButton?.showsMenuAsPrimaryAction = true
    optionsButton?.menu = UIMenu.lazyMenu(title: "Player Options") {
      menuCreateCB()
    }
  }

  func refreshCurrentlyPlayingInfo(
    artworkImage: LibraryEntityImage,
    titleLabel: UILabel,
    artistLabel: UILabel,
    albumLabel: UILabel? = nil,
    albumButton: UIButton? = nil,
    albumContainerView: UIView? = nil
  ) {
    refreshArtwork(artworkImage: artworkImage)
    if let playableInfo = player.currentlyPlaying {
      if playableInfo.isRadio {
        // For radios, show stream metadata if available, otherwise show station name
        if let radioInfo = player.currentRadioNowPlaying, !radioInfo.isEmpty {
          titleLabel.text = radioInfo.title
          artistLabel.text = radioInfo.artist
        } else {
          titleLabel.text = playableInfo.title
          artistLabel.text = ""
        }
        // Show station name in album label
        albumLabel?.text = playableInfo.title
        albumButton?.isEnabled = false
        albumContainerView?.isHidden = false
      } else {
        titleLabel.text = playableInfo.title
        albumLabel?.text = playableInfo.asSong?.album?.name ?? ""
        albumButton?.isEnabled = playableInfo.isSong
        albumContainerView?.isHidden = !playableInfo.isSong
        artistLabel.text = playableInfo.creatorName
      }
    } else {
      switch player.playerMode {
      case .music:
        titleLabel.text = "No music playing"
      case .podcast:
        titleLabel.text = "No podcast playing"
      }
      albumLabel?.text = ""
      albumButton?.isEnabled = false
      albumContainerView?.isHidden = true
      artistLabel.text = ""
    }
  }

  func refreshArtwork(artworkImage: LibraryEntityImage) {
    if let playableInfo = player.currentlyPlaying {
      artworkImage.display(entity: playableInfo)
    } else {
      switch player.playerMode {
      case .music:
        artworkImage.display(
          artworkType: .song
        )
      case .podcast:
        artworkImage.display(
          artworkType: .podcastEpisode
        )
      }
    }
  }

  func airplayButtonPushed(rootView: UIView) {
    appDelegate.userStatistics.usedAction(.airplay)

    #if targetEnvironment(macCatalyst)
      if let url = URL(string: "x-apple.systempreferences:com.apple.Sound-Settings.extension") {
        UIApplication.shared.open(url)
      }
    #else
      guard let window = rootView.window,
            let rootVC = window.rootViewController else {
        triggerNativeAirPlay(rootView: rootView)
        return
      }

      var presenter: UIViewController = rootVC
      while let presented = presenter.presentedViewController {
        presenter = presented
      }

      let isCasting = NestCastManager.shared.isCasting
      let alert = UIAlertController(
        title: "Dispositivo de Audio",
        message: isCasting
          ? "Actualmente transmitiendo a Google Nest Mini (Comedor)."
          : "Selecciona dónde reproducir la música:",
        preferredStyle: .actionSheet
      )

      if isCasting {
        alert.addAction(UIAlertAction(title: "Desconectar Google Nest Mini (Volver al iPhone)", style: .destructive, handler: { _ in
          NestCastManager.shared.disconnect(rootView: rootView)
        }))

        alert.addAction(UIAlertAction(title: "Ajustar Volumen de Nest Mini", style: .default, handler: { _ in
          NestCastManager.shared.showVolumeSliderAlert(presenter: presenter)
        }))
      } else {
        alert.addAction(UIAlertAction(title: "Google Nest Mini (Comedor)", style: .default, handler: { _ in
          NestCastManager.shared.connect(rootView: rootView)
        }))
      }

      alert.addAction(UIAlertAction(title: "AirPlay / Bluetooth (iPhone, AirPods)", style: .default, handler: { [weak self] _ in
        guard let self = self else { return }
        self.triggerNativeAirPlay(rootView: rootView)
      }))

      alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))

      if let popover = alert.popoverPresentationController {
        popover.sourceView = rootView
        popover.sourceRect = rootView.bounds
      }

      presenter.present(alert, animated: true, completion: nil)
    #endif
  }

  private func triggerNativeAirPlay(rootView: UIView) {
    let rect = CGRect(x: -100, y: 0, width: 0, height: 0)
    let airplayVolume = MPVolumeView(frame: rect)
    airplayVolume.showsVolumeSlider = false
    rootView.addSubview(airplayVolume)
    for view: UIView in airplayVolume.subviews {
      if let button = view as? UIButton {
        button.sendActions(for: .touchUpInside)
        break
      }
    }
    airplayVolume.removeFromSuperview()
  }

  var isLyricsButtonAllowedToDisplay: Bool {
    appDelegate.player.playerMode == .music && appDelegate.storage.settings.accounts
      .availableApiTypes.contains(.subsonic)
  }

  private var remainingTime: Int? {
    let duration = player.duration
    if player.currentlyPlaying != nil, duration.isNormal, !duration.isZero {
      return Int(player.elapsedTime - ceil(player.duration))
    }
    return nil
  }

  func timeSliderChanged(timeSlider: UISlider) {
    let target = Double(timeSlider.value)
    player.seek(toSecond: target)
    if NestCastManager.shared.isCasting {
      NestCastManager.shared.seek(to: target)
    }
  }

  func timeSliderIsChanging(
    timeSlider: UISlider,
    elapsedTimeLabel: UILabel,
    remainingTimeLabel: UILabel
  ) {
    let elapsedClockTime = ClockTime(timeInSeconds: Int(timeSlider.value))
    elapsedTimeLabel.text = elapsedClockTime.asShortString()
    let remainingTime =
      ClockTime(timeInSeconds: Int(Double(timeSlider.value) - ceil(player.duration)))
    remainingTimeLabel.text = remainingTime.asShortString()
  }

  func refreshTimeInfo(
    timeSlider: UISlider,
    elapsedTimeLabel: UILabel,
    remainingTimeLabel: UILabel,
    audioInfoLabel: UILabel,
    playTypeIcon: UIImageView,
    liveLabel: UILabel
  ) {
    timeSlider.preferredBehavioralStyle = .pad
    timeSlider.sliderStyle = .thumbless
    if let currentlyPlaying = player.currentlyPlaying {
      let supportTimeInteraction = !currentlyPlaying.isRadio
      timeSlider.isEnabled = supportTimeInteraction && (style != .miniPlayeriOS)
      timeSlider.minimumValue = 0.0
      timeSlider.maximumValue = Float(player.duration)
      if !timeSlider.isTracking, supportTimeInteraction {
        let elapsedClockTime = ClockTime(timeInSeconds: Int(player.elapsedTime))
        elapsedTimeLabel.text = elapsedClockTime.asShortString()
        if let remainingTime = remainingTime {
          remainingTimeLabel.text = ClockTime(timeInSeconds: remainingTime).asShortString()
        } else {
          remainingTimeLabel.text = "--:--"
        }
        timeSlider.value = Float(player.elapsedTime)
      }

      if !supportTimeInteraction {
        audioInfoLabel.isHidden = true
        playTypeIcon.isHidden = true
        liveLabel.isHidden = false
        timeSlider.minimumValue = 0.0
        timeSlider.maximumValue = 1.0
        timeSlider.value = 0.0

        // make the middle part of the time slider transparent
        let mask = CAGradientLayer()
        mask.frame = timeSlider.bounds
        mask.colors = [
          UIColor.white.cgColor,
          UIColor.white.withAlphaComponent(0).cgColor,
          UIColor.white.withAlphaComponent(0).cgColor,
          UIColor.white.cgColor,
        ]
        mask.startPoint = CGPoint(x: 0.0, y: 0.0)
        mask.endPoint = CGPoint(x: 1.0, y: 0.0)
        mask.locations = [
          0.0, 0.4, 0.6, 1.0,
        ]
        timeSlider.layer.mask = mask

        elapsedTimeLabel.text = ""
        remainingTimeLabel.text = ""
      } else {
        audioInfoLabel.isHidden = false
        playTypeIcon.isHidden = false
        refreshAudioInfo(
          currentlyPlaying: currentlyPlaying,
          audioInfoLabel: audioInfoLabel,
          playTypeIcon: playTypeIcon
        )

        liveLabel.isHidden = true
        timeSlider.layer.mask = nil
      }
    } else {
      audioInfoLabel.isHidden = true
      playTypeIcon.isHidden = true
      liveLabel.isHidden = true
      timeSlider.layer.mask = nil
      elapsedTimeLabel.text = "--:--"
      remainingTimeLabel.text = "--:--"
      timeSlider.isEnabled = false
      timeSlider.minimumValue = 0.0
      timeSlider.maximumValue = 1.0
      timeSlider.value = 0.0
    }
  }

  private func refreshAudioInfo(
    currentlyPlaying: AbstractPlayable,
    audioInfoLabel: UILabel,
    playTypeIcon: UIImageView
  ) {
    guard let playType = player.playType else {
      playTypeIcon.image = nil
      playTypeIcon.isHidden = true
      audioInfoLabel.isHidden = true
      return
    }
    playTypeIcon.isHidden = false
    audioInfoLabel.isHidden = false
    var displayBitrateInKbps = 0
    var formatText = ""

    func getFormat(contentType: String?) -> String {
      guard let contentType else { return "" }
      var contentFormatText = ""
      // Display MIME type: "audio/mp3" -> "MP3"
      let components = contentType.split(separator: "/")
      if components.count > 1 {
        let format = String(components[1]).uppercased()
        // Format for display
        switch format {
        case "MP3", "MPEG":
          contentFormatText = "MP3"
        default:
          if format.contains("LOSSLESS") {
            contentFormatText = "LOSSLESS"
          } else if format.hasPrefix("X-"), format.count > "X-".count {
            contentFormatText = String(format.dropFirst("X-".count))
          } else {
            contentFormatText = format
          }
        }
      }
      return contentFormatText
    }

    if playType == .cache {
      playTypeIcon.image = UIImage.cache
      displayBitrateInKbps = currentlyPlaying.bitrate / 1000
      formatText = getFormat(contentType: currentlyPlaying.fileContentType)
    } else {
      playTypeIcon.image = UIImage.antenna
      let streamingBitrate = player.activeStreamingBitrate
      if let streamingBitrate {
        if streamingBitrate == .noLimit ||
          (streamingBitrate.rawValue > (currentlyPlaying.bitrate / 1000)) {
          displayBitrateInKbps = currentlyPlaying.bitrate / 1000
        } else {
          displayBitrateInKbps = streamingBitrate.rawValue
        }
      } else {
        displayBitrateInKbps = 0
      }

      let transcodingFormat = player.activeTranscodingFormat
      if let transcodingFormat {
        if transcodingFormat == .raw {
          // it is the format of the streamed file
          formatText = getFormat(contentType: currentlyPlaying.contentType)
        } else {
          formatText = transcodingFormat.shortInfo
        }
      } else {
        formatText = ""
      }
    }

    audioInfoLabel
      .text = (displayBitrateInKbps > 0) ? "\(formatText) \(displayBitrateInKbps) kbps" :
      "\(formatText)"
    playTypeIcon.tintColor = .label
  }
}

// MARK: - NestCastState Notification

extension Notification.Name {
  public static let nestCastStateChanged = Notification.Name("de.amperfy.nestCast.stateChanged")
}

// MARK: - NestCastManager

@MainActor
public class NestCastManager: NSObject, MusicPlayable {
  public static let shared = NestCastManager()

  public private(set) var isCasting: Bool = false
  public private(set) var remoteVolume: Float = 0.5
  private var savedLocalVolume: Float = 1.0
  private var lastCastingSongId: String? = nil

  private let endpoints = [
    "http://100.117.169.38:4550",
    "http://192.168.100.90:4550"
  ]

  private var player: PlayerFacade?

  public func setup(player: PlayerFacade) {
    self.player = player
    player.addNotifier(notifier: self)
  }

  // MARK: - Connect & Cast

  public func connect(rootView: UIView) {
    guard var player = player ?? (UIApplication.shared.delegate as? AppDelegate)?.player else { return }
    self.player = player

    guard let song = player.currentlyPlaying else {
      let alert = UIAlertController(
        title: "Google Nest Mini",
        message: "No hay ninguna canción reproduciéndose en este momento.",
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      presentAlert(alert, from: rootView)
      return
    }

    let songTitle = song.title
    let songId = song.id
    let currentTime = player.elapsedTime

    let currentVol = player.volume
    if currentVol > 0.05 {
      savedLocalVolume = currentVol
    } else {
      savedLocalVolume = 0.8
    }

    isCasting = true
    lastCastingSongId = songId

    // Mute local iPhone audio so only the Nest Mini sounds, but timeline keeps running
    player.volume = 0.0

    sendCastPlay(songId: songId, title: songTitle, startTime: currentTime)
    NotificationCenter.default.post(name: .nestCastStateChanged, object: nil)

    let alert = UIAlertController(
      title: "Google Nest Mini (Comedor)",
      message: "Transmitiendo \"\(songTitle)\" al parlante desde el minuto exacto.\nEl audio del iPhone se silenció.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    presentAlert(alert, from: rootView)
  }

  // MARK: - Disconnect

  public func disconnect(rootView: UIView? = nil) {
    guard isCasting else { return }
    isCasting = false
    lastCastingSongId = nil

    sendCastControl(action: "stop")
    NotificationCenter.default.post(name: .nestCastStateChanged, object: nil)

    if var player = player ?? (UIApplication.shared.delegate as? AppDelegate)?.player {
      player.volume = savedLocalVolume > 0.05 ? savedLocalVolume : 0.8
    }

    if let rootView = rootView {
      let alert = UIAlertController(
        title: "Google Nest Mini",
        message: "Desconectado. El audio ha vuelto a tu iPhone.",
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      presentAlert(alert, from: rootView)
    }
  }

  // MARK: - Volume Control

  public func setVolume(_ volume: Float) {
    guard isCasting else { return }
    let clamped = max(0.0, min(1.0, volume))
    remoteVolume = clamped
    sendCastControl(action: "volume", extra: ["volume": clamped])
  }

  public func showVolumeSliderAlert(presenter: UIViewController) {
    let alert = UIAlertController(
      title: "Volumen Google Nest Mini",
      message: "Nivel actual: \(Int(remoteVolume * 100))%\nSelecciona el volumen deseado:",
      preferredStyle: .actionSheet
    )
    let volumes: [(String, Float)] = [
      ("20%", 0.2),
      ("40%", 0.4),
      ("60%", 0.6),
      ("80%", 0.8),
      ("100%", 1.0)
    ]
    for (label, vol) in volumes {
      alert.addAction(UIAlertAction(title: label, style: .default, handler: { [weak self] _ in
        self?.setVolume(vol)
      }))
    }
    alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
    presenter.present(alert, animated: true, completion: nil)
  }

  // MARK: - Seeking

  public func seek(to second: Double) {
    guard isCasting else { return }
    sendCastControl(action: "seek", extra: ["time": second])
  }

  // MARK: - MusicPlayable Callbacks

  public func didStartPlayingFromBeginning() {
    guard isCasting else { return }
    guard var player = player ?? (UIApplication.shared.delegate as? AppDelegate)?.player else { return }
    player.volume = 0.0

    guard let song = player.currentlyPlaying else { return }
    lastCastingSongId = song.id
    sendCastPlay(songId: song.id, title: song.title, startTime: 0.0)
  }

  public func didStartPlaying() {
    guard isCasting else { return }
    guard var player = player ?? (UIApplication.shared.delegate as? AppDelegate)?.player else { return }
    player.volume = 0.0

    if let currentSong = player.currentlyPlaying, currentSong.id != lastCastingSongId {
      lastCastingSongId = currentSong.id
      sendCastPlay(songId: currentSong.id, title: currentSong.title, startTime: player.elapsedTime)
    } else {
      sendCastControl(action: "resume")
    }
  }

  public func didPause() {
    guard isCasting else { return }
    sendCastControl(action: "pause")
  }

  public func didStopPlaying() {
    guard isCasting else { return }
    sendCastControl(action: "stop")
  }

  public func didElapsedTimeChange() {
    if isCasting, var player = player, player.volume > 0.01 {
      savedLocalVolume = player.volume
      player.volume = 0.0
    }
  }

  public func didPlaylistChange() {}
  public func didArtworkChange() {}
  public func didNowPlayingInfoChange() {}
  public func didShuffleChange() {}
  public func didRepeatChange() {}
  public func didPlaybackRateChange() {}

  // MARK: - Networking

  private func sendCastPlay(songId: String, title: String, startTime: Double) {
    var payload: [String: Any] = [
      "title": title,
      "time": startTime,
      "start_time": startTime
    ]
    if !songId.isEmpty {
      payload["id"] = songId
    }

    guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else { return }

    for base in endpoints {
      guard let url = URL(string: "\(base)/api/cast/play") else { continue }
      var req = URLRequest(url: url)
      req.httpMethod = "POST"
      req.setValue("application/json", forHTTPHeaderField: "Content-Type")
      req.httpBody = jsonData
      req.timeoutInterval = 4.0

      URLSession.shared.dataTask(with: req) { [weak self] data, _, _ in
        if let data = data,
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let vol = json["volume"] as? Double {
          Task { @MainActor in
            self?.remoteVolume = Float(vol)
          }
        }
      }.resume()
    }
  }

  private func sendCastControl(action: String, extra: [String: Any] = [:]) {
    var payload: [String: Any] = ["action": action]
    for (k, v) in extra {
      payload[k] = v
    }

    guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else { return }

    for base in endpoints {
      guard let url = URL(string: "\(base)/api/cast/control") else { continue }
      var req = URLRequest(url: url)
      req.httpMethod = "POST"
      req.setValue("application/json", forHTTPHeaderField: "Content-Type")
      req.httpBody = jsonData
      req.timeoutInterval = 3.0
      URLSession.shared.dataTask(with: req).resume()
    }
  }

  private func presentAlert(_ alert: UIAlertController, from rootView: UIView) {
    if let window = rootView.window, let rootVC = window.rootViewController {
      var presenter = rootVC
      while let p = presenter.presentedViewController { presenter = p }
      presenter.present(alert, animated: true)
    }
  }
}
