import UIKit

class NoteViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var noteLabel: UITextView! 

    // Переменные для хранения данных заметки (заголовка и текста)
        public var noteTitle: String = "" // Заголовок заметки
        public var note: String = "" // Текст заметки

        override func viewDidLoad() {
            super.viewDidLoad()
            
            //Ком
            // Установка заголовка и текста заметки в соответствующие элементы интерфейса
            titleLabel.text = noteTitle
            noteLabel.text = note
        }
    }
