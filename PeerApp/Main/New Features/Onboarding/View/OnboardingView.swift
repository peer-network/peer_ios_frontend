//
//  OnboardingView.swift
//  PeerApp
//
//  Created by Artem Vasin on 04.09.25.
//

import SwiftUI
import DesignSystem
import Environment

struct OnboardingView: View {
    @Namespace private var animation

    @StateObject private var viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    // Bridge to optional for scrollPosition
    private var scrollIDBinding: Binding<OnboardingStep?> {
        Binding<OnboardingStep?>(
            get: { viewModel.onboardingStep },
            set: { newValue in
                if let step = newValue {
                    withAnimation(.easeInOut) {
                        viewModel.onboardingStep = step
                    }
                }
            }
        )
    }

    var body: some View {
        content()
            .background {
                backgroundView
                    .ignoresSafeArea()
            }
            .environmentObject(viewModel)
    }

    private func content() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            topScreenImageView()
                .padding(.leading, 20)
                .padding(.bottom, 5)

            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    page { OnboardingFirstPageView() }
                        .id(OnboardingStep.welcome)
                        .containerRelativeFrame(.horizontal)

                    page { OnboardingSecondPageView() }
                        .id(OnboardingStep.prices)
                        .containerRelativeFrame(.horizontal)

                    page { OnboardingThirdPageView() }
                        .id(OnboardingStep.earnings)
                        .containerRelativeFrame(.horizontal)

                    page { OnboardingFourthPageView() }
                        .id(OnboardingStep.distribution)
                        .containerRelativeFrame(.horizontal)

