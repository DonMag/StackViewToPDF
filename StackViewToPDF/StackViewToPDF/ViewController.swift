//
//  ViewController.swift
//  StackViewToPDF
//
//  Created by Don Mag on 1/30/20.
//  Copyright © 2020 Don Mag. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet var resultLabel: UILabel!
	
	@IBAction func generatePDF(_ sender: Any) {

		let theSheetView = PDFSheet()
		
		let views: [UIView] = theSheetView.makeSheet()
		
		guard let v = views.first else {
			fatalError("PDFSheet failed to create TaskSheet")
		}

		// note: if we don't force this,
		//	the view layout will not be completed
		v.setNeedsLayout()
		v.layoutIfNeeded()
		
		let s = v.exportAsPdfFromView()

		if s == "" {
			resultLabel.text = "Error creating PDF"
			print("Error creating PDF")
		} else {
			resultLabel.text = "Saved!" + "\n\n" +
				"Path to PDF file output to Debug Console"
			print("Saved:\n", s)
		}

	}
	
}

class TaskSheet: UIView {
	
	@IBOutlet var contentView: UIView!
	@IBOutlet var mainStack: UIStackView!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	func setup() {
		let nib = UINib(nibName: "TaskSheet", bundle: nil)
		nib.instantiate(withOwner: self, options: nil)
		addSubview(contentView)
		
		NSLayoutConstraint.activate([
			// constrain contentView on all 4 sides with 0-pts "padding"
			contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
			contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0),
			contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0),
			contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0),
		])
	}
}

class PDFSheet: UIView {
	
	var taskSheet: TaskSheet!
	var sheetArray = [UIView]()
	
	func makeSheet() -> [UIView] {
		
		taskSheet = TaskSheet(frame: CGRect(x: 0, y: 0, width: 612, height: 792))
		
		let newView1 = UIView()
		newView1.backgroundColor = .green
		
		let newView2 = UIView()
		newView2.backgroundColor = .yellow
		
		let spacerView = UIView()
		spacerView.backgroundColor = .clear
		
		// to get the "expected result" as shown in the OP's image,
		//  a 3-part stack view with equal heights,
		//  an easy way is to add a clear "spacer view" as the
		//	first - "top" - arranged subview
		
		taskSheet.mainStack.addArrangedSubview(spacerView)
		taskSheet.mainStack.addArrangedSubview(newView1)
		taskSheet.mainStack.addArrangedSubview(newView2)
		
		sheetArray.append(taskSheet)
		
		return sheetArray
	}
}

// extension from:
//  https://www.swiftdevcenter.com/create-pdf-from-uiview-wkwebview-and-uitableview/
extension UIView {
	
	// Export pdf from Save pdf in drectory and return pdf file path
	func exportAsPdfFromView() -> String {
		let pdfPageFrame = self.bounds
		let pdfData = NSMutableData()
		UIGraphicsBeginPDFContextToData(pdfData, pdfPageFrame, nil)
		UIGraphicsBeginPDFPageWithInfo(pdfPageFrame, nil)
		guard let pdfContext = UIGraphicsGetCurrentContext() else { return "" }
		self.layer.render(in: pdfContext)
		UIGraphicsEndPDFContext()
		return self.saveViewPdf(data: pdfData)
	}
	
	// Save pdf file in document directory
	func saveViewPdf(data: NSMutableData) -> String {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let docDirectoryPath = paths[0]
		let pdfPath = docDirectoryPath.appendingPathComponent("viewPdf.pdf")
		if data.write(to: pdfPath, atomically: true) {
			return pdfPath.path
		} else {
			return ""
		}
	}
}
