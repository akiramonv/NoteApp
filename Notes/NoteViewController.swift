import UIKit
import FirebaseFirestore

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

            // Сохранение в Firestore после обновления
            self?.saveNoteToFirestore(title: updatedTitle, content: updatedNote)
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    private func saveNoteToFirestore(title: String, content: NSAttributedString) {
        let db = Firestore.firestore()
        let noteData: [String: Any] = [
            "title": title,
            "content": content.string, // Если нужно сохранить как строку
            "date": Timestamp(date: Date())
        ]
        
        db.collection("notes").document(title).setData(noteData) { error in
            if let error = error {
                print("Ошибка обновления: \(error)")
            } else {
                print("Заметка успешно обновлена")
            }
        }
    }

    }
