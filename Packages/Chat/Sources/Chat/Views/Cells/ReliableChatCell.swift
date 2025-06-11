//
//  ReliableChatCell.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//
import UIKit
import Models

final class ReliableChatCell: UICollectionViewCell {
    // MARK: ‑ UI
    private let bubbleView            = UIView()
    private let headerView            = UIView()
    private let usernameLabel         = UILabel()
    private let headerTimestampLabel  = UILabel()
    private let messageLabel          = UILabel()
    private let timeLabel             = UILabel()   // bottom‑right (optional)
    private let avatarImageView       = UIImageView()

    // Alignment constraints (activated per direction)
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    private var avatarLeadingConstraint: NSLayoutConstraint?
    private var avatarTrailingConstraint: NSLayoutConstraint?

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: Setup
    private func setupViews() {
        contentView.backgroundColor = .clear

        // Avatar (35×35)
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 17.5
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarImageView)

        // Bubble
        bubbleView.layer.cornerRadius = 12
        bubbleView.layer.masksToBounds = true
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)

        // Header
        headerView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(headerView)

        usernameLabel.font = .boldSystemFont(ofSize: 13)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(usernameLabel)

        headerTimestampLabel.font = .systemFont(ofSize: 11)
        headerTimestampLabel.textAlignment = .right
        headerTimestampLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerTimestampLabel)

        // Priorities – allow timestamp to stay visible when space tight
        usernameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        headerTimestampLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        headerTimestampLabel.setContentHuggingPriority(.required, for: .horizontal)

        // Message
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(messageLabel)

        // Bottom time (optional)
        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(timeLabel)

        // Layout
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 6),
            headerView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            headerView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),

            usernameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            usernameLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),

            headerTimestampLabel.leadingAnchor.constraint(greaterThanOrEqualTo: usernameLabel.trailingAnchor, constant: 4),
            headerTimestampLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            headerTimestampLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerTimestampLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),

            // Message below header
            messageLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),

            // Bottom time
            timeLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 4),
            timeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),

            // Bubble vertical padding relative to cell
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            // 85% width max
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.85)
        ])
    }

    // MARK: Configure
    func configure(with message: Message1) {
        // Reset dynamic constraints
        NSLayoutConstraint.deactivate([leadingConstraint, trailingConstraint, avatarLeadingConstraint, avatarTrailingConstraint].compactMap { $0 })

        // Texts
        usernameLabel.text          = message.sender.name
        let relativeTime            = message.timestamp.toStringFormat().timeAgo(isShort: true)
        headerTimestampLabel.text   = relativeTime
        timeLabel.text              = relativeTime
        messageLabel.text           = message.text
        messageLabel.textAlignment  = message.isIncoming ? .left : .right

        // Direction‑specific styling
        if message.isIncoming {
            styleIncoming()
        } else {
            styleOutgoing()
        }

        // Avatar download (simple demo implementation)
        avatarImageView.image = nil
        if let imgURL = message.sender.image, let url = URL(string: imgURL) {
            DispatchQueue.global(qos: .userInitiated).async {
                if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                    DispatchQueue.main.async { self.avatarImageView.image = img }
                }
            }
        } else {
            avatarImageView.image = UIImage(named: "avatar-placeholder")
        }
    }

    private func styleIncoming() {
        avatarLeadingConstraint = avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8)
        avatarTrailingConstraint = nil
        leadingConstraint  = bubbleView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8)
        trailingConstraint = bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8)

        applyCommonStyle(bg: UIColor(hex: "#77AFFF"))
        bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner] // square bottom‑left

        activateDynamic()
    }

    private func styleOutgoing() {
        avatarTrailingConstraint = avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        avatarLeadingConstraint = nil
        leadingConstraint  = bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 8)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: -8)

        applyCommonStyle(bg: UIColor(hex: "#323232"))
        bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner] // square bottom‑right

        activateDynamic()
    }

    private func applyCommonStyle(bg: UIColor) {
        bubbleView.backgroundColor      = bg
        [usernameLabel, messageLabel].forEach { $0.textColor = .white }
        [headerTimestampLabel, timeLabel].forEach { $0.textColor = UIColor.white.withAlphaComponent(0.8) }
    }

    private func activateDynamic() {
        let avatarConstraints = [
            avatarImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 35),
            avatarImageView.heightAnchor.constraint(equalToConstant: 35)
        ]
        NSLayoutConstraint.activate([
            leadingConstraint, trailingConstraint, avatarLeadingConstraint, avatarTrailingConstraint
        ].compactMap { $0 } + avatarConstraints)
    }

    // MARK: Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        NSLayoutConstraint.deactivate([leadingConstraint, trailingConstraint, avatarLeadingConstraint, avatarTrailingConstraint].compactMap { $0 })
        avatarImageView.image = nil
    }
}

// MARK: Helpers
private extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64(); Scanner(string: hex).scanHexInt64(&int)
        let (a,r,g,b): (UInt64,UInt64,UInt64,UInt64)
        switch hex.count {
        case 3: (a,r,g,b) = (255,(int>>8)*17,(int>>4 & 0xF)*17,(int & 0xF)*17)
        case 6: (a,r,g,b) = (255,int>>16,int>>8 & 0xFF,int & 0xFF)
        case 8: (a,r,g,b) = (int>>24,int>>16 & 0xFF,int>>8 & 0xFF,int & 0xFF)
        default:(a,r,g,b) = (255,0,0,0)
        }
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255)
    }
}

private extension Date {
    func toStringFormat() -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd HH:mm:ss"; f.timeZone = .init(abbreviation: "UTC"); return f.string(from: self)
    }
}
