import Foundation

let wallpaper = Wallpaper()

func getLink(id: Int) {
    let url = URL(string: "https://walltaker.joi.how/api/links/" + String(id) + ".json")!

    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if (error != nil) {
            print(error?.localizedDescription as Any)
            return
        }

        do {
            // Turn JSON into a Link...
            let link = try linkFactory(data: data!)

            // ...set wallpaper to new Link
            try wallpaper.update(link: link)
        } catch {
            print(error.localizedDescription)
        }
    }

    task.resume()
}

print("Walltaker - MacOS Beta Client")
print("-----------------------------")
print("Enter your link ID:")

if let linkId = Int(readLine()!) {
    print("Starting link-pinging for ID " + String(linkId))

    while RunLoop.main.run(mode: .default, before: .distantFuture) {
        getLink(id: linkId)
        sleep(10)
    }
} else {
    print("Quitting, that's not a link ID.")
    exit(0)
}
