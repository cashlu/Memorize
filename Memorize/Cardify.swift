//
//  Cardify.swift
//  Memorize
//
//  Created by 芦满 on 2022/7/12.
//

import SwiftUI

/*
 自定义ViewModifier，将卡牌变化部分的功能抽离出来（包括翻转牌面）。
 CardView只负责绘制卡牌的内容，其他的翻转、倒计时等动画效果，在这个ViewModifier中来实现。
 */
struct Cardify: AnimatableModifier{
    
    init(isFaceUp: Bool){
        rotation = isFaceUp ? 0 : 180
    }
    
    var rotation: Double // 牌面旋转的角度
    
    /*
     遵循AnimatableModifier协议，必须实现animatableData属性，这里用了个小技巧，使用计算属性的特性，
     将adnimatableData和rotation绑定在一起。当然，也可以不定义rotation，直接替换使用animatableData。
     */
    var animatableData: Double{
        get{ rotation }
        set{ rotation = newValue }
    }
    
    // content是将要修改的View
    func body(content: Content) -> some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
            /*
             当翻转角度<90时，再将红色背景填充为白色，并加上边框。如果单纯的用isFaceUp来判断的话，出现牌面和背景淡化（牌背转牌面）
             这两个动画会和翻转动画同时开始，这里用rotation来控制动画的过程，只有当动画翻转角度超过90度后，马上改变牌面夜色，显示
             牌面内容。也就是这两个效果时瞬间发生的，不应该有淡入淡出的动画。
             */
            if rotation < 90 {
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: DrawingConstants.lineWidth )
            }else {
                shape.fill()
            }
            /*
             通常的逻辑，是将content放在ifFaceUp==true的代码块中，目的是如果牌面没翻开，那么这个View就不渲染。但是如果加上动画，就会出问题，
             因为在EmojiMemoryGameView.swift中，卡牌配对成功后的动画激活条件，是card.isMatched==true，但是当用户点击这张牌，这张牌在
             翻开（渲染）之前，isMatched就等于true了，也就是说，isMatched的状态变化，是在View存在之前。根据swiftui动画的三大定律，动画
             不会生效。
             所以这里不能将content放在isFaceUp的代码块中，而是要单独抽离出来，然后根据isFaceUp来控制透明度，切换是否显示出来。
             
             三大定律：
             1、Animation only animates changes.
             2、Animation can only animate the ViewModifier for Views that are already on screen.
             3、TODO：忘了，想起来补充。
             */
            content
                .opacity(rotation < 90 ? 1 : 0)
        }
        // 给翻开牌面添加3D动画，沿着y轴旋转180度
        .rotation3DEffect(Angle.degrees(rotation), axis: (x: 0, y: 1, z: 0))
    }
    
    /*
     统一管理所有常量
     */
    private struct DrawingConstants{
        // 这里的类型约束不能省略，否则swift会自动将20推导为Int类型。
        static let cornerRadius: CGFloat = 10
        static let lineWidth: CGFloat = 3
    }
}

// 扩展View，这样任何View就可以直接调用cardify方法了。
extension View{
    func cardify(isFaceUp: Bool) -> some View{
        return self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}
