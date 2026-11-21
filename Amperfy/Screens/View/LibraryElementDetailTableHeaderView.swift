//
//  LibraryElementDetailTableHeaderView.swift
//  Amperfy
//
//  Created by Maximilian Bauer on 09.03.19.
//  Copyright (c) 2019 Maximilian Bauer. All rights reserved.
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
import UIKit

typealias GetInfoCallback = () -> String

// MARK: - PlayShuffleInfoConfiguration

struct PlayShuffleInfoConfiguration {
  var infoCB: GetInfoCallback?
  var playContextCb: GetPlayContextCallback?
  var player: PlayerFacade
  let isInfoAlwaysHidden: Bool
  var customPlayName: String?
  var isShuffleHidden = false
  var isShuffleOnContextNeccessary: Bool = true
  var shuffleContextCb: GetPlayContextCallback?
  var isEmbeddedInOtherView: Bool = false
}

// MARK: - LibraryElementDetailTableHeaderView

class LibraryElementDetailTableHeaderView: UIView {
  @IBOutlet
  weak var playAllButton: UIButton!
  @IBOutlet
  weak var playShuffledButton: UIButton!
  @IBOutlet
  weak var infoContainerView: UIView!
  @IBOutlet
  weak var infoLabel: UILabel!

  static let frameHeight: CGFloat = 40.0 + margin.top + margin.bottom
  static let margin = UIView.defaultMarginMiddleElement

  private var config: PlayShuffleInfoConfiguration?

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.layoutMargins = UIEdgeInsets(
      top: 0.0,
      left: UIView.defaultMarginX,
      bottom: 0.0,
      right: UIView.defaultMarginX
    )

