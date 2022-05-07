import Foundation

struct LinkResponse: Codable {
    var post_url: String?
    var set_by: String?
}

struct Link {
    var postUrl: URL?
    var setBy: String
}

func linkFactory (data: Data) throws -> Link {
    let decoder = JSONDecoder()
    let linkResponse = try decoder.decode(LinkResponse.self, from: data)

    let postUrl: URL? = linkResponse.post_url != nil ? URL(string: linkResponse.post_url!) : nil

    let link = Link(
            postUrl: postUrl,
            setBy: linkResponse.set_by ?? "anon"
    )

    return link
}
