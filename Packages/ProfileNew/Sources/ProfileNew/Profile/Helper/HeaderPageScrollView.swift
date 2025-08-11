//
//  HeaderPageScrollView.swift
//  ProfileNew
//
//  Created by Artem Vasin on 25.05.25.
//

import SwiftUI
import DesignSystem

public struct PageLabel {
    var title: String
    var icon: Image
}

@resultBuilder
public struct PageLabelBuilder {
    public static func buildBlock(_ components: PageLabel...) -> [PageLabel] {
        components.compactMap({ $0 })
    }
}

@available(iOS 18.0, *)
public struct HeaderPageScrollView<Header: View, Pages: View>: View {
    /// Header View
    var header: Header
    /// Labels (Tab Title or Tab Image)
    var labels: [PageLabel]
    /// Tab Views
    var pages: Pages
    /// For Refreshing
    var onRefresh: () async -> ()

    public init(
        @ViewBuilder header: @escaping () -> Header,
        @PageLabelBuilder labels: @escaping () -> [PageLabel],
        @ViewBuilder pages: @escaping () -> Pages,
        onRefresh: @escaping () async -> () = {  }
    ) {
        self.header = header()
        self.labels = labels()
        self.pages = pages()
        self.onRefresh = onRefresh

        let count = labels().count
        self._scrollPositions = .init(initialValue: .init(repeating: .init(), count: count))
        self._scrollGeometries = .init(initialValue: .init(repeating: .init(), count: count))
    }

    /// View Properties
    @State private var activeTab: String?
    @State private var headerHeight: CGFloat = 0
    @State private var scrollGeometries: [ScrollGeometry]
    @State private var scrollPositions: [ScrollPosition]
    /// Main Scroll Properties
    @State private var mainScrollDisabled: Bool = false
    @State private var mainScrollPhase: ScrollPhase = .idle
    @State private var mainScrollGeometry: ScrollGeometry = .init()

