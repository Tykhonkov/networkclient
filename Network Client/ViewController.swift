//
//  ViewController.swift
//  Network Client
//
//  Created by Ilya Tihonkov on 1/16/17.
//  Copyright © 2017 Ilya Tihonkov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    private var model = Model()
    private var disposeBag = DisposeBag()
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        model.myClasses.asObservable()
            .bindTo(
                tableView.rx.items(cellIdentifier:"UITableViewCell" , cellType: UITableViewCell.self)
            ) { [weak self] index, myclass, cell in

            }.addDisposableTo(disposeBag)

        model.requestMyClasses()
    }

    @IBAction func requestMore(_ sender: Any) {
        model.requestMyClasses()
    }

    @IBAction func clearData(_ sender: Any) {
        model.myClasses.value.removeAll()
    }


}
