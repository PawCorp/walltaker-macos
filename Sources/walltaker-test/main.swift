import Cocoa
import Foundation

func setWallpaper(path: String) {
    let newWallpaperURL = URL(fileURLWithPath: path)
    if let screen = NSScreen.main {
        try! NSWorkspace.shared.setDesktopImageURL(newWallpaperURL, for: screen, options: [:])
    }
}

protocol Link {
    var post_url: String { get set }
}

func getLink(id: Int) {
    let url = URL(string: "https://walltaker.joi.how/api/links/" + String(id) + ".json")!

    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let data = data else {
            return
        }
        let link = try? JSONSerialization.jsonObject(with: data) as! [String: Any]

        if link?["post_url"] != nil {
            print(link?["post_url"])

            let directory = NSTemporaryDirectory()
            let fileName = NSUUID().uuidString

            guard let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName]) else {
                fatalError("guard failure handling has not been implemented")
            }

            let url = URL(string: link?["post_url"] as! String)
            let data: Data? = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            print(data)

            try! data?.write(to: fullURL)
            print(fullURL.path)

            setWallpaper(path: fullURL.path)
        }
    }

    task.resume()
}

getLink(id: 1)
while RunLoop.main.run(mode: .default, before: .distantFuture) {
}

