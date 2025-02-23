//
//  CustomTabBar.swift
//  Flow
//
//  Created by Joseph DeWeese on 1/31/25.
//

import SwiftUI
import SwiftData

struct CustomTab: View {
    @Binding var activeTab: Category
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        GeometryReader { geometry in
            TabBarContent(
                activeTab: $activeTab,
                size: geometry.size,
                scheme: scheme
            )
        }
        .frame(height: 40)
    }
}

// MARK: - Tab Bar Content
private struct TabBarContent: View {
    @Binding var activeTab: Category
    let size: CGSize
    let scheme: ColorScheme
    
    var body: some View {
        let tabSpacing = activeTab == .scheduled ? -15 : 8
        let allOffset = calculateOffset()
        
        HStack(spacing: 5) {
            RegularTabsView(
                activeTab: $activeTab,
                spacing: 5
            )
            
            ScheduledTabView(
                activeTab: $activeTab,
                offset: allOffset
            )
        }
        .padding(.horizontal, 10)
    }
    
    private func calculateOffset() -> CGFloat {
        size.width - (10 * CGFloat(Category.allCases.count - 1))
    }
}

// MARK: - Regular Tabs
private struct RegularTabsView: View {
    @Binding var activeTab: Category
    let spacing: CGFloat
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(Category.allCases.filter { $0 != .scheduled }, id: \.rawValue) { tab in
                ResizableTabButton(
                    tab: tab,
                    isActive: activeTab == tab,
                    onTap: updateActiveTab
                )
            }
            .fontDesign(.serif)
        }
    }
    
    private func updateActiveTab(_ tab: Category) {
        withAnimation(.bouncy) {
            activeTab = (activeTab == tab) ? .scheduled : tab
        }
    }
}

// MARK: - Scheduled Tab
private struct ScheduledTabView: View {
    @Binding var activeTab: Category
    let offset: CGFloat
    
    var body: some View {
        if activeTab == .scheduled {
            ResizableTabButton(
                tab: .scheduled,
                isActive: true,
                onTap: { _ in }
            )
            .transition(.offset(x: offset))
        }
    }
}

// MARK: - Resizable Tab Button
private struct ResizableTabButton: View {
    let tab: Category
    let isActive: Bool
    let onTap: (Category) -> Void
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        HStack(spacing: 8) {
            TabIcon(symbol: tab.symbolImage, isActive: isActive)
            
            if isActive {
                Text(tab.rawValue)
                    .font(.callout)
                    .fontDesign(.serif)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(tabStyle)
        .frame(maxHeight: .infinity)
        .frame(maxWidth: isActive ? .infinity : nil)
        .padding(.horizontal, isActive ? 10 : 15)
        .background(tabBackground)
        .clipShape(.rect(cornerRadius: 10, style: .circular))
        .background(tabBorder)
        .contentShape(.rect)
        .onTapGesture {
            if tab != .scheduled {
                onTap(tab)
            }
        }
    }
    
    private var tabStyle: Color {
        tab == .scheduled ? schemeColor : isActive ? .white : .gray
    }
    
    private var schemeColor: Color {
        scheme == .dark ? .black : .white
    }
    
    @ViewBuilder
    private var tabBackground: some View {
        Rectangle()
            .fill(isActive ? tab.color : .inActiveTab)
    }
    
    @ViewBuilder
    private var tabBorder: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(.background)
            .padding(tab == .scheduled && !isActive ? -3 : 3)
    }
}

// MARK: - Tab Icon
private struct TabIcon: View {
    let symbol: String
    let isActive: Bool
    
    var body: some View {
        Image(systemName: symbol)
            .opacity(isActive ? 0 : 1)
            .overlay {
                Image(systemName: symbol)
                    .symbolVariant(.fill)
                    .opacity(isActive ? 1 : 0)
            }
    }
}
