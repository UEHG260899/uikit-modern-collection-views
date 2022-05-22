import Foundation

struct TutorialCollection: Decodable {
    let title: String
    let tutorials: [Tutorial]
    let identifier = UUID().uuidString
}

extension TutorialCollection: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(tutorials)
    }
}

extension TutorialCollection: Equatable {
    static func ==(lhs: TutorialCollection, rhs: TutorialCollection) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension TutorialCollection {
    var queuedTutorials: [Tutorial] {
        return tutorials.filter({ $0.isQueued })
    }
}
