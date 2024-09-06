import SwiftUI

struct RewardsView: View {
    @State private var rewards = sampleRewards
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeaderView()
                
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
    }
    
    private var availableRewardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Rewards")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ForEach(rewards.filter { !$0.isRedeemed }) { reward in
                RewardRow(reward: reward)
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
                .font(.headline)
                .foregroundColor(.secondary)
            
            ForEach(rewards.filter { $0.isRedeemed }) { reward in
                RewardRow(reward: reward)
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
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Earn rewards by joining activities and hosting events. The more you participate, the more rewards you unlock!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct RewardRow: View {
    let reward: Reward
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(reward.title)
                    .font(.headline)
                Text(reward.businessName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(reward.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
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
                    Text("Valid until \(reward.expirationDate, formatter: dateFormatter)")
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
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        RewardsView()
    }
}