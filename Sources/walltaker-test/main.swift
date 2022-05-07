import Cocoa
import Foundation

var lastPostUrl: String = ""

func setWallpaper(path: String) {
    let newWallpaperURL = URL(fileURLWithPath: path)
    if let screen = NSScreen.main {
        try! NSWorkspace.shared.setDesktopImageURL(newWallpaperURL, for: screen, options: [:])
    }
}

struct Link: Codable {
    var post_url: String?
    var set_by: String?
}

func getLink(id: Int) {
    let url = URL(string: "https://walltaker.joi.how/api/links/" + String(id) + ".json")!

    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let data = data else {
            return
        }
        let decoder = JSONDecoder()
        do {
            let link = try decoder.decode(Link.self, from: data)
            print(link)
            if link.post_url != nil {
                if (link.post_url != lastPostUrl) {
                    print("New post from " + (link.set_by ?? "anon"))
                    lastPostUrl = link.post_url as! String

                    let directory = NSTemporaryDirectory()
                    let fileName = NSUUID().uuidString

                    guard let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName]) else {
                        fatalError("guard failure handling has not been implemented")
                    }

                    let url = URL(string: link.post_url as! String)
                    let data: Data? = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    print(data)

                    try! data?.write(to: fullURL)
                    print(fullURL.path)

                    setWallpaper(path: fullURL.path)
                } else {
                    print("Wallpaper remains unchanged.")
                }
            }
        } catch {
            print(error.localizedDescription, "sdf")
        }
    }

    task.resume()
}

print("Walltaker - MacOS Beta Client")
print("-----------------------------")
print("Enter your link ID:")
if let linkId = Int(readLine()!) {
    print("Starting link-pinging for ID " + String(linkId))
    getLink(id: linkId)

    while RunLoop.main.run(mode: .default, before: .distantFuture) {
        getLink(id: linkId)
        sleep(10)
    }
} else {
    print("Quitting, that's not a link ID.")
    exit(0)
}
