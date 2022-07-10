//
//  AspectVGrid.swift
//  Memorize
//
//  Created by 芦满 on 2022/7/11.
//

import SwiftUI

struct AspectVGrid<Item, ItemView>: View where ItemView: View {
    var item: [Item]
    var aspectRatio: CGFloat
    /*
     这里使用了另一个泛型ItemView，而不是some View，因为some View代表
     当前函数返回某个遵循View协议的对象，但不确定是哪一个，具体在函数体中
     确认。而这里只是声明属性，并没有具体的函数实现，所以不能用在这里。
     下面的body可以用，是因为body有具体的函数实现。body会根据内部包含的具体
     View实现类，来替换声明中的some View。
     简单一句话概括：这是Swift的语法限制。
     
     但是，这里的ItemView也不是毫无限制，他必须是一个View实现类，所以必有在
     函数声明的位置使用where关键字约束。
     */
    var content: (Item) -> ItemView
    
    
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

// 这里不需要预览
//struct AspectVGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        AspectVGrid()
//    }
//}
