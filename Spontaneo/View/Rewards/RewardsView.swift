import SwiftUI

struct RewardsView: View {
    @State private var rewards = sampleRewards
    @State private var selectedReward: Reward?
    @State private var showingRewardDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    
                    VStack(spacing: 20) {
                        availableRewardsSection
                        rewardHistorySection
                        howToEarnSection
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .offset(y: -30)
                }
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .edgesIgnoringSafeArea(.top)
            .navigationBarHidden(true)
        }
        .sheet(item: $selectedReward) { reward in
            RewardDetailView(reward: reward)
        }
    }
    
    private var headerView: some View {
        VStack {
            Text("Rewards")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text("Earn points and get exclusive offers")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.top, 60)
        .padding(.bottom, 30)
    }
    
    private var availableRewardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Rewards")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            ForEach(rewards.filter { !$0.isRedeemed }) { reward in
                RewardRow(reward: reward)
                    .onTapGesture {
                        selectedReward = reward
                    }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private var rewardHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reward History")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            ForEach(rewards.filter { $0.isRedeemed }) { reward in
                RewardRow(reward: reward)
                    .onTapGesture {
                        selectedReward = reward
                    }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private var howToEarnSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How to Earn")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            HStack(alignment: .top, spacing: 20) {
                earnMethodView(icon: "person.2.fill", title: "Join Activities", description: "Participate in group events")
                earnMethodView(icon: "star.fill", title: "Host Events", description: "Create and lead your own activities")
                earnMethodView(icon: "hand.thumbsup.fill", title: "Get Likes", description: "Receive likes on your posts")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func earnMethodView(icon: String, title: String, description: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct RewardRow: View {
    let reward: Reward
    
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
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                if reward.isRedeemed {
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
                            .background(Color.blue)
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