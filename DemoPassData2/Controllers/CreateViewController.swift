import UIKit

class CreateViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var newButton: UIButton!
    
    @IBOutlet weak var inProgressButton: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!
    
    
    var onCreate: ((TodoItem) -> Void)?
    
    var taskType: TaskType?
    
    var item: TodoItem?
    
    var todoType: TodoType = TodoType.new
    
    var selectedImagePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSaveButton))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        photoImageView.contentMode = .scaleAspectFit
        
        setupAutoLayout()
        
        if let item {
            titleTextField.text = item.title
            descriptionTextView.text = item.description
            todoType = item.type
            
            if !item.image.isEmpty {
                let imagePath = getDocumentsDirectory().appendingPathComponent(item.image)
                if FileManager.default.fileExists(atPath: imagePath.path) {
                    photoImageView.image = UIImage(contentsOfFile: imagePath.path)
                } else {
                    print("Image not found at path: \(imagePath.path)")
                }
            }
            
            switch todoType {
            case .new:
                newButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            case .inprogress:
                inProgressButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            case .completed:
                doneButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            }
        }
    }
    
    func setupAutoLayout() {
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        newButton.translatesAutoresizingMaskIntoConstraints = false
        inProgressButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        newButton.titleLabel?.adjustsFontSizeToFitWidth = true
        inProgressButton.titleLabel?.adjustsFontSizeToFitWidth = true
        doneButton.titleLabel?.adjustsFontSizeToFitWidth = true

        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),

            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 120),

            photoImageView.topAnchor.constraint(equalTo: newButton.bottomAnchor, constant: 20),
            photoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            photoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor, multiplier: 0.75),

            uploadButton.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 20),
            uploadButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            uploadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            uploadButton.heightAnchor.constraint(equalToConstant: 44),

            newButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            newButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            newButton.widthAnchor.constraint(equalToConstant: 100),
            newButton.heightAnchor.constraint(equalToConstant: 40),

           
            inProgressButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            inProgressButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inProgressButton.widthAnchor.constraint(equalToConstant: 140),
            inProgressButton.heightAnchor.constraint(equalToConstant: 40),

            
            doneButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.widthAnchor.constraint(equalToConstant: 100),
            doneButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @IBAction func onUploadImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func didTapSaveButton() {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        guard let description = descriptionTextView.text, !description.isEmpty else { return }

        var imageData = item?.image ?? ""

        if photoImageView.image == nil && !imageData.isEmpty {
            imageData = item?.image ?? ""
        }
        else if let image = photoImageView.image, let data = image.pngData() {
            let imageName = UUID().uuidString
            let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
            do {
                try data.write(to: imagePath)
                imageData = imageName  
                print("Image saved at path: \(imagePath)")
            } catch {
                print("Error saving image: \(error)")
                return
            }
        }

        let id = taskType == .update ? item?.id ?? UUID().uuidString : UUID().uuidString
        let todoItem = TodoItem(id: id, title: title, description: description, image: imageData, type: todoType)

        onCreate?(todoItem)
        navigationController?.popViewController(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onSelectButton(_ sender: UIButton) {
        print(sender.tag)
        if sender.tag == 1 {
            todoType = .new
            newButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            inProgressButton.setImage(UIImage(systemName: "circle"), for: .normal)
            doneButton.setImage(UIImage(systemName: "circle"), for: .normal)
        } else if sender.tag == 2 {
            todoType = .inprogress
            newButton.setImage(UIImage(systemName: "circle"), for: .normal)
            inProgressButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            doneButton.setImage(UIImage(systemName: "circle"), for: .normal)
        } else if sender.tag == 3 {
            todoType = .completed
            newButton.setImage(UIImage(systemName: "circle"), for: .normal)
            inProgressButton.setImage(UIImage(systemName: "circle"), for: .normal)
            doneButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        }
    }
    
    
}

extension CreateViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        photoImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
