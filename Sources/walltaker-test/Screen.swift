import Foundation
import Termbox

extension String {
    func components(withMaxLength length: Int) -> [String] {
        return stride(from: 0, to: self.count, by: length).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
    }
}

class Screen {
    var mainAreaContent: [String] = []
    var linkId: Int = 0
    var link: Link?

    func run() {
        do {
            try Termbox.initialize()
        } catch let error {
            print(error)
            return
        }

        Termbox.inputModes = [.esc]

        startEventPoll()
    }

    func appendToMainArea(content: String) {
        mainAreaContent.append(content)
        refreshMainArea()
    }

    func setLink(link: Link) {
        self.link = link
        refreshStatusBar()
    }

    func setLinkId(linkId: Int) {
        self.linkId = linkId
        refreshStatusBar()
    }

    private func refreshStatusBar() {
        var content = "Press q to exit █ ID: \(linkId) █ From: \(link?.setBy ?? "???")"
        if #available(macOS 12, *) {
            let time = link?.updatedAt.formatted()
            content += " at \(time ?? "???")"
        }
        setStatusBar(content: content)
    }

    private func setStatusBar(content: String) {
        let lastY = Termbox.height - 1
        let trimmedContent = content.prefix(Int(Termbox.width))
        let filler = String(
                repeating: " ",
                count: Int(Termbox.width) - trimmedContent.unicodeScalars.count
        )
        printAt(x: 0, y: lastY, text: trimmedContent + filler,
                foreground: .black, background: .yellow)

        Termbox.present()
    }

    private func refreshMainArea() {
        setMainArea(content: mainAreaContent)
    }

    private func setMainArea(content: [String]) {
        let lastY = Termbox.height - 1
        let maxCols = Termbox.width

        let rows = content.flatMap {
            $0.components(withMaxLength: Int(maxCols) - 1)
        }
        let clippedRows = rows.map({
                    $0 + String(
                            repeating: " ",
                            count: Int(Termbox.width) - $0.unicodeScalars.count
                    )
                }) // Pad out every line with empty chars to hide overwrites
                .suffix(Int(lastY)) // Get only the last few rows that fit on the screen
        let countOfRowsToPad = Int(lastY) - clippedRows.count
        let paddingArray = Array(repeatElement(String(repeating: " ", count: Int(Termbox.width)), count: countOfRowsToPad))

        let paddedRows = clippedRows + paddingArray

        for (index, row) in paddedRows.enumerated() {
            printAt(x: 0, y: Int32(index), text: row,
                    foreground: .default, background: .default)
        }

        Termbox.present()
    }

    private func printAt(x: Int32, y: Int32, text: String,
                         foreground: Attributes = .default,
                         background: Attributes = .default) {
        let border = Termbox.width

        for (c, xi) in zip(text.unicodeScalars, x..<border) {
            Termbox.put(x: xi, y: y, character: c,
                    foreground: foreground, background: background)
        }
    }

    private func startEventPoll() {
        if #available(macOS 10.15, *) {
            Task {
                while true {
                    guard let event = Termbox.pollEvent() else {
                        print("Oh crap, this terminal isn't supported. Use version v0.0.1.")
                        exit(0)
                    }

                    switch event {
                    case let .character(_, value):
                        if value == "q" {
                            appendToMainArea(content: "Quitting.")
                            exit(0)
                        }
                    case .key(_, _):
                        continue
                    case .resize(_, _):
                        refreshMainArea()
                        refreshStatusBar()
                    case .mouse(_, _):
                        continue
                    case .timeout:
                        continue
                    }
                }
            }
        } else {
            failAsBadMacOSVersion()
        }
    }
}
