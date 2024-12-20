//
//  ViewController.swift
//  RacingCondition
//
//  Created by YoonieMac on 12/20/24.
//

import UIKit

class ViewController: UIViewController {
    
    var value: Int = 0
    let firstQueue = DispatchQueue(label: "first", attributes: .concurrent)
    let secondQueue = DispatchQueue(label: "second", attributes: .concurrent)
    let syncQueue = DispatchQueue(label: "Sync") // firstQueue와 SecondQueue 에서 보낸 변수값을 받는 직렬 큐
    
    let group = DispatchGroup()
    
    
    @IBOutlet weak var countLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func start(_ sender: UIButton) {
        
        value = 0
        
        for _ in 1...1000 {
            // Race Condition: 경합상황
            firstQueue.async(group: group) {
                self.syncQueue.sync {
                    self.value += 1
                }
                //                self.value += 1 // Critical Section
            }
            secondQueue.async(group: group) {
                self.syncQueue.sync {
                    self.value += 1
                }
                //                self.value += 1 // Critical Section
            }
        }
        group.notify(queue: DispatchQueue.main) {
            self.countLabel.text = "\(self.value)"
        }
    }
    
    let mutex = NSLock()
    @IBAction func mutex(_ sender: UIButton) {

        value = 0
        
        for _ in 1...1000 {
            firstQueue.async(group: group) {
                self.mutex.lock()
                self.value += 1
                self.mutex.unlock()
            }
            secondQueue.async(group: group) {
                self.mutex.lock()
                self.value += 1
                self.mutex.unlock()
            }
        }
        
        group.notify(queue: .main) {
            self.countLabel.text = String(self.value)
        }
    }
    

    let semaphore = DispatchSemaphore(value: 1)
    @IBAction func semaphore(_ sender: UIButton) {

        value = 0
        for _ in 1...1000 {
            firstQueue.async(group: group, qos: .utility) {
                self.semaphore.wait()
                self.value += 1
                self.semaphore.signal()
            }
            secondQueue.async(group: group, qos: .utility) {
                self.semaphore.wait()
                self.value += 1
                self.semaphore.signal()
            }
        }
        group.notify(queue: .main) {
            self.countLabel.text = String(describing: self.value)
        }
    }
    
    @IBAction func reset(_ sender: UIButton) {
        value = 0
        countLabel.text = "\(value)"
    }
}
