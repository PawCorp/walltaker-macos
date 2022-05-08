import Foundation

struct LinkResponse: Codable {
    var post_url: String?
    var set_by: String?
    var updated_at: String
}

struct Link {
    var postUrl: URL?
    var setBy: String
    var updatedAt: Date
}

func parseIsoDate(timestamp: String) -> Date? {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return formatter.date(from: timestamp)
}

func linkFactory (data: Data) throws -> Link {
    let decoder = JSONDecoder()
    let linkResponse = try decoder.decode(LinkResponse.self, from: data)

    let postUrl: URL? = linkResponse.post_url != nil ? URL(string: linkResponse.post_url!) : nil

    let date = parseIsoDate(timestamp: linkResponse.updated_at)

    let link = Link(
            postUrl: postUrl,
            setBy: linkResponse.set_by ?? "anon",
            updatedAt: date ?? Date()
    )

    return link
}
