import SwiftUI

// MARK: Background Modifier
struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            content
        }
    }
}

extension View {
    func appBackground() -> some View {
        modifier(AppBackgroundModifier())
    }
}

// MARK: Colors
extension Color {
    static let primaryText = AppColors.Text.primary
    static let appMint = AppColors.UI.background
    static let appTeal = AppColors.Text.teriary
    static let appSubtitle = AppColors.Text.secondary
    static let appBackground = AppColors.UI.appBackground

    static let appNavy = Color(red: 19/255,  green: 33/255,  blue: 44/255)  // #13212C
    static let appAmber      = Color(red: 232/255, green: 160/255, blue: 32/255)  // #E8A020
    static let appOrange = Color(red: 255/255, green: 122/255, blue: 0/255)   // #FF7A00
    static let appCardTitle = Color(red: 26/255,  green: 47/255,  blue: 63/255)  // #1A2F3F
    static let appButtonBackground = Color(red: 235/255, green: 235/255, blue: 240/255) // #EBEBF0
    static let appLightTeal = Color(red: 230/255, green: 237/255, blue: 236/255) // #34797C
    static let appGray = Color(red: 217/255, green: 217/255, blue: 217/255) // #F5F4F2
    static let primaryOrange = Color(red: 235/255, green: 150/255, blue: 50/255)
    static let appChartGray = Color(red: 140/255, green: 140/255, blue: 145/255) // #8C8C91
    static let appRed = Color(red: 255/255, green: 59/255, blue: 48/255)
    static let appDarkBlue = Color(red: 26/255, green: 47/255, blue: 63/255)
    static let appThreadsPrimary = Color(red: 148/255, green: 182/255, blue: 182/255) // #94B6B6
    static let appThreadsReply = Color(red: 253/255, green: 242/255, blue: 229/255) // #RDF2E5

    static let paletteLagoon1 = Color(red: 0/255, green: 191/255, blue: 216/255) // #00BFD8
    static let paletteLagoon2 = Color(red: 68/255, green: 235/255, blue: 182/255) // #44EBB6
    static let paletteLagoon3 = Color(red: 30/255, green: 169/255, blue: 215/255) // #1EA9D7
    static let paletteLagoon4 = Color(red: 140/255, green: 237/255, blue: 143/255) // #8CED8F
    static let paletteLagoon5 = Color(red: 84/255, green: 207/255, blue: 255/255) // #54CFFF

    static let paletteSunset1 = Color(red: 109/255, green: 149/255, blue: 255/255) // #6D95FF
    static let paletteSunset2 = Color(red: 176/255, green: 165/255, blue: 255/255) // #B0A5FF
    static let paletteSunset3 = Color(red: 243/255, green: 114/255, blue: 173/255) // #F372AD
    static let paletteSunset4 = Color(red: 251/255, green: 119/255, blue: 56/255) // #FB7738
    static let paletteSunset5 = Color(red: 243/255, green: 179/255, blue: 64/255) // #F3B340

    static let paletteHarvest1 = Color(red: 247/255, green: 109/255, blue: 90/255) // #F76D5A
    static let paletteHarvest2 = Color(red: 70/255, green: 170/255, blue: 205/255) // #46AACD
    static let paletteHarvest3 = Color(red: 235/255, green: 150/255, blue: 50/255) // #EB9632
    static let paletteHarvest4 = Color(red: 97/255, green: 167/255, blue: 118/255) // #61A776
    static let paletteHarvest5 = Color(red: 211/255, green: 126/255, blue: 177/255) // #D37EB1

    static let palettePetal1 = Color(red: 255/255, green: 129/255, blue: 152/255) // #FF8198
    static let palettePetal2 = Color(red: 255/255, green: 198/255, blue: 214/255) // #FFC6D6
    static let palettePetal3 = Color(red: 255/255, green: 185/255, blue: 120/255) // #FFB978
    static let palettePetal4 = Color(red: 255/255, green: 153/255, blue: 200/255) // #FF99C8
    static let palettePetal5 = Color(red: 255/255, green: 99/255, blue: 167/255) // #FF63A7
}

enum AppColors {
    enum Text {
        static let primary = Color("TextPrimary")
        static let secondary = Color("TextSecondary")
        static let teriary = Color("TextTertiary")
        static let placeholder = Color("TextPlaceholder")
    }

    enum UI {
        static let background = Color("ComponentBackground")
        static let cardShare = Color("CardShare")
        static let appBackground = Color("AppBackground")
    }
}