    public var body: some View {
        GeometryReader {
            let size = $0.size

            ScrollView(.horizontal) {
                /// Using HStack allows us to maintain references to other scrollviews, enabling us to update them when necessary.
                HStack(spacing: 0) {
                    Group(subviews: pages) { collection in
                        /// Checking both collection and labels match with each other
                        if collection.count != labels.count {
                            Text("Tabviews and labels does not match!")
                                .frame(width: size.width, height: size.height)
                        } else {
                            ForEach(labels, id: \.title) { label in
                                PageScrollView(label: label, size: size, collection: collection)
                            }
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $activeTab)
            .scrollIndicators(.hidden)
            .scrollDisabled(mainScrollDisabled)
            /// Disabling Interaction when scroll view is animating to avoid unintentional taps!
            .allowsHitTesting(mainScrollPhase == .idle)
            .onScrollPhaseChange({ oldPhase, newPhase in
                mainScrollPhase = newPhase
            })
            .onScrollGeometryChange(for: ScrollGeometry.self, of: {
                $0
            }, action: { oldValue, newValue in
                mainScrollGeometry = newValue
            })
            .mask {
                Rectangle()
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            .onAppear {
                /// Setting up Initial Tab Value
                guard activeTab == nil else { return }

                activeTab = labels.first?.title
            }
        }
    }

    @ViewBuilder
    func PageScrollView(label: PageLabel, size: CGSize, collection: SubviewsCollection) -> some View {
        let index = labels.firstIndex(where: { $0.title == label.title }) ?? 0

        ScrollView(.vertical) {
            /// Using LazyVstack for Optimizing Performance as it LazyLoads Views!
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                /// Only Showing Header for the active Tab View!
                ZStack {
                    if activeTab == label.title {
                        header
                            /// Making it as a sticky one so that it won't move left or right when interacting!
                            .visualEffect({ content, proxy in
                                content
                                    .offset(x: -proxy.frame(in: .scrollView(axis: .horizontal)).minX)
                            })
                            .onGeometryChange(for: CGFloat.self) {
                                $0.size.height
                            } action: { newValue in
                                headerHeight = newValue
                            }
                            .transition(.identity)
                    } else {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: headerHeight)
                            .transition(.identity)
                    }
                }
                .simultaneousGesture(horizontalScrollDisableGesture)


                /// Using Pinned Views to actually pin our tab bar at the top!
                Section {
                    collection[index]
                        /// Let's make it to be scrollable to the top even if the view does not have enough content
                        /// 40 - Tab Bar Size, -5 is given so that it will not reset scrollviews when it's bounces!
                        .frame(minHeight: size.height - 29, alignment: .top)
                } header: {
                    /// Doing the same behaviour as the header view!
                    ZStack {
                        if activeTab == label.title {
                            CustomTabBar()
                                .visualEffect({ content, proxy in
                                    content
                                        .offset(x: -proxy.frame(in: .scrollView(axis: .horizontal)).minX)
                                })
                                .transition(.identity)
                        } else {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(height: 34)
                                .transition(.identity)
                        }
                    }
                    .simultaneousGesture(horizontalScrollDisableGesture)
                }
            }
        }
        .onScrollGeometryChange(for: ScrollGeometry.self, of: {
            $0
        }, action: { oldValue, newValue in
            scrollGeometries[index] = newValue

            if newValue.offsetY < 0 {
                resetScrollViews(label)
            }
        })
        .scrollPosition($scrollPositions[index])
        .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
            if activeTab == label.title {
                withAnimation {
                    scrollPositions[index].scrollTo(y: 0)
                }
            }
          }
        .onScrollPhaseChange { oldPhase, newPhase in
            let geometry = scrollGeometries[index]
            let maxOffset = min(geometry.offsetY, headerHeight)

            if newPhase == .idle && maxOffset <= headerHeight {
                updateOtherScrollViews(label, to: maxOffset)
            }

            /// Fail-Safe
            if newPhase == .idle && mainScrollDisabled {
                mainScrollDisabled = false
            }
        }
        .frame(width: size.width)
        .scrollClipDisabled()
        .refreshable {
            await onRefresh()
        }
        .zIndex(activeTab == label.title ? 1000 : 0)
    }

    /// Custom Tab Bar
    @ViewBuilder
    func CustomTabBar() -> some View {
        let progress = max(min(mainScrollGeometry.offsetX / mainScrollGeometry.containerSize.width, CGFloat(labels.count - 1)), 0)

        ZStack(alignment: .bottomLeading) {
            HStack(spacing: 0) {
                ForEach(labels, id: \.title) { label in
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            activeTab = label.title
                        }
                    } label: {
                        label.icon
                            .iconSize(height: 16)
                            .padding(.vertical, 9)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(activeTab == label.title ? Colors.whitePrimary : Colors.whiteSecondary)
                            .contentShape(.rect)
                    }
                }
            }
            .frame(maxHeight: .infinity)

            Rectangle()
                .fill(Colors.whiteSecondary)
                .frame(height: 1)

            /// Let's Create a sliding indicator for the tab bar!
            Capsule()
                .fill(Colors.whitePrimary)
                .frame(height: 1)
                .containerRelativeFrame(.horizontal) { value, _ in
                    return value / CGFloat(labels.count)
                }
                .visualEffect { content, proxy in
                    content
                        .offset(x: proxy.size.width * progress)
                }

        }
        .frame(height: 34)
        .background(Colors.textActive)
    }

    var horizontalScrollDisableGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                mainScrollDisabled = true
            }.onEnded { _ in
                mainScrollDisabled = false
            }
    }

    /// Reset's Page ScrollView to it's Initial Position
    func resetScrollViews(_ from: PageLabel) {
        for index in labels.indices {
            let label = labels[index]

            if label.title != from.title {
                scrollPositions[index].scrollTo(y: 0)
            }
        }
    }

    /// Update Other scrollviews to match up with the current scroll view till reaching it's header height
    func updateOtherScrollViews(_ from: PageLabel, to: CGFloat) {
        for index in labels.indices {
            let label = labels[index]
            let offset = scrollGeometries[index].offsetY

            let wantsUpdate = offset < headerHeight || to < headerHeight

            if wantsUpdate && label.title != from.title {
                scrollPositions[index].scrollTo(y: to)
            }
        }
    }
}

@available(iOS 18.0, *)
fileprivate extension ScrollGeometry {
    init() {
        self.init(contentOffset: .zero, contentSize: .zero, contentInsets: .init(.zero), containerSize: .zero)
    }

    var offsetY: CGFloat {
        contentOffset.y + contentInsets.top
    }

    var offsetX: CGFloat {
        contentOffset.x + contentInsets.leading
    }
}