                    page { OnboardingFifthPageView() }
                        .id(OnboardingStep.spending)
                        .containerRelativeFrame(.horizontal)
                }
                .scrollTargetLayout()
                .overlay(alignment: .bottom) {
                    PagingIndicator(
                        activeTint: Colors.whitePrimary,
                        inActiveTint: Colors.whiteSecondary,
                        opacityEffect: true,
                        clipEdges: true
                    )
                    .offset(y: 22)
                }
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: scrollIDBinding)
            .scrollClipDisabled()
            .contentMargins(.zero, for: .scrollContent)
            .padding(.bottom, 36)

            if let hint = viewModel.onboardingStep.bottomHintText(dailyTokensAmount: viewModel.minting.dailyNumberTokens) {
                bottomHintView(hint)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
            }

            footerView
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
    }

    @ViewBuilder
    private func page<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        ScrollView {
            content()
                .padding(.horizontal, 20)
        }
        .scrollIndicators(.automatic)
    }

    @ViewBuilder
    private var footerView: some View {
        if viewModel.isLast {
            letsGoButton
                .frame(maxWidth: .infinity)
                .matchedGeometryEffect(id: "Shape", in: animation)
        } else {
            HStack(spacing: 0) {
                closeButton

                Spacer(minLength: 0)

                navigationButtons
            }
        }
    }

    private func topScreenImageView() -> some View {
        Images.logoText
            .iconSize(height: 34)
    }

    private func bottomHintView(_ text: String) -> some View {
        var a = (try? AttributedString(markdown: text,
                                       options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
        ?? AttributedString(text)

        for run in a.runs {
            let intent = run.inlinePresentationIntent ?? []
            let isEmphasis = intent.contains(.emphasized) || intent.contains(.stronglyEmphasized)
            a[run.range].foregroundColor = isEmphasis ? Colors.whitePrimary : Colors.whiteSecondary
        }

        return Text(a)
            .font(.custom(.bodyRegular))
            .multilineTextAlignment(.center)
            .accessibilityLabel(text)
    }

    private var backgroundView: some View {
        ZStack {
            Colors.textActive

            GeometryReader { proxy in
                let w = proxy.size.width
                let h = proxy.size.height

                // MARK: - First Glow
                let glow1Width  = w * (347 / 393)
                let glow1Height = glow1Width * (318 / 347)

                Ellipse()
                    .frame(width: glow1Width, height: glow1Height)
                    .foregroundStyle(Colors.glowBlue.opacity(0.19))
                    .blur(radius: 50)
                    .offset(
                        x: w * (141 / 393),
                        y: -(glow1Height - (0.047 * h))
                    )

                // MARK: - Second Glow
                let glow2Width  = w * (530 / 393)
                let glow2Height = glow2Width * (342 / 530)

                Ellipse()
                    .frame(width: glow2Width, height: glow2Height)
                    .foregroundStyle(Colors.glowBlue.opacity(0.56))
                    .blur(radius: 100)
                    .offset(
                        x: -(glow2Width * (50 / 530)),
                        y: h + (0.0317 * h)
                    )
            }
        }
        .drawingGroup(opaque: false)
    }

    private var closeButton: some View {
        StateButton(config: viewModel.closeButtonType.buttonConfig) {
            viewModel.dismissAction(true)
        }
        .fixedSize()
        .accessibilityLabel("Close")
    }

    private var navigationButtons: some View {
        HStack(spacing: 10) {
            if !viewModel.isFirst {
                // Back button (hidden on the very first screen)
                let backButtonConfig = StateButtonConfig(
                    buttonSize: .small,
                    buttonType: .primary,
                    title: "",
                    icon: Icons.arrowDownNormal,
                    iconPlacement: .trailing
                )
                StateButton(config: backButtonConfig) {
                    withAnimation(.easeInOut) {
                        viewModel.goBack()
                    }
                }
                .fixedSize()
                .rotationEffect(.degrees(90))
                .accessibilityLabel("Back")
            }

            // Forward button
            let forwardButtonConfig = StateButtonConfig(
                buttonSize: .small,
                buttonType: .primary,
                title: "",
                icon: Icons.arrowDownNormal,
                iconPlacement: .trailing
            )
            StateButton(config: forwardButtonConfig) {
                if viewModel.isLast {
                    // Safety: should not be reachable because we swap footer, but keep it robust.
                    triggerFinish()
                } else {
                    withAnimation(.easeInOut) {
                        viewModel.goNext()
                    }
                }
            }
            .fixedSize()
            .rotationEffect(.degrees(-90))
            .accessibilityLabel("Next")
            .matchedGeometryEffect(id: "Shape", in: animation)
        }
    }

    @ViewBuilder
    private var letsGoButton: some View {
        let config = StateButtonConfig(
            buttonSize: .small,
            buttonType: .primary,
            title: "Lets go!",
            icon: nil,
            iconPlacement: .trailing
        )

        StateButton(config: config) {
            triggerFinish()
        }
        .accessibilityLabel("Let’s go")
    }

    private func triggerFinish() {
        viewModel.dismissAction(false)
    }
}

// MARK: - First Page

private struct OnboardingFirstPageView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleView()
                .padding(.bottom, 20)

            subtitleView()
                .padding(.bottom, 25)

            imageView()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 23)
        }
        .multilineTextAlignment(.leading)
        .foregroundStyle(Colors.whitePrimary)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func titleView() -> some View {
        Text("Welcome to ")
            .font(.custom(.extraLargeTitleRegular))

        +

        Text("peer!")
            .font(.custom(.extraLargeTitleBoldItalic))
    }

    private func subtitleView() -> some View {
        Text("Peer is the first social platform where your posts, likes, comments, and views help you earn real rewards.")
            .font(.custom(.bodyRegular))
    }

    private func imageView() -> some View {
        Images.onboarding1
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

// MARK: - Second Page

private struct OnboardingSecondPageView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleView()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)

            subtitleView()
                .padding(.bottom, 20)

            dailyFreeSection()
                .padding(.bottom, 14)

            wantMoreView()
                .padding(.bottom, 10)

            extraPricesView()
        }
        .multilineTextAlignment(.leading)
        .foregroundStyle(Colors.whitePrimary)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func titleView() -> some View {
        Text("Create, Like, Comment - Smartly")
            .font(.custom(.extraLargeTitleRegular))
    }

    private func subtitleView() -> some View {
        Text("Your daily free pass:")
            .font(.custom(.bodyRegular))
    }

    private func dailyFreeSection() -> some View {
        HStack {
            Spacer()
                .overlay {
                    VStack(alignment: .center, spacing: 17) {
                        Icons.camera
                            .iconSize(height: 35)

                        Text("^[\(viewModel.dailyFree.dailyFreeActions.post) post](inflect: true)")
                            .font(.custom(.bodyRegular))
                    }
                }

            Capsule()
                .frame(width: 1, height: 96)
                .foregroundStyle(Colors.whiteSecondary)

            Spacer()
                .overlay {
                    VStack(alignment: .center, spacing: 17) {
                        Icons.heartFill
                            .iconSize(height: 35)
                            .foregroundStyle(Colors.redAccent)

                        Text("^[\(viewModel.dailyFree.dailyFreeActions.like) like](inflect: true)")
                            .font(.custom(.bodyRegular))
                    }
                }

            Capsule()
                .frame(width: 1, height: 96)
                .foregroundStyle(Colors.whiteSecondary)

            Spacer()
                .overlay {
                    VStack(alignment: .center, spacing: 17) {
                        Icons.bubbleBold
                            .iconSize(height: 35)

                        Text("^[\(viewModel.dailyFree.dailyFreeActions.comment) comment](inflect: true)")
                            .font(.custom(.bodyRegular))
                            .fixedSize()
                    }
                }
        }
        .lineLimit(1)
        .foregroundStyle(Colors.whitePrimary)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
    }

    private func wantMoreView() -> some View {
        Text("Want more?")
            .font(.custom(.bodyRegular))
    }

    private func extraPricesView() -> some View {
        VStack(spacing: 10) {
            ActionRowView(actionText: "Extra post", priceText: formatTokensText(viewModel.tokenomics.actionTokenPrices.post), icon: Icons.camera, priceIcon: Icons.logoCircleWhite)

            ActionRowView(actionText: "Extra like", priceText: formatTokensText(viewModel.tokenomics.actionTokenPrices.like), icon: Icons.heartBold, priceIcon: Icons.logoCircleWhite)

            ActionRowView(actionText: "Extra comment", priceText: formatTokensText(viewModel.tokenomics.actionTokenPrices.comment), icon: Icons.bubbleBold, priceIcon: Icons.logoCircleWhite)

            ActionRowView(actionText: "Want to give a dislike?", priceText: formatTokensText(viewModel.tokenomics.actionTokenPrices.dislike), icon: Icons.heartBrokeBold, priceIcon: Icons.logoCircleWhite)
        }
    }

    private func formatTokensText(_ tokens: Double) -> String {
        let absValue = abs(tokens)

        // Check if it's an integer
        if absValue.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(absValue))"
        } else {
            return "\(absValue)"
        }
    }
}

