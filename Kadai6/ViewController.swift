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
    @IBOutlet private var judgeButton: UIButton!

    private let disposeBug = DisposeBag()
    private let correctAnswerRelay = BehaviorRelay<Int?>(value: nil)
    private let resetTrigger = PublishRelay<Void>()
    private let correctAnswerRange = 1...100

    override func viewDidLoad() {
        super.viewDidLoad()

        answerSlider.minimumValue = Float(correctAnswerRange.lowerBound)
        answerSlider.maximumValue = Float(correctAnswerRange.upperBound)

        setupBinding()

        resetTrigger.accept(())
    }

    private func setupBinding() {
        func makeRandomNumber() -> Int {
            Int.random(in: correctAnswerRange)
        }

        // 正解の値はラベルに反映する
        correctAnswerRelay
            .map { $0.map { String($0) } ?? "" }
            .bind(to: questionNumberLabel.rx.text)
            .disposed(by: disposeBug)

        let sliderValue = answerSlider.rx.value.map { Int($0) }

        // 現在正解か不正解か
        let isCorrect = Observable.combineLatest(correctAnswerRelay.compactMap { $0 }, sliderValue) { $0 == $1 }

        // 現在の1行目のメッセージ
        let firstLine = isCorrect.map { $0 ? "あたり!" : "ハズレ" }

        // 現在のメッセージ
        let message = Observable.combineLatest(firstLine, sliderValue).map { "\($0)\nあなたの値：\($1)" }

        // アラートを表示すべきタイミング
        let alertTrigger = judgeButton.rx.tap
            .withLatestFrom(message, resultSelector: { $1 })
            .asDriver(onErrorDriveWith: .empty())

        // アラートの表示処理
        alertTrigger
            .drive(onNext: { [weak self] in
                let alert = UIAlertController(title: "結果", message: $0, preferredStyle: .alert)
                let action = UIAlertAction(title: "再挑戦", style: .default) { [weak self] _ in
                    self?.resetTrigger.accept(())
                }
                alert.addAction(action)
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBug)

        // リセット要求が来たら、ランダム値を生成して correctAnswerRelay に反映
        resetTrigger
            .map(makeRandomNumber)
            .bind(to: correctAnswerRelay)
            .disposed(by: disposeBug)
    }
}
