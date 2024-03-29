//
//  ViewController.swift
//  pomodoro
//
//  Created by 정현화 on 2023/08/15.
//

import UIKit
import AudioToolbox

enum TimerStatus {
    case start
    case pause
    case end
}

class ViewController: UIViewController {

    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toggelButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    // 타이머에 설정된 시간을 초로 저장하는 프로퍼티
    // 60으로 초기화 하는 이유는 DatePicker의 default 값이 1min 이기 때문에
    var duration = 60
    var timerStatus: TimerStatus = .end
    var timer: DispatchSourceTimer?
    var currentSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureToggleButton()
    }
    
    func setTimerInfoViewVisible(isHidden: Bool) {
        self.timerLabel.isHidden = isHidden
        self.progressView.isHidden = isHidden
    }
    
    func configureToggleButton() {
        self.toggelButton.setTitle("시작", for: .normal) // 초기 상태면 "시작"
        self.toggelButton.setTitle("일시정지", for: .selected) // 선택된 상태면 "일시정지
    }
    
    func startTimer() {
        if self.timer == nil {
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            self.timer?.schedule(deadline: .now(), repeating: 1) // 3초 후에 실행시키고 싶으면 .now() + 3 이런식으로 가능
            self.timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else { return }
                self.currentSeconds -= 1
                let hour = self.currentSeconds / 3600
                let minutes = (self.currentSeconds % 3600) / 60
                let seconds = (self.currentSeconds % 3600) % 60
                self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconds)
                self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
                
                UIView.animate(withDuration: 0.5, delay: 0, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi) // 2D 이미지를 180도 회전 시키기
                })
                UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2) // 2D 이미지를 360도 회전 시키기
                })
                
                if self.currentSeconds <= 0 {
                    self.stopTimer()
                    AudioServicesPlaySystemSound(1005)
                }
            })
            self.timer?.resume()
        }
    }
    
    func stopTimer() {
        if self.timerStatus == .pause {
            self.timer?.resume()
        }
        self.timerStatus = .end
        self.cancelButton.isEnabled = false
//        self.setTimerInfoViewVisible(isHidden: true)
//        self.datePicker.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.timerLabel.alpha = 0
            self.progressView.alpha = 0
            self.datePicker.alpha = 1
            self.imageView.transform = .identity // 이미지뷰 원상태로 돌리기 
        })
        self.toggelButton.isSelected = false
        self.timer?.cancel()
        self.timer = nil
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        switch self.timerStatus {
        case .start, .pause:
            self.stopTimer()
            
        default:
            break
        }
    }
    
    @IBAction func tapToggleButton(_ sender: Any) {
        self.duration = Int(self.datePicker.countDownDuration)
        
        switch self.timerStatus {
        case .end:
            self.currentSeconds = self.duration
            self.timerStatus = .start
//            self.setTimerInfoViewVisible(isHidden: false)
//            self.datePicker.isHidden = true
            UIView.animate(withDuration: 0.5, animations: {
                self.timerLabel.alpha = 1
                self.progressView.alpha = 1
                self.datePicker.alpha = 0
            })
            self.toggelButton.isSelected = true
            self.cancelButton.isEnabled = true
            self.startTimer()
        
        case .start:
            self.timerStatus = .pause
            self.toggelButton.isSelected = false
            self.timer?.suspend()
            
        case .pause:
            self.timerStatus = .start
            self.toggelButton.isSelected = true
            self.timer?.resume()
        }
    }
    
    
}