// MARK: - Third Page

private struct OnboardingThirdPageView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleView()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)

            postView()
                .padding(.bottom, 20)

            howItWorksTextView()
                .padding(.bottom, 10)

            rewardsView()
        }
        .multilineTextAlignment(.leading)
        .foregroundStyle(Colors.whitePrimary)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func titleView() -> some View {
        Text("Engage & Earn")
            .font(.custom(.extraLargeTitleRegular))
    }

    private func postView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 0) {
                Icons.logoCircleBlue
                    .iconSize(width: 30)
                    .padding(.trailing, 10)

                Text("peernetwork")
                    .font(.custom(.bodyBoldItalic))
                    .layoutPriority(1)

                Spacer()
                    .frame(minWidth: 0, maxWidth: .infinity)

                FollowButton2(viewModel: .init(id: "1", isFollowing: true, isFollowed: true))
                    .environmentObject(APIServiceManager()) // TODO: Remove it
                    .fixedSize()

                Spacer()
                    .frame(width: 20)

                Icons.ellipsis
                    .iconSize(width: 16)
                    .padding(.trailing, 10)
            }

            Text("Created something people love?")
                .font(.custom(.bodyBold))

            Text("Get rewarded!")
                .font(.custom(.bodyRegular))

            HStack(spacing: 17) {
                HStack(spacing: 5) {
                    Icons.heartFill
                        .iconSize(height: 15)
                        .foregroundStyle(Colors.redAccent)

                    Text("2.5k")
                }

                HStack(spacing: 5) {
                    Icons.heartBroke
                        .iconSize(height: 15)

                    Text("5")
                }

                HStack(spacing: 5) {
                    Icons.bubble
                        .iconSize(height: 15)

                    Text("533")
                }

                HStack(spacing: 5) {
                    Icons.eyeCircled
                        .iconSize(height: 15)
                        .foregroundStyle(Colors.whiteSecondary)

                    Text("3.6k")
                }
            }
            .font(.custom(.bodyRegular))
            .padding(.vertical, 10)
        }
        .foregroundStyle(Colors.whitePrimary)
        .multilineTextAlignment(.leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
        .allowsHitTesting(false)
    }

    private func howItWorksTextView() -> some View {
        Text("Here’s how it works:")
            .font(.custom(.bodyRegular))
    }

    private func rewardsView() -> some View {
        VStack(spacing: 10) {
            ActionRowView(actionText: "Got a like", priceText: formatGemsText(viewModel.tokenomics.actionGemsReturn.like), icon: Icons.heartFill, iconColor: Colors.redAccent, priceIcon: Icons.gem)

            ActionRowView(actionText: "Got a dislike", priceText: formatGemsText(viewModel.tokenomics.actionGemsReturn.dislike), icon: Icons.heartBrokeFill, iconColor: Colors.redAccent, priceIcon: Icons.gem)

            ActionRowView(actionText: "Got a comment", priceText: formatGemsText(viewModel.tokenomics.actionGemsReturn.comment), icon: Icons.bubbleFill, priceIcon: Icons.gem)

            ActionRowView(actionText: "Got a view", priceText: formatGemsText(viewModel.tokenomics.actionGemsReturn.view), icon: Icons.eyeCircled, priceIcon: Icons.gem)
        }
    }

    private func formatGemsText(_ gems: Double) -> String {
        let sign = gems < 0 ? "- " : "+ "
        let absValue = abs(gems)

        // Check if it's an integer
        if absValue.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(sign)\(Int(absValue))"
        } else {
            return "\(sign)\(absValue)"
        }
    }
}

