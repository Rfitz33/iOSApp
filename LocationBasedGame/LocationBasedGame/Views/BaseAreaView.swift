import SwiftUI

// MARK: - BaseAreaView
struct BaseAreaView: View {
    @ObservedObject var gameManager: GameManager // To check upgrade status and costs

    let upgradeType: BaseUpgradeType // Which upgrade this area represents
    let builtIconName: String       // SF Symbol or Asset name when BUILT
    let builtIconColor: Color
    let unbuiltIconName: String = "plus.circle.fill" // Default for unbuilt slot
    let unbuiltIconColor: Color = .gray
    
    let size: CGFloat
    let actionForBuilt: () -> Void    // Action when tapped if BUILT
    // Action when tapped if NOT BUILT (will present upgrade details)
    // We'll use a binding to show a sheet with the upgrade details.
    // This requires a new @State var in HomeBaseView.
    // For now, let's pass a simpler action that HomeBaseView can handle.
    let actionForUnbuilt: () -> Void

    private var isActuallyBuilt: Bool {
        gameManager.activeBaseUpgrades.contains(upgradeType)
    }

    var body: some View {
        Button(action: {
            if isActuallyBuilt {
                actionForBuilt()
            } else {
                actionForUnbuilt()
            }
        }) {
            VStack(spacing: 5) {
                Image(systemName: isActuallyBuilt ? builtIconName : unbuiltIconName)
                    .font(.system(size: size * 0.35, weight: isActuallyBuilt ? .regular : .light))
                    .foregroundColor(isActuallyBuilt ? builtIconColor : unbuiltIconColor.opacity(0.7))
                    .frame(width: size * 0.5, height: size * 0.5)
                    .padding(5)
                    .background(
                        (isActuallyBuilt ? builtIconColor.opacity(0.1) : Color.clear)
                            .clipShape(Circle())
                    )

                Text(isActuallyBuilt ? upgradeType.displayName : "Build \(upgradeType.displayName)")
                    .font(.caption)
                    .fontWeight(isActuallyBuilt ? .medium : .regular)
                    .foregroundColor(isActuallyBuilt ? .primary : .secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8) // Allow text to shrink slightly if needed
            }
            .frame(width: size, height: size)
            .background(isActuallyBuilt ? builtIconColor.opacity(0.08) : Color(uiColor: .systemGray6).opacity(0.7))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isActuallyBuilt ? builtIconColor.opacity(0.7) : Color.gray.opacity(0.4), lineWidth: 1.5)
            )
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// Preview for BaseAreaView (optional but good)
struct BaseAreaView_Previews: PreviewProvider {
    static var gameManagerWithForge: GameManager {
        let gm = GameManager.shared // Use shared for easy setup or a fresh mock
        gm.activeBaseUpgrades.insert(.basicForge) // Simulate forge built
        return gm
    }
    static var gameManagerWithoutForge: GameManager {
        let gm = GameManager.shared
        gm.activeBaseUpgrades.remove(.basicForge) // Simulate forge not built
        return gm
    }

    static var previews: some View {
        Group {
            BaseAreaView(gameManager: gameManagerWithForge,
                         upgradeType: .basicForge,
                         builtIconName: "flame.fill",
                         builtIconColor: .red,
                         size: 90,
                         actionForBuilt: { print("Forge Built Tapped") },
                         actionForUnbuilt: { print("Forge Unbuilt Tapped") }
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Built Forge")

            BaseAreaView(gameManager: gameManagerWithoutForge,
                         upgradeType: .basicForge,
                         builtIconName: "flame.fill",
                         builtIconColor: .red,
                         size: 90,
                         actionForBuilt: { print("Forge Built Tapped") },
                         actionForUnbuilt: { print("Forge Unbuilt Tapped") }
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Unbuilt Forge")
        }
    }
}
