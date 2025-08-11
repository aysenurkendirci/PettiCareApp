import UIKit

final class AddRoutineSheetViewController: UIViewController {

    var onRoutineAdded: ((Routine) -> Void)?


    private let nameInput = RoutineNameInputView()
    private let frequencyPicker = RoutineFrequencyPickerView()

    // 🔄 Güncellenmiş saveButton: GradientButton component
    private let saveButton: GradientButton = {
        let button = GradientButton(type: .system)
        button.setTitle("Rutini Kaydet", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        setupLayout()
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
    }

    private func setupStyle() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = false
        
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [nameInput, frequencyPicker, saveButton])
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -24),

            // Buton yüksekliği sabitlenmiş
            saveButton.heightAnchor.constraint(equalToConstant: 52)
            
        ])
    }

    @objc private func handleSave() {
        let newRoutine = Routine(
            title: nameInput.routineName,
            iconName: "star.fill",  // iconName ikinci parametre
            frequency: frequencyPicker.selectedFrequency
        )
        onRoutineAdded?(newRoutine)
        dismiss(animated: true)
    }

}
