//
//  DetailViewController.swift
//  MilestoneProject7
//
//  Created by John Nyquist on 4/26/19.
//  Copyright © 2019 Nyquist Art + Logic LLC. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var textView: UITextView!
    var note: Note!
    weak var delegate: NotesViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never // small titles

        textView.delegate = self
        textView.text = note.text

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }


    @objc func shareTapped() {
        let vc = UIActivityViewController(activityItems: [note.text], applicationActivities: [])

        /* This line of code tells iOS to anchor the activity view
         controller to the right bar button item (our share button),
         but this only has an effect on iPad – on iPhone it's ignored. */
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem

        present(vc, animated: true)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        note.text = textView.text
        delegate.save()
    }

    /*
    Receives a parameter that is of type Notification.
    This will include the name of the notification as well as
    a dictionary containing notification-specific information called userInfo.
    */
    @objc func adjustForKeyboard(notification: Notification) {
        print(notification.name)
        /*
        The userInfo dictionary will contain a key called
        UIResponder.keyboardFrameEndUserInfoKey
        telling us the frame of the keyboard after it has finished animating.
        This is a NSValue instance that we cast from type Any to NSValue.
        */
        guard let userInfo = notification.userInfo,
              let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey],
              let keyboardValue = value as? NSValue
            else {
            return
        }

        /*
        NSValue holds a CGRect (at this time, but could hold other types).
        The CGRect struct holds both a CGPoint and a CGSize,
        so it can be used to describe a rectangle.
        */
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        /*
        We need to convert the rectangle to our view's co-ordinates.
        This is because rotation isn't factored into the frame,
        so if the user is in landscape we'll have the width and height flipped –
        using the convert() method will fix that.
        convert() - Converts keyboardScreenEndFrame from the coordinate system of view.window.
        */
        let keyboardViewEndFrame =
            view.convert(keyboardScreenEndFrame, from: view.window)

        /*
        Adjust the contentInset and scrollIndicatorInsets of our text view.
        These two essentially indent the edges of our text view so that it
        appears to occupy less space even though its constraints are still
        edge to edge in the view.
        contentInset - The custom distance that the content view is inset
        from the safe area or scroll view edges. Use this property to extend
        the space between your content and the edges of the content view.
        */
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom,
                right: 0)
        }
        /*
         scrollIndicatorInsets - The distance the scroll indicators are inset from the edge of the scroll view.
         */
        textView.scrollIndicatorInsets = textView.contentInset

        /*
        Finally, we're going to make the text view scroll so that the
        text entry cursor is visible. If the text view has shrunk this will
        now be off screen, so scrolling to find it again keeps the
        user experience intact.
        */
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }

}
