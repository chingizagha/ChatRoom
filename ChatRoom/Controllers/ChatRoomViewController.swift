//
//  ViewController.swift
//  ChatRoom
//
//  Created by Chingiz on 10.04.24.
//

import UIKit
import FirebaseAuth
import Combine

class ChatRoomViewController: UIViewController {
    
    var tokens: Set<AnyCancellable> = []
    private var messages: [Message] = []
    var currentUser: User!
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        return tableView
    }()
    
    lazy var textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.backgroundColor = .systemGray6
        tv.autocorrectionType = .no
        tv.autocapitalizationType = .none
        tv.returnKeyType = .send
        tv.font = .systemFont(ofSize: 16)
        tv.textContainerInset = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        return tv
    }()
    
    lazy var sendImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "paperplane")
        image.tintColor = .label
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .systemGray6
        image.contentMode = .scaleAspectFit
        image.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapSend))
        image.addGestureRecognizer(gesture)
        return image
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        layoutUI()
        subscribeToKeyboardShowHide()
        setUpNavBar()
        fetchMessages()
        subsciribeToMessagePublisher()
    }
    
    init(currentUser: User){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func fetchMessages() {
        Task {
            let messages = try await DatabaseManager.shared.fetchAllMessages()
            self.messages = messages
            await MainActor.run {
                self.reloadChat()
            }
        }
    }
    
    private func setUpNavBar(){
        navigationController?.navigationBar.topItem?.title = "Chat Room"
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(didTapSignOut))
        navigationController?.navigationBar.tintColor = .systemRed
        navigationController?.navigationBar.backgroundColor = .systemBackground
    }
    
    private func subsciribeToMessagePublisher() {
        DatabaseManager.shared.updatedMessagesPublisher.receive(on: DispatchQueue.main).sink { _ in
            
        } receiveValue: { messages in
            self.messages = messages
            self.reloadChat()
        }.store(in: &tokens)

    }
    
    private func layoutUI(){
        view.addSubview(tableView)
        view.addSubview(textView)
        view.addSubview(sendImageView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: 0),
            
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: sendImageView.leadingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.heightAnchor.constraint(equalToConstant: 100),
            
            sendImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            sendImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sendImageView.heightAnchor.constraint(equalToConstant: 101),
            sendImageView.widthAnchor.constraint(equalToConstant: 50),

        ])
    }
    
    private func subscribeToKeyboardShowHide() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func reloadChat() {
        tableView.reloadData()
        let index = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: index, at: .bottom, animated: true)
    }
    
    @objc
    private func keyboardWillShow(notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.view.frame.origin.y = -keyboardFrame.size.height
    }
    
    @objc
    private func keyboardWillHide(notification: Notification) {
        let info = notification.userInfo!
        let _: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.view.frame.origin.y = 0
    }
    
    @objc
    private func didTapSend() {
        textView.resignFirstResponder()
        if let textMessage = textView.text, textMessage.count > 1 {
            let message = Message(text: textMessage, photoURL: currentUser.photoURL?.absoluteString ?? "" , uid: currentUser.uid, createdAt: Date())
            DatabaseManager.shared.sendMessageToDatabase(message: message)
            messages.append(message)
            textView.text = ""
            reloadChat()
        }
    }
    
    @objc
    private func didTapSignOut() {
        do {
            try AuthManager.shared.signOut()
            let signInVC = UINavigationController(rootViewController: SignInViewController())
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc: signInVC)
        } catch {
            print("")
        }
    }


}

extension ChatRoomViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.identifier, for: indexPath) as? ChatTableViewCell else{ fatalError() }
        
        let message = messages[indexPath.row]
        cell.configureForMessage(message: message, currentUID: currentUser.uid)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

extension ChatRoomViewController: UITextViewDelegate {
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            didTapSend()
            return false
        }
        return true
    }
}
