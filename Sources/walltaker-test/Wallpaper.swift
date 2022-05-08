import Foundation
import Cocoa

class Wallpaper {
    var lastPostUrl: URL? = nil
    let mainMonitor: NSScreen
    let screen: Screen

    init(screen: Screen) {
        self.screen = screen
        mainMonitor = NSScreen.main!
    }

    func update(link: Link) throws {
        guard let newPostUrl = link.postUrl else {
            printWithTimestamp(msg: "Fresh link! Try setting a image on it first.")
            return
        }

        if (newPostUrl != lastPostUrl) {
            printWithTimestamp(msg: "New post from " + link.setBy)
            lastPostUrl = newPostUrl
            screen.setLink(link: link)

            let tempFilePath = try getTempFilePath()
            try downloadImageTo(sourceURL: newPostUrl, destinationURL: tempFilePath)
            try applyWallpaper(url: tempFilePath)
        } else {
            printWithTimestamp(msg: "Wallpaper not changed.")
        }
    }

    private func applyWallpaper(url: URL) throws {
        try NSWorkspace.shared.setDesktopImageURL(url, for: mainMonitor, options: [:])
        printWithTimestamp(msg: "  | 4/4 - Wallpaper set!")
    }

    private func getTempFilePath() throws -> URL {
        let directory = NSTemporaryDirectory()
        let fileName = NSUUID().uuidString

        let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName])!

        return fullURL
    }

    private func downloadImageTo(sourceURL: URL, destinationURL: URL) throws {
        printWithTimestamp(msg: "  | 1/4 - Downloading...")
        let data = try Data(contentsOf: sourceURL)
        printWithTimestamp(msg: "  | 2/4 - Downloaded " + String(data.count) + " bytes")
        try data.write(to: destinationURL)
        printWithTimestamp(msg: "  | 3/4 - Saved to " + destinationURL.absoluteString)
    }

    private func printWithTimestamp(msg: String) {
        let timestamp = NSDate().timeIntervalSince1970.rounded()

        screen.appendToMainArea(content: String(timestamp) + " - " + msg)
    }

}
