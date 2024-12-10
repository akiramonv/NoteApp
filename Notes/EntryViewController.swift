
import UIKit

class EntryViewController: UIViewController {

    @IBOutlet var titleField: UITextField!
    @IBOutlet var noteField: UITextView!
    
    public var noteTitle: String?
       public var note: NSAttributedString?
       public var completion: ((String, NSAttributedString) -> Void)?

       private var selectedFont: UIFont = UIFont.systemFont(ofSize: 16)
       private var selectedColor: UIColor = .black
       private var selectedFontSize: CGFloat = 16

       override func viewDidLoad() {
           super.viewDidLoad()

           titleField.becomeFirstResponder()
           navigationItem.rightBarButtonItem = UIBarButtonItem(
               title: "Сохранить",
               style: .done,
               target: self,
               action: #selector(didTapSave)
           )

           if let noteTitle = noteTitle, let note = note {
               titleField.text = noteTitle
               noteField.attributedText = note
           }

           noteField.inputAccessoryView = createFormattingToolbar()
           noteField.layer.borderColor = UIColor.lightGray.cgColor
           noteField.layer.borderWidth = 1.0
           noteField.layer.cornerRadius = 8.0
       }

       private func createFormattingToolbar() -> UIToolbar {
           let toolbar = UIToolbar()
           toolbar.sizeToFit()

           let fontButton = UIBarButtonItem(title: "Шрифт", style: .plain, target: self, action: #selector(changeFont))
           let sizeButton = UIBarButtonItem(title: "Размер", style: .plain, target: self, action: #selector(changeFontSize))
           let colorButton = UIBarButtonItem(title: "Цвет", style: .plain, target: self, action: #selector(changeTextColor))
           let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

           toolbar.setItems([fontButton, sizeButton, colorButton, flexibleSpace], animated: false)
           return toolbar
       }

       @objc private func changeFont() {
           let alertController = UIAlertController(title: "Выберите шрифт", message: nil, preferredStyle: .actionSheet)

           // Добавьте шрифты для выбора
           let fonts = ["Courier", "Arial", "Helvetica", "Times New Roman"]
           for fontName in fonts {
               alertController.addAction(UIAlertAction(title: fontName, style: .default, handler: { [weak self] _ in
                   self?.applyFont(named: fontName)
               }))
           }

           alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
           present(alertController, animated: true, completion: nil)
       }

       @objc private func changeFontSize() {
           let alertController = UIAlertController(title: "Выберите размер шрифта", message: nil, preferredStyle: .actionSheet)

           // Размеры шрифта для выбора
           let sizes: [CGFloat] = [14, 16, 18, 20, 24, 30]
           for size in sizes {
               alertController.addAction(UIAlertAction(title: "\(size)", style: .default, handler: { [weak self] _ in
                   self?.applyFontSize(size)
               }))
           }

           alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
           present(alertController, animated: true, completion: nil)
       }

       @objc private func changeTextColor() {
           let colorPicker = UIColorPickerViewController()
           colorPicker.delegate = self
           colorPicker.selectedColor = selectedColor
           present(colorPicker, animated: true)
       }

       private func applyFont(named fontName: String) {
           if let font = UIFont(name: fontName, size: selectedFontSize) {
               selectedFont = font
               updateTextAttributes()
           }
       }

       private func applyFontSize(_ size: CGFloat) {
           selectedFontSize = size
           selectedFont = UIFont(name: selectedFont.fontName, size: size) ?? UIFont.systemFont(ofSize: size)
           updateTextAttributes()
       }

       private func updateTextAttributes() {
           let selectedRange = noteField.selectedRange
           if selectedRange.length > 0 {
               applyAttribute(.font, value: selectedFont, range: selectedRange)
           }
       }

       private func applyAttribute(_ attribute: NSAttributedString.Key, value: Any, range: NSRange) {
           let attributedText = NSMutableAttributedString(attributedString: noteField.attributedText)
           attributedText.addAttribute(attribute, value: value, range: range)
           noteField.attributedText = attributedText
       }

       @objc func didTapSave() {
           if let text = titleField.text, !text.isEmpty, noteField.attributedText.string.count > 0 {
               completion?(text, noteField.attributedText)
               navigationController?.popViewController(animated: true)
           } else {
               let alert = UIAlertController(
                   title: "Ошибка",
                   message: "Пожалуйста, заполните все строки",
                   preferredStyle: .alert
               )
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               present(alert, animated: true)
           }
       }
   }

   extension EntryViewController: UIColorPickerViewControllerDelegate {
       func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
           selectedColor = viewController.selectedColor
           let selectedRange = noteField.selectedRange
           if selectedRange.length > 0 {
               applyAttribute(.foregroundColor, value: selectedColor, range: selectedRange)
           }
       }
       
       func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
           selectedColor = viewController.selectedColor
           let selectedRange = noteField.selectedRange
           if selectedRange.length > 0 {
               applyAttribute(.foregroundColor, value: selectedColor, range: selectedRange)
           }
       }
   }
