//
//  HashtagTextView.swift
//  FeedNew
//
//  Created by Artem Vasin on 16.03.25.
//

import SwiftUI
import DesignSystem

struct HashtagTextView: UIViewRepresentable {
    let inputString: String
    let font: UIFont
    let textColor: UIColor
    let lineLimit: Int?
    let alignment: NSTextAlignment
    let onHashtagTap: (String) -> Void
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.isUserInteractionEnabled = true
        textView.delegate = context.coordinator

        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)

        textView.font = font
        textView.textColor = textColor
        textView.textAlignment = alignment
        textView.dataDetectorTypes = .link
        
        let attributedString = NSMutableAttributedString(string: inputString, attributes: [
            .font: font,
            .foregroundColor: textColor
        ])
        let hashtagPattern = "#[\\w_]{3,50}"
        let regex = try! NSRegularExpression(pattern: hashtagPattern)
        
        let matches = regex.matches(in: inputString, range: NSRange(location: 0, length: inputString.utf16.count))
        for match in matches {
            let range = match.range
            let hashtag = (inputString as NSString).substring(with: range)
            attributedString.addAttribute(.foregroundColor, value: UIColor(Colors.hashtag), range: range)
            attributedString.addAttribute(.link, value: "hashtag://\(hashtag)", range: range)
        }
        
        textView.attributedText = attributedString
        
        if let lineLimit = lineLimit {
            textView.textContainer.maximumNumberOfLines = lineLimit
            textView.textContainer.lineBreakMode = .byTruncatingTail
        }
        
        return textView
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }
        let dimensions = inputString.boundingRect(
            with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil)
        return .init(width: width, height: ceil(dimensions.height))
    }

    func updateUIView(_ uiView: UITextView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onHashtagTap: onHashtagTap)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        let onHashtagTap: (String) -> Void
        
        init(onHashtagTap: @escaping (String) -> Void) {
            self.onHashtagTap = onHashtagTap
        }
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            if URL.scheme == "hashtag" {
                let hashtag = URL.absoluteString.replacingOccurrences(of: "hashtag://", with: "")
                onHashtagTap(hashtag)
                return false
            }
            return true
        }
    }
}
