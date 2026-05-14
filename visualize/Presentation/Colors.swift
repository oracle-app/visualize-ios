import SwiftUI

extension Color {
    static let primaryText = AppColors.Text.primary
    static let appMint = AppColors.UI.background
    static let appTeal = AppColors.Text.teriary
    static let appSubtitle = AppColors.Text.secondary

    static let appNavy = Color(red: 19/255,  green: 33/255,  blue: 44/255)  // #13212C
    static let appAmber      = Color(red: 232/255, green: 160/255, blue: 32/255)  // #E8A020
    static let appBackground = Color(red: 247/255, green: 247/255, blue: 247/255) // #F7F7F7
    static let appOrange = Color(red: 255/255, green: 122/255, blue: 0/255)   // #FF7A00
    static let appCardTitle = Color(red: 26/255,  green: 47/255,  blue: 63/255)  // #1A2F3F
    static let appButtonBackground = Color(red: 235/255, green: 235/255, blue: 240/255) // #EBEBF0
    static let appLightTeal = Color(red: 230/255, green: 237/255, blue: 236/255) //#34797C
    static let appGray = Color(red: 217/255, green: 217/255, blue: 217/255) //#F5F4F2
    static let primaryOrange = Color(red: 235/255, green: 150/255, blue: 50/255)
    static let appChartGray = Color(red: 140/255, green: 140/255, blue: 145/255) // #8C8C91
    static let appRed = Color(red: 255/255, green: 59/255, blue: 48/255)
    static let appDarkBlue = Color(red: 26/255, green: 47/255, blue: 63/255)

    static let paletteAqua1 = Color(red: 0/255, green: 53/255, blue: 102/255) //#003566
    static let paletteAqua2 = Color(red: 0/255, green: 150/255, blue: 199/255) //#0096C7
    static let paletteAqua3 = Color(red: 15/255, green: 238/255, blue: 208/255) //#0FEED0
    static let paletteAqua4 = Color(red: 0/255, green: 191/255, blue: 216/255) //#00BFD78
    static let paletteAqua5 = Color(red: 82/255, green: 225/255, blue: 255/255) //#52E1FF

    static let paletteIris1 = Color(red: 74/255, green: 127/255, blue: 247/255) //#4A7FF7
    static let paletteIris2 = Color(red: 174/255, green: 141/255, blue: 245/255) //#AE8DF5
    static let paletteIris3 = Color(red: 243/255, green: 184/255, blue: 107/255) //#F3B86B
    static let paletteIris4 = Color(red: 46/255, green: 196/255, blue: 182/255) //#2EC4B6
    static let paletteIris5 = Color(red: 66/255, green: 66/255, blue: 66/255) //#42423E

    static let paletteAutumn1 = Color(red: 202/255, green: 77/255, blue: 60/255) //#CA4D3C
    static let paletteAutumn2 = Color(red: 65/255, green: 144/255, blue: 172/255) //#4190AC
    static let paletteAutumn3 = Color(red: 235/255, green: 150/255, blue: 50/255) //#EB9632
    static let paletteAutumn4 = Color(red: 76/255, green: 130/255, blue: 92/255) //#4C825C
    static let paletteAutumn5 = Color(red: 168/255, green: 144/255, blue: 182/255) //#A890B6

    static let paletteBlossom1 = Color(red: 201/255, green: 24/255, blue: 74/255) //#C9184A
    static let paletteBlossom2 = Color(red: 255/255, green: 77/255, blue: 109/255) //#FF4D6D
    static let paletteBlossom3 = Color(red: 255/255, green: 133/255, blue: 161/255) //#FF85A1
    static let paletteBlossom4 = Color(red: 255/255, green: 153/255, blue: 200/255) //#FF99C8
    static let paletteBlossom5 = Color(red: 247/255, green: 37/255, blue: 133/255) //#F72585
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
    }
}
