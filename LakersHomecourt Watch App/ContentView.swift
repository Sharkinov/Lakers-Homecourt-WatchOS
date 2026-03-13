import SwiftUI

// Colors & Gradient

extension Color {
    static let lakersGold  = Color(red: 253/255, green: 185/255, blue: 39/255)
    static let gswGray     = Color(red: 180/255, green: 180/255, blue: 185/255)
    static let gradientTop = Color(hex: "2B1842")
    static let gradientBot = Color(hex: "542581")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

var appGradient: LinearGradient {
    LinearGradient(
        colors: [.gradientTop, .gradientBot],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Font {
    static func graphik(_ size: CGFloat) -> Font {
        .custom("Graphik-Regular", size: size)
    }
}

// Loading / Error Views

struct LoadingView: View {
    var body: some View {
        ZStack {
            appGradient.ignoresSafeArea()
            ProgressView().tint(.lakersGold)
        }
    }
}

struct ErrorView: View {
    let message: String
    var body: some View {
        ZStack {
            appGradient.ignoresSafeArea()
            Text(message)
                .font(.graphik(11))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

// Scrolling Ticker

struct ScrollingTicker: View {
    let text: String
    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let repeated = String(repeating: "\(text)    ", count: 8)
            Text(repeated)
                .font(.graphik(10))
                .foregroundColor(.white)
                .fixedSize()
                .offset(x: offset)
                .onAppear {
                    offset = 0
                    withAnimation(.linear(duration: 9).repeatForever(autoreverses: false)) {
                        offset = -(geo.size.width * 4)
                    }
                }
        }
        .clipped()
    }
}

// Scoreboard

struct ScoreboardView: View {
    let data: ScoreboardResponse
    let gameClock: String

    var body: some View {
        ZStack(alignment: .bottom) {
            appGradient.ignoresSafeArea()

            VStack(spacing: 0) {

                // Status bar
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 7, height: 7)
                    Text("Q\(data.current_quarter)  \(gameClock)")
                        .font(.graphik(13))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 6)

                // Gold divider
                Rectangle()
                    .fill(Color.lakersGold)
                    .frame(height: 1.5)
                    .padding(.horizontal, 12)
                    .padding(.top, 5)

                // Logos
                HStack(alignment: .top) {
                    TeamColumn(name: lakersAbbr, logoURL: data.lakers_logo)
                    Spacer()
                    TeamColumn(name: opponentAbbr, logoURL: data.opposing_team_logo)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)

                // Scores
                HStack {
                    Text("\(data.lakers_score)")
                        .font(.graphik(25))
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(data.opposing_score)")
                        .font(.graphik(25))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.top, 2)

                Spacer(minLength: 4)

                // Defense ticker
                if data.defense {
                    ZStack {
                        Color(red: 0.78, green: 0.10, blue: 0.10)
                        ScrollingTicker(text: "DEFENSE")
                    }
                    .frame(height: 20)
                }
            }
        }
    }

    // e.g. "Golden State Warriors" → "GSW"
    var opponentAbbr: String {
        let words = data.opposing_team_name.split(separator: " ")
        return words.prefix(3).compactMap { $0.first }.map { String($0) }.joined()
    }
    
    var lakersAbbr: String {
        let words = data.lakers_team_name.split(separator: " ")
        return words.prefix(3).compactMap { $0.first }.map { String($0) }.joined()
    }
}

struct TeamColumn: View {
    let name: String
    let logoURL: String

    var body: some View {
        VStack(spacing: 3) {
            AsyncImage(url: URL(string: logoURL)) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFit()
                default:
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .overlay(
                            Text(name)
                                .font(.graphik(10))
                                .foregroundColor(.white)
                        )
                }
            }
            .frame(width: 52, height: 52)

            Text(name)
                .font(.graphik(14))
                .foregroundColor(.white)
        }
    }
}

// Field Goal

struct FieldGoalView: View {
    let data: FieldGoalResponse

    var pct: Double { (data.fg_percentage) / 100.0 }

    var body: some View {
        ZStack {
            appGradient.ignoresSafeArea()

            VStack(spacing: 12) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.lakersGold)
                        .frame(width: 8, height: 8)
                    Text("Lakers")
                        .font(.graphik(13))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.9), lineWidth: 20)

                    Circle()
                        .trim(from: 0, to: CGFloat(pct))
                        .stroke(
                            Color.lakersGold,
                            style: StrokeStyle(lineWidth: 20, lineCap: .butt)
                        )
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(data.fg_percentage))%")
                        .font(.graphik(22))
                        .foregroundColor(.white)
                }
                .frame(width: 100, height: 100)

                Text("Field goal")
                    .font(.graphik(12))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

// Team Comparison

struct TeamComparisonView: View {

    let data: TeamComparisonResponse

    struct StatRow: Identifiable {
        let id    = UUID()
        let label: String
        let lakers: Double
        let opposing: Double
    }

    var stats: [StatRow] {[
        StatRow(label: "Rebounds", lakers: Double(data.lakers_rebounds),  opposing: Double(data.opposing_rebounds)),
        StatRow(label: "Assists",  lakers: Double(data.lakers_assists),   opposing: Double(data.opposing_assists)),
        StatRow(label: "Steals",   lakers: Double(data.lakers_steals),    opposing: Double(data.opposing_steals)),
    ]}

    var body: some View {
        ZStack {
            appGradient.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 10) {

                HStack(spacing: 16) {
                    LegendDot(color: .lakersGold, label: "LA")
                    LegendDot(color: .gswGray,    label: "OPP")
                }
                .padding(.bottom, 2)

                ForEach(stats) { stat in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stat.label)
                            .font(.graphik(12))
                            .foregroundColor(.white)

                        GeometryReader { geo in
                            let total  = stat.lakers + stat.opposing
                            let lWidth = geo.size.width * CGFloat(stat.lakers   / total)
                            let gWidth = geo.size.width * CGFloat(stat.opposing / total)

                            HStack(spacing: 3) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.lakersGold)
                                    .frame(width: lWidth, height: 14)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gswGray.opacity(0.7))
                                    .frame(width: gWidth, height: 14)
                            }
                        }
                        .frame(height: 14)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

struct LegendDot: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label)
                .font(.graphik(12))
                .foregroundColor(.white)
        }
    }
}

// Previews

#Preview("All") {
    ContentView()
        .frame(width: 184, height: 224)
}

// Root

struct ContentView: View {
    @StateObject private var network = NetworkManager()

    var body: some View {
        Group {
            if network.isLoading {
                LoadingView()
            } else if let error = network.error {
                ErrorView(message: error)
            } else if let sb = network.scoreboard,
                      let fg = network.fieldGoal,
                      let tc = network.teamComparison {
                TabView {
                    ScoreboardView(
                        data: sb,
                        gameClock: network.gameClock(from: sb.current_quarter_start)
                    )
                    FieldGoalView(data: fg)
                    TeamComparisonView(data: tc)
                }
                .tabViewStyle(.page)
            } else {
                LoadingView()
            }
        }
        .onAppear {
            network.fetchAll()
            network.subscribeToRealtime()
        }
        .onDisappear {
            network.unsubscribe()
        }
    }
}
