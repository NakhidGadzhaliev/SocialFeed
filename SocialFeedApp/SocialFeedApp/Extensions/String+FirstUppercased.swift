import Foundation

extension String {
    var firstUppercased: String {
        prefix(1).uppercased() + dropFirst()
    }
}
