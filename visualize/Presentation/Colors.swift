import SwiftUI

// MARK: Background Modifier
struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color("AppBackground")
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

enum AppColors {
    // MARK: Base
    enum Base {
        static let mint = Color("ComponentBackground")
        static let teal = Color("ColorTeal")
        static let navy = Color("ColorNavy")
    }
    
    // MARK: Text
    enum Text {
        static let primary = Base.navy
        static let secondary = Color("TextSecondary")
        static let tertiary = Base.teal
        static let placeholder = Color("TextPlaceholder")
        static let authFieldText = Color("AuthFieldText")
        static let authButtonText = Color("AuthButtonText")
        static let versionText = Color(red: 121/255, green: 139/255, blue: 138/255)
    }

    // MARK: UI
    enum UI {
        static let background = Base.mint
        static let card = Color("Card")
        static let screenBackground = Color("AppBackground")
        static let authErrorBackground = Color("AuthErrorBackground")
        static let authButtonIcon = Color("AuthButtonIcon")
        static let authButton = Color("AuthButton")

        static let lightTeal = Color(red: 230/255, green: 237/255, blue: 236/255)
        static let gray = Color(red: 217/255, green: 217/255, blue: 217/255)
    }

    // MARK: Core Colors
    enum Brand {
        static let mint = Base.mint
        static let teal = Base.teal
        static let navy = Base.navy

        static let orange = Color(red: 255/255, green: 122/255, blue: 0/255)
        static let primaryOrange = Color(red: 235/255, green: 150/255, blue: 50/255)
    }

    // MARK: Status
    enum Status {
        static let red = Color(red: 255/255, green: 59/255, blue: 48/255)
    }

    // MARK: Threads
    enum Threads {
        static let primary = Color(red: 148/255, green: 182/255, blue: 182/255)
        static let replyBackground = Color(red: 253/255, green: 242/255, blue: 229/255)
    }

    // MARK: Palettes
    // swiftlint:disable nesting
    enum Palette {
        enum Lagoon {
            static let c1 = Color(red: 0/255, green: 191/255, blue: 216/255)
            static let c2 = Color(red: 68/255, green: 235/255, blue: 182/255)
            static let c3 = Color(red: 30/255, green: 169/255, blue: 215/255)
            static let c4 = Color(red: 140/255, green: 237/255, blue: 143/255)
            static let c5 = Color(red: 84/255, green: 207/255, blue: 255/255)
        }

        enum Sunset {
            static let c1 = Color(red: 109/255, green: 149/255, blue: 255/255)
            static let c2 = Color(red: 176/255, green: 165/255, blue: 255/255)
            static let c3 = Color(red: 243/255, green: 114/255, blue: 173/255)
            static let c4 = Color(red: 251/255, green: 119/255, blue: 56/255)
            static let c5 = Color(red: 243/255, green: 179/255, blue: 64/255)
        }

        enum Harvest {
            static let c1 = Color(red: 247/255, green: 109/255, blue: 90/255)
            static let c2 = Color(red: 70/255, green: 170/255, blue: 205/255)
            static let c3 = Color(red: 235/255, green: 150/255, blue: 50/255)
            static let c4 = Color(red: 97/255, green: 167/255, blue: 118/255)
            static let c5 = Color(red: 211/255, green: 126/255, blue: 177/255)
        }

        enum Petal {
            static let c1 = Color(red: 255/255, green: 129/255, blue: 152/255)
            static let c2 = Color(red: 255/255, green: 198/255, blue: 214/255)
            static let c3 = Color(red: 255/255, green: 185/255, blue: 120/255)
            static let c4 = Color(red: 255/255, green: 153/255, blue: 200/255)
            static let c5 = Color(red: 255/255, green: 99/255, blue: 167/255)
        }
    }
}