// MARK: - Fourth Page

private struct OnboardingFourthPageView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleView()

            subtitleView()
                .padding(.bottom, 7.5)

            GeometryReader { proxy in
                ZStack(alignment: .top) {
                    pieChartView()
                        .frame(height: proxy.size.width)

                    HStack {
                        firstUserStatsView

                        Spacer()

                        thirdUserStatsView
                    }
                    .offset(y: proxy.size.width - 117 / 4 * 3)
                    .overlay {
                        secondUserStatsView
                            .offset(y: proxy.size.width - 117 / 4 * 3)
                    }
                }
            }
            .padding(.horizontal, 35)

            Spacer()
                .frame(height: 117 * 5)
        }
        .multilineTextAlignment(.leading)
        .foregroundStyle(Colors.whitePrimary)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func titleView() -> some View {
        Text("Your effort = Your reward")
            .font(.custom(.extraLargeTitleRegular))
    }

    private func subtitleView() -> some View {
        Text("The more Gems you earn, the bigger your slice of the daily pool.")
            .font(.custom(.bodyRegular))
    }

    private func pieChartView() -> some View {
        TokenDistributionChartView()
    }

    private var firstUserStatsView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Capsule()
                .frame(width: 1, height: 117)

            Text("User A")
                .font(.custom(.bodyBold))
                .foregroundStyle(Colors.whitePrimary)

            HStack(spacing: 0) {
                Text("has 5 ")
                Icons.gem.iconSize(height: 13)
                Text(" Gems")
            }
            .font(.custom(.bodyRegular))
            .fixedSize()

            HStack(spacing: 0) {
                Text("will get \(formatTokensText(Double(viewModel.minting.dailyNumberTokens) * 0.25)) ")
                Icons.logoCircleWhite.iconSize(height: 14.5)
            }
            .font(.custom(.bodyRegular))
            .foregroundStyle(Colors.whitePrimary)
        }
        .foregroundStyle(Colors.whiteSecondary)
    }

    private var secondUserStatsView: some View {
        VStack(alignment: .center, spacing: 5) {
            Capsule()
                .frame(width: 1, height: 117)

            Text("User B")
                .font(.custom(.bodyBold))
                .foregroundStyle(Colors.whitePrimary)

            HStack(spacing: 0) {
                Text("has 5 ")
                Icons.gem.iconSize(height: 13)
                Text(" Gems")
            }
            .font(.custom(.bodyRegular))
            .fixedSize()

            HStack(spacing: 0) {
                Text("will get \(formatTokensText(Double(viewModel.minting.dailyNumberTokens) * 0.25)) ")
                Icons.logoCircleWhite.iconSize(height: 14.5)
            }
            .font(.custom(.bodyRegular))
            .foregroundStyle(Colors.whitePrimary)
        }
        .foregroundStyle(Colors.whiteSecondary)
        .offset(y: 117)
    }

    private var thirdUserStatsView: some View {
        VStack(alignment: .trailing, spacing: 5) {
            Capsule()
                .frame(width: 1, height: 117)

            Text("User C")
                .font(.custom(.bodyBold))
                .foregroundStyle(Colors.whitePrimary)

            HStack(spacing: 0) {
                Text("has 10 ")
                Icons.gem.iconSize(height: 13)
                Text(" Gems")
            }
            .font(.custom(.bodyRegular))
            .fixedSize()

            HStack(spacing: 0) {
                Text("will get \(formatTokensText(Double(viewModel.minting.dailyNumberTokens) * 0.5)) ")
                Icons.logoCircleWhite.iconSize(height: 14.5)
            }
            .font(.custom(.bodyRegular))
            .foregroundStyle(Colors.whitePrimary)
        }
        .foregroundStyle(Colors.whiteSecondary)
    }

    private func formatTokensText(_ tokens: Double) -> String {
        let absValue = abs(tokens)

        // Check if it's an integer
        if absValue.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(absValue))"
        } else {
            return "\(absValue)"
        }
    }
}

// MARK: - Fifth Page

