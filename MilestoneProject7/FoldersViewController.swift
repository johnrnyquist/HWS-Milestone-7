//
//  FolderViewController.swift
//  MilestoneProject7
//
//  Created by John Nyquist on 4/28/19.
//  Copyright © 2019 Nyquist Art + Logic LLC. All rights reserved.
//

import UIKit


class FoldersViewController: UITableViewController, UINavigationControllerDelegate {

    //MARK:- FoldersViewController
    //MARK: Variables
    var sections: [Section] = []
    var addFolderButton: UIBarButtonItem!
    var deleteButton: UIBarButtonItem!

    //MARK: Methods

    @objc func addFolderTapped() {
        let ac = UIAlertController(title: "New Folder",
                                   message: "Where would you like to add this folder?",
                                   preferredStyle: .actionSheet)

        ac.addAction(UIAlertAction(title: "iCloud",
                                   style: .default,
                                   handler: addFolder))
        ac.addAction(UIAlertAction(title: "On My iPhone",
                                   style: .default,
                                   handler: addFolder))
        ac.addAction(UIAlertAction(title: "Cancel",
                                   style: .cancel))

        ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(ac,
                animated: true)
    }

    @objc func deleteItems() {
        if let rows = tableView.indexPathsForSelectedRows {
            for indexPath in rows {
                sections[indexPath.section].folders.remove(at: indexPath.row)
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: rows, with: .automatic)
            tableView.endUpdates()
            saveSections()
        }
        isEditing = false
        deleteButton.isEnabled = false
    }

    func addFolder(addAction: UIAlertAction) {

        let ac = UIAlertController(title: "Add Folder",
                                   message: "Name the new folder",
                                   preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit",
                                         style: .default) { [unowned self, ac] (action: UIAlertAction) in
            var selectedSection:Section
            if addAction.title! == self.sections[0].name {
                selectedSection = self.sections[0]
            } else {
                selectedSection = self.sections[1]
            }

            let answer = ac.textFields![0]
            selectedSection.folders.append(Folder(name: answer.text!,
                                                 noteCount: 0,
                                                 dateCreated: Date()))
            self.saveSections()
        }
        ac.addAction(submitAction)
        present(ac,
                animated: true)

    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask)
        return paths.first!
    }

    func saveSections() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(sections) {
            let defaults = UserDefaults.standard
            defaults.set(savedData,
                         forKey: "allsections")
            tableView.reloadData()
        } else {
            print("Failed to save folders.")
        }
    }

    func loadSections() {
        let defaults = UserDefaults.standard
        if let savedFolders = defaults.object(forKey: "allsections") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                sections = try jsonDecoder.decode([Section].self,
                                                 from: savedFolders)
            } catch {
                print("Failed to load folders.")
            }
        }
    }


    //MARK:- UIViewController class
    override func viewDidLoad() {
        super.viewDidLoad()

        sections.append(Section(name: "iCloud", folders: [Folder]()))
        sections.append(Section(name: "On My iPhone", folders: [Folder]()))

        navigationController?.delegate = self

        title = "Folders" // set the title
        navigationController?.isToolbarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true // big titles

        addFolderButton = UIBarButtonItem(title: "New Folder",
                                          style: .plain,
                                          target: self,
                                          action: #selector(addFolderTapped))
        let spacerButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                           target: self,
                                           action: nil)
        toolbarItems = [spacerButton, addFolderButton]


        deleteButton = UIBarButtonItem(title: "Delete",
                                       style: .plain,
                                       target: self,
                                       action: #selector(deleteItems))
        navigationItem.rightBarButtonItems = [editButtonItem, deleteButton]
        deleteButton.isEnabled = false

        clearsSelectionOnViewWillAppear = false

        //IMPORTANT: Below is how we get the checkboxes when isEditing
        tableView.allowsMultipleSelectionDuringEditing = true

        loadSections()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(tableView.isEditing, animated: true)
        addFolderButton.isEnabled.toggle()
        deleteButton.isEnabled.toggle()
    }


    // MARK:- UITableViewDataSource protocol
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return sections[section].folders.count
    }

    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell",
                                                 for: indexPath)

        cell.textLabel?.text = sections[indexPath.section].folders[indexPath.row].name
        cell.detailTextLabel?.text = String(sections[indexPath.section].folders[indexPath.row].noteCount)

        return cell
    }


    //MARK: - UITableViewDelegate protocol
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        guard isEditing == false else { return }
        if let notesView = storyboard?.instantiateViewController(withIdentifier: "NotesViewController") as? NotesViewController {
            let folder = sections[indexPath.section].folders[indexPath.row]
            notesView.folder = folder
            notesView.delegate = self
            // Pushes a view controller onto the receiver’s stack and updates the display. Note it is animated.
            navigationController?.pushViewController(notesView,
                                                     animated: true)
        }
    }
}
