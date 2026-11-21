//
//  UtilitiesExtensions.swift
//  Amperfy
//
//  Created by Maximilian Bauer on 06.06.22.
//  Copyright (c) 2022 Maximilian Bauer. All rights reserved.
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
import Foundation
import MarqueeLabel
import os.log
import SwiftUI
import UIKit

extension MarqueeLabel {
  func applyAmperfyStyle() {
    if trailingBuffer != 30.0 {
      trailingBuffer = 30.0
    }
    if leadingBuffer != 0.0 {
      leadingBuffer = 0.0
    }
    if animationDelay != 2.0 {
      animationDelay = 2.0
    }
    if type != .continuous {
      type = .continuous
    }
    speed = .rate(30.0)
    if fadeLength != 10.0 {
      fadeLength = 10.0
    }
  }
}

extension UIColor {
  static let hardLabelColor = UIColor(named: "hardLabelColor")
}

extension Color {
  static let error = Color.red
  static let success = Color.green

  // MARK: - Text Colors

  static let lightText = Color(UIColor.lightText)
  static let darkText = Color(UIColor.darkText)
  static let placeholderText = Color(UIColor.placeholderText)

  // MARK: - Label Colors

  static let label = Color(UIColor.label)
  static let secondaryLabel = Color(UIColor.secondaryLabel)
  static let tertiaryLabel = Color(UIColor.tertiaryLabel)
  static let quaternaryLabel = Color(UIColor.quaternaryLabel)

  // MARK: - Background Colors

  static let systemBackground = Color(UIColor.systemBackground)
  static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
  static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)

  // MARK: - Fill Colors

  static let systemFill = Color(UIColor.systemFill)
  static let secondarySystemFill = Color(UIColor.secondarySystemFill)
  static let tertiarySystemFill = Color(UIColor.tertiarySystemFill)
  static let quaternarySystemFill = Color(UIColor.quaternarySystemFill)

  // MARK: - Grouped Background Colors

  static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)
  static let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
  static let tertiarySystemGroupedBackground = Color(UIColor.tertiarySystemGroupedBackground)

  // MARK: - Gray Colors

  static let systemGray = Color(UIColor.systemGray)
  static let systemGray2 = Color(UIColor.systemGray2)
  static let systemGray3 = Color(UIColor.systemGray3)
  static let systemGray4 = Color(UIColor.systemGray4)
  static let systemGray5 = Color(UIColor.systemGray5)
  static let systemGray6 = Color(UIColor.systemGray6)

  // MARK: - Other Colors

  static let separator = Color(UIColor.separator)
  static let opaqueSeparator = Color(UIColor.opaqueSeparator)
  static let link = Color(UIColor.link)

  // MARK: System Colors

  static let systemBlue = Color(UIColor.systemBlue)
  static let systemPurple = Color(UIColor.systemPurple)
  static let systemGreen = Color(UIColor.systemGreen)
  static let systemYellow = Color(UIColor.systemYellow)
  static let systemOrange = Color(UIColor.systemOrange)
  static let systemPink = Color(UIColor.systemPink)
  static let systemRed = Color(UIColor.systemRed)
  static let systemTeal = Color(UIColor.systemTeal)
  static let systemIndigo = Color(UIColor.systemIndigo)
}

public func withPopupAnimation<Result>(_ body: () throws -> Result) rethrows -> Result {
  try withAnimation(.easeInOut(duration: 0.2)) {
    try body()
  }
}

extension View {
  var appDelegate: AppDelegate {
    (UIApplication.shared.delegate as! AppDelegate)
  }
}

extension UIButton.Configuration {
  static func player(isSelected: Bool) -> UIButton.Configuration {
    var config = UIButton.Configuration.tinted()
    if isSelected {
      config.background.strokeColor = .label
      config.background.strokeWidth = 1.0
      config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
    }
    config.buttonSize = .small
    #if targetEnvironment(macCatalyst)
      config.baseForegroundColor = .label
      config.baseBackgroundColor = .clear
    #else
      config.baseForegroundColor = !isSelected ? .label : .systemBackground
      config.baseBackgroundColor = !isSelected ? .clear : .label
    #endif
    config.cornerStyle = .medium
    return config
  }

  static func playerRound() -> UIButton.Configuration {
    var config = UIButton.Configuration.gray()
    config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
    config.buttonSize = .small
    return config
  }
}

extension UIViewController {
  /// macOS: shows or hides the title in the title bar of the view controller's window
  public func setWindowTitle(isHidden: Bool) {
    #if targetEnvironment(macCatalyst)
      view.window?.windowScene?.titlebar?.titleVisibility = isHidden ? .hidden : .visible
    #endif
  }
}

extension UINavigationItem {
  /// Transparent navigation bar without separator line
  public func configureTransparentAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.shadowColor = .clear
    standardAppearance = appearance
    compactAppearance = appearance
    scrollEdgeAppearance = appearance
    compactScrollEdgeAppearance = appearance
  }
}

extension UIView {
  /// Centers the view in `container` and sizes it relative to the container. The default
  /// multiplier lets the view fill the container. The view must already be in the same view
  /// hierarchy as `container`.
  public func constrainCentered(in container: UIView, sizeMultiplier: CGFloat = 1.0) {
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      centerXAnchor.constraint(equalTo: container.centerXAnchor),
      centerYAnchor.constraint(equalTo: container.centerYAnchor),
      widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: sizeMultiplier),
      heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: sizeMultiplier),
    ])
  }

  public func setBackgroundBlur(style: UIBlurEffect.Style, alpha: CGFloat = 1.0) {
    backgroundColor = UIColor.clear
    let blurEffect = UIBlurEffect(style: style)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.alpha = alpha
    blurEffectView.frame = bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    insertSubview(blurEffectView, at: 0)
  }
}

