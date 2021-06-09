//
//  ViewController.swift
//  Kadai6
//
//  Created by daiki umehara on 2021/06/09.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

final class ViewController: UIViewController {
    
    @IBOutlet private var questionNumberLabel: UILabel!
    @IBOutlet private var answerSlider: UISlider!
    private let disposeBug = DisposeBag()
    private var valueRelay = BehaviorRelay<Int>(value: 0)
    private let maxValue: Float = 100.0
    private var judgeText: String {
        if Int(floorf(answerSlider.value * maxValue)) == valueRelay.value {
            return "あたり!"
        } else {
            return "ハズレ"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        updateRelayValue()
    }
    
    private func setupBinding() {
        valueRelay
            .map { String($0) }
            .bind(to: questionNumberLabel.rx.text)
            .disposed(by: disposeBug)
    }
    
    private func getRandomNumber() -> Int {
        Int(arc4random_uniform(100) + 1)
    }
    
    private func updateRelayValue() {
        valueRelay.accept(getRandomNumber())
    }

    @IBAction private func didTapJudgeButton(_ sender: Any) {
        let alert = UIAlertController(title: "結果",
                                      message: "\(judgeText)\nあなたの値：\(Int(floorf(answerSlider.value * maxValue)))",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "再挑戦", style: .default) {  [ weak self ]_ in
            self?.updateRelayValue()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
