//
//  ViewController.swift
//  MilestoneProject7
//
//  Created by John Nyquist on 4/26/19.
//  Copyright © 2019 Nyquist Art + Logic LLC. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UINavigationControllerDelegate {
    var notes = [Note]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self

        title = "Notes" // set the title
        navigationController?.navigationBar.prefersLargeTitles = true // big titles

        load()
        if notes.count == 0 {
            notes.append(Note(text: "Hello",
                              dateCreated: Date()))
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(addNote))
    }

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        print("willShow", viewController.restorationIdentifier)
    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        print("didShow", viewController.restorationIdentifier)
    }

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print(fromVC.restorationIdentifier, toVC.restorationIdentifier)
//        if fromVC.restorationIdentifier == "DetailViewController" {
//            save()
//            tableView.reloadData()
//        }
        return nil
    }

    //MARK: - ViewController class

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(notes) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "notes")
            tableView.reloadData()
        } else {
            print("Failed to save notes.")
        }
    }

    func load() {
        let defaults = UserDefaults.standard
        if let savedNotes = defaults.object(forKey: "notes") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                notes = try jsonDecoder.decode([Note].self, from: savedNotes)
            } catch {
                print("Failed to load notes.")
            }
        }
    }

    @objc func addNote() {
        print("addNote")
        notes.insert(Note(text: "New Note", dateCreated: Date()), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        save()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note",
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
        if let detailView = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            detailView.note = notes[indexPath.row]
            detailView.delegate = self
            // Pushes a view controller onto the receiver’s stack and updates the display. Note it is animated.
            navigationController?.pushViewController(detailView,
                                                     animated: true)
        }
    }
}