extension UINavigationController {
  func replaceCurrentlyActiveVC(with vc: UIViewController, animated: Bool) {
    var vcs = viewControllers
    vcs = vcs.dropLast()
    vcs.append(vc)
    setViewControllers(vcs, animated: animated)
  }
}

extension UITableView {
  func register(nibName: String) {
    register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
  }

  func dequeueCell<CellType: UITableViewCell>(
    for tableView: UITableView,
    at indexPath: IndexPath
  )
    -> CellType {
    guard let cell = dequeueReusableCell(
      withIdentifier: CellType.typeName,
      for: indexPath
    ) as? CellType else {
      os_log(.error, "The dequeued cell is not an instance of %s", CellType.typeName)
      return CellType()
    }
    return cell
  }

  func hasRowAt(indexPath: IndexPath) -> Bool {
    indexPath.section < numberOfSections && indexPath
      .row < numberOfRows(inSection: indexPath.section)
  }

  // MARK: Text size

  /// Keeps the rows up to date with the user's text size (see `TextScaling`): whenever it
  /// changes, the table is reloaded, so that cells and `tableView(_:heightForRowAt:)` pick up
  /// the new size. Tables with one height for all rows pass it as `rowHeight`: it is applied to
  /// `rowHeight` and `estimatedRowHeight` now and before every reload.
  func reloadOnTextSizeChange(rowHeight: (@MainActor () -> CGFloat)? = nil) {
    let applyRowHeight = { (tableView: UITableView) in
      guard let rowHeight else { return }
      tableView.rowHeight = rowHeight()
      tableView.estimatedRowHeight = tableView.rowHeight
    }
    applyRowHeight(self)
    registerForTraitChanges(
      [UITraitPreferredContentSizeCategory.self],
      handler: { (self: Self, previousTraitCollection: UITraitCollection) in
        applyRowHeight(self)
        self.reloadData()
      }
    )
  }
}

// MARK: - TextScaling

/// Proxy for everything that scales with the user's text size: fonts of `ScaledLabel`s, row
/// heights and other text dependent sizes. The text size is the system's or the in-app text size
/// (Settings > Display), which `AppDelegate.applyTextSize()` sets as `preferredContentSizeCategory`
/// trait override on all windows, so views get notified like for Dynamic Type changes.
/// - iOS/iPadOS: forwards to Dynamic Type (text styles in the xibs, `UIFontMetrics`).
/// - Mac Catalyst: macOS has no Dynamic Type, text styles always have the same size. Fonts and
///   sizes are scaled with the factors of the iOS text sizes instead.
@MainActor
enum TextScaling {
  /// Text sizes that can be chosen in the settings
  static let textSizes: [UIContentSizeCategory] = [
    .extraSmall, .small, .medium, .large, .extraLarge, .extraExtraLarge, .extraExtraExtraLarge,
    .accessibilityMedium, .accessibilityLarge, .accessibilityExtraLarge,
    .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge,
  ]

  /// The in-app text size, nil: system text size (iOS) / default text size (Mac)
  static var textSize: UIContentSizeCategory?

  /// Size of the body text style on iOS for each text size (17pt at the default size)
  private static let bodySizes: [UIContentSizeCategory: CGFloat] = [
    .extraSmall: 14, .small: 15, .medium: 16, .large: 17, .extraLarge: 19,
    .extraExtraLarge: 21, .extraExtraExtraLarge: 23, .accessibilityMedium: 28,
    .accessibilityLarge: 33, .accessibilityExtraLarge: 40, .accessibilityExtraExtraLarge: 47,
    .accessibilityExtraExtraExtraLarge: 53,
  ]

  /// `.footnote` scales slightly stronger than `.body`, so scaled sizes leave enough room
  private static let metrics = UIFontMetrics(forTextStyle: .footnote)

  /// iOS: unchanged, Dynamic Type scales the font. Mac: scaled to the traits' text size.
  static func scaledFont(_ font: UIFont, compatibleWith traits: UITraitCollection) -> UIFont {
    #if targetEnvironment(macCatalyst)
      return font.withSize((font.pointSize * factor(for: currentTextSize(traits))).rounded())
    #else
      return font
    #endif
  }

  /// `value` at the default text size, scaled to the text size of `traits` (or the app's)
  static func scaledValue(
    _ value: CGFloat,
    compatibleWith traits: UITraitCollection? = nil,
    maximum: UIContentSizeCategory? = nil
  )
    -> CGFloat {
    var textSize = currentTextSize(traits)
    if let maximum, textSize > maximum {
      textSize = maximum
    }
    #if targetEnvironment(macCatalyst)
      return value * factor(for: textSize)
    #else
      return metrics.scaledValue(
        for: value,
        compatibleWith: UITraitCollection(preferredContentSizeCategory: textSize)
      )
    #endif
  }

  /// The traits of a view in a window already contain the in-app text size (and its maximum)
  private static func currentTextSize(_ traits: UITraitCollection?) -> UIContentSizeCategory {
    if let traitsTextSize = traits?.preferredContentSizeCategory,
       traitsTextSize != .unspecified {
      return traitsTextSize
    }
    return textSize ?? UIApplication.shared.preferredContentSizeCategory
  }

  private static func factor(for textSize: UIContentSizeCategory) -> CGFloat {
    (bodySizes[textSize] ?? 17.0) / 17.0
  }
}

// MARK: - ScaledLabel

/// Label whose text scales with the user's text size. Use it as custom class in xibs together
/// with a text style font (incl. size class variations).
/// - iOS/iPadOS: a plain `UILabel`, Dynamic Type scales the text style.
/// - Mac Catalyst: every font that gets assigned (by the xib or code) is the unscaled base font,
///   the label displays it scaled by `TextScaling`.
class ScaledLabel: UILabel {
  #if targetEnvironment(macCatalyst)
    private var unscaledFont: UIFont?
    private var isRegisteredForTextSizeChanges = false