private struct OnboardingFifthPageView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleView()
                .padding(.bottom, 20)

            usagePlatesView()
        }
        .multilineTextAlignment(.leading)
        .foregroundStyle(Colors.whitePrimary)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func titleView() -> some View {
        Text("How to use tokens?")
            .font(.custom(.extraLargeTitleRegular))
    }

    private func usagePlatesView() -> some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 23)
                    .foregroundStyle(Colors.inactiveDark)
                    .overlay {
                        usageTileView(title: "Post and engage more", icon: Icons.lock)
                    }

                RoundedRectangle(cornerRadius: 23)
                    .foregroundStyle(Colors.inactiveDark)
                    .overlay {
                        usageTileView(title: "Boost your content", description: "Coming soon...", icon: Icons.ad)
                    }
            }
            .frame(height: 180)

            HStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 23)
                    .foregroundStyle(Colors.inactiveDark)
                    .overlay {
                        usageTileView(title: "Shop in-app", description: "Coming soon...", icon: Icons.shop)
                    }

                RoundedRectangle(cornerRadius: 23)
                    .foregroundStyle(Colors.inactiveDark)
                    .overlay {
                        usageTileView(title: "Cash-out", description: "We’re working on the license - stay tuned!", icon: Icons.btcExchange)
                    }
            }
            .frame(height: 180)
        }
    }

    private func usageTileView(title: String, description: String? = nil, icon: Image) -> some View {
        VStack(spacing: 10) {
            icon
                .iconSize(height: 21)
                .foregroundStyle(Colors.hashtag)
                .padding(7)
                .background {
                    Circle()
                        .foregroundStyle(Colors.whitePrimary)
                }

            Text(title)
                .font(.custom(.bodyBold))
                .foregroundStyle(Colors.whitePrimary)

            if let description {
                Text(description)
                    .font(.custom(.bodyRegular))
                    .foregroundStyle(Colors.whiteSecondary)
            }
        }
        .multilineTextAlignment(.center)
    }
}

// MARK: - Subviews

private struct ActionRowView: View {
    let actionText: String
    let priceText: String
    let icon: Image
    var iconColor: Color? = nil
    let priceIcon: Image

    var body: some View {
        HStack(spacing: 10) {
            icon
                .iconSize(height: 15.5)
                .ifCondition(iconColor != nil) {
                    $0.foregroundStyle(iconColor!)
                }

            Text(actionText)
                .font(.custom(.bodyBold))

            Spacer()
                .frame(minWidth: 0, maxWidth: .infinity)
                .layoutPriority(-1)

            Text(priceText)
                .font(.custom(.largeTitleBold))

            priceIcon
                .iconSize(height: 17)
        }
        .lineLimit(1)
        .foregroundStyle(Colors.whitePrimary)
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
    }
}

private struct PagingIndicator: View {
    /// Customization Properties
    var activeTint: Color = Colors.whitePrimary
    var inActiveTint: Color = Colors.whiteSecondary
    var opacityEffect: Bool = false
    var clipEdges: Bool = false
    var body: some View {
        GeometryReader {
            /// Entire View Size for Calculating Pages
            let width = $0.size.width
            /// ScrollView Bounds
            if let scrollViewWidth = $0.bounds(of: .scrollView(axis: .horizontal))?.width, scrollViewWidth > 0 {
                let minX = $0.frame(in: .scrollView(axis: .horizontal)).minX
                let totalPages = Int(width / scrollViewWidth)
                /// Progress
                let freeProgress = -minX / scrollViewWidth
                let clippedProgress = min(max(freeProgress, 0.0), CGFloat(totalPages - 1))
                let progress = clipEdges ? clippedProgress : freeProgress
                /// Indexes
                let activeIndex = Int(progress)
                let nextIndex = Int(progress.rounded(.awayFromZero))
                let indicatorProgress = progress - CGFloat(activeIndex)
                /// Indicator Width's (Current & Upcoming)
                let currentPageWidth = 18 - (indicatorProgress * 18)
                let nextPageWidth = indicatorProgress * 18

                HStack(spacing: 10) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Capsule()
                            .fill(.clear)
                            .frame(width: 8 + (activeIndex == index ? currentPageWidth : nextIndex == index ? nextPageWidth : 0), height: 8)
                            .overlay {
                                ZStack {
                                    Capsule()
                                        .fill(inActiveTint)

                                    Capsule()
                                        .fill(activeTint)
                                        .opacity(opacityEffect ? activeIndex == index ? 1 - indicatorProgress : nextIndex == index ? indicatorProgress : 0 : 1)
                                }
                            }
                    }
                }
                .frame(width: scrollViewWidth)
                .offset(x: -minX)
            }
        }
        .frame(height: 8)
    }
}
