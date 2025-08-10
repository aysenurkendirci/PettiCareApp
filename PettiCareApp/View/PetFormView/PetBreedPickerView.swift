import UIKit

final class PetBreedPickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    private let label: UILabel = {
        let label = UILabel()
        label.text = "Evcil hayvanınızın cinsi"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    private let pickerView = UIPickerView()
    private let textField = UITextField()

    private var breeds: [String] = []
    private var selectedBreedInternal: String?

    // Dışarıdan sadece okunabilir erişim
    public var selectedBreed: String? {
        return selectedBreedInternal
    }

    var onBreedSelected: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        configurePicker()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        pickerView.delegate = self
        pickerView.dataSource = self

        textField.placeholder = "Cins seçiniz"
        textField.inputView = pickerView
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let stack = UIStackView(arrangedSubviews: [label, textField])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func configurePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Tamam", style: .done, target: self, action: #selector(doneTapped))
        toolbar.setItems([doneButton], animated: true)
        textField.inputAccessoryView = toolbar
    }

    func updateBreedList(for petType: String) {
        switch petType {
        case "Kedi":
            breeds = ["British Shorthair", "Scottish Fold", "Tekir", "Van", "Bengal"]
        case "Köpek":
            breeds = ["Golden Retriever", "Poodle", "Chihuahua", "Labrador", "German Shepherd"]
        case "Kuş":
            breeds = ["Muhabbet Kuşu", "Kanarya", "Sultan Papağanı", "Cennet Papağanı"]
        case "Balık":
            breeds = ["Japon Balığı", "Lepistes", "Beta", "Molly", "Neon Tetra"]
        default:
            breeds = []
        }

        pickerView.reloadAllComponents()
        textField.text = ""
        selectedBreedInternal = nil
    }

    @objc private func doneTapped() {
        let row = pickerView.selectedRow(inComponent: 0)
        if breeds.indices.contains(row) {
            selectedBreedInternal = breeds[row]
            textField.text = selectedBreedInternal
            onBreedSelected?(selectedBreedInternal!)
        }
        textField.resignFirstResponder()
    }

    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        breeds.count
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        breeds[row]
    }
}