    override var font: UIFont! {
      get { super.font }
      set {
        unscaledFont = newValue
        guard newValue != nil else {
          super.font = nil
          return
        }
        applyScaledFont()
      }
    }

    override func didMoveToWindow() {
      super.didMoveToWindow()
      if !isRegisteredForTextSizeChanges {
        isRegisteredForTextSizeChanges = true
        registerForTraitChanges(
          [UITraitPreferredContentSizeCategory.self],
          handler: { (self: Self, previousTraitCollection: UITraitCollection) in
            self.applyScaledFont()
          }
        )
      }
      applyScaledFont()
    }

    private func applyScaledFont() {
      if unscaledFont == nil {
        unscaledFont = super.font
      }
      guard let unscaledFont else { return }
      super.font = TextScaling.scaledFont(unscaledFont, compatibleWith: traitCollection)
    }
  #endif
}

extension UICollectionView {
  func hasItemAt(indexPath: IndexPath) -> Bool {
    indexPath.section < numberOfSections && indexPath
      .row < numberOfItems(inSection: indexPath.section)
  }
}

@MainActor
extension UITableViewController {
  func dequeueCell<CellType: UITableViewCell>(
    for tableView: UITableView,
    at indexPath: IndexPath
  )
    -> CellType {
    self.tableView.dequeueCell(for: tableView, at: indexPath)
  }

  func exectueAfterAnimation(body: @escaping () -> ()) {
    Task { @MainActor in
      body()
    }
  }
}

extension UIViewController {
  var typeName: String {
    Self.typeName
  }
}

extension NSObject {
  @MainActor
  var appDelegate: AppDelegate {
    (UIApplication.shared.delegate as! AppDelegate)
  }
}

extension UIApplication {
  var mainWindow: UIWindow? {
    let scenes = UIApplication.shared.connectedScenes
    for uiScene in scenes {
      if let windowScene = uiScene as? UIWindowScene {
        for window in windowScene.windows {
          if window.isKeyWindow {
            return window
          }
        }
      }
    }
    return nil
  }
}

extension UITraitCollection {
  static let maxDisplayScale = UITraitCollection(displayScale: 3.0)
}

extension UITableViewCell {
  func animateActivation() {
    UIView.animate(withDuration: 0.2, animations: {
      self.markAsFocused()
    }, completion: { _ in
      self.markAsFocused()
      UIView.animate(withDuration: 0.2, animations: {
        self.markAsUnfocused()
      }, completion: { _ in
        self.markAsUnfocused()
      })
    })
  }

  func markAsFocused() {
    backgroundColor = .systemGray4
  }

  func markAsUnfocused() {
    backgroundColor = .clear
  }
}

extension UICollectionViewCell {
  func animateActivation() {
    UIView.animate(withDuration: 0.2, animations: {
      self.markAsFocused()
    }, completion: { _ in
      self.markAsFocused()
      UIView.animate(withDuration: 0.2, animations: {
        self.markAsUnfocused()
      }, completion: { _ in
        self.markAsUnfocused()
      })
    })
  }

  /// `@objc` so that subclasses can override it (e.g. `KeyboardFocusableListCell`)
  @objc
  func markAsFocused() {
    let focuseBackground = UIView(frame: bounds)
    focuseBackground.backgroundColor = .systemGray4
    backgroundView = focuseBackground
  }

  @objc
  func markAsUnfocused() {
    backgroundView = nil
  }
}

extension UIMenu {
  /// rebuilds menu on every access
  static func lazyMenu(
    title: String = "",
    builder: @escaping () -> [UIMenuElement]
  )
    -> UIMenu {
    UIMenu(title: title, children: [
      UIDeferredMenuElement.uncached { completion in
        let actions = builder()
        completion(actions)
      },
    ])
  }
}

extension UIImage {
  func carPlayImage(carTraitCollection traits: UITraitCollection) -> UIImage {
    let imageAsset = UIImageAsset()
    imageAsset.register(self, with: traits)
    return imageAsset.image(with: traits)
  }
}

extension UICollectionViewLayout {
  static var verticalLayout: UICollectionViewFlowLayout {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    return layout
  }
}

extension UIDevice.BatteryState {
  public var description: String {
    switch self {
    case .unknown:
      return "unknown"
    case .unplugged:
      return "unplugged"
    case .charging:
      return "charging"
    case .full:
      return "full"
    @unknown default:
      return "@unknown default"
    }
  }
}

/// This fixes in swiftui mutliple picker views side by side to overlapp their touch areas
/// This is effective in addition to use .clipped() which only fixes the overlapping area visually
extension UIPickerView {
  open override var intrinsicContentSize: CGSize {
    CGSize(width: UIView.noIntrinsicMetric, height: 150)
  }
}

extension Notification.Name {
  static let LibraryItemsChanged = Notification.Name("de.familie-zimba.Amperfy.LibraryItemsChanged")
}

extension UIViewController {
  @objc
  var sceneTitle: String? { nil }

  func extendSafeAreaToAccountForMiniPlayer() {
    guard let hostVC = AppDelegate.mainWindowHostVC else { return }
    additionalSafeAreaInsets = UIEdgeInsets(
      top: 0,
      left: 0,
      bottom: hostVC.getSafeAreaExtension(),
      right: 0
    )
  }
}

extension UISearchBar {
  /// Whether the list is limited to cached entries. Mac Catalyst has no scope bar
  /// (see `configureSearchController`), so offline mode alone decides there.
  @MainActor
  var isCachedScopeSelected: Bool {
    if scopeButtonTitles?.count ?? 0 > 1 {
      return selectedScopeButtonIndex == 1
    }
    return appDelegate.storage.settings.user.isOfflineMode
  }
}

