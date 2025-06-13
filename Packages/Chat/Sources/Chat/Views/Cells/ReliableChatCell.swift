//
//  ReliableChatCell.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//
import UIKit
import Models
import DesignSystem

final class ReliableChatCell: UICollectionViewCell {
    // MARK: - UI
    private let bubbleView = UIView()
    private let headerView = UIView()
    private let usernameLabel = UILabel()
    private let timestampLabel = UILabel()
    private let messageLabel = UILabel()
    private let avatarImageView = UIImageView()
    

    // Alignment constraints
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    private var avatarLeadingConstraint: NSLayoutConstraint?
    private var avatarTrailingConstraint: NSLayoutConstraint?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup
    private func setupViews() {
        contentView.backgroundColor = .clear

        // Avatar (35×35)
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 17.5
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarImageView)

        // Bubble
        bubbleView.layer.cornerRadius = 24
        bubbleView.layer.masksToBounds = true
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)

        // Header
        headerView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(headerView)

        usernameLabel.font = .boldSystemFont(ofSize: 13)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(usernameLabel)

        timestampLabel.font = .systemFont(ofSize: 11)
        timestampLabel.textAlignment = .right
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(timestampLabel)

        // Set content priorities
        usernameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        timestampLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        timestampLabel.setContentHuggingPriority(.required, for: .horizontal)

        // Message
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.setContentHuggingPriority(.required, for: .horizontal)
        messageLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(messageLabel)

        let bubbleWidthConstraint = bubbleView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.55)
            bubbleWidthConstraint.priority = .required
            bubbleWidthConstraint.isActive = true
        // Layout
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 6),
            headerView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            headerView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            headerView.heightAnchor.constraint(equalToConstant: 20),

            usernameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            usernameLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),

            timestampLabel.leadingAnchor.constraint(greaterThanOrEqualTo: usernameLabel.trailingAnchor, constant: 4),
            timestampLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            timestampLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            timestampLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),

            // Message below header
            messageLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),

            // Bubble vertical padding relative to cell
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            //bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75)
        ])
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        
        layoutIfNeeded()
        
        let calculatedSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        var attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        attributes.frame.size.height = calculatedSize.height
        return attributes
    }

    
    // MARK: - Configuration
    func configure(with message: Message1) {
        resetConstraints()
        
        // Set content
        usernameLabel.text = message.sender.name
        timestampLabel.text = message.timestamp.timeAgo(isShort: true)
        messageLabel.text = message.text
        messageLabel.textAlignment = message.isIncoming ? .left : .right

        // Apply styling based on message direction
        if message.isIncoming {
            styleIncoming()
        } else {
            styleOutgoing()
        }

        loadAvatarImage(from: message.sender.image)
    }

    private func resetConstraints() {
        [leadingConstraint, trailingConstraint, avatarLeadingConstraint, avatarTrailingConstraint].forEach {
            $0?.isActive = false
        }

        leadingConstraint = nil
        trailingConstraint = nil
        avatarLeadingConstraint = nil
        avatarTrailingConstraint = nil
    }

    private func styleIncoming() {
        avatarLeadingConstraint = avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8)
        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8)
        trailingConstraint = bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8)

        applyCommonStyle(bg: Colors.blueLight.uiColor)
        bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        activateDynamicConstraints()
    }

    private func styleOutgoing() {
        avatarTrailingConstraint = avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        leadingConstraint = bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 8)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: -8)

        applyCommonStyle(bg: Colors.inactiveDark.uiColor)
        bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        
        activateDynamicConstraints()
    }

    private func applyCommonStyle(bg: UIColor) {
        bubbleView.backgroundColor = bg
        usernameLabel.textColor = .white
        messageLabel.textColor = .white
        timestampLabel.textColor = UIColor.white.withAlphaComponent(0.8)
    }

    private func activateDynamicConstraints() {
        NSLayoutConstraint.activate([
            avatarLeadingConstraint,
            avatarTrailingConstraint,
            leadingConstraint,
            trailingConstraint,
            avatarImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 35),
            avatarImageView.heightAnchor.constraint(equalToConstant: 35)
        ].compactMap { $0 })
    }

    private func loadAvatarImage(from urlString: String?) {
        avatarImageView.image = UIImage(named: "avatar-placeholder")
        
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.avatarImageView.image = image
                }
            }
        }
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        resetConstraints()
        avatarImageView.image = nil
    }
}
