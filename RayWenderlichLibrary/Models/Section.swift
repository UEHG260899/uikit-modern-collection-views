import Foundation

struct Section: Decodable {
    let title: String
    let videos: [Video]
    let identifier = UUID().uuidString
}

extension Section: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension Section: Equatable {
    static func ==(lhs: Section, rhs: Section) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
