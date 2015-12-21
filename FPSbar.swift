//
//  FPSbar.swift
//
//  Created by Ilya Seliverstov on 18.12.15.
//  Copyright 2015 Ilya Seliverstov. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//


import Foundation
import UIKit
import QuartzCore

class FPSbar: UIWindow {
    var desiredChartUpdateInterval: NSTimeInterval = 1.0 / 60.0
    var showsAverage: Bool = false
    
    private var _displayLink: CADisplayLink?
    
    private var _historyDTLength: Int?
    private var _maxHistoryDTLength: Int?
    
    private var _historyDT: [CFTimeInterval]?
    private var _displayLinkTickTimeLast: CFTimeInterval?
    private var _lastUIUpdateTime: CFTimeInterval?

    private var _fpsTextLayer: CATextLayer?
    private var _chartLayer: CAShapeLayer?
    
    private let selSingleTap : Selector = "displayLinkTick"
    
    func initilize() {
        if Float(UIDevice.currentDevice().systemVersion) >= 9.0 {
            self.rootViewController = UIViewController() // iOS 9 requires rootViewController for any window
        }

        _historyDTLength = Int(0)
        _maxHistoryDTLength = Int (CGRectGetWidth(self.bounds));

        _historyDT = Array.init(count: _maxHistoryDTLength!, repeatedValue: 0.0)
        _displayLinkTickTimeLast = CACurrentMediaTime();
        _lastUIUpdateTime = 0.0
        
        self.windowLevel = (UIWindowLevelStatusBar + 1.0)
        self.backgroundColor = UIColor.blackColor()
        
        // Track FPS using display link
        _displayLink = CADisplayLink(target: self, selector: selSingleTap)
        _displayLink!.paused = true
        _displayLink!.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
        // Chart Layer
        _chartLayer = CAShapeLayer()
        _chartLayer!.frame = self.bounds
        _chartLayer!.strokeColor = UIColor.redColor().CGColor
        _chartLayer!.contentsScale = UIScreen.mainScreen().scale
        self.layer.addSublayer(_chartLayer!)

        // Info Layer
        _fpsTextLayer = CATextLayer();
        _fpsTextLayer!.frame = CGRect(x:2.5, y:self.bounds.size.height - 11.0, width:200.0, height:10.0)
        _fpsTextLayer!.fontSize = 9.0
        _fpsTextLayer!.foregroundColor = UIColor.greenColor().CGColor
        _fpsTextLayer!.contentsScale = UIScreen.mainScreen().scale
        self.layer.addSublayer(_fpsTextLayer!)

        // Draw asynchronously on iOS6+
        _chartLayer!.drawsAsynchronously = true
        _fpsTextLayer!.drawsAsynchronously = true
        
        _displayLink!.paused = false
    }

    func displayLinkTick() {
        // Shift up the buffer
        for (var i = _historyDTLength!; i >= 1; i-=1) {
            _historyDT![i] = _historyDT![i - 1]
        }
        
        // Store new state
        _historyDT![0] = _displayLink!.timestamp - _displayLinkTickTimeLast!
        
        // Update length if there is more place
        if _historyDTLength! < (_maxHistoryDTLength! - 1) {
            _historyDTLength! += 1
        }
        
        // Store last timestamp
        _displayLinkTickTimeLast! = _displayLink!.timestamp;
        
        // Update UI
        let timeSinceLastUIUpdate = _displayLinkTickTimeLast! - _lastUIUpdateTime!
        if _historyDT![0] < 0.1 && timeSinceLastUIUpdate >= desiredChartUpdateInterval {
            self.updateChartAndText()
        }
    }
    
    private func updateChartAndText() {
        let path = UIBezierPath()
        path.moveToPoint(CGPointZero)
        
        var maxDT = CGFloat.min
        var avgDT = 0.0
        let curDT = roundf(1.0 / Float(Float(_historyDT![0])))
        
        if curDT < 30.0 {
            _fpsTextLayer!.foregroundColor = UIColor.redColor().CGColor
        } else {
            _fpsTextLayer!.foregroundColor = UIColor.greenColor().CGColor
        }
        
        for (var i = 0; i <= _historyDTLength!; i++) {
            maxDT = max(CGFloat(maxDT), CGFloat(_historyDT![i]))
            avgDT += _historyDT![i];
            
            let fraction = roundf(Float(1.0 / Float(_historyDT![i]))) / 60.0
            
            var y = Float(_chartLayer!.frame.size.height) - Float(_chartLayer!.frame.size.height) * fraction
            y = max(0.0, min(Float(_chartLayer!.frame.size.height), y))
            
            path.addLineToPoint(CGPoint(x: Double(i) + 1.0, y: Double(y)))
        }
        
        path.addLineToPoint(CGPoint(x: Double(_historyDTLength!), y: 0.0))
        
        avgDT /= Double(_historyDTLength!)
        _chartLayer!.path = path.CGPath
        
        let minFPS = roundf(1.0 / Float(maxDT))
        let avgFPS = roundf(1.0 / Float(avgDT))
        
        var text = "";
        if showsAverage {
            text = "cur: " + String(curDT) + " | low: " + String(minFPS) + " | avg: " + String(avgFPS)
        } else {
            text = "cur: " + String(curDT) + " | low: " + String(minFPS)
        }
        _fpsTextLayer?.string = text
        
        _lastUIUpdateTime = _displayLinkTickTimeLast
    }
}
