import SwiftUI

extension Color {
    static let primaryText = AppColors.Text.primary
    static let appMint = AppColors.UI.background
    static let appTeal = AppColors.Text.teriary
    static let appSubtitle = AppColors.Text.secondary
    
    static let appNavy = Color(red: 19/255,  green: 33/255,  blue: 44/255)  // #13212C
    static let appOrange = Color(red: 255/255, green: 122/255, blue: 0/255)   // #FF7A00
    static let appCardTitle = Color(red: 26/255,  green: 47/255,  blue: 63/255)  // #1A2F3F
    static let appButtonBackground = Color(red: 235/255, green: 235/255, blue: 240/255) // #EBEBF0
    static let appLightTeal = Color(red: 230/255, green: 237/255, blue: 236/255) //34797C
    static let primaryOrange = Color(red: 235/255,green: 150/255,blue: 50/255)
    static let appRed = Color(red: 255/255, green: 59/255, blue: 48/255)
    static let appDarkBlue = Color(red: 26/255, green: 47/255, blue: 63/255)
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
