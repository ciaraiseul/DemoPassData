import UIKit
enum TodoType: Codable {
    case new
    case inprogress
    case completed
}

struct TodoItem: Codable {
    var id: String
    var title: String
    var description: String
    var image: String
    var isSelected: Bool = false
    var type: TodoType
}
