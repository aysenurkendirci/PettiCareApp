import UIKit

/// Evcil hayvanın doğum tarihini seçmek için özel bir bileşen (View)
final class PetBirthDatePickerView: UIView {
    
    // Başlık etiketi
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Doğum Tarihi"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    // Tarihi göstermek için kullanılan metin kutusu (kullanıcı doğrudan yazamaz)
    private let dateTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Tarih seçiniz"
        textField.borderStyle = .roundedRect
        textField.textAlignment = .left
        textField.textColor = .label
        textField.tintColor = .clear // İmleç gizlenir, çünkü kullanıcı yazı girmeyecek
        return textField
    }()
    
    // Tarih seçimi için kullanılacak picker
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels // iOS 14+ için tekerlekli görünüm
        picker.maximumDate = Date() // Bugünden sonraki tarih seçilemez
        return picker
    }()
    
    /// ViewController'a seçilen tarihi string olarak iletmek için closure
    var onDateSelected: ((Date) -> Void)?
    
    /// Dışarıdan erişilebilir Date değeri (örneğin form gönderiminde kullanılabilir)
    var selectedDate: Date {
        return datePicker.date
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Yapılandırması
    private func setupView() {
        // TextField'a picker atanıyor, klavye yerine picker çıkacak
        dateTextField.inputView = datePicker
        
        // Picker'da tarih değiştiğinde `dateChanged()` çağrılacak
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        // Label + TextField -> dikey stack olarak yerleştiriliyor
        let stack = UIStackView(arrangedSubviews: [titleLabel, dateTextField])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        // StackView bu bileşenin içine ekleniyor
        addSubview(stack)
        
        // StackView sınırları bu View’e sabitleniyor (tam oturması için)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    // MARK: - Tarih Değiştiğinde Çalışır
    @objc private func dateChanged() {
        // Tarihi kullanıcıya gösterilecek formata çevir (TextField için)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "tr_TR") // Türkçe tarih biçimi

        let date = datePicker.date
        let dateStr = formatter.string(from: date)

        // TextField'da görünmesi için formatlı yazı
        dateTextField.text = dateStr

        // ViewController'a Date tipini gönder
        onDateSelected?(date) 
    }

}
