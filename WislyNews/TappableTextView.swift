import SwiftUI
import UIKit

struct TappableTextView: UIViewRepresentable {
    let text: String
    let savedWords: Set<String>
    var onWordTapped: (String, String?) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onWordTapped: onWordTapped) }

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tv.addGestureRecognizer(tap)
        context.coordinator.textView = tv
        return tv
    }

    func updateUIView(_ tv: UITextView, context: Context) {
        context.coordinator.onWordTapped = onWordTapped
        tv.attributedText = buildAttributedString()
        tv.invalidateIntrinsicContentSize()
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        let width = proposal.width ?? UIScreen.main.bounds.width - 32
        return uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
    }

    private func buildAttributedString() -> NSAttributedString {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let para = NSMutableParagraphStyle()
        para.lineSpacing = 6
        let result = NSMutableAttributedString()

        for token in tokenize(text) {
            let isWord = token.rangeOfCharacter(from: .letters) != nil
            let clean  = token.trimmingCharacters(in: .punctuationCharacters).lowercased()
            var attrs: [NSAttributedString.Key: Any] = [.font: font, .paragraphStyle: para, .foregroundColor: UIColor.label]
            if isWord && savedWords.contains(clean) {
                attrs[.foregroundColor]  = UIColor.systemBlue
                attrs[.underlineStyle]   = NSUnderlineStyle.single.rawValue
                attrs[.underlineColor]   = UIColor.systemBlue
            }
            result.append(NSAttributedString(string: token, attributes: attrs))
        }
        return result
    }

    private func tokenize(_ text: String) -> [String] {
        var tokens: [String] = []; var current = ""
        for ch in text {
            if ch.isLetter || ch.isNumber { current.append(ch) }
            else { if !current.isEmpty { tokens.append(current); current = "" }; tokens.append(String(ch)) }
        }
        if !current.isEmpty { tokens.append(current) }
        return tokens
    }

    final class Coordinator: NSObject {
        var onWordTapped: (String, String?) -> Void
        weak var textView: UITextView?

        init(onWordTapped: @escaping (String, String?) -> Void) { self.onWordTapped = onWordTapped }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let tv = textView else { return }
            let location = gesture.location(in: tv)
            guard let position = tv.closestPosition(to: location),
                  let wordRange = tv.tokenizer.rangeEnclosingPosition(position, with: .word, inDirection: .storage(.forward))
            else { return }
            let word = tv.text(in: wordRange) ?? ""
            let clean = word.trimmingCharacters(in: .punctuationCharacters)
            guard !clean.isEmpty, clean.rangeOfCharacter(from: .letters) != nil else { return }

            var sentence: String? = nil
            if let sentenceRange = tv.tokenizer.rangeEnclosingPosition(position, with: .sentence, inDirection: .storage(.forward)),
               let raw = tv.text(in: sentenceRange) {
                let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { sentence = trimmed }
            }

            onWordTapped(clean, sentence)
        }
    }
}
