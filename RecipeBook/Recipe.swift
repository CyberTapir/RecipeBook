import Foundation
import SwiftUI
struct Recipe: Identifiable, Codable {
    var id = UUID()
    var title: String
    var method: String
    var serves: Int
    var timeToCook: Int
}