// MARK: - ThemeBackgroundView

public class ThemeBackgroundView: UIView {
  public static let shared = ThemeBackgroundView()

  private let wallpaperImageView = UIImageView()
  private let gradientLayer = CAGradientLayer()
  private let pulseLayer = CAGradientLayer()
  private var bubbleViews: [UIView] = []
  private var currentTheme: ThemePreference?

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setupBackground()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupBackground()
  }

  private func setupBackground() {
    isUserInteractionEnabled = false
    clipsToBounds = true

    wallpaperImageView.contentMode = .scaleAspectFill
    wallpaperImageView.clipsToBounds = true
    wallpaperImageView.frame = bounds
    wallpaperImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(wallpaperImageView)

    gradientLayer.frame = bounds
    layer.addSublayer(gradientLayer)

    pulseLayer.frame = bounds
    pulseLayer.opacity = 0.0
    layer.addSublayer(pulseLayer)
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    wallpaperImageView.frame = bounds
    gradientLayer.frame = bounds
    pulseLayer.frame = bounds
    CATransaction.commit()

    if currentTheme == .frutigerAero && !bubbleViews.isEmpty {
      restartBubbleAnimations()
    }
  }

  private func getWallpaper(named: String) -> UIImage? {
    if let img = UIImage(named: named, in: Bundle(for: Self.self), compatibleWith: nil) {
      return img
    }
    if let img = UIImage(named: named, in: Bundle.main, compatibleWith: nil) {
      return img
    }
    if let img = UIImage(named: named) {
      return img
    }
    return ThemeWallpapers.fallbackImage(named: named)
  }

  public func applyTheme(_ theme: ThemePreference) {
    currentTheme = theme
    for bubble in bubbleViews {
      bubble.removeFromSuperview()
    }
    bubbleViews.removeAll()
    pulseLayer.removeAllAnimations()
    pulseLayer.opacity = 0.0

    switch theme {
    case .frutigerAero:
      wallpaperImageView.isHidden = false
      wallpaperImageView.image = getWallpaper(named: "ThemeFrutigerAeroBg")

      gradientLayer.colors = [
        UIColor(red: 0.0, green: 0.70, blue: 0.88, alpha: 0.38).cgColor,
        UIColor(red: 0.0, green: 0.78, blue: 0.92, alpha: 0.28).cgColor,
        UIColor(red: 0.0, green: 0.55, blue: 0.75, alpha: 0.48).cgColor
      ]
      gradientLayer.locations = [0.0, 0.45, 1.0]
      gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
      gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
      gradientLayer.isHidden = false

      setupAeroFloatingBubbles()

    case .cyberpunk:
      wallpaperImageView.isHidden = false
      wallpaperImageView.image = getWallpaper(named: "ThemeCyberpunkBg")

      gradientLayer.colors = [
        UIColor(red: 0.10, green: 0.04, blue: 0.18, alpha: 0.72).cgColor,
        UIColor(red: 0.06, green: 0.02, blue: 0.12, alpha: 0.82).cgColor,
        UIColor(red: 0.03, green: 0.01, blue: 0.07, alpha: 0.90).cgColor
      ]
      gradientLayer.locations = [0.0, 0.5, 1.0]
      gradientLayer.startPoint = CGPoint(x: 0.1, y: 0.0)
      gradientLayer.endPoint = CGPoint(x: 0.9, y: 1.0)
      gradientLayer.isHidden = false

      setupCyberpunkPulse()

    case .minimalist:
      wallpaperImageView.isHidden = true
      gradientLayer.colors = [
        UIColor.systemBackground.cgColor,
        UIColor.systemBackground.cgColor
      ]
      gradientLayer.isHidden = false

    default:
      wallpaperImageView.isHidden = true
      gradientLayer.isHidden = true
    }
  }

  private func setupCyberpunkPulse() {
    pulseLayer.colors = [
      UIColor(red: 1.0, green: 0.16, blue: 0.52, alpha: 0.14).cgColor,
      UIColor(red: 0.0, green: 0.92, blue: 1.0, alpha: 0.09).cgColor
    ]
    pulseLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
    pulseLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

    let anim = CABasicAnimation(keyPath: "opacity")
    anim.fromValue = 0.0
    anim.toValue = 0.80
    anim.duration = 6.0
    anim.autoreverses = true
    anim.repeatCount = .infinity
    anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    pulseLayer.add(anim, forKey: "neonBreathing")
  }

  private func setupAeroFloatingBubbles() {
    let screenW = max(bounds.width, 390.0)
    let screenH = max(bounds.height, 844.0)

    let bubbleConfigs: [(xRel: CGFloat, size: CGFloat, duration: Double, delay: Double)] = [
      (0.12, 42.0, 14.0, 0.0),
      (0.82, 54.0, 18.0, 3.5),
      (0.35, 30.0, 16.0, 7.0),
      (0.68, 48.0, 20.0, 1.5),
      (0.20, 36.0, 15.0, 10.0),
      (0.88, 44.0, 17.0, 5.0)
    ]

    for cfg in bubbleConfigs {
      let bView = UIView(frame: CGRect(x: screenW * cfg.xRel, y: screenH + 60, width: cfg.size, height: cfg.size))
      bView.isUserInteractionEnabled = false
      bView.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
      bView.layer.cornerRadius = cfg.size / 2.0
      bView.layer.borderWidth = 1.0
      bView.layer.borderColor = UIColor(white: 1.0, alpha: 0.65).cgColor

      let shine = UIView(frame: CGRect(x: cfg.size * 0.22, y: cfg.size * 0.16, width: cfg.size * 0.28, height: cfg.size * 0.28))
      shine.backgroundColor = UIColor(white: 1.0, alpha: 0.75)
      shine.layer.cornerRadius = (cfg.size * 0.28) / 2.0
      shine.isUserInteractionEnabled = false
      bView.addSubview(shine)

      addSubview(bView)
      bubbleViews.append(bView)

      animateBubble(bView, startY: screenH + 60, endY: -80, duration: cfg.duration, delay: cfg.delay)
    }
  }

  private func animateBubble(_ view: UIView, startY: CGFloat, endY: CGFloat, duration: Double, delay: Double) {
    let anim = CABasicAnimation(keyPath: "transform.translation.y")
    anim.fromValue = 0
    anim.toValue = endY - startY
    anim.duration = duration
    anim.beginTime = CACurrentMediaTime() + delay
    anim.repeatCount = .infinity
    anim.timingFunction = CAMediaTimingFunction(name: .linear)
    view.layer.add(anim, forKey: "floatUp")
  }

  private func restartBubbleAnimations() {
    let screenH = max(bounds.height, 844.0)
    for (i, bView) in bubbleViews.enumerated() {
      bView.layer.removeAnimation(forKey: "floatUp")
      let duration = 14.0 + Double(i * 2)
      let delay = Double(i) * 2.5
      animateBubble(bView, startY: screenH + 60, endY: -80, duration: duration, delay: delay)
    }
  }
}

