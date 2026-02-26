import SwiftUI

/// Light theme — values taken directly from the `html[data-theme="light"]` CSS prototype.
public struct LightTheme: AppThemeProvider {
    public var id: String { "light" }
    public var displayName: String { "Light" }
    public var icon: String { "sun.max.fill" }

    // MARK: - Background

    public var backgroundGradient: LinearGradient {
        // --bg-base: #f7f7f8
        LinearGradient(
            colors: [
                Color(red: 0.969, green: 0.969, blue: 0.973),
                Color(red: 0.941, green: 0.941, blue: 0.949),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public var showBackgroundOrbs: Bool { false }

    // MARK: - Cards & Glass

    public var cardGradient: LinearGradient {
        // --bg-card: rgba(0,0,0,0.045)
        LinearGradient(
            colors: [Color.black.opacity(0.045), Color.black.opacity(0.025)],
            startPoint: .top, endPoint: .bottom
        )
    }

    public var glassBackground: Color { Color.black.opacity(0.045) }  // --bg-card
    public var glassBorder: Color     { Color.black.opacity(0.09) }   // --border
    public var glassHighlight: Color  { Color.black.opacity(0.16) }   // --border-focus

    public var cardCornerRadius: CGFloat { 10 }
    public var pillCornerRadius: CGFloat { 20 }

    // MARK: - Typography

    // --text-primary:   rgba(26,26,31,0.92)
    public var textPrimary: Color   { Color(red: 0.102, green: 0.102, blue: 0.122).opacity(0.92) }
    // --text-secondary: rgba(102,102,112,1)
    public var textSecondary: Color { Color(red: 0.400, green: 0.400, blue: 0.439) }
    // --text-tertiary:  rgba(158,158,166,1)
    public var textTertiary: Color  { Color(red: 0.620, green: 0.620, blue: 0.651) }
    // --text-mono: #007acc
    public var textMono: Color      { Color(red: 0.000, green: 0.478, blue: 0.800) }

    public var fontDesign: Font.Design { .default }

    // MARK: - Status Colors

    public var statusLive: Color       { Color(red: 0.110, green: 0.698, blue: 0.333) } // #1cb255
    public var statusEditable: Color   { Color(red: 0.000, green: 0.478, blue: 0.976) } // #007af9
    public var statusPending: Color    { Color(red: 0.851, green: 0.482, blue: 0.000) } // #d97b00
    public var statusRemoved: Color    { Color(red: 0.878, green: 0.188, blue: 0.188) } // #e03030
    public var statusProcessing: Color { Color(red: 0.550, green: 0.550, blue: 0.580) }

    // MARK: - Accents

    public var accentPrimary: Color   { Color(red: 0.000, green: 0.478, blue: 0.976) } // #007af9
    public var accentSecondary: Color { Color(red: 0.482, green: 0.208, blue: 0.851) } // #7b35d9

    public var accentGradient: LinearGradient {
        LinearGradient(
            colors: [BaseColors.brandPurple, BaseColors.brandPink],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    public var pillGradient: LinearGradient {
        LinearGradient(
            colors: [Color.black.opacity(0.05), Color.black.opacity(0.02)],
            startPoint: .top, endPoint: .bottom
        )
    }

    // MARK: - Interactive

    public var hoverBackground: Color   { Color.black.opacity(0.075) } // --bg-card-hover
    public var pressedBackground: Color { Color.black.opacity(0.110) }
    public var progressTrack: Color     { Color.black.opacity(0.090) } // --progress-track

    // MARK: - Surface

    public var backgroundColor: Color  { Color(red: 0.969, green: 0.969, blue: 0.973) } // #f7f7f8
    public var dividerColor: Color     { Color.black.opacity(0.09) }  // rgba(0,0,0,.09)
    public var codeBackground: Color   { Color.black.opacity(0.05) }  // light .code-snippet bg
    public var shimmerBase: Color      { Color.black.opacity(0.06) }
    public var shimmerHighlight: Color { Color.black.opacity(0.14) }
}
