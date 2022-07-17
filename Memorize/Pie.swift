//
//  Pie.swift
//  Memorize
//
//  Created by 芦满 on 2022/7/12.
//

import SwiftUI

/*
 自定义Pie结构体，用于卡牌背景的倒计时效果。
 绘制shape的原理，是先画出轮廓，然后填充颜色。
 */
struct Pie: Shape{
    // 绘图开始的角度
    var startAngel: Angle
    // 绘图结束的角度
    var endAngle: Angle
    /*
     画弧线的方向（顺时针还是逆时针）
     注意：swiftui绘图的坐标系，并不是笛卡尔坐标系（左下角开始），而是左上角开始。所以在实际使用的clockwise的时候，要取反。
     因为y坐标的增加，是向下走的。
     */
    var clockwise: Bool = false
    
    // 动画效果需要监控animatableData值的变化，从而插值实现动画效果。
    var animatableData: AnimatablePair<Double, Double>{
        get{
            AnimatablePair(startAngel.radians, endAngle.radians)
        }
        set{
            startAngel = Angle.radians(newValue.first)
            endAngle = Angle.radians(newValue.second)
        }
    }
    
    //rect是绘图的容器
    func path(in rect: CGRect) -> Path {
        // 通过容器先找到画布的中心点
        let center = CGPoint(x: rect.midX, y: rect.midY)
        // 半径
        let radius = min(rect.width, rect.height) / 2
        // 起始直线的上端点（center是下端点，构成12点方向的一条直线）
        let start = CGPoint(
            x: center.x + radius * CGFloat(cos(startAngel.radians)),
            y: center.y + radius * CGFloat(sin(startAngel.radians))
        )
        /*
         开始画图
         首先将“画笔”移动到中心点，然后向上画直线，直线的长度是半径。然后画一条弧线，最后画直线返回中心点。
         因为Pie图形要随着倒计时减少面积，也就是改变结束的角度，所以定义了startAngle和endAngle，以方便修改。
         */
        var p = Path()
        // 将画笔移到中心点
        p.move(to: center)
        // 向12点方向画第一条直线
        p.addLine(to: start)
        /*
         画一条弧线
         画弧线所需要的参数，是中心点、半径、起始角度、结束角度、方向。
         */
        p.addArc(center: center,
                 radius: radius,
                 startAngle: startAngel,
                 endAngle: endAngle,
                 clockwise: !clockwise
        )
        // 画直线回到中心点
        p.addLine(to: center)
        
        return p
    } 
}