// MARK: - ThemeWallpapers Fallback Data

enum ThemeWallpapers {
  static func fallbackImage(named: String) -> UIImage? {
    if named == "ThemeCyberpunkBg" {
      if let data = Data(base64Encoded: cyberpunkBase64) {
        return UIImage(data: data)
      }
    } else if named == "ThemeFrutigerAeroBg" {
      if let data = Data(base64Encoded: frutigerAeroBase64) {
        return UIImage(data: data)
      }
    }
    return nil
  }

  static let cyberpunkBase64 = "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O/Sq0prppooqzGqU5q1OaozmvSooykVJjVOWrUxqpJXrUUKK1IWpAKc1AFd0TvoQFUc1IopqipBVHr0ojhThTRTqk7IoKKKKCwooooAKKKKACiiigAooooAKKKKACiiigBRT0pgp6UEssQ1ftuoqhDV+26imjjrbGtadRW1ZdqxbTqK2rLtWqPBxRtWnatCLoKz7TtWhF0FaI+erj3qnc9DVx+lU7roaZzR3Ma971h33et296GsG+70md9ExLzvWRdHrWte96x7o9ak9GBn3B61nXDdau3JrNuG600TUehUnaqEz1ZuGrPnatYo8ytIjkeoWemyNULNWiR585khkpN9QFqA1VY53Msh6kR6qqalRqlonmLsbVOjVSjap0asJRKTLgagtUCtS7qxcS7jy1APNR5pV60mhliLrWhbDkVQhHNaVqvSuaqzamalmOlbdkvSsmyXpW5ZL0rxsRI9CkjStV6VpQr0qlarwK0YRXjVZHfBEyCpQKagqQCuRs3QgFLiloqblXG4pMU+kNFxXG4pKcaSmFxpNFB60UCGmmPUhqNu9aRGQSVVlq1JVSauqkDZTnPWqE5q7PVCc16lAzbKkp61WerEtV3r1aRrTVyM0oFBpwrsR6lCIqinimininc9SmhRS0CikdCCiiigYUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAop6UwU9KCWWIav23UVQhq/bdRTRx1tjWtOorasu1Ytp1FbVl2rVHg4o2rTtWhF0rPtO1aEPStEfPV9yRulU7noauN0qnc9KZzR3Me971gX/et+971g3/AHpHoUUYN93rGuz1rYvuprEuz1qTvjsZtyazLk9a0Lk9azLk1SMarKFwetUJzV2eqM1axPLrMqyGoGNTSCoGFao86bG5oBoIoqkYNjwakQ81EtPU0mgTLKGpkaqyGpFNZuJSZZDUob3qANTw1ZOJaZKDUqdRUCdasRCsZFxLduORWraL0rPtVyRWvZJ0rzq8jrpI1LJOlbdmnArMsk6VtWidK8PETPRpRL1svStCIcVVt16VcjHFeTUZ3RRKgp9NWnVgaBRRRSC4UhoJppNMANFFFMBp60U6kNACHpUb081G5q4hcglqnPVuU1SmNddJGbZTnNUJ6uznrVGavUokplSSoWFTyVCwr1KbOuihlKBRinAV1RZ69CICnCkFOqz0YIUUUUUGwUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAKKelMFPSglliGr9t1FUIav23UU0cdbY1rTqK2rLtWLadRW1Zdq1R4OKNq07Vow9KzrTtWjD0rRHz1fce3Sqlz0NXG6VTuOlM547mPe96wNQ71v3vesDUO9Sz0KJgX3esO86mtu+6msS870HYnoZNz3rNuO9alwOtZ8y5q0c1WRmzCqUy1pypVWWP2rRHm1WZki1A61oyx1WeOtEcM0UytJirDJioytUYtDBTlpMUop2JJFOKkBqEU5TUtDuTA09TUINSJWckUixH1q5AKqwir9svIrkquxvBF+0TpWzZJ0rNs06Vt2SdK8bESO+kjSsk6Vs2q9KzrNeBWrbivDryPRpouwirSVXi6VYWvPmdSJFp1Rg0uaysWOzRTc0UWACaKKKYBRRS4oASkPSnU00IBrdKikNSNUMhrSKJbK8pqnOatSmqc1dtJGTZUmqnLVyYc1VkFejSYRKjiomFWXWomWvQps76CIcUoFPIpMV1xZ7FFCUvejFFao74hRRRTNAooooAKKKKACiiigAooooAKKKKACiiigAooooAUU9KYKelBLLENX7bqKoQ1ftuopo462xrWnUVtWXasW06itqy7VqjwcUbVp2rRh6VnWnatGLpWiPnq+5I3Sqlx0q0elVLnoaZzx3Me96GsC/wC9b993rAv+9I76TMC+HWsS6HJrbvu9Y9yOTQdN9DLmWqkkdaMqZqFo81SOWozMki9qgkh9q1zD7VG8HtVpnFNXMKWH2qrLD7Vvy2/tVOaD2q0zncDDkjxUDpWtND7VTljx2q0zKUCgVppFWXSoWWqMnGwylFBFIOtBFiRTU0fWoVqeIVlMqJbgHStK0WqFuOlaloOledWZ1U0almvStqzXpWTZDpWzadq8XEM9CkjVtR0rSgrNtzwKvwmvIqo74F6M1OpqpG1TK1ccom6ZYBpRUSmng1k0XcdmlpKUVIC0YoFOApDEpcUtFIBtNNOamNVIRG5qCQ1M9V5K3giGQS1VlqzJUDiuuBmypIKrutXHWoXWuynIuCKbrUTLVt1qF1rupyPSoIrEU0ipWFRkc13QZ61FDaBQelA71ujtiJRRRVFhRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAop6UwU9KCWWIav23UVQhq/bdRTRx1tjWtOorasu1Ytp1FbVl2rVHg4o2rTtWhF0rPtO1aEXStEfPV9yRulVLnoatt0qnc9DTOWL1Me+71g3/et6971g33eg7KcjBveprKuBzWveDrWXOOaDpuUmXmm+XU5HNCrTMZkIioaH2q2qU7ZRcwcbmXLB7VSng68VuyRVUnh9qpMPZ3OduIPaqE8PWuhuIevFZ1xD1qlIiVEwpY8VWkStaeL2qjKlaJnLOnYosKSppFqIiqucziKvWrEVV061Zi6isphEvWw5Falp2rMtu1alr2rzax1UzXtO1a1r2rItT0rVtj0ryKyO+makDVehas2A1dhNeZUidcGX42qZDVSM9Ksoa5JI3TLCGpFqJKlWueRoiQdKcBTRTwKyZQoFLRRUjCiiigBrVG3SntTGq4iIn71A9TtUTCt4kMruKiZasMKYy1tGRNiq61C61bZahkFdMJG0IlORaryCrkgqrJXoUmelRRWcVG3WpXqJq9GmenSQw0g70GjtXSjriJRRRVFhRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAop6UwU9KCWWIav23UVQhq/bdRTRx1tjWtOorasu1Ytp1FbVl2rVHg4o2bXoK0YulZ1r0FaMXStEfPV9x7dKp3PQ1cbpVS5qjjT1Me96GsG+HWugvR1rDvV60HVTZg3Y61lzDk1r3a9azJxyaR0opnrSrQ/FNzimJonTFSCq6vUiuKQKJIwqvKlTbhTW5pXN40zOuI+tZ1zF1rZmGaoXCdaaZUqWhh3MdZ1wlbdynWsy5XrWsWcNamZUq1XYVdmWqjjmtLnm1I2GL1qeLqKhHWp4uorOZklqX7btWna9qzLYdK1LUdK86sdNM1bWtS27VmWo6Vq2y9K8mszupl6Cr0NVIFq9CvSvNqM64IsRDpVmMVFEtWY1rimzeKJEFTKKYgqVRXLJmqHKKcKFFLWZQUtAoqRiGig0UxMY1MbpUjUw1aERMKYwqYimEVomS0QlaYy1ORUbCtIsaRXcVXkFWpO9VZa6qRvTiVZaqS1alqpKa9Sij0aKIHqFqlkNQtXp00elTQ00lKetJXQjpiFFFFMoKKKKACiiigAooooAKKKKACiiigAooooAKKKKAFFPSmCnpQSyxDV+26iqEVXrbtTRx1tjXtOorasu1YdmelbVmelao8HFG3a9q0IulZlqeBWjCeK0R8/XWpO3SqtwOKsE8VBNVHFbUybsdaxrxetbt0ODWReL1pHTTRz94nWsq4XrW7eJ1rIul60HXFGVMMVXZsVZuBVGU4NMbH+ZinrLVJpMUglp2EjSWSnb81nLN71KJaho66bLDnIqpPT2k4qCV+KSNnaxSuR1rMuR1rRuG61m3J61pE4K5nT96pyCrk/eqr9a1ueTVI1HNTxDmo1HNWYFrGpI50i3ar0rVtF6VRtU6Vr2cfSvNrzOqnEv2idK1rVOlU7SPpxWtbR9K8etUO+nEnt0q/ClRwR+1XYkrzKkzrhEdGlTotCLUyrXHORukCipFFCinVg2WFKKAKKkYUUUUABpKWkNNAIaaRT6QimmIjNNIqQimkVSYEbConqZqhk6VrApIry96qTHrVmU1TmNd9GJ0U4laY1UkNTzGqshr16MT0aUSJzUZpzGmGvQgjvghtFLSVsjoQUUUUxhRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAop6UwU9aCWTxdavW56VQj61cgNNHLVWhr2h6VsWjdKwrVulatq/StEeJiY3N+1fpWhE/FYttJ0q/FN71omeFXp6mjv4qKVuKhEvHWmPJTucfs9SK4PWsu6HWr071n3LdaLm8IGVdjrWRdr1rYuj1rIuz1oOhRMe66msu4PJrUvDWRdHrVoiWhVlfFQ+bTZ35qq8nNXYwc7F5ZvepVm96yxL709Zvek4m0Kpp+d71HJLxVLzqY83vU8pq6xJPJVCd+tPll96qSvmqSOSrUuQzGoDyakc5pqjJobsefN3CNcmrtvHk1HBHmtG1i6cVyValhRiWLSLpxWzZxdOKrWcPTitmzh6cV42IqnbSgWbSLpxWrbRdKhtYunFadvH7V49aqd9OA+COrcaYpIkqwi1585nTGIKtSKKFFOrBu5oFKBQBRU3GFFFFABRRRQAUUUUAJRS0hpgIaYaeaYxqkCI3PFV5TUshqtM1dNNGkUV5mqlM1WJmqnM1epQgdlOJBKaqyGppTVdzXrUonoUojGphpxptdkUdsUJRS0laGgUUUUDCiiigAooooAKKKKACiiigAooooAKKKKAClpKdQIBTlptOWkJkqdatQmqqVPGadzmqGjbtitG3krHhbFXYZMVSZ5taFzcgm96uRz+9YcU3vVlJ/eqUjzKlG5sif3pGn96yxP70Gf3quY5Xhy5LN71Tnl61DJP71Wmm96LjVGw25k61lXbdas3EvWs26k61SYpRsULxutY923WtG7frWRdv1rWJyVNCjcN1qnI9TXLVRletkjgnOw8yUCWqjPTfMp2M1VsXvO96a0tU/Mppk96XKV7YsvJ71A71GXpM5qWjOVS48c1NEmajjGTVy3jyRXPUnYhak1tF04rWs4enFQWkPTitmyg6cV5WIqnTTgWLODpxWzaQ9OKgs4enFa9tFjHFeJXqnoU4ElvFV+FPamQR1bjXFeXUnc7IxHItSqKRRT652zRIKUUCioKCiiigAooooAKKKKACiiigApD1paQ00A1qjc8U5jUMhrSCGiOU1UmappWqnM1d1GBtBEEzVTlappmqpI1evQgd9KJFIahY09zUTGvSpxPQpxENJQaDXQjpihKKKKosKKKKACiiigAooooAKKKKACiiigAooooAKKKKAFFLRRSJFFOFIKcKm5MmOWpkNRKKkWlcwkyxGasRviqimpFai5yzVy8ktTLN71nq9OElPmOeVO5oiekM/vVDzKa0tVzGTpFx5veq8s3vVd5aryy+9UmYyhYlnm681nXEvXmlml96oXEtbROKroRXUnXmsu6frU9xLWdcSda3ijy60itcP1qjK1TTvVOVq3ijzKkhjtUZekdqjJq7HO5Em+jfUOaUGk0HOTA81InNQpVqFcmsajsUncngTJFadpF0qtbR5xWvZxZxxXmV6ljppxLdlD0rbsoenFVLKHpW3ZxdOK8LEVTvpQLNpFgCtKCPpUVtH0q/ClePVqHfCI+JKsKKai1IBiuSTN0haUUCisygooooAKKKKACiiigAooooAKKKKAA01jSmmMapIBjmq8rVLIaqzNXRTiNEMzVSmappm96pzNXp0IHTTIZWqrI1SStVd2r1qMD0aSGseaYaUmmmu6KO+CAUlLSVqjdBRRRQMKKKKACiiigAooooAKKKKACiiigAooooAKKKKAHUCilFIkUU9aaKctQzORIKetRing81JhIepp4NRinZpGTH5o3UykzTJsPL01nphNRu1NESQrvVaWSlleqkz1rFHHVdhs0vvVC4lp88lZ9xJ710QR5NeYy4k61nzyVJPJ1qlM+a6Yo8atMjmeqsjU+Rqrua2R585DXPNRk0pNNqjBsUGnLTBUqCpkNE0S1etk5FVoV5rStI84rjrSsjeCLlpH0rbsYunFU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"
  static let frutigerAeroBase64 = "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abEtWUWvZw9RkOBHtqN1q1sqKRa9uhM55xKUgqtLVuaqc1etSkcc0QOaiJpzmozXXFmDA0opBTgKq4gFLiiik2NMUUZppNNLVDRakS7qUNUBf3ppkqHEfMXUerET1mLLU8cvvWbiNSNeF6uRSVjRTe9Wo5x61lKJvGZsxyVMsorIS496lFx71nyGqmaZlqKST3qkbj3qN7getUoicyW4k61l3UnWpLifrzWZdTdea6qUTjqzIriTnrVNpeabcTe9U2lyetd8I6HnzlqaUMvNaVpJ0rnoZeetadnLyKirE0pS1Ons36c1r2zcVztjL0ratH6V5VZHr0GaidKcV4qKJsipSeK4pHdErzLWfcr1rSm6VRuaIsTRj3Q61mXA5Na10OtZdyK6YGLKEvWos1LL1NQmumKIciZGqZHqqDTgxp8hPtC15tNaaqzPULyGl7MPalpp/emG496ovLURmp+zH7U0vP8Aekab3rN86jzvej2Ye0LkkmapzNQZM1DI2aaiS5kExqs5wank5qvJWqRk5AHxUiS4qqTik34quUzczQWb3p3n+9Zwkp4epcDP2hcaU+tMMlQA5pwzU8oucN1G6kor8Z5T3hwanA1GKcKOUCQGng1GKcKlxEPBpwNR0uamwEgNPU1CDT1NAE6mpkNVlNTxmqQFqM1ahPNU4zVuGtoIpIuw1fgFUbcdK0bcZrvoxGW4Vq0i1FAtW0Xivaw8SZEbLxUEoq4y8VWnFe5Qic1RGdcDrVCetC471nzV6lI4ahVfrTKkcUzHNdaZzsUCnAUgFKatEgTTGah2xVeR6pIlyHs9RNJ71DJJ71A8tVyEOoWWlphlqm03vTDNS5CfaGgJqkSf3rL873pwm96hwKVQ2UuPep0ufesJZ/epFufes3TNVUN9br3p4u/eufF170v2v3qHTNVUOgN571G9371gm896je896OQfObM1371n3FznvWfJd571Wkuc962grGFR3LU8+c81WMvPWqzzZPWmh+a64s45I0IZORWnZycjmsSBua07RulKbuVT0Z0tjL0rbs5OBzXMWUnStu0l6c15taJ6dGdjoIJOKsB+KyoJeOtWll4rglDU9GMyeRuKpXDdakkl461UnkojAJTKd0etZlx3q9cNWfOetdUIHPOoU5RzVcirMlQmumMTnlUGClowaCK05TJ1Bjmq8hqdxVaWnyk8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"
}

