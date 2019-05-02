//
//  GridView.swift
//  TestComposition
//
//  Created by Quentin Fasquel on 01/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import UIKit

class GridView: UIView {

    /// A vertical stack view that will holds horizontal stack views
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 1.0
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    public let columCount: Int
    public let rowCount: Int
    
    required init(columnCount: Int, rowCount: Int) {
        self.columCount = columnCount
        self.rowCount = rowCount
        super.init(frame: .zero)
        self.createGridView(columnCount, rowCount: rowCount)
    }
    
    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
        fatalError()
    }

    public func cellView(_ columnIndex: Int, _ rowIndex: Int) -> UIView! {
        let view = (verticalStackView.arrangedSubviews[rowIndex] as? UIStackView)?.arrangedSubviews[columnIndex]
        return view!
    }

    private func createGridView(_ columnCount: Int, rowCount: Int) {
        guard verticalStackView.superview == nil else {
            return // Already set
        }
        
        addSubview(verticalStackView)

        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalStackView.topAnchor.constraint(equalTo: topAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        var previousHeightAnchor: NSLayoutDimension?
        var previousWidthAnchor: NSLayoutDimension?
        
        (0..<rowCount).forEach { rowIndex in
            let horizontalStackView = UIStackView()
            horizontalStackView.axis = .horizontal
            horizontalStackView.spacing = 1.0
            verticalStackView.addArrangedSubview(horizontalStackView)
            
            if let heightAnchor = previousHeightAnchor {
                horizontalStackView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            }
            
            previousHeightAnchor = horizontalStackView.heightAnchor
            previousWidthAnchor = nil
            
            (0..<columnCount).forEach { columnIndex in
                let view = UIView()
                view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
                // set tag?
                horizontalStackView.addArrangedSubview(view)
                
                if let widthAnchor = previousWidthAnchor {
                    view.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
                }
                
                previousWidthAnchor = view.widthAnchor
            }
        }
    }
}

