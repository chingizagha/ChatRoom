//
//  ChatTableViewCell.swift
//  ChatRoom
//
//  Created by Chingiz on 10.04.24.
//

import UIKit
import SDWebImage

class ChatTableViewCell: UITableViewCell {
    
    static let identifier = "ChatTableViewCell"
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private let chatTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "person")
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = 16
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .label
        return image
    }()
    
    var textLeading: NSLayoutConstraint!
    var textTrailing: NSLayoutConstraint!
    
    var imageLeading: NSLayoutConstraint!
    var imageTrailing: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func layoutUI(){
        addSubview(bubbleView)
        addSubview(chatTextLabel)
        addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            //profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            profileImageView.heightAnchor.constraint(equalToConstant: 32),
            profileImageView.widthAnchor.constraint(equalToConstant: 32),
            
            chatTextLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            chatTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            chatTextLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 260),
            
            bubbleView.topAnchor.constraint(equalTo: chatTextLabel.topAnchor, constant: -8),
            bubbleView.leadingAnchor.constraint(equalTo: chatTextLabel.leadingAnchor, constant: -8),
            bubbleView.trailingAnchor.constraint(equalTo: chatTextLabel.trailingAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: chatTextLabel.bottomAnchor, constant: 8)
        ])
        
        imageLeading = profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12)
        imageTrailing = profileImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        
        textLeading = chatTextLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16)
        textTrailing = chatTextLabel.trailingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: -16)
    }
    
    func configureForMessage(message: Message, currentUID: String) {
        let isUser = currentUID == message.uid ? true : false
        chatTextLabel.text = message.text
        
        if message.photoURL.count > 0 {
            let url = URL(string: message.photoURL)
            profileImageView.sd_setImage(with: url)
        }
        
        if isUser {
            textTrailing.isActive = true
            imageTrailing.isActive = true
            
            imageLeading.isActive = false
            textLeading.isActive = false
            
            bubbleView.backgroundColor = .systemBlue
        } else {
            imageLeading.isActive = true
            textLeading.isActive = true
            
            textTrailing.isActive = false
            imageTrailing.isActive = false
            
            bubbleView.backgroundColor = .systemGray6
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        chatTextLabel.text = nil
        profileImageView.image = nil
        
    }

}
