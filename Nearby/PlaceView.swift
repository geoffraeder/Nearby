//
//  PlaceView.swift
//  Nearby
//
//  Created by Geoff Raeder on 10/24/21.
//

import UIKit

protocol PlaceViewDelegate: NSObjectProtocol {
    func placeViewDidToggleBookmarkStatus(_ view: PlaceView)
}

class PlaceView: UIView {

    let iconView = UIImageView()
    let nameLabel = UILabel()
    let addressLabel = UILabel()
    let ratingLabel = UILabel()
    let priceLevelLabel = UILabel()
    let websiteButton = UIButton(type: .custom)
    let bookmarkButton = UIButton(type: .custom)

    var isBookmarked = false {
        didSet {
            bookmarkButton.isSelected = isBookmarked
        }
    }

    weak var delegate: PlaceViewDelegate?

    private func setup() {
        self.backgroundColor = .white

        let iconConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold, scale: .large)
        iconView.image = UIImage(systemName: "fork.knife.circle.fill", withConfiguration: iconConfiguration)

        nameLabel.font = .preferredFont(forTextStyle: .headline)
        addressLabel.font = .preferredFont(forTextStyle: .subheadline)
        ratingLabel.font = .preferredFont(forTextStyle: .subheadline)
        priceLevelLabel.font = .preferredFont(forTextStyle: .subheadline)

        addressLabel.textColor = .systemGray
        ratingLabel.textColor = .systemGray
        priceLevelLabel.textColor = .systemGray

        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)

        let bookmarkConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .light, scale: .large)
        let outlineImage = UIImage(systemName: "bookmark", withConfiguration: bookmarkConfiguration)
        bookmarkButton.setImage(outlineImage, for: .normal)

        let filledImage = UIImage(systemName: "bookmark.fill", withConfiguration: bookmarkConfiguration)
        bookmarkButton.setImage(filledImage, for: .selected)

        bookmarkButton.addAction(UIAction(handler: { _ in
            self.isBookmarked.toggle()
            self.delegate?.placeViewDidToggleBookmarkStatus(self)
        }), for: .touchUpInside)

        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bookmarkButton)

        let stackView = UIStackView(arrangedSubviews: [
            nameLabel,
            addressLabel,
            ratingLabel,
            priceLevelLabel,
            websiteButton
        ])

        stackView.axis = .vertical
        stackView.spacing = 3
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            iconView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
            bookmarkButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
            bookmarkButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 23),
            stackView.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
}
