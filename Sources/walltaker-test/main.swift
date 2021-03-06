import Foundation

func failAsBadMacOSVersion() {
    print("Sorry bitch, can't work on this version of MacOS.")
    exit(0)
}

@available(macOS 10.15.0, *)
class Walltaker {
    let wallpaper: Wallpaper
    let screen = Screen()
    var linkId: Int = 0

    init() {
        wallpaper = Wallpaper(screen: screen)
    }

    func run() async {
        print("\u{001B}[2J") // Clear screen
        linkId = askLinkID()
        screen.run()
        present()
        screen.setLinkId(linkId: linkId)
        while true {
            guard let link = await fetchLink() else {
                screen.appendToMainArea(content: "Link fetch failed... trying again.")
                return
            }

            do {
                try wallpaper.update(link: link)
            } catch {
                screen.appendToMainArea(content: "Wallpaper setting failed... trying again.")
            }

            sleep(10)
        }
    }

    private func present() {
        screen.appendToMainArea(content: "Walltaker - MacOS Beta Client")
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
                let (data, _) = try await URLSession.shared.data(from: url)

                return try linkFactory(data: data)
            } else {
                failAsBadMacOSVersion();
                return nil
            }
        } catch {
            screen.appendToMainArea(content: error.localizedDescription)
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
    failAsBadMacOSVersion()
}

while RunLoop.main.run(mode: .default, before: .distantFuture) {}