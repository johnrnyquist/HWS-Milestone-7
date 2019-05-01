//
//  ViewController.swift
//  MilestoneProject7
//
//  Created by John Nyquist on 4/26/19.
//  Copyright © 2019 Nyquist Art + Logic LLC. All rights reserved.
//

import UIKit

class NotesViewController: UITableViewController, UINavigationControllerDelegate {

    //MARK:- NotesViewController class
    var folder: Folder!
    var notes = [Note]()
    weak var delegate: FoldersViewController!
    var countButton: UIBarButtonItem!
    var deleteButton: UIBarButtonItem!
    var swipedToDelete = false


    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    @objc func saveNotes() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(notes) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "\(folder.name)-notes")
            folder.noteCount = notes.count
            countButton.title = "\(notes.count) notes"
            delegate.saveSections()
            tableView.reloadData()
        } else {
            print("Failed to save notes.")
        }
    }

    func loadSavedNotes() {
        let defaults = UserDefaults.standard
        if let savedNotes = defaults.object(forKey: "\(folder.name)-notes") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                notes = try jsonDecoder.decode([Note].self, from: savedNotes)
            } catch {
                print("Failed to load notes.")
            }
        }
    }

    @objc func addNote() {
        notes.insert(Note(text: "New Note", dateCreated: Date()), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        saveNotes()
    }

    @objc func deleteItems() {
        if let rows = tableView.indexPathsForSelectedRows {
            for indexPath in rows {
                notes.remove(at: indexPath.row)
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: rows, with: .automatic)
            tableView.endUpdates()
            saveNotes()
        }
        isEditing = false
        deleteButton.isEnabled = false
    }

    //MARK:- UINavigationControllerDelegate protocol
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        print("willShow", viewController.restorationIdentifier!)
    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        print("didShow", viewController.restorationIdentifier!)
    }

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print(fromVC.restorationIdentifier!, toVC.restorationIdentifier!)
        return nil
    }




    //MARK:- UIViewController class
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true // big titles
        navigationController?.isToolbarHidden = false

        let addNoteButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addNote))
        let spacerButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        countButton = UIBarButtonItem(title: "\(notes.count) notes", style: .plain, target: nil, action: nil)
        countButton.isEnabled = false

        toolbarItems = [spacerButton, countButton, spacerButton, addNoteButton]

        loadSavedNotes()

        title = folder.name

        deleteButton = UIBarButtonItem(title: "Delete",
                                       style: .plain,
                                       target: self,
                                       action: #selector(deleteItems))
        navigationItem.rightBarButtonItems = [editButtonItem, deleteButton]
        deleteButton.isEnabled = false

        clearsSelectionOnViewWillAppear = false

        //IMPORTANT: Below is how we get the checkboxes when isEditing
        tableView.allowsMultipleSelectionDuringEditing = true

    }

    override func tableView(_ tableView: UITableView,
                            willBeginEditingRowAt indexPath: IndexPath) {
        // tableView.isEditing is false
        swipedToDelete = true
        super.tableView(tableView,
                        willBeginEditingRowAt: indexPath) // setEditing(true) will get called
        // tableView.isEditing is true
        swipedToDelete = false
    }

    override func setEditing(_ editing: Bool,
                             animated: Bool) {
        // tableView.isEditing is false
        super.setEditing(editing,
                         animated: true)
        // tableView.isEditing is true
        guard swipedToDelete == false else { return }
        deleteButton.isEnabled.toggle()
    }

    //MARK: - UITableViewDataSource protocol
    // Tells the data source to return the number of rows in a given section of a table view.
    // This class is the data source.
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    // Asks the data source for a cell to insert in a particular location of the table view.
    // This class is the data source.
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell",
                                                 for: indexPath)

        /*  Swift lets us use a question mark – textLabel? –
         to mean “do this only if there is an actual text label there,
         or do nothing otherwise.”   */
        cell.textLabel?.text = notes[indexPath.row].text // indexPath: A list of indexes that together represent the
        cell.detailTextLabel?.text = notes[indexPath.row].dateCreated.description
        // path to a specific location in a tree of nested arrays.

        return cell
    }

    //MARK: - UITableViewDelegate protocol
    // Tells the delegate that the specified row is now selected.
    // This class is the delegate.
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        guard isEditing == false else { return }

        if let detailView = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            detailView.note = notes[indexPath.row]
            detailView.delegate = self
            // Pushes a view controller onto the receiver’s stack and updates the display. Note it is animated.
            navigationController?.pushViewController(detailView,
                                                     animated: true)
        }
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath],
                                 with: .fade)
            perform(#selector(saveNotes), with: nil, afterDelay: 1) //HACK
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
 
}

