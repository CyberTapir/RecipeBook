import Foundation
import SwiftUI
struct Recipe: Identifiable, Codable {
    let id = UUID()
    let name: String
    let ingredients: [String]
    let instructions: [String]
    var serves: Int
    var timeToCook: Int
}
