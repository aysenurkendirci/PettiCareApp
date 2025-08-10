import UIKit

final class RoutineFrequencyPickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    private let picker = UIPickerView()
    
    private let options = [
        "Günde 1 kez",
        "Günde 2 kez",
        "Günde 3 kez",
        "Haftada 1 kez",
        "Haftada 2 kez",
        "Haftada 3 kez"
    ]

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPicker()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPicker() {
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false

        addSubview(containerView)
        containerView.addSubview(picker)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),

            picker.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            picker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            picker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            picker.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        options.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        options[row]
    }

    var selectedFrequency: String {
        return options[picker.selectedRow(inComponent: 0)]
    }
}
