//
//  EditingViewController.swift
//  Заметки
//
//  Created by Федор Гладков on 15.02.2024.
//

import UIKit
import RealmSwift

class EditingViewController: UIViewController {
    
    var note: Note?
    let realm = try! Realm()
    private var notes = List<Note>()
    
//    MARK: - UI elements
    
    let scrollView: UIScrollView = {
        
        let sv = UIScrollView()
            sv.backgroundColor = .blue
            sv.keyboardDismissMode = .interactive
            sv.translatesAutoresizingMaskIntoConstraints = false
            sv.keyboardDismissMode = .interactive
        return sv
    }()
    
    let contentView: UIView = {
        
        let cv = UIView()
            cv.backgroundColor = .green
            cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    let noteTitle: UITextView = {
        
        let tv = UITextView()
            tv.backgroundColor = .white
            tv.textAlignment = .left
            tv.font = UIFont.systemFont(ofSize: 18)
            tv.isScrollEnabled = false
            tv.isEditable = true
            tv.isSelectable = true
            tv.translatesAutoresizingMaskIntoConstraints = false
        
        return tv
    }()

    let noteText: UITextView = {
        
        let tv = UITextView()
            tv.backgroundColor = .white
            tv.text = "Place for your note"
            tv.font = UIFont.systemFont(ofSize: 18)
            tv.isScrollEnabled = false
            tv.isEditable = true
            tv.isSelectable = true
            tv.textAlignment = .left
            tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let saveChangesButton: UIButton = {
        
        let btn = UIButton()
            btn.setTitle("Save changes", for: .normal)
            
            btn.layer.backgroundColor = UIColor.blue.cgColor
            btn.layer.cornerRadius = 10
        
            btn.isEnabled = false
            btn.alpha = 0.5
        
            btn.translatesAutoresizingMaskIntoConstraints = false
            
        
            btn.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return btn
    }()
    
//    MARK: - viewDidLoad()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
        
        let safeLayout = self.view.safeAreaLayoutGuide
        
        addAllSubviews()
        configureNavigationBar()
    
        noteTitle.delegate = self
        noteText.delegate = self
        
        noteTitle.text = note?.text
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: safeLayout.topAnchor),
            view.bottomAnchor.constraint(equalTo: safeLayout.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: safeLayout.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: safeLayout.trailingAnchor),
            
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
                    contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                    contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                    contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                    
                        noteTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                        noteTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                        noteTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//                        nameTextView.heightAnchor.constraint(equalToConstant: 50),
                        
                        noteText.topAnchor.constraint(equalTo: noteTitle.bottomAnchor, constant: 10),
                        noteText.leadingAnchor.constraint(equalTo: noteTitle.leadingAnchor),
                        noteText.trailingAnchor.constraint(equalTo: noteTitle.trailingAnchor),
//                        textTextView.heightAnchor.constraint(equalToConstant: 400),

                        saveChangesButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                        saveChangesButton.heightAnchor.constraint(equalToConstant: 50),
                        saveChangesButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -50),
                        saveChangesButton.topAnchor.constraint(equalTo: noteText.bottomAnchor, constant: 10),
                        saveChangesButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
        ])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeKeyboardEvents()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
//    MARK: - Functions
    
    func addAllSubviews() {
        view.addSubview(scrollView)
            scrollView.addSubview(contentView)
                contentView.addSubview(noteTitle)
                contentView.addSubview(noteText)
                contentView.addSubview(saveChangesButton)
    }
    
    func configureNavigationBar() {
        guard let navigationbar = navigationController?.navigationBar else {
            return
        }
        
        title = "Editing a note"
        navigationbar.tintColor = .white
        navigationbar.backgroundColor = .gray
        
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(doneButtonTapped))
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("editing...")
        saveChangesButton.alpha = 1
        saveChangesButton.isEnabled = true
    }
    
    @objc func saveButtonTapped() {
//        print("tapped")
        
        let updatedNote = Note()
        updatedNote.noteID = note!.noteID
        
        if noteTitle.text.isEmpty {
            updatedNote.text = "Empty note"
        } else {
            updatedNote.text = noteTitle.text
        }
        
        do {
            try realm.write {
                realm.add(updatedNote, update: .modified)
            }
        } catch let error as NSError {
            print("Error writing to realm: \(error)")
        }
    }
    
    func subscribeKeyboardEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let ks = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: ks.height, right: 0)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.scrollView.contentInset = .zero
    }

}
    
extension EditingViewController: UITextViewDelegate {
    
}

/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
}
*/