// MARK: - UpdateManager (Seamless OTA / Sideload Updates)

public struct AppReleaseInfo: Sendable {
  public let tagName: String
  public let versionNumber: String
  public let releaseNotes: String
  public let ipaDownloadUrl: String?
  public let htmlUrl: String
  public let publishedAt: String
}

@MainActor
public class UpdateManager: NSObject {
  public static let shared = UpdateManager()

  public static let currentAppVersion = "1.4"
  public static let currentBuildTag = "v1.4"

  private var isChecking = false
  private var lastCheckDate: Date?

  public override init() {
    super.init()
  }

  public func check(notifyIfUpToDate: Bool = false) {
    guard !isChecking else { return }

    // Throttle automatic checks to at most once every 4 hours
    if !notifyIfUpToDate, let last = lastCheckDate, Date().timeIntervalSince(last) < 14400 {
      return
    }

    isChecking = true
    lastCheckDate = Date()

    guard let url = URL(string: "https://api.github.com/repos/Chr0n0sL00p/amperfy-custom/releases/latest") else {
      isChecking = false
      return
    }

    var request = URLRequest(url: url)
    request.timeoutInterval = 8.0
    request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

    URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
      DispatchQueue.main.async {
        guard let self = self else { return }
        self.isChecking = false

        if let error = error {
          if notifyIfUpToDate {
            self.showAlert(
              title: "Error al comprobar",
              message: "No se pudo conectar con GitHub: \(error.localizedDescription)"
            )
          }
          return
        }

        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tagName = json["tag_name"] as? String else {
          if notifyIfUpToDate {
            self.showAlert(
              title: "Actualizaciones",
              message: "No se encontró información de versiones recientes."
            )
          }
          return
        }

        let body = json["body"] as? String ?? "Nuevas mejoras de rendimiento y corrección de errores."
        let htmlUrl = json["html_url"] as? String ?? "https://github.com/Chr0n0sL00p/amperfy-custom/releases"
        let publishedAt = json["published_at"] as? String ?? ""

        var ipaUrl: String? = nil
        if let assets = json["assets"] as? [[String: Any]] {
          for asset in assets {
            if let name = asset["name"] as? String, name.hasSuffix(".ipa"),
               let downloadUrl = asset["browser_download_url"] as? String {
              ipaUrl = downloadUrl
              break
            }
          }
        }

        let release = AppReleaseInfo(
          tagName: tagName,
          versionNumber: tagName.components(separatedBy: "-").first?.replacingOccurrences(of: "v", with: "") ?? tagName,
          releaseNotes: body,
          ipaDownloadUrl: ipaUrl,
          htmlUrl: htmlUrl,
          publishedAt: publishedAt
        )

        let isNewer = self.isRemoteNewer(remote: release.versionNumber, local: Self.currentAppVersion)

        if isNewer {
          self.promptUpdate(release: release)
        } else if notifyIfUpToDate {
          self.showAlert(
            title: "Amperfy está al día",
            message: "Tienes instalada la versión más reciente (v\(Self.currentAppVersion))."
          )
        }
      }
    }.resume()
  }

  private func isRemoteNewer(remote: String, local: String) -> Bool {
    return remote.compare(local, options: .numeric) == .orderedDescending
  }

  private func promptUpdate(release: AppReleaseInfo) {
    let alert = UIAlertController(
      title: "🚀 Nueva Versión: \(release.tagName)",
      message: "\(release.releaseNotes)\n\n¿Cómo deseas actualizar?",
      preferredStyle: .alert
    )

    if let ipaUrl = release.ipaDownloadUrl {
      alert.addAction(UIAlertAction(title: "⚡ SideStore / AltStore", style: .default, handler: { _ in
        if let encoded = ipaUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
          if let sidestore = URL(string: "sidestore://install?url=\(encoded)"), UIApplication.shared.canOpenURL(sidestore) {
            UIApplication.shared.open(sidestore)
            return
          }
          if let altstore = URL(string: "altstore://install?url=\(encoded)"), UIApplication.shared.canOpenURL(altstore) {
            UIApplication.shared.open(altstore)
            return
          }
        }
        if let safariUrl = URL(string: ipaUrl) {
          UIApplication.shared.open(safariUrl)
        }
      }))

      alert.addAction(UIAlertAction(title: "🌐 Descargar IPA Directa", style: .default, handler: { _ in
        if let safariUrl = URL(string: ipaUrl) {
          UIApplication.shared.open(safariUrl)
        }
      }))
    } else {
      alert.addAction(UIAlertAction(title: "Ver en GitHub", style: .default, handler: { _ in
        if let url = URL(string: release.htmlUrl) {
          UIApplication.shared.open(url)
        }
      }))
    }

    alert.addAction(UIAlertAction(title: "Más tarde", style: .cancel, handler: nil))

    presentAlert(alert)
  }

  private func showAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    presentAlert(alert)
  }

  private func presentAlert(_ alert: UIAlertController) {
    let window = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow } ?? UIApplication.shared.windows.first
    guard let rootVC = window?.rootViewController else { return }
    var presenter = rootVC
    while let p = presenter.presentedViewController { presenter = p }
    presenter.present(alert, animated: true)
  }
}

