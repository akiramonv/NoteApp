
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
            
            // Устанавливаем отступы, чтобы текст начинался ниже
            noteField.textContainerInset = UIEdgeInsets(top: 40, left: 5, bottom: 5, right: 5)
        }

        // Создание панели инструментов для редактирования
        private func setupFormattingToolbar() {
            formattingToolbar = UIView()
            formattingToolbar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(formattingToolbar)

            // Размещаем панель между titleField и noteField
            NSLayoutConstraint.activate([
                formattingToolbar.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 10),
                formattingToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                formattingToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                formattingToolbar.heightAnchor.constraint(equalToConstant: 44)
            ])

            let fontButton = UIButton(type: .system)
            fontButton.setTitle("Шрифт", for: .normal)
            fontButton.addTarget(self, action: #selector(changeFont), for: .touchUpInside)

            let sizeButton = UIButton(type: .system)
            sizeButton.setTitle("Размер", for: .normal)
            sizeButton.addTarget(self, action: #selector(changeFontSize), for: .touchUpInside)

            let colorButton = UIButton(type: .system)
            colorButton.setTitle("Цвет", for: .normal)
            colorButton.addTarget(self, action: #selector(changeTextColor), for: .touchUpInside)

            let stackView = UIStackView(arrangedSubviews: [fontButton, sizeButton, colorButton])
            stackView.spacing = 10
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

        // Открытие меню для выбора шрифта
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

        // Открытие меню для выбора размера шрифта
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

        // Открытие цветового выбора для текста
        @objc private func changeTextColor() {
            let colorPicker = UIColorPickerViewController()
            colorPicker.delegate = self
            colorPicker.selectedColor = selectedColor
            present(colorPicker, animated: true)
        }

        // Применение выбранного шрифта
        private func applyFont(named fontName: String) {
            if let font = UIFont(name: fontName, size: selectedFontSize) {
                selectedFont = font
                updateTextAttributes()
            }
        }

        // Применение выбранного размера шрифта
        private func applyFontSize(_ size: CGFloat) {
            selectedFontSize = size
            selectedFont = UIFont(name: selectedFont.fontName, size: size) ?? UIFont.systemFont(ofSize: size)
            updateTextAttributes()
        }

        // Применение выбранного цвета
        private func applyTextColor(_ color: UIColor) {
            selectedColor = color
            updateTextAttributes()
        }

        // Обновление атрибутов текста (шрифт и цвет) для выделенного текста
        private func updateTextAttributes() {
            let selectedRange = noteField.selectedRange
            if selectedRange.length > 0 {
                applyAttribute(.font, value: selectedFont, range: selectedRange)
                applyAttribute(.foregroundColor, value: selectedColor, range: selectedRange)
            } else {
                // Если текст не выделен, применяем ко всему тексту
                let fullRange = NSRange(location: 0, length: noteField.text.count)
                applyAttribute(.font, value: selectedFont, range: fullRange)
                applyAttribute(.foregroundColor, value: selectedColor, range: fullRange)
            }
        }

        // Применение атрибута к выделенному диапазону
        private func applyAttribute(_ attribute: NSAttributedString.Key, value: Any, range: NSRange) {
            let attributedText = NSMutableAttributedString(attributedString: noteField.attributedText)
            attributedText.addAttribute(attribute, value: value, range: range)
            noteField.attributedText = attributedText
        }

        // Сохранение заметки
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

    // Расширение для работы с UIColorPicker
    extension EntryViewController: UIColorPickerViewControllerDelegate {
        func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
            selectedColor = viewController.selectedColor
            updateTextAttributes()
        }
        
        func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            selectedColor = viewController.selectedColor
            updateTextAttributes()
        }
    }
