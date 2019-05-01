//
//  FolderViewController.swift
//  MilestoneProject7
//
//  Created by John Nyquist on 4/28/19.
//  Copyright © 2019 Nyquist Art + Logic LLC. All rights reserved.
//

import UIKit
enum Sections {
    case icloud, local
}
class FoldersViewController: UITableViewController, UINavigationControllerDelegate {
    var sections: [Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        sections.append(Section(name: "iCloud", folders: [Folder]()))
        sections.append(Section(name: "On My iPhone", folders: [Folder]()))

        navigationController?.delegate = self

        title = "Folders" // set the title
        navigationController?.navigationBar.prefersLargeTitles = true // big titles
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(editList))
        load()
//        if folders.count == 0 {
//            folders.append(Folder(name: "Hello",
//                                  noteCount: 0,
//                                  dateCreated: Date()))
//            tableView.reloadData()
//        }

        self.clearsSelectionOnViewWillAppear = false
        navigationController?.isToolbarHidden = false
        let addFolderButton = UIBarButtonItem(title: "New Folder",
                                              style: .plain,
                                              target: self,
                                              action: #selector(newFolderTapped))
        let spacerButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                           target: self,
                                           action: nil)
        toolbarItems = [spacerButton, addFolderButton]
    }

    @objc func editList() {
    }

    @objc func newFolderTapped() {
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

    func addFolder(addAction: UIAlertAction) {
        print("addFolder",
              addAction.title!)

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
            self.save()
        }
        ac.addAction(submitAction)
        present(ac,
                animated: true)

    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory,
                                             in: .userDomainMask)
        return paths[0]
    }

    func save() {
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

    func load() {
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


    // MARK: - Table view data source
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
    // Tells the delegate that the specified row is now selected.
    // This class is the delegate.
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if let notesView = storyboard?.instantiateViewController(withIdentifier: "NotesViewController") as? NotesViewController {
            let folder = sections[indexPath.section].folders[indexPath.row]
            notesView.folder = folder
            notesView.delegate = self
            // Pushes a view controller onto the receiver’s stack and updates the display. Note it is animated.
            navigationController?.pushViewController(notesView,
                                                     animated: true)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView,
                            moveRowAt fromIndexPath: IndexPath,
                            to: IndexPath) {

    }
    */
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
