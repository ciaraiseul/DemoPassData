import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var todo: TodoItem? {
            didSet {
                if let todo = todo {
                    titleLabel.text = todo.title
                    descriptionLabel.text = todo.description

                    if let imagePath = getImagePath(for: todo.image) {
                        if FileManager.default.fileExists(atPath: imagePath.path) {
                            photoImageView.image = UIImage(contentsOfFile: imagePath.path)
                        } else {
                            print("Image does not exist at path: \(imagePath.path)")
                            photoImageView.image = UIImage(systemName: "seal.fill")
                        }
                    } else {
                        photoImageView.image = UIImage(systemName: "seal.fill")
                    }
                }
            }
        }

        override func awakeFromNib() {
            super.awakeFromNib()

            titleLabel.numberOfLines = 2
            descriptionLabel.numberOfLines = 0

            photoImageView.layer.cornerRadius = 10
            photoImageView.clipsToBounds = true
            photoImageView.layer.shadowColor = UIColor.black.cgColor
            photoImageView.layer.shadowOpacity = 0.3
            photoImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
            photoImageView.layer.shadowRadius = 5
            photoImageView.layer.borderWidth = 1
            photoImageView.layer.borderColor = UIColor.blue.cgColor

            setupAutoLayout()
        }

        func setupAutoLayout() {
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            photoImageView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                photoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                photoImageView.widthAnchor.constraint(equalToConstant: 60),
                photoImageView.heightAnchor.constraint(equalToConstant: 60),

                titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
                titleLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

                descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                descriptionLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 16),
                descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
            ])
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }

        func getImagePath(for imageName: String) -> URL? {
            guard !imageName.isEmpty else { return nil }
            let path = getDocumentsDirectory().appendingPathComponent(imageName)
            return path
        }

        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
    }
