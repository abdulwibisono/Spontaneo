import SwiftUI

struct RewardsView: View {
    @State private var rewards = sampleRewards
    @State private var selectedReward: Reward?
    @State private var showingRewardDetail = false
    @State private var totalPoints = 1250
    @State private var nextRewardPoints = 2000
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    headerView
                        .padding(.top, 60)
                        .padding(.bottom, 50)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color("AccentColor"), Color("SecondaryColor")]),
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .animation(.easeInOut(duration: 0.5), value: totalPoints)
                    
                    VStack(spacing: 24) {
                        pointsProgressView
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .animation(.easeInOut(duration: 0.5), value: totalPoints)
                        
                        availableRewardsSection
                        rewardHistorySection
                        howToEarnSection
                    }
                    .padding(.horizontal)
                    .padding(.top, 30)
                    .background(Color(.systemBackground))
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .offset(y: -30)
                }
                .padding(.bottom, 0) 
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color("AccentColor"), Color("SecondaryColor")]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            )
            .navigationBarHidden(true)
        }
        .sheet(item: $selectedReward) { reward in
            NavigationView {
                RewardDetailView(reward: reward)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Text("Rewards")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text("Earn points and get exclusive offers")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private var pointsProgressView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(totalPoints) pts")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("\(nextRewardPoints) pts")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: Float(totalPoints), total: Float(nextRewardPoints))
                .progressViewStyle(RoundedRectProgressViewStyle())
            
            Text("You're \(nextRewardPoints - totalPoints) points away from your next reward!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var availableRewardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Rewards")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(rewards.filter { !$0.isRedeemed }) { reward in
                RewardRow(reward: reward)
                    .onTapGesture {
                        selectedReward = reward
                    }
                    .transition(.slide)
                    .animation(.easeInOut(duration: 0.3))
            }
        }
    }
    
    private var rewardHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reward History")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(rewards.filter { $0.isRedeemed }) { reward in
                RewardRow(reward: reward, isHistory: true)
                    .onTapGesture {
                        selectedReward = reward
                    }
                    .transition(.slide)
                    .animation(.easeInOut(duration: 0.3))
            }
        }
    }
    
    private var howToEarnSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How to Earn")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                earnMethodView(icon: "person.2.fill", title: "Join Activities", description: "Participate in group events", points: "+50 pts")
                earnMethodView(icon: "star.fill", title: "Host Events", description: "Create and lead your own activities", points: "+100 pts")
                earnMethodView(icon: "hand.thumbsup.fill", title: "Get Likes", description: "Receive likes on your posts", points: "+5 pts")
                earnMethodView(icon: "calendar", title: "Daily Check-in", description: "Open the app daily", points: "+10 pts")
            }
        }
        .padding(.bottom, 50)
    }
    
    private func earnMethodView(icon: String, title: String, description: String, points: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Color("AccentColor"))
                Spacer()
                Text(points)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            Text(title)
                .font(.headline)
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}

struct RewardRow: View {
    let reward: Reward
    var isHistory: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: reward.logoURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 60, height: 60)
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reward.title)
                    .font(.headline)
                Text(reward.businessName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(reward.discount)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(isHistory ? .secondary : .green)
                
                if isHistory {
                    Text("Redeemed")
                        .font(.caption)
                        .padding(4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                } else {
                    Text(reward.expirationDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct RoundedRectProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 14)
                .frame(height: 20)
                .foregroundColor(Color("AccentColor").opacity(0.2))
            
            RoundedRectangle(cornerRadius: 14)
                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * UIScreen.main.bounds.width - 40, height: 20)
                .foregroundColor(Color("AccentColor"))
        }
    }
}

struct RewardDetailView: View {
    let reward: Reward
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AsyncImage(url: reward.logoURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 150)
                .cornerRadius(20)
                
                Text(reward.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(reward.businessName)
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Text(reward.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                
                HStack {
                    Label("Discount", systemImage: "tag.fill")
                    Spacer()
                    Text(reward.discount)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                
                HStack {
                    Label("Expires", systemImage: "calendar")
                    Spacer()
                    Text(reward.expirationDate, style: .date)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                
                if let websiteURL = reward.websiteURL {
                    Link(destination: websiteURL) {
                        Label("Visit Website", systemImage: "globe")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                Text(reward.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationBarTitle("Reward Details", displayMode: .inline)
        .navigationBarItems(trailing: Button("Close") {
            presentationMode.wrappedValue.dismiss()
        })
    }
}