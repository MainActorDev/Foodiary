import SwiftUI

struct SettingsView: View {
    @Bindable var state: AppState

    @ObservedObject private var themeManager = ThemeManager.shared
    @EnvironmentObject private var localeManager: LocaleManager
    @Environment(\.dismiss) private var dismiss
    @State private var showResetConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - § Preferences
                sectionLabel(L10n["settings.section.preferences"])

                groupCard {
                    // Appearance → segmented picker
                    settingRow(icon: "circle.lefthalf.filled", tint: FoodiaryDesign.pulsePrimary) {
                        Text(L10n["settings.appearance"])
                    }
                    themePicker
                }

                // MARK: - § Language
                sectionLabel(L10n["settings.language"])
                groupCard(spacing: 0) {
                    ForEach(LocaleManager.supportedLanguages) { lang in
                        languageRow(lang)
                    }
                }

                // MARK: - § About
                sectionLabel(L10n["settings.about"])

                groupCard {
                    settingRow(icon: "info.circle.fill", tint: Color(hex: "8B5CF6")) {
                        Text(L10n["settings.version"])
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(FoodiaryDesign.pulseMuted)
                    }
                }

                // MARK: - § Data
                sectionLabel(L10n["settings.data"])

                Button(action: { showResetConfirm = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "trash")
                            .font(.system(size: 15, weight: .medium))
                        Text(L10n["action.reset_data"])
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(FoodiaryDesign.pulseDanger)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(FoodiaryDesign.pulseSurface)
                }
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(FoodiaryDesign.pulseBorder.opacity(0.5), lineWidth: 1)
                )

                // MARK: - Footer
                Text(L10n["settings.footer_text"])
                    .font(.system(size: 12))
                    .foregroundColor(FoodiaryDesign.pulseMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 28)

                Text("Foodiary · v\(appVersion)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(FoodiaryDesign.pulseMuted)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 32)
        }
        .background(FoodiaryDesign.pulseBackground)
        .preferredColorScheme(themeManager.selectedTheme.colorScheme)
        .navigationTitle(L10n["nav.settings"])
        .navigationBarTitleDisplayMode(.inline)
        .pulseBackButton(dismiss: dismiss)
        .alert(L10n["alert.reset_title"], isPresented: $showResetConfirm) {
            Button(L10n["alert.cancel"], role: .cancel) { }
            Button(L10n["alert.reset_confirm"], role: .destructive) {
                state.resetAll()
            }
        } message: {
            Text(L10n["alert.reset_message"])
        }
    }

    // MARK: - Theme Picker

    private var themePicker: some View {
        HStack(spacing: 4) {
            ForEach(AppTheme.allCases, id: \.self) { theme in
                let isSelected = themeManager.selectedTheme == theme
                Button(action: { themeManager.switchTo(theme) }) {
                    VStack(spacing: 5) {
                        Image(systemName: theme.iconName)
                            .font(.system(size: 18))
                        Text(theme.displayName)
                            .font(.system(size: 11, weight: isSelected ? .bold : .semibold))
                    }
                    .foregroundColor(isSelected ? FoodiaryDesign.pulseInk : FoodiaryDesign.pulseMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isSelected ? FoodiaryDesign.pulseSurface : Color.clear)
                            .shadow(color: isSelected ? FoodiaryDesign.pulseShadow.opacity(0.06) : .clear, radius: 4, y: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(FoodiaryDesign.pulseSurfaceSoft)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    // MARK: - Language Row

    private func languageRow(_ lang: SupportedLanguage) -> some View {
        let isSelected = localeManager.selectedLanguage == lang.code
        return Button(action: { localeManager.switchTo(lang.code) }) {
            HStack(spacing: 14) {
                Text(lang.flag)
                    .font(.system(size: 22))

                Text(lang.nativeName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(FoodiaryDesign.pulseInk)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(FoodiaryDesign.pulseMint)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 22))
                        .foregroundColor(FoodiaryDesign.pulseBorder)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Card Components

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .pulseSectionLabel()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.top, 24)
            .padding(.bottom, 10)
    }

    @ViewBuilder
    private func groupCard<Content: View>(spacing: CGFloat = 0, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: spacing) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FoodiaryDesign.pulseSurface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(FoodiaryDesign.pulseBorder.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: FoodiaryDesign.pulseShadow.opacity(0.04), radius: 12, y: 4)
        .padding(.bottom, 2)
    }

    @ViewBuilder
    private func settingRow<C: View>(
        icon: String,
        tint: Color,
        @ViewBuilder trailing: () -> C
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Data

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}
