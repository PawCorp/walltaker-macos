import Foundation

@available(macOS 10.15.0, *)
class Walltaker {
    let wallpaper = Wallpaper()
    var linkId: Int = 0

    func run() async {
        linkId = askLinkID()
        print("Starting link-pinging for ID " + String(linkId))
        while true {
            guard let link = await fetchLink() else {
                print("Link fetch failed... trying again.")
                return
            }

            do {
                try wallpaper.update(link: link)
            } catch {
                print("Wallpaper setting failed... trying again.", error.localizedDescription)
            }

            sleep(10)
        }
    }

    private func present() {
        print("Walltaker - MacOS Beta Client")
        print("-----------------------------")
    }

    private func askLinkID() -> Int {
        print("Enter your link ID:")
        if let selectedLinkId = Int(readLine()!) {
            return selectedLinkId
        } else {
            print("That's not a link ID! You are looking for a number. It's the last number in the URL for your link.\n")
            return askLinkID()
        }
    }

    private func fetchLink() async -> Link? {
        do {
            let url = URL(string: "https://walltaker.joi.how/api/links/" + String(linkId) + ".json")!
            if #available(macOS 12.0, *) {
                let (data, response) = try await URLSession.shared.data(from: url)

                return try linkFactory(data: data)
            } else {
                print("Sorry bitch, can't work on this version of MacOS")
                exit(0)
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

if #available(macOS 10.15, *) {
    Task {
        let app = Walltaker()
        await app.run()
    }
} else {
    print("Sorry bitch, can't work on this version of MacOS")
    exit(0)
}

while RunLoop.main.run(mode: .default, before: .distantFuture) {}