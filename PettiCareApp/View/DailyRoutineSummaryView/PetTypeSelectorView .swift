import UIKit
import SwiftData

/// Bu view, seçilen evcil hayvan türünü göstermek için kullanılır.
/// Kullanıcı bu view üzerinden seçim yapamaz — yalnızca gösterim amaçlıdır.
final class PetTypeSelectorView: UIStackView {
    
    /// Seçim değiştiğinde tetiklenir (şu an için kullanılmıyor çünkü seçim yapılamaz)
    var onSelectionChanged: ((PetType) -> Void)?
    
    /// Dışarıdan atanır — yalnızca bu tür gösterilir
    var preselectedType: PetType? {
        didSet {
            if let type = preselectedType {
                selectedType = type
                setupButtons(for: [type]) // Sadece seçilen türün butonunu göster
            }
        }
    }

    /// Şu an seçili olan tür (varsayılan: .cat)
    private var selectedType: PetType = .cat

    /// Enum'daki tüm türler (şu an sadece gösterim için)
    private let allTypes: [PetType] = PetType.allCases

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        spacing = 12
        distribution = .fillEqually
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Buton Oluşturma

    /// Belirtilen tür(ler) için butonları oluşturur (şu an sadece 1 tür)
    private func setupButtons(for typesToShow: [PetType]) {
        // Eski tüm butonları kaldır
        arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, type) in typesToShow.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(type.displayName, for: .normal) // Örn: "Kedi"
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .systemPurple
            button.layer.cornerRadius = 12
            button.tag = index
            button.isUserInteractionEnabled = false // Tek tür olduğu için tıklanamaz
            addArrangedSubview(button)
        }
    }

    // MARK: - Dışarıdan çağrılan yardımcı fonksiyonlar

    /// Başlangıçta gösterilecek türü ayarlamak için
    func setInitialType(from type: PetType) {
        selectedType = type
        setupButtons(for: [type])
    }

    /// Seçilen türü dışarıya verir
    func getSelectedType() -> PetType {
        return selectedType
    }
}