    registerForTraitChanges(
      [UITraitUserInterfaceStyle.self, UITraitHorizontalSizeClass.self],
      handler: { (self: Self, previousTraitCollection: UITraitCollection) in
        self.refresh()
      }
    )
  }

  public static func createTableHeader(
    rootView: BasicTableViewController,
    configuration: PlayShuffleInfoConfiguration
  )
    -> LibraryElementDetailTableHeaderView? {
    rootView.tableView.tableHeaderView = UIView(frame: CGRect(
      x: 0,
      y: 0,
      width: rootView.view.bounds.size.width,
      height: Self.frameHeight
    ))
    let genericDetailTableHeaderView = ViewCreator<LibraryElementDetailTableHeaderView>
      .createFromNib(withinFixedFrame: CGRect(
        x: 0,
        y: 0,
        width: rootView.view.bounds.size.width,
        height: Self.frameHeight
      ))!
    genericDetailTableHeaderView.prepare(configuration: configuration)
    rootView.tableView.tableHeaderView?.addSubview(genericDetailTableHeaderView)
    return genericDetailTableHeaderView
  }

  func refresh() {
    guard let config = config else { return }
    if config.isEmbeddedInOtherView {
      layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    } else {
      if traitCollection.horizontalSizeClass == .compact {
        layoutMargins = UIEdgeInsets(
          top: 0.0,
          left: UIView.defaultMarginCellX,
          bottom: 0.0,
          right: UIView.defaultMarginCellX
        )
      } else {
        layoutMargins = UIEdgeInsets(
          top: 0.0,
          left: UIView.defaultMarginX,
          bottom: 0.0,
          right: UIView.defaultMarginX
        )
      }
    }
    infoContainerView.isHidden = config
      .isInfoAlwaysHidden || (traitCollection.horizontalSizeClass == .compact)
    infoLabel.text = config.infoCB?() ?? ""
    applyThemeToButtons()
  }

  @IBAction
  func playAllButtonPressed(_ sender: Any) {
    Haptics.success.vibrate(isHapticsEnabled: appDelegate.storage.settings.user.isHapticsEnabled)
    animateButtonPress(playAllButton)
    play(isShuffled: false)
  }

  @IBAction
  func addAllShuffledButtonPressed(_ sender: Any) {
    Haptics.success.vibrate(isHapticsEnabled: appDelegate.storage.settings.user.isHapticsEnabled)
    animateButtonPress(playShuffledButton)
    shuffle()
  }

  private func animateButtonPress(_ button: UIButton) {
    UIView.animate(withDuration: 0.08, animations: {
      button.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
    }, completion: { _ in
      UIView.animate(withDuration: 0.12, animations: {
        button.transform = .identity
      })
    })
  }

  func applyThemeToButtons() {
    backgroundColor = .clear
    let theme = appDelegate.storage.settings.accounts.activeSetting.read.themePreference
    switch theme {
    case .frutigerAero:
      playAllButton.backgroundColor = UIColor(red: 0.0, green: 0.78, blue: 0.92, alpha: 0.92)
      playAllButton.setTitleColor(.white, for: .normal)
      playAllButton.tintColor = .white
      playAllButton.layer.cornerRadius = 12.0
      playAllButton.layer.borderWidth = 1.0
      playAllButton.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
      playAllButton.layer.shadowOpacity = 0.0

      playShuffledButton.backgroundColor = UIColor(red: 0.0, green: 0.78, blue: 0.92, alpha: 0.92)
      playShuffledButton.setTitleColor(.white, for: .normal)
      playShuffledButton.tintColor = .white
      playShuffledButton.layer.cornerRadius = 12.0
      playShuffledButton.layer.borderWidth = 1.0
      playShuffledButton.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
      playShuffledButton.layer.shadowOpacity = 0.0

    case .cyberpunk:
      playAllButton.backgroundColor = UIColor(red: 1.0, green: 0.16, blue: 0.52, alpha: 1.0)
      playAllButton.setTitleColor(.white, for: .normal)
      playAllButton.tintColor = .white
      playAllButton.layer.cornerRadius = 10.0
      playAllButton.layer.borderWidth = 1.0
      playAllButton.layer.borderColor = UIColor(red: 1.0, green: 0.45, blue: 0.72, alpha: 0.8).cgColor
      playAllButton.layer.shadowOpacity = 0.0

      playShuffledButton.backgroundColor = UIColor(red: 0.0, green: 0.88, blue: 1.0, alpha: 1.0)
      playShuffledButton.setTitleColor(UIColor(red: 0.06, green: 0.02, blue: 0.14, alpha: 1.0), for: .normal)
      playShuffledButton.tintColor = UIColor(red: 0.06, green: 0.02, blue: 0.14, alpha: 1.0)
      playShuffledButton.layer.cornerRadius = 10.0
      playShuffledButton.layer.borderWidth = 1.0
      playShuffledButton.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
      playShuffledButton.layer.shadowOpacity = 0.0

    case .minimalist:
      playAllButton.backgroundColor = UIColor.secondarySystemFill
      playAllButton.setTitleColor(.label, for: .normal)
      playAllButton.tintColor = .label
      playAllButton.layer.cornerRadius = 10.0
      playAllButton.layer.borderWidth = 0.5
      playAllButton.layer.borderColor = UIColor.separator.cgColor
      playAllButton.layer.shadowOpacity = 0.0

      playShuffledButton.backgroundColor = UIColor.secondarySystemFill
      playShuffledButton.setTitleColor(.label, for: .normal)
      playShuffledButton.tintColor = .label
      playShuffledButton.layer.cornerRadius = 10.0
      playShuffledButton.layer.borderWidth = 0.5
      playShuffledButton.layer.borderColor = UIColor.separator.cgColor
      playShuffledButton.layer.shadowOpacity = 0.0

    default:
      playAllButton.backgroundColor = .systemGray6
      playAllButton.layer.cornerRadius = 10.0
      playAllButton.layer.shadowOpacity = 0.0
      playShuffledButton.backgroundColor = .systemGray6
      playShuffledButton.layer.cornerRadius = 10.0
      playShuffledButton.layer.shadowOpacity = 0.0
    }
  }

  private func play(isShuffled: Bool) {
    guard let playContext = config?.playContextCb?(), let player = config?.player else { return }
    isShuffled ? player.playShuffled(context: playContext) : player.play(context: playContext)
  }

  private func shuffle() {
    guard let player = config?.player else { return }
    if let shuffleContext = config?.shuffleContextCb?() {
      if config?.isShuffleOnContextNeccessary ?? true {
        player.playShuffled(context: shuffleContext)
      } else {
        player.play(context: shuffleContext)
      }
    } else {
      play(isShuffled: true)
    }
  }

  /// isShuffleOnContextNeccessary: In AlbumsVC the albums are shuffled, keep the order when shuffle button is pressed
  func prepare(configuration: PlayShuffleInfoConfiguration) {
    config = configuration
    playAllButton.setTitle(config?.customPlayName ?? "Play", for: .normal)
    playShuffledButton.setTitle(
      configuration.isShuffleOnContextNeccessary ? "Shuffle" : "Random",
      for: .normal
    )
    playShuffledButton.isHidden = configuration.isShuffleHidden
    applyThemeToButtons()
    activate()
    registerForTraitChanges(
      [UITraitUserInterfaceStyle.self, UITraitHorizontalSizeClass.self],
      handler: { (self: Self, previousTraitCollection: UITraitCollection) in
        self.refresh()
      }
    )
  }

  func activate() {
    playAllButton.isEnabled = true
    playShuffledButton.isEnabled = !(config?.isShuffleOnContextNeccessary ?? true) || appDelegate
      .storage.settings.user.isPlayerShuffleButtonEnabled
  }

  func deactivate() {
    playAllButton.isEnabled = false
    playShuffledButton.isEnabled = false
  }
}
