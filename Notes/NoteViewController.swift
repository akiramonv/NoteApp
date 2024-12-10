import UIKit

class NoteViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var noteLabel: UITextView! 

    public var noteTitle: String = ""
        public var note: NSAttributedString? = nil

        override func viewDidLoad() {
            super.viewDidLoad()
            
            titleLabel.text = noteTitle
            noteLabel.attributedText = note
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Edit",
                style: .plain,
                target: self,
                action: #selector(editNote)
            )
        }

        @objc private func editNote() {
            guard let vc = storyboard?.instantiateViewController(identifier: "new") as? EntryViewController else { return }
            
            vc.title = "Редактировать"
            vc.noteTitle = noteTitle
            vc.note = note
            
            vc.completion = { [weak self] updatedTitle, updatedNote in
                self?.noteTitle = updatedTitle
                self?.note = updatedNote
                self?.titleLabel.text = updatedTitle
                self?.noteLabel.attributedText = updatedNote
            }
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
