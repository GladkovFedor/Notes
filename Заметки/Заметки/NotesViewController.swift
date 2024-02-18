//  NotesViewController.swift
//  Заметки
//
//  Created by Федор Гладков on 13.02.2024.
//

import UIKit
import RealmSwift

class NotesViewController: UIViewController {
    
    let realm = try! Realm()
    let tableView = UITableView()
    private var notes = List<Note>()

//    MARK: - Methods of VC's lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        let safeLayout = self.view.safeAreaLayoutGuide
        
        addAllSubviews()
        
        loadNotes()
        defaultNote()
        
        configureTableView()
        configureNavigationBar()
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: safeLayout.topAnchor),
            view.bottomAnchor.constraint(equalTo: safeLayout.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: safeLayout.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: safeLayout.trailingAnchor),
        
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
//     MARK: - Methods of VC configuration
    
    func addAllSubviews() {
        view.addSubview(tableView)
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGray
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func configureNavigationBar() {
        guard let navigationbar = navigationController?.navigationBar else {
            return
        }
        
        title = "Заметки"
        navigationbar.tintColor = .white
        
        let addNoteButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addNoteButtonTapped))
    
        navigationItem.rightBarButtonItem = addNoteButton
    }
    
    @objc func addNoteButtonTapped() {
        let note = Note(text: "New noteNew noteNew noteNew noteNew noteNew notNew noteNew noteNew noteNew noteNew noteNew notNew noteNew noteNew noteNew noteNew noteNew note")
        
        notes.append(note)
        saveNotes()
        tableView.reloadData()
    }
    
//     MARK: - Realm-using Methods

    func defaultNote() {
        if notes.count == 0 {
            let defaultNote = Note(text: "There's no notes here yet.")
            notes.append(defaultNote)
        }
    }

    func loadNotes() {
        let realmNotes = realm.objects(Note.self)
        notes.append(objectsIn: realmNotes)
    }

    func saveNotes() {
        do {
            try realm.write {
                realm.add(notes, update: .modified)
            }
        } catch let error as NSError {
            print("Error writing to realm: \(error)")
        }
    }

    func deleteNote(index: Int) {
        do {
            try realm.write {
                realm.delete(notes[index])
                notes.remove(at: index)
            }
        } catch let error as NSError {
            print("Error deleting note: \(error)")
        }
    }
    
}

extension NotesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = notes[indexPath.row].text
            cell.backgroundColor = .gray
        return cell
    }
}

extension NotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteNote(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true)
        let editingViewController = EditingViewController()
//        editingViewController.delegate = self
        editingViewController.note = notes[indexPath.row]
        navigationController?.pushViewController(editingViewController, animated: true)
    }
}
