import SwiftUI
import CoreText

/// Centralized font management.
///
/// Register custom fonts once at launch, then access via type-safe
/// static properties. Provides fallback chains for missing fonts.
enum FontManager {
    // MARK: - Registration

    /// Call once at app launch to register bundled custom fonts.
    static func registerCustomFonts() {
        // Placeholder for future bundled fonts.
        // When .ttf/.otf files are added to the bundle, register them here.
        //
        // Example:
        //   guard let url = Bundle.main.url(forResource: "MyFont", withExtension: "ttf"),
        //         let provider = CGDataProvider(url: url as CFURL),
        //         let font = CGFont(provider) else { return }
        //   CTFontManagerRegisterGraphicsFont(font, nil)
    }

    // MARK: - Display Fonts

    /// The app's display font (Space Grotesk Bold), with system fallback.
    static func titleFont(size: CGFloat) -> UIFont {
        let ct = CTFontCreateWithName("Space Grotesk" as CFString, size, nil)
        if let bold = CTFontCreateCopyWithSymbolicTraits(ct, 0, nil, .boldTrait, .boldTrait) {
            return bold as UIFont
        }
        return .systemFont(ofSize: size, weight: .bold)
    }

    /// Large title variant of the display font.
    static func largeTitleFont(size: CGFloat) -> UIFont {
        titleFont(size: size)
    }

    /// SwiftUI Font variant of the display font.
    static var displayFont: Font {
        .system(size: 18, weight: .bold, design: .default)
    }
}
