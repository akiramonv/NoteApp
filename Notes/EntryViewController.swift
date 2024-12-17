
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

        private var formattingToolbar: UIView!

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

            // Настроим панель инструментов
            setupFormattingToolbar()

            noteField.layer.borderColor = UIColor.lightGray.cgColor
            noteField.layer.borderWidth = 1.0
            noteField.layer.cornerRadius = 8.0
            
            noteField.textContainerInset = UIEdgeInsets(top: 40, left: 5, bottom: 5, right: 5)
        }

        private func setupFormattingToolbar() {
            formattingToolbar = UIView()
            formattingToolbar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(formattingToolbar)

            NSLayoutConstraint.activate([
                formattingToolbar.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 10),
                formattingToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                formattingToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                formattingToolbar.heightAnchor.constraint(equalToConstant: 44)
            ])

            // Кнопки форматирования
            let boldButton = UIButton(type: .system)
            boldButton.setTitle("B", for: .normal)
            boldButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            boldButton.addTarget(self, action: #selector(applyBold), for: .touchUpInside)

            let italicButton = UIButton(type: .system)
            italicButton.setTitle("I", for: .normal)
            italicButton.titleLabel?.font = UIFont.italicSystemFont(ofSize: 18)
            italicButton.addTarget(self, action: #selector(applyItalic), for: .touchUpInside)

            let underlineButton = UIButton(type: .system)
            underlineButton.setTitle("U", for: .normal)
            underlineButton.addTarget(self, action: #selector(applyUnderline), for: .touchUpInside)

            // Кнопки для шрифта, размера и цвета
            let fontButton = UIButton(type: .system)
            fontButton.setTitle("Шрифт", for: .normal)
            fontButton.addTarget(self, action: #selector(changeFont), for: .touchUpInside)

            let sizeButton = UIButton(type: .system)
            sizeButton.setTitle("Размер", for: .normal)
            sizeButton.addTarget(self, action: #selector(changeFontSize), for: .touchUpInside)

            let colorButton = UIButton(type: .system)
            colorButton.setTitle("Цвет", for: .normal)
            colorButton.addTarget(self, action: #selector(changeTextColor), for: .touchUpInside)

            let stackView = UIStackView(arrangedSubviews: [boldButton, italicButton, underlineButton, fontButton, sizeButton, colorButton])
            stackView.spacing = 6
            stackView.distribution = .fillEqually
            stackView.translatesAutoresizingMaskIntoConstraints = false
            formattingToolbar.addSubview(stackView)

            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: formattingToolbar.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: formattingToolbar.trailingAnchor),
                stackView.topAnchor.constraint(equalTo: formattingToolbar.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: formattingToolbar.bottomAnchor)
            ])
        }

        // Форматирование текста
        @objc private func applyBold() {
            toggleAttribute(.font, value: UIFont.boldSystemFont(ofSize: selectedFontSize))
        }

        @objc private func applyItalic() {
            toggleAttribute(.font, value: UIFont.italicSystemFont(ofSize: selectedFontSize))
        }

        @objc private func applyUnderline() {
            toggleAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue)
        }

        private func toggleAttribute(_ attribute: NSAttributedString.Key, value: Any) {
            let selectedRange = noteField.selectedRange
            guard selectedRange.length > 0 else { return }

            let attributedText = NSMutableAttributedString(attributedString: noteField.attributedText)
            attributedText.enumerateAttribute(attribute, in: selectedRange, options: []) { (existingValue, range, _) in
                if let existingValue = existingValue, "\(existingValue)" == "\(value)" {
                    attributedText.removeAttribute(attribute, range: range)
                } else {
                    attributedText.addAttribute(attribute, value: value, range: range)
                }
            }

            noteField.attributedText = attributedText
            noteField.selectedRange = selectedRange
        }

        // Выбор шрифта
        @objc private func changeFont() {
            let alertController = UIAlertController(title: "Выберите шрифт", message: nil, preferredStyle: .actionSheet)

            let fonts = ["Courier", "Arial", "Helvetica", "Times New Roman"]
            for fontName in fonts {
                alertController.addAction(UIAlertAction(title: fontName, style: .default, handler: { [weak self] _ in
                    self?.applyFont(named: fontName)
                }))
            }

            alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }

        private func applyFont(named fontName: String) {
            if let font = UIFont(name: fontName, size: selectedFontSize) {
                selectedFont = font
                updateTextAttributes()
            }
        }

        @objc private func changeFontSize() {
            let alertController = UIAlertController(title: "Выберите размер шрифта", message: nil, preferredStyle: .actionSheet)

            let sizes: [CGFloat] = [14, 16, 18, 20, 24, 30]
            for size in sizes {
                alertController.addAction(UIAlertAction(title: "\(size)", style: .default, handler: { [weak self] _ in
                    self?.applyFontSize(size)
                }))
            }

            alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }

        private func applyFontSize(_ size: CGFloat) {
            selectedFontSize = size
            selectedFont = UIFont(name: selectedFont.fontName, size: size) ?? UIFont.systemFont(ofSize: size)
            updateTextAttributes()
        }

        @objc private func changeTextColor() {
            let colorPicker = UIColorPickerViewController()
            colorPicker.delegate = self
            colorPicker.selectedColor = selectedColor
            present(colorPicker, animated: true)
        }

        private func applyTextColor(_ color: UIColor) {
            selectedColor = color
            updateTextAttributes()
        }

        private func updateTextAttributes() {
            let selectedRange = noteField.selectedRange
            if selectedRange.length > 0 {
                applyAttribute(.font, value: selectedFont, range: selectedRange)
                applyAttribute(.foregroundColor, value: selectedColor, range: selectedRange)
            } else {
                let fullRange = NSRange(location: 0, length: noteField.text.count)
                applyAttribute(.font, value: selectedFont, range: fullRange)
                applyAttribute(.foregroundColor, value: selectedColor, range: fullRange)
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
            updateTextAttributes()
        }
    }
